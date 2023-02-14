# frozen_string_literal: true

module DarkKnight
  class LogController
    include Logging

    def initialize(dyno_repo:)
      @dyno_repo = dyno_repo
    end

    def call(request)
      buffer = request.body.read

      logger.debug("[#{self.class}#call] #{buffer}")

      logs = HerokuLogParser.parse(buffer)
      dyno_repo.update_repo_from_logs(logs)

      [204, '']
    end

    private

    attr_reader :dyno_repo
  end
end
