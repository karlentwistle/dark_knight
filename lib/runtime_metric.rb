# frozen_string_literal: true

module DarkKnight
  class RuntimeMetric
    ASSIGN_CHAR = '='
    SPACE_CHAR = ' '
    DYNO_SERVICE = /\.\d+\Z/.freeze

    def initialize(log)
      @log = log
    end

    def to_h
      return {} unless relevant?

      log_message_split.to_h { |y| y.split(ASSIGN_CHAR) }
    end

    def irrelevant?
      !relevant?
    end

    def dyno
      to_h.fetch('dyno')
    end

    private

    def log_message
      log.fetch(:message, '')
    end

    def log_message_split
      log_message.split(SPACE_CHAR)
    end

    def relevant?
      runtime_metric_log? && dyno_service? && monitored_proc_id?
    end

    def runtime_metric_log?
      log_message_split.size == 9
    end

    def dyno_service?
      proc_id.match?(DYNO_SERVICE)
    end

    def monitored_types
      ENV.fetch('DYNO_TYPES', 'web').split(',')
    end

    def monitored_proc_id?
      monitored_types.include?(proc_type)
    end

    def proc_id
      log[:proc_id].to_s
    end

    def proc_type
      proc_id.split('.')[0]
    end

    attr_reader :log
  end
end
