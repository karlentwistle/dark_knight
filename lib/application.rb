# frozen_string_literal: true

require 'faraday'
require 'heroku-log-parser'
require 'rack'
require 'roda'

require_relative 'dyno'
require_relative 'dyno_repo'
require_relative 'log_controller'
require_relative 'restart_dyno'
require_relative 'runtime_metric'

module DarkKnight
  class Application
    def self.logger
      Logger.new($stdout).tap { |l| l.level = ENV.fetch('LOG_LEVEL', Logger::Severity::INFO) }
    end

    def initialize(dyno_repo: DynoRepo.new, logger: self.class.logger)
      @app = Class.new(Roda) do
        plugin :drop_body

        use Rack::Auth::Basic do |_, password|
          Rack::Utils.secure_compare(ENV.fetch('DRAIN_PASSWORD'), password)
        end

        route do |r|
          # POST /logs
          r.post 'logs' do
            controller = LogController.new(dyno_repo: dyno_repo, logger: logger)
            response.status, body = controller.call(request)
            body
          end
        end
      end
    end

    attr_reader :app
  end
end
