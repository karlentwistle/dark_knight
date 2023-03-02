# frozen_string_literal: true

module DarkKnight
  class SourceRestartLock < Sequel::Model
    set_primary_key [:source]
    unrestrict_primary_key
    plugin :optimistic_locking
    plugin :update_or_create
    plugin :validation_helpers

    def self.source_unlocked?(source)
      where(source:).where { expires_at > Time.now }.none?
    end

    def self.source_locked?(source)
      !source_unlocked?(source)
    end

    def self.lock_source(source)
      update_or_create(source:) do |lock|
        lock.expires_at = lock.fetch_expires_at
      end
    end

    def validate
      super
      validates_presence %i[source expires_at]
      validates_unique :source
    end

    def process_type
      source.split('.').first
    end

    def fetch_expires_at
      Time.now + fetch_restart_window
    end

    private

    def fetch_restart_window
      if (restart_window = ENV.fetch("#{process_type}_restart_window".upcase, nil))
        restart_window.to_i
      else
        10 * 60
      end
    end
  end
end
