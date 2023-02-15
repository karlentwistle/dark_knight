# frozen_string_literal: true

module DarkKnight
  class HerokuLog
    DYNO_SERVICE = /\.\d+\Z/

    def self.from_logs(buffer)
      HerokuLogParser
        .parse(buffer)
        .map { |parsed_log| HerokuLog.new(parsed_log) }
    end

    def initialize(parsed_log)
      @parsed_log = parsed_log
    end

    def proc_id
      parsed_log[:proc_id].to_s
    end

    def dyno_proc?
      proc_id.match?(DYNO_SERVICE)
    end

    def proc_type
      proc_id.split('.')[0]
    end

    def app_name
      parsed_log[:appname].to_s
    end

    def message
      parsed_log[:message].to_s
    end

    private

    attr_reader :parsed_log
  end
end
