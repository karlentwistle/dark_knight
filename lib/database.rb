# frozen_string_literal: true

module DarkKnight
  DB = Sequel.sqlite

  DB.create_table :dynos do
    String :dyno, null: false, index: { unique: true }
    String :source, null: false
    Integer :memory_quota, null: false
    Integer :memory_total, null: false
    Integer :restart_threshold, null: false
    DateTime :updated_at, null: false
  end

  DB.create_table :source_restart_locks do
    String :source, null: false, index: { unique: true }
    DateTime :expires_at, null: false
  end
end
