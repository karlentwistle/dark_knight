# frozen_string_literal: true

module DarkKnight
  class SlackNotificationJob
    include SuckerPunch::Job

    def perform(dyno)
      SlackNotificationRequest.run(dyno)
    end
  end
end
