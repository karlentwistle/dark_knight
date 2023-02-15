# frozen_string_literal: true

module RuntimeMetricHelpers
  def build_runtime_metric(**attrs)
    DarkKnight::RuntimeMetric.new(
      DarkKnight::HerokuLog.new(
        parsed_log_runtime_metric(**attrs)
      )
    )
  end
end

RSpec.configure do |config|
  config.include RuntimeMetricHelpers
end
