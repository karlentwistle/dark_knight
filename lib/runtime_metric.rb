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

    private

    def relevant?
      log[:proc_id].to_s.match?(DYNO_SERVICE)
    end

    attr_reader :log
  end
end
