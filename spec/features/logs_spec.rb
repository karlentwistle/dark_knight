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

  it 'ignores logplex logs' do
    basic_authorize 'username', ENV.fetch('DRAIN_PASSWORD', nil)
    post('/logs', log_fixture('logplex'))

    expect(last_response).to be_no_content
  end
end
