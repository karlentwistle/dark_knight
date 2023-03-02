# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/application'

RSpec.describe '{DYNO_TYPE}_RESTART_WINDOW' do
  include Rack::Test::Methods

  def app
    DarkKnight::Application.new.app
  end

  it 'issues restart request each time dyno exceeds memory threshold within a restart window' do
    basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)

    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      with_env('WEB_RESTART_WINDOW', '300') do
        Timecop.freeze(Time.now - 301) do
          post('/logs', log_fixture('web.1.out_of_memory'))
        end

        post('/logs', log_fixture('web.1.new_dyno'))
        post('/logs', log_fixture('web.1.new_dyno.out_of_memory'))
      end
    end

    expect(a_restart_request('todo', 'web.1')).to have_been_made.twice
  end

  it 'doesnt restart dyno multiple times within a restart window even if it is still out of memory' do
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
end
