# frozen_string_literal: true

module DarkKnight
  class Dyno < Sequel::Model
    set_primary_key [:dyno]
    unrestrict_primary_key
    plugin :optimistic_locking
    plugin :timestamps, create: :updated_at, update: :updated_at
    plugin :update_or_create
    plugin :validation_helpers

    def self.delete_expired
      where { updated_at < Time.now - (5 * 60) }.delete
    end

    def self.restart_dynos
      where { memory_total > restart_threshold }.where(restarting: false).each(&:restart)
    end

    def validate
      super
      validates_presence %i[dyno source memory_quota memory_total updated_at]
      validates_unique :dyno
    end

    def before_create
      self.restart_threshold ||= fetch_restart_threshold
      super
    end

    def process_type
      source.split('.').first
    end

    def restart
      return if restarting?

      update(restarting: true)
      RestartDynoJob.perform_async(self)
    end

    def restart_failed
      update(restarting: false)
    end

    private

    def restarting?
      refresh
      typecast_value(:boolean, get_column_value(:restarting))
    end

    def fetch_restart_threshold
      if (restart_threshold = ENV.fetch("#{process_type}_restart_threshold".upcase, nil))
        restart_threshold.to_i
      else
        memory_quota
      end
    end
  end
end
