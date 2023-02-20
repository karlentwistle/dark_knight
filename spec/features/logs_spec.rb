# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/application'

RSpec.describe '/logs' do
  include Rack::Test::Methods

  def app
    DarkKnight::Application.new.app
  end

  it 'responds with no content' do
    basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
    post('/logs', log_fixture('web.1'))

    expect(last_response).to be_no_content
  end

  it 'successfully parses logs' do
    with_env('DYNO_TYPES', 'web') do
      basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
      post('/logs', log_fixture('web.1.restarting'))
    end

    expect(last_response).to be_no_content
  end

  it 'doesnt issue restart request for dyno within memory limits' do
    with_env('DYNO_TYPES', 'web') do
      basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
      post('/logs', log_fixture('web.1'))
    end

    expect_no_request
  end

  it 'issues restart request for out of memory dyno of monitored type' do
    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
      post('/logs', log_fixture('web.1.out_of_memory'))
    end

    expect_restart_request('todo', 'web.1')
  end

  it 'issues another restart request for out of memory dyno of monitored type outside restart window' do
    basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)

    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      with_env('WEB_RESTART_WINDOW', '300') do
        Timecop.freeze(Time.now - 301) do
          post('/logs', log_fixture('web.1.out_of_memory'))
        end

        post('/logs', log_fixture('web.1'))
        post('/logs', log_fixture('web.1.out_of_memory'))
      end
    end

    expect(a_restart_request('todo', 'web.1')).to have_been_made.twice
  end

  it 'issues restart request for dyno above restart threshold of monitored type' do
    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      with_env('WEB_RESTART_THRESHOLD', '128') do
        basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
        post('/logs', log_fixture('web.1'))
      end
    end

    expect_restart_request('todo', 'web.1')
  end

  it 'adds slack notification when a dyno is restarted if SLACK_WEBHOOK_URL is configured' do
    stub_restart_request('todo', 'web.1')
    stub_successful_slack_request({ text: 'web.1 dyno restarted with memory total 768MB' }.to_json)

    with_env('DYNO_TYPES', 'web') do
      with_env('SLACK_WEBHOOK_URL', 'https://hooks.slack.com/services/top/secret/password') do
        basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
        post('/logs', log_fixture('web.1.out_of_memory'))
      end
    end

    expect_slack_request
  end

  it 'doesnt restart dyno multiple times within a restart window even if it\'s still out of memory' do
    basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)

    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      with_env('WEB_RESTART_WINDOW', '300') do
        post('/logs', log_fixture('web.1.out_of_memory'))
        post('/logs', log_fixture('web.1'))
        post('/logs', log_fixture('web.1.out_of_memory'))
      end
    end

    expect(a_restart_request('todo', 'web.1')).to have_been_made.once
  end

  it 'ignores unmonitored dynos even if they\'re out of memory' do
    with_env('DYNO_TYPES', 'worker') do
      basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
      post('/logs', log_fixture('web.1.out_of_memory'))
    end

    expect_no_request
  end

  it 'ignores logplex logs' do
    basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
    post('/logs', log_fixture('logplex'))

    expect(last_response).to be_no_content
  end
end
