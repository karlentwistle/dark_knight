# frozen_string_literal: true

module DarkKnight
  class Dyno
    RUNTIME_METRICS_KEYS = %w[source sample#memory_quota sample#memory_total].freeze

    def self.from_runtime_metric(runtime_metric)
      new(
        source: runtime_metric['source'],
        memory_quota: runtime_metric['sample#memory_quota'],
        memory_total: runtime_metric['sample#memory_total']
      )
    end

    def initialize(source:, memory_quota:, memory_total:)
      @source = source.to_s
      @memory_quota = memory_quota.to_f
      @memory_total = memory_total.to_f
      @updated_at = Time.now
    end

    def update_from_metric(runtime_metric)
      self.source = runtime_metric['source'].to_s
      self.memory_quota = runtime_metric['sample#memory_quota'].to_f
      self.memory_total = runtime_metric['sample#memory_total'].to_f
      self.updated_at = Time.now
    end

    attr_accessor :source, :memory_quota, :memory_total, :updated_at

    def restart_if_swapping
      restart if swapping?
    end

    def swapping?
      memory_total > memory_quota
    end

    def expired?
      updated_at < Time.now - (5 * 60)
    end

    def restart
      RestartDyno.run(source)
    end

    def ==(other)
      instance_of?(other.class) &&
        source == other.source &&
        memory_quota == other.memory_quota &&
        memory_total == other.memory_total
    end
  end
end
