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

      delete_expired
      restart_dynos
    end

    def delete_expired
      Dyno.delete_expired
    end

    def restart_dynos
      Dyno.restart_dynos
    end
  end
end
