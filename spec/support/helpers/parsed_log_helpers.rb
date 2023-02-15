# frozen_string_literal: true

module ParsedLogHelpers
  def parsed_log_runtime_metric(dyno: nil, memory_total: nil, proc_id: nil)
    dyno ||= 'heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e'
    memory_total ||= 7.11
    proc_id ||= 'web.1'

    {
      priority: 134,
      syslog_version: 1,
      emitted_at: '2023-02-11 20:17:07.957556 UTC',
      hostname: 'host',
      appname: 'heroku',
      proc_id:,
      msg_id: nil,
      structured_data: nil,
      message: "source=#{proc_id} dyno=#{dyno} sample#memory_total=#{memory_total}MB sample#memory_rss=1.07MB sample#memory_cache=6.04MB sample#memory_swap=0.00MB sample#memory_pgpgin=1978pages sample#memory_pgpgout=158pages sample#memory_quota=512.00MB"
    }
  end

  def parsed_log_http_request
    {
      priority: 158,
      syslog_version: 1,
      emitted_at: '2023-02-11 20:20:03.271237 UTC',
      hostname: 'host',
      appname: 'heroku',
      proc_id: 'router',
      msg_id: nil,
      structured_data: nil,
      message: 'at=info method=GET path="/" host=whatismyip.herokuapp.com request_id=deebfda6-cf90-4d53-b22b-8c5a207075d7 fwd="140.248.40.40" dyno=web.1 connect=0ms service=0ms status=200 bytes=148 protocol=http'
    }
  end

  def parsed_log_logplex
    {
      priority: 172,
      syslog_version: 1,
      emitted_at: '2023-02-11 20:46:52.398833 UTC',
      hostname: 'host',
      appname: 'heroku',
      proc_id: 'logplex',
      msg_id: nil,
      structured_data: nil,
      message: 'Error L10 (output buffer overflow): 1 messages dropped since 2023-02-11T20:46:37.307999+00:00.'
    }
  end
end

RSpec.configure do |config|
  config.include ParsedLogHelpers
end
