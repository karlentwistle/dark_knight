# frozen_string_literal: true

require 'sequel'

workers 2
threads_count = 5
threads threads_count, threads_count

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

before_fork do
  Sequel::DATABASES.each(&:disconnect)
end
