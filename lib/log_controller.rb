# frozen_string_literal: true

require 'heroku-log-parser'
require_relative 'runtime_metric_parser'
require_relative 'dyno'

module DarkKnight
  class LogController
    def call(request)
      buffer = request.body.read
      logs = HerokuLogParser.parse(buffer)
      logs.each do |log|
        runtime_metric = RuntimeMetricParser.parse(log)
        Dyno.from_runtime_metric(runtime_metric).restart_if_swapping
      end

      [204, '']
    end
  end
end
