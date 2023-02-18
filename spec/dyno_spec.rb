# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::Dyno do
  describe '#restart' do
    it 'issues restart request to heroku api' do
      stub_successful_restart_request('todo', 'web.1')

      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      subject.restart

      expect_restart_request('todo', 'web.1')
    end

    it 'only issues one restart request to heroku api if first response succeeds' do
      stub_successful_restart_request('todo', 'web.1')

      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      Array.new(10) do
        Thread.new do
          subject.restart
        end
      end.each(&:join)

      expect(a_restart_request('todo', 'web.1')).to have_been_made.once
    end

    it 'issues requests to heroku api until response succeeds' do
      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      stub_failed_restart_request('todo', 'web.1')

      Array.new(2) do
        Thread.new do
          subject.restart
        end
      end.each(&:join)

      stub_successful_restart_request('todo', 'web.1')

      Array.new(2) do
        Thread.new do
          subject.restart
        end
      end.each(&:join)

      expect(a_restart_request('todo', 'web.1')).to have_been_made.at_least_times(2)
    end

    it 'recovers from Faraday exceptions' do
      # TODO: this should be a spec on RestartDyno

      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      stub_restart_request('todo', 'web.1').to_timeout
      subject.restart

      stub_successful_restart_request('todo', 'web.1')
      subject.restart

      expect(a_restart_request('todo', 'web.1')).to have_been_made.twice
    end
  end

  describe '#restart_required?' do
    context 'restart threshold specified' do
      it 'returns true if memory_total exceeds specified threshold' do
        with_env('WEB_RESTART_THRESHOLD', '972.8') do
          subject = described_class.new(source: 'web.1', memory_total: 1024.0, memory_quota: 1024.0)

          expect(subject).to be_restart_required
        end
      end

      it 'returns false if memory_total equals specified threshold' do
        with_env('WORKER1_RESTART_THRESHOLD', '512.0') do
          subject = described_class.new(source: 'worker1.1', memory_total: 512.0, memory_quota: 1024.0)

          expect(subject).not_to be_restart_required
        end
      end

      it 'returns false if memory_total is lower than specified threshold' do
        with_env('WEB_RESTART_THRESHOLD', '1024.0') do
          subject = described_class.new(source: 'web.1', memory_total: 512.0, memory_quota: 1024.0)

          expect(subject).not_to be_restart_required
        end
      end
    end

    context 'no restart threshold specified' do
      it 'returns true if memory_total exceeds memory_quota' do
        subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

        expect(subject).to be_restart_required
      end

      it 'returns false if memory_total equals memory_quota' do
        subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 512.0)

        expect(subject).not_to be_restart_required
      end

      it 'returns false if memory_total is lower than memory_quota' do
        subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 256.0)

        expect(subject).not_to be_restart_required
      end
    end
  end
end
