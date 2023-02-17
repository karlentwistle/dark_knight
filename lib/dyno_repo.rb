# frozen_string_literal: true

module DarkKnight
  class DynoRepo
    def initialize
      @dynos = {}
    end

    def update_repo(runtime_metrics)
      runtime_metrics.each { |runtime_metric| initialize_or_update_dyno_from(runtime_metric) }
      forget_expired_dynos
      restart_dynos_if_required?
    end

    def initialize_or_update_dyno_from(runtime_metric)
      return unless runtime_metric.monitored_dyno?

      dyno = runtime_metric.dyno

      if dynos.key?(dyno)
        dynos[dyno].update_from_metric(runtime_metric)
      else
        dynos[dyno] = Dyno.from_runtime_metric(runtime_metric)
      end
    end

    def forget_expired_dynos
      dynos.reject! { |_k, v| v.expired? }
    end

    def restart_dynos_if_required?
      dynos.each_value do |dyno|
        dyno.restart if dyno.restart_required?
      end
    end

    attr_reader :dynos
  end
end
