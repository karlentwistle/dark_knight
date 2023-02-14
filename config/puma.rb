# frozen_string_literal: true

workers 0
threads_count = 1
threads threads_count, threads_count

rackup      DefaultRackup if defined?(DefaultRackup)
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
