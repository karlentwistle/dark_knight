# frozen_string_literal: true

module LogHelpers
  def log_fixture(metric_name)
    File.read(File.join(File.dirname(__FILE__), "../fixtures/runtime_metrics/#{metric_name}"))
  end
end

RSpec.configure do |config|
  config.include LogHelpers
end
