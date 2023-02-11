# frozen_string_literal: true

module DarkKnight
  module RuntimeMetricParser
    ASSIGN_CHAR = '='
    SPACE_CHAR = ' '
    DYNO_SERVICE = /\.\d+\Z/.freeze

    def self.parse(log)
      return {} unless log[:proc_id].to_s.match?(DYNO_SERVICE)

      log
        .fetch(:message, '')
        .split(SPACE_CHAR)
        .to_h { |y| y.split(ASSIGN_CHAR) }
    end
  end
end
