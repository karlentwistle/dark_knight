# frozen_string_literal: true

RSpec.configure do |c|
  c.around(:each) do |example|
    DarkKnight::DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end
