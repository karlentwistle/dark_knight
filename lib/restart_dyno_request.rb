# frozen_string_literal: true

module DarkKnight
  module RestartDynoRequest
    class << self
      def run(source)
        connection.delete("/apps/#{app_id_or_name}/dynos/#{source}")
      end

      def connection
        @connection ||= Faraday.new(
          url: 'https://api.heroku.com/',
          headers: {
            Content_Type: 'application/json',
            Accept: 'application/vnd.heroku+json; version=3',
            Authorization: "Bearer #{auth_token}"
          }
        ) do |f|
          f.options.open_timeout = 10
          f.options.timeout = 10
        end
      end

      def app_id_or_name
        ENV.fetch('APP_ID_OR_NAME')
      end

      def auth_token
        ENV.fetch('AUTH_TOKEN')
      end
    end
  end
end
