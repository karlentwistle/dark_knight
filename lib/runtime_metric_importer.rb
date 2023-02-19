# frozen_string_literal: true

module DarkKnight
  class RuntimeMetricImporter
    def call(runtime_metrics)
      runtime_metrics.each do |runtime_metric|
        next unless runtime_metric.monitored_dyno?

        Dyno.update_or_create(dyno: runtime_metric.dyno) do |dyno|
          dyno.source = runtime_metric.source
          dyno.memory_quota = runtime_metric.memory_quota
          dyno.memory_total = runtime_metric.memory_total
        end
      end

      Dyno.delete_expired
      Dyno.restart_dynos
    end
  end
end
