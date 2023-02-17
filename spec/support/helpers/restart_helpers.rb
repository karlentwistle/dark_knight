# frozen_string_literal: true

module RestartHelpers
  def stub_successful_restart_request(app_id_or_name, dyno_id_or_name)
    stub_restart_request(app_id_or_name, dyno_id_or_name).to_return(status: 202)
  end

  def stub_failed_restart_request(app_id_or_name, dyno_id_or_name)
    stub_restart_request(app_id_or_name, dyno_id_or_name).to_return(status: 500)
  end

  def expect_restart_request(app_id_or_name, dyno_id_or_name)
    expect(a_restart_request(app_id_or_name, dyno_id_or_name)).to have_been_made.once
  end

  def stub_restart_request(app_id_or_name, dyno_id_or_name)
    stub_request(:delete, restart_uri(app_id_or_name, dyno_id_or_name)).with(headers: restart_headers)
  end

  def a_restart_request(app_id_or_name, dyno_id_or_name)
    a_request(:delete, restart_uri(app_id_or_name, dyno_id_or_name))
      .with(headers: restart_headers)
  end

  def expect_no_request
    expect(a_request(:any, 'api.heroku.com')).not_to have_been_made
  end

  def restart_headers
    {
      'Accept' => 'application/vnd.heroku+json; version=3',
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer 01234567-89ab-cdef-0123-456789abcdef'
    }
  end

  def restart_uri(app_id_or_name, dyno_id_or_name)
    "https://api.heroku.com/apps/#{app_id_or_name}/dynos/#{dyno_id_or_name}"
  end
end

RSpec.configure do |config|
  config.include RestartHelpers
end
