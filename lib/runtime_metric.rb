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

      split_log_message.to_h { |y| y.split(ASSIGN_CHAR) }
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

    def split_log_message
      log_message.split(SPACE_CHAR)
    end

    def relevant?
      heroku_service? && monitored_proc_id? && runtime_metric_log?
    end

    def runtime_metric_log?
      split_log_message.size == 9
    end

    def heroku_service?
      proc_id.match?(DYNO_SERVICE) && app_name == 'heroku'
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

    def app_name
      log[:appname].to_s
    end

    def proc_type
      proc_id.split('.')[0]
    end

    attr_reader :log
  end
end
