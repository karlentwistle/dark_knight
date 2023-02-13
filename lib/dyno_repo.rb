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
      runtime_metric = RuntimeMetric.new(log)

      return if runtime_metric.irrelevant?

      dyno = runtime_metric.dyno

      if dynos.key?(dyno)
        dynos[dyno].update_from_metric(runtime_metric.to_h)
      else
        dynos[dyno] = Dyno.from_runtime_metric(runtime_metric.to_h)
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
