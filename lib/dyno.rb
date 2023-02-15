# frozen_string_literal: true

module DarkKnight
  class Dyno
    include Logging

    def self.from_runtime_metric(runtime_metric)
      new(
        source: runtime_metric.source,
        memory_quota: runtime_metric.memory_quota,
        memory_total: runtime_metric.memory_total
      )
    end

    def initialize(source:, memory_quota:, memory_total:)
      @source = source
      @memory_quota = memory_quota
      @memory_total = memory_total
      @updated_at = Time.now
    end

    def update_from_metric(runtime_metric)
      self.source = runtime_metric.source
      self.memory_quota = runtime_metric.memory_quota
      self.memory_total = runtime_metric.memory_total
      self.updated_at = Time.now
    end

    attr_accessor :source, :memory_quota, :memory_total, :updated_at

    def restart_if_swapping
      return if restarting?

      restart if swapping?
    end

    def swapping?
      memory_total > memory_quota
    end

    def expired?
      updated_at < Time.now - (5 * 60)
    end

    def restart
      response = RestartDyno.run(source)
      restarting! if response.success?
    end

    def restarting!
      logger.info("restarting dyno #{source}")
      @restarting = true
    end

    def restarting?
      !!@restarting
    end
  end
end
