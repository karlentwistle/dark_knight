# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/application'

RSpec.describe 'DYNO_TYPES' do
  include Rack::Test::Methods

  def app
    DarkKnight::Application.new.app
  end

  it 'issues restart request for dyno out of memory of monitored type' do
    stub_restart_request('todo', 'web.1')

    with_env('DYNO_TYPES', 'web') do
      basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
      post('/logs', log_fixture('web.1.out_of_memory'))
    end

    expect_restart_request('todo', 'web.1')
  end

  it 'ignores unmonitored dynos even if they are out of memory' do
    with_env('DYNO_TYPES', 'worker') do
      basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
      post('/logs', log_fixture('web.1.out_of_memory'))
    end

    expect_no_request
  end
end
