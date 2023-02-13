# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::RuntimeMetric do
  describe '#to_h' do
    context 'log_runtime_metrics' do
      it 'parses message' do
        subject = described_class.new(parsed_log_runtime_metric).to_h

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
        subject = described_class.new(parsed_log_http_request).to_h

        expect(subject).to eql({})
      end
    end

    context 'logplex' do
      it 'returns an empty hash' do
        subject = described_class.new(parsed_log_logplex).to_h

        expect(subject).to eql({})
      end
    end

    context 'invalid request' do
      it 'returns an empty hash' do
        subject = described_class.new({}).to_h

        expect(subject).to eql({})
      end
    end
  end
end
