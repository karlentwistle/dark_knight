# frozen_string_literal: true

$stdout.sync = true

require_relative 'lib/application'

run DarkKnight::Application.new.app
