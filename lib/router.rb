# frozen_string_literal: true

require 'roda'
require_relative 'log_controller'

module DarkKnight
  class Router
    def initialize
      @app = Class.new(Roda) do
        plugin :drop_body

        use Rack::Auth::Basic do |_, password|
          Rack::Utils.secure_compare(ENV.fetch('DRAIN_PASSWORD'), password)
        end

        route do |r|
          # POST /logs
          r.post 'logs' do
            controller = LogController.new
            response.status, body = controller.call(request)
            body
          end
        end
      end
    end

    attr_reader :app
  end
end
