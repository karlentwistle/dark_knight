# frozen_string_literal: true

module SlackHelpers
  def stub_successful_slack_request(body)
    stub_slack_request(body).to_return(status: 200)
  end

  def expect_slack_request
    expect(a_slack_request).to have_been_made.once
  end

  def stub_slack_request(body)
    stub_request(:post, slack_uri).with(headers: slack_headers, body:)
  end

  def a_slack_request
    a_request(:post, slack_uri).with(headers: slack_headers)
  end

  def slack_headers
    {
      'Content-Type' => 'application/json'
    }
  end

  def slack_uri
    'https://hooks.slack.com/services/top/secret/password'
  end
end

RSpec.configure do |config|
  config.include SlackHelpers
end
