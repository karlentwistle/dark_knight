# frozen_string_literal: true

module DarkKnight
  class LogController
    include Logging

    def call(request)
      buffer = request.body.read

      logger.debug("[#{self.class}#call] #{buffer}")

      heroku_logs = HerokuLog.from_logs(buffer)
      runtime_metrics = RuntimeMetric.from_heroku_logs(heroku_logs)
      RuntimeMetricImporter.new.call(runtime_metrics)

      [204, '']
    end

    private

    attr_reader :dyno_repo
  end
end
