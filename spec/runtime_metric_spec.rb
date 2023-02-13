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

  describe '#irrelevant?' do
    context 'log_runtime_metrics' do
      it 'returns false if dyno is a monitored type' do
        with_dyno_types_env('web') do
          subject = described_class.new(parsed_log_runtime_metric)

          expect(subject).not_to be_irrelevant
        end
      end

      it 'returns true if dyno isnt a monitored type' do
        with_dyno_types_env('worker1,worker2') do
          subject = described_class.new(parsed_log_runtime_metric)

          expect(subject).to be_irrelevant
        end
      end
    end

    context 'http_request' do
      it 'returns true' do
        subject = described_class.new(parsed_log_http_request)

        expect(subject).to be_irrelevant
      end
    end

    context 'logplex' do
      it 'returns true' do
        subject = described_class.new(parsed_log_logplex)

        expect(subject).to be_irrelevant
      end
    end

    context 'invalid request' do
      it 'returns true' do
        subject = described_class.new({})

        expect(subject).to be_irrelevant
      end
    end
  end

  describe '#dyno' do
    it 'returns dyno' do
      subject = described_class.new(parsed_log_runtime_metric)

      expect(subject.dyno).to eql('heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
    end
  end

  def with_dyno_types_env(dyno_types)
    pervious_dyno_types = ENV.fetch('DYNO_TYPES', nil)

    ENV['DYNO_TYPES'] = dyno_types
    yield
    ENV['DYNO_TYPES'] = pervious_dyno_types
  end
end
