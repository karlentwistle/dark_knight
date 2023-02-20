# frozen_string_literal: true

module DarkKnight
  DB = Sequel.sqlite

  DB.create_table :dynos do
    String :dyno, null: false, index: { unique: true }
    String :source, null: false
    Integer :memory_quota, null: false
    Integer :memory_total, null: false
    Integer :restart_threshold, null: false
    TrueClass :restarting, default: false
    DateTime :updated_at
    Integer :lock_version, default: 0
  end
end
