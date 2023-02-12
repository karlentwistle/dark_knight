# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::RuntimeMetricParser do
  describe '.parse' do
    context 'log_runtime_metrics' do
      it 'parses message' do
        subject = described_class.parse(parsed_log_runtime_metric)

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
        subject = described_class.parse(parsed_log_http_request)

        expect(subject).to eql({})
      end
    end

    context 'logplex' do
      it 'returns an empty hash' do
        subject = described_class.parse(parsed_log_logplex)

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
end
