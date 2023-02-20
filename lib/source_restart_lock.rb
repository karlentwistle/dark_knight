# frozen_string_literal: true

module DarkKnight
  class SourceRestartLock < Sequel::Model
    set_primary_key [:source]
    unrestrict_primary_key
    plugin :validation_helpers

    def self.delete_expired
      where { expires_at <= Time.now }.delete
    end

    def validate
      super
      validates_presence %i[source expires_at]
      validates_unique :source
    end

    def before_validation
      self.expires_at ||= fetch_expires_at
      super
    end

    def process_type
      source.split('.').first
    end

    private

    def fetch_expires_at
      Time.now + fetch_restart_window
    end

    def fetch_restart_window
      if (restart_window = ENV.fetch("#{process_type}_restart_window".upcase, nil))
        restart_window.to_i
      else
        10 * 60
      end
    end
  end
end
