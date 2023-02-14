require 'logger'

module Logging
  class << self
    def logger
      @logger ||= Logger.new($stdout).tap { |l| l.level = ENV.fetch("LOG_LEVEL", Logger::Severity::INFO) }
    end

    def logger=(new_logger)
      @logger = new_logger
    end
  end

  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    Logging.logger
  end
end
