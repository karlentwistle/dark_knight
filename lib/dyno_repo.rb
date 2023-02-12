# frozen_string_literal: true

module DarkKnight
  class DynoRepo
    def update_from_logs(logs)
      logs.each do |log|
        runtime_metric = RuntimeMetricParser.parse(log)
        Dyno.from_runtime_metric(runtime_metric).restart_if_swapping
      end
    end
  end
end
