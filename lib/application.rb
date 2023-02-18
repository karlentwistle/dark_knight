# frozen_string_literal: true

require 'faraday'
require 'heroku-log-parser'
require 'rack'
require 'roda'
require 'sucker_punch'
require 'concurrent'

require_relative 'logging'

require_relative 'dyno'
require_relative 'dyno_repo'
require_relative 'heroku_log'
require_relative 'log_controller'
require_relative 'restart_dyno_job'
require_relative 'restart_dyno_request'
require_relative 'runtime_metric'

module DarkKnight
  class Application
    def initialize(dyno_repo: DynoRepo.new)
      @app = Class.new(Roda) do
        plugin :drop_body

        use Rack::Auth::Basic do |_, password|
          Rack::Utils.secure_compare(ENV.fetch('DRAIN_PASSWORD'), password)
        end

        route do |r|
          # POST /logs
          r.post 'logs' do
            controller = LogController.new(dyno_repo:)
            response.status, body = controller.call(request)
            body
          end
        end
      end
    end

    attr_reader :app
  end
end
