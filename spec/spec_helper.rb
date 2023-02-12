# frozen_string_literal: true

require 'webmock/rspec'
require 'byebug'
require_relative '../lib/application'

ENV['DRAIN_PASSWORD'] = 'password'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  Kernel.srand config.seed
end
