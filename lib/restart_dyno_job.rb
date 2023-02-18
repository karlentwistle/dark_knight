# frozen_string_literal: true

module DarkKnight
  class RestartDynoJob
    include SuckerPunch::Job

    def perform(dyno)
      if RestartDynoRequest.run(dyno.source).success?
        logger.info("restarting dyno #{dyno.source}")
        SlackNotificationJob.perform_async(dyno) if Slack.configured?
      else
        dyno.restart_failed
      end
    end
  end
end
