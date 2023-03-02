# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :dynos do
      String :dyno, null: false, index: { unique: true }
      String :source, null: false
      Integer :memory_quota, null: false
      Integer :memory_total, null: false
      Integer :restart_threshold, null: false
      DateTime :updated_at, null: false
      Boolean :restarting, null: false, default: false
      Integer :lock_version, default: 0
    end
  end

  down do
    drop_table(:dyno)
  end
end
