# frozen_string_literal: true

require 'spec_helper'

require_relative '../lib/runtime_metric_parser'

RSpec.describe DarkKnight::RuntimeMetricParser do
  describe '.parse' do
    context 'log_runtime_metrics' do
      it 'parses message' do
        subject = described_class.parse(log_runtime_metrics)

        expect(subject).to eql(
          {
            'dyno' => 'heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e',
            'sample#memory_cache' => '6.04MB',
            'sample#memory_pgpgin' => '1978pages',
            'sample#memory_pgpgout' => '158pages',
            'sample#memory_quota' => '512.00MB',
            'sample#memory_rss' => '1.07MB',
            'sample#memory_swap' => '0.00MB',
            'sample#memory_total' => '7.11MB',
            'source' => 'web.1'
          }
        )
      end
    end

    context 'http_request' do
      it 'returns an empty hash' do
        subject = described_class.parse(http_request)

        expect(subject).to eql({})
      end
    end

    context 'logplex' do
      it 'returns an empty hash' do
        subject = described_class.parse(logplex)

        expect(subject).to eql({})
      end
    end

    context 'invalid request' do
      it 'returns an empty hash' do
        subject = described_class.parse({})

        expect(subject).to eql({})
      end
    end
  end

  def log_runtime_metrics
    {
      priority: 134,
      syslog_version: 1,
      emitted_at: '2023-02-11 20:17:07.957556 UTC',
      hostname: 'host',
      appname: 'heroku',
      proc_id: 'web.1',
      msg_id: nil,
      structured_data: nil,
      message: 'source=web.1 dyno=heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e sample#memory_total=7.11MB sample#memory_rss=1.07MB sample#memory_cache=6.04MB sample#memory_swap=0.00MB sample#memory_pgpgin=1978pages sample#memory_pgpgout=158pages sample#memory_quota=512.00MB',
      original: '<134>1 2023-02-11T20:17:07.957556+00:00 host heroku web.1 - source=web.1 dyno=heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e sample#memory_total=7.11MB sample#memory_rss=1.07MB sample#memory_cache=6.04MB sample#memory_swap=0.00MB sample#memory_pgpgin=1978pages sample#memory_pgpgout=158pages sample#memory_quota=512.00MB'
    }
  end

  def http_request
    {
      priority: 158,
      syslog_version: 1,
      emitted_at: '2023-02-11 20:20:03.271237 UTC',
      hostname: 'host',
      appname: 'heroku',
      proc_id: 'router',
      msg_id: nil,
      structured_data: nil,
      message: 'at=info method=GET path="/" host=whatismyip.herokuapp.com request_id=deebfda6-cf90-4d53-b22b-8c5a207075d7 fwd="140.248.40.40" dyno=web.1 connect=0ms service=0ms status=200 bytes=148 protocol=http',
      original: '<158>1 2023-02-11T20:20:03.271237+00:00 host heroku router - at=info method=GET path="/" host=whatismyip.herokuapp.com request_id=deebfda6-cf90-4d53-b22b-8c5a207075d7 fwd="140.248.40.40" dyno=web.1 connect=0ms service=0ms status=200 bytes=148 protocol=http'
    }
  end

  def logplex
    {
      priority: 172,
      syslog_version: 1,
      emitted_at: '2023-02-11 20:46:52.398833 UTC',
      hostname: 'host',
      appname: 'heroku',
      proc_id: 'logplex',
      msg_id: nil,
      structured_data: nil,
      message: 'Error L10 (output buffer overflow): 1 messages dropped since 2023-02-11T20:46:37.307999+00:00.',
      original: '<172>1 2023-02-11T20:46:52.398833+00:00 host heroku logplex - Error L10 (output buffer overflow): 1 messages dropped since 2023-02-11T20:46:37.307999+00:00.'
    }
  end
end
