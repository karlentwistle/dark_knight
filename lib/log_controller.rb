# frozen_string_literal: true

module DarkKnight
  class LogController
    def initialize(dyno_repo:)
      @dyno_repo = dyno_repo
    end

    def call(request)
      buffer = request.body.read
      logs = HerokuLogParser.parse(buffer)
      dyno_repo.update_from_logs(logs)

      [204, '']
    end

    private

    attr_reader :dyno_repo
  end
end
