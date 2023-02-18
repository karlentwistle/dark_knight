# frozen_string_literal: true

module DarkKnight
  class Slack
    class << self
      def configured?
        !!ENV.fetch('SLACK_WEBHOOK_URL', false)
      end

      def webhook_url
        ENV.fetch('SLACK_WEBHOOK_URL')
      end
    end
  end
end
