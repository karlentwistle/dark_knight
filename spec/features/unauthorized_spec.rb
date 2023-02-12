# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../lib/application'

RSpec.describe 'Unauthorized' do
  include Rack::Test::Methods

  def app
    DarkKnight::Application.new.app
  end

  it 'requires valid HTTP basic authentication' do
    post('/logs')

    expect(last_response).to be_unauthorized
  end
end
