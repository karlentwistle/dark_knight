# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/application'

RSpec.describe '/logs' do
  include Rack::Test::Methods

  def app
    DarkKnight::Application.new.app
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
end
