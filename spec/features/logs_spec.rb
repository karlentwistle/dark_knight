# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/router'

RSpec.describe '/logs' do
  include Rack::Test::Methods

  def app
    DarkKnight::Router.new.app
  end

  it 'responds with no content' do
    runtime_metric_path = File.join(File.dirname(__FILE__), '../fixtures/runtime_metric/web.1')
    runtime_metric = File.read(runtime_metric_path)

    basic_authorize 'username', ENV['DRAIN_PASSWORD']
    post('/logs', runtime_metric)

    expect(last_response).to be_no_content
  end
end
