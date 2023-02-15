# frozen_string_literal: true

module DarkKnight
  class RuntimeMetric
    ASSIGN_CHAR = '='
    SPACE_CHAR = ' '
    VALID_RUNTIME_METRICS_COUNT = 9

    def self.from_heroku_logs(heroku_logs)
      heroku_logs
        .select { |heroku_log| valid_runtime_metric?(heroku_log) }
        .map { |runtime_metric_log| new(runtime_metric_log) }
    end

    def self.valid_runtime_metric?(heroku_log)
      split_log = heroku_log.message.split(SPACE_CHAR)

      return false if split_log.size != VALID_RUNTIME_METRICS_COUNT

      split_log
        .map { |metric| metric.split(ASSIGN_CHAR) }
        .all? { |metric| metric.length == 2 }
    end

    def initialize(heroku_log)
      @heroku_log = heroku_log
    end

    def dyno
      runtime_metrics['dyno']
    end

    def source
      runtime_metrics['source'].to_s
    end

    def memory_quota
      runtime_metrics['sample#memory_quota'].to_f
    end

    def memory_total
      runtime_metrics['sample#memory_total'].to_f
    end

    def monitored_dyno?
      monitored_types.include?(heroku_log.proc_type)
    end

    private

    def runtime_metrics
      @runtime_metrics ||= heroku_log.message.split(SPACE_CHAR).to_h { |y| y.split(ASSIGN_CHAR) }
    end

    def monitored_types
      ENV.fetch('DYNO_TYPES', 'web').split(',')
    end

    attr_reader :heroku_log
  end
end
