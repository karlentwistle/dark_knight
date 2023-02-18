# frozen_string_literal: true

module DarkKnight
  class RestartDynoJob
    include SuckerPunch::Job

    def perform(dyno)
      if RestartDyno.run(dyno.source).success?
        logger.info("restarting dyno #{dyno.source}")
      else
        dyno.restart_failed
      end
    rescue Faraday::Error
      dyno.restart_failed
    end
  end
end
