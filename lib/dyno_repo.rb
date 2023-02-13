# frozen_string_literal: true

module DarkKnight
  class DynoRepo
    def initialize
      @dynos = {}
    end

    def update_repo_from_logs(logs)
      logs.each { |log| initialize_or_update_dyno_by(log) }
      forget_expired_dynos
      restart_dynos_if_swapping
    end

    def initialize_or_update_dyno_by(log)
      runtime_metric = RuntimeMetric.new(log).to_h

      return if runtime_metric.empty?

      dyno_id = runtime_metric.fetch('dyno')

      if dynos.key?(dyno_id)
        dynos[dyno_id].update_from_metric(runtime_metric)
      else
        dynos[dyno_id] = Dyno.from_runtime_metric(runtime_metric)
      end
    end

    def forget_expired_dynos
      dynos.reject! { |_k, v| v.expired? }
    end

    def restart_dynos_if_swapping
      dynos.values(&:restart_if_swapping)
    end

    attr_reader :dynos
  end
end
