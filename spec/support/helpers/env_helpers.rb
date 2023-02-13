# frozen_string_literal: true

module LogHelpers
  def with_env(name, value)
    pervious_value = ENV.fetch(name, nil)

    ENV[name] = value
    yield
    ENV[name] = pervious_value
  end
end

RSpec.configure do |config|
  config.include LogHelpers
end
