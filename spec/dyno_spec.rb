# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::Dyno do
  describe '#restart' do
    it 'issues restart request to heroku api' do
      stub_successful_restart_request('todo', 'web.1')

      subject = described_class.create(dyno: 'uuid', source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      subject.restart

      expect_restart_request('todo', 'web.1')
    end

    it 'only issues one restart request to heroku api if first response succeeds' do
      stub_successful_restart_request('todo', 'web.1')

      subject = described_class.create(dyno: 'uuid', source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      2.times { subject.restart }

      expect(a_restart_request('todo', 'web.1')).to have_been_made.once
    end

    it 'issues requests to heroku api until response succeeds' do
      subject = described_class.create(dyno: 'uuid', source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      stub_failed_restart_request('todo', 'web.1')

      2.times { subject.restart }

      stub_successful_restart_request('todo', 'web.1')

      2.times { subject.restart }

      expect(a_restart_request('todo', 'web.1')).to have_been_made.times(3)
    end

    it 'recovers from Faraday exceptions' do
      # TODO: this should be a spec on RestartDyno

      subject = described_class.create(dyno: 'uuid', source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      stub_restart_request('todo', 'web.1').to_timeout
      subject.restart

      stub_successful_restart_request('todo', 'web.1')
      subject.restart

      expect(a_restart_request('todo', 'web.1')).to have_been_made.twice
    end

    it 'wont issue duplicate restart if another instance of dyno already triggered restart' do
      stub_successful_restart_request('todo', 'web.1')

      subject = described_class.create(dyno: 'uuid', source: 'web.1', memory_quota: 512.00, memory_total: 513.5)
      duplicate = described_class.where(dyno: 'uuid').first

      subject.restart
      duplicate.restart

      expect(a_restart_request('todo', 'web.1')).to have_been_made.once
    end

    it 'wont issue duplicate restarts for the same dyno uuid' do
      stub_successful_restart_request('todo', 'web.1')

      subject = described_class.create(dyno: 'uuid', source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      with_env('WEB_RESTART_WINDOW', '-1') do
        subject.restart
        subject.restart
      end

      expect(a_restart_request('todo', 'web.1')).to have_been_made.once
    end
  end
end
