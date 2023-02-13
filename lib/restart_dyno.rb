# frozen_string_literal: true

module DarkKnight
  module RestartDyno
    class << self
      def run(dyno)
        connection.delete("/apps/#{app_id_or_name}/dynos/#{dyno.source}")
      end

      def connection
        @connection ||= Faraday.new(
          url: 'https://api.heroku.com/',
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/vnd.heroku+json; version=3'
          }
        )
      end

      def app_id_or_name
        ENV.fetch('APP_ID_OR_NAME')
      end
    end
  end
end
