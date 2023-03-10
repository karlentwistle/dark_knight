# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/application'

RSpec.describe '{DYNO_TYPE}_RESTART_THRESHOLD' do
  include Rack::Test::Methods

  def app
    DarkKnight::Application.new.app
  end

  it 'issues restart request for dyno with memory above restart threshold of monitored type' do
    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      with_env('WEB_RESTART_THRESHOLD', '128') do
        basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
        post('/logs', log_fixture('web.1'))
      end
    end

    expect_restart_request('todo', 'web.1')
  end

  it 'doesnt issue restart request for dyno within restat threshold' do
    with_env('DYNO_TYPES', 'web') do
      with_env('WEB_RESTART_THRESHOLD', '1024') do
        basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
        post('/logs', log_fixture('web.1'))
      end
    end

    expect_no_request
  end
end
