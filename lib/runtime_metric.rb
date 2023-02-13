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

      log
        .fetch(:message, '')
        .split(SPACE_CHAR)
        .to_h { |y| y.split(ASSIGN_CHAR) }
    end

    def irrelevant?
      !relevant?
    end

    def dyno
      to_h.fetch('dyno')
    end

    private

    def relevant?
      dyno_service? && monitored_proc_id?
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
