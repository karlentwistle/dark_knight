# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::RuntimeMetric do
  describe '.from_heroku_logs' do
    it 'returns array of only valid runtime metrics' do
      parsed_logs = [
        parsed_log_http_request,
        parsed_log_runtime_metric,
        parsed_log_logplex
      ]
      heroku_logs = parsed_logs.map { |parsed_log| DarkKnight::HerokuLog.new(parsed_log) }
      subject = described_class.from_heroku_logs(heroku_logs)

      expect(subject.size).to be 1
      expect(subject).to all(be_a(described_class))
    end
  end

  describe '#monitored_dyno?' do
    it 'returns true if dyno is a monitored type' do
      with_env('DYNO_TYPES', 'web') do
        subject = build_runtime_metric(proc_id: 'web.1')

        expect(subject).to be_monitored_dyno
      end
    end

    it 'returns false if dyno isnt a monitored type' do
      with_env('DYNO_TYPES', 'worker1,worker2') do
        subject = build_runtime_metric(proc_id: 'web.1')

        expect(subject).not_to be_monitored_dyno
      end
    end
  end

  describe '#dyno' do
    it 'returns dyno identifier' do
      subject = described_class.new(DarkKnight::HerokuLog.new(parsed_log_runtime_metric))

      expect(subject.dyno).to eql('heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
    end
  end
end
