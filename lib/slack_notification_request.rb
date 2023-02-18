# frozen_string_literal: true

module DarkKnight
  module SlackNotificationRequest
    class RequestFailed
      def success?
        false
      end
    end

    class << self
      def run(dyno)
        connection.post('', {
          text: "#{dyno.source} dyno restarted with memory total #{dyno.memory_total}MB"
        }.to_json)
      rescue Faraday::Error
        RequestFailed.new
      end

      def connection
        @connection ||= Faraday.new(
          url: Slack.webhook_url,
          headers: {
            Content_Type: 'application/json'
          }
        ) do |f|
          f.options.open_timeout = 10
          f.options.timeout = 10
        end
      end
    end
  end
end
