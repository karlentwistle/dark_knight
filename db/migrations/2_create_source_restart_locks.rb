# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :source_restart_locks do
      String :source, null: false, index: { unique: true }
      DateTime :expires_at, null: false
      Integer :lock_version, default: 0
    end
  end

  down do
    drop_table(:source_restart_locks)
  end
end
