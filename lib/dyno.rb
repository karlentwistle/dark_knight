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
      @mutex = Mutex.new
    end

    def update_from_metric(runtime_metric)
      self.source = runtime_metric.source
      self.memory_quota = runtime_metric.memory_quota
      self.memory_total = runtime_metric.memory_total
      self.updated_at = Time.now
    end

    attr_accessor :source, :memory_quota, :memory_total, :updated_at

    def process_type
      source.split('.').first
    end

    def restart_required?
      memory_total > restart_threshold
    end

    def expired?
      updated_at < Time.now - (5 * 60)
    end

    def restart
      @mutex.synchronize do
        return if @restarting

        @restarting = true

        begin
          if RestartDyno.run(source).success?
            logger.info("restarting dyno #{source}")
          else
            @restarting = false
          end
        rescue Faraday::Error
          # TODO: this should be handled by RestartDyno
          @restarting = false
        end
      end
    end

    private

    def restart_threshold
      @restart_threshold ||= fetch_restart_threshold
    end

    def fetch_restart_threshold
      if (restart_threshold = ENV.fetch("#{process_type}_restart_threshold".upcase, nil))
        restart_threshold.to_i
      else
        memory_quota
      end
    end
  end
end
