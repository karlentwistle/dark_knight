# frozen_string_literal: true

module DarkKnight
  DB = Sequel.sqlite(File.join(File.dirname(__FILE__), '../db/dark_knight.sqlite'))

  Sequel.extension :migration

  Sequel::Migrator.run(DB, 'db/migrations', target: 2)
end
