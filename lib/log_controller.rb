# frozen_string_literal: true

module DarkKnight
  class LogController
    def initialize(dyno_repo:, logger:)
      @dyno_repo = dyno_repo
      @logger = logger
    end

    def call(request)
      buffer = request.body.read

      logger.debug("[#{self.class}#call] #{buffer}")

      logs = HerokuLogParser.parse(buffer)
      dyno_repo.update_repo_from_logs(logs)

      [204, '']
    end

    private

    attr_reader :dyno_repo, :logger
  end
end
