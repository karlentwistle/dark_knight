# frozen_string_literal: true

module DarkKnight
  class Dyno
    RUNTIME_METRICS_KEYS = %w[source sample#memory_quota sample#memory_total].freeze

    def self.from_runtime_metric(runtime_metric)
      new(
        source: runtime_metric['source'],
        memory_quota: runtime_metric['sample#memory_quota'],
        memory_total: runtime_metric['sample#memory_total']
      )
    end

    def initialize(source:, memory_quota:, memory_total:)
      @source = source.to_s
      @memory_quota = memory_quota.to_f
      @memory_total = memory_total.to_f
    end

    attr_reader :source, :memory_quota, :memory_total

    def restart_if_swapping
      restart if swapping?
    end

    def swapping?
      memory_total > memory_quota
    end

    def restart
      heroku_connection.delete("/apps/#{app_id_or_name}/dynos/#{source}")
    end

    def app_id_or_name
      'todo'
    end

    def ==(other)
      instance_of?(other.class) &&
        source == other.source &&
        memory_quota == other.memory_quota &&
        memory_total == other.memory_total
    end

    private

    def heroku_connection
      @heroku_connection ||= Faraday.new(
        url: 'https://api.heroku.com/',
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/vnd.heroku+json; version=3'
        }
      )
    end
  end
end
