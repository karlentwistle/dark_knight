# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::Dyno do
  describe '#from_runtime_metric' do
    it 'creates a dyno object' do
      subject = described_class.from_runtime_metric(web_runtime_metric)

      expect(subject).to eq(
        described_class.new(
          source: 'web.1',
          memory_quota: 512.00,
          memory_total: 7.11
        )
      )
    end

    it 'creates an empty object given invalid input' do
      subject = described_class.from_runtime_metric({})

      expect(subject).to eq(
        described_class.new(
          source: '',
          memory_quota: 0,
          memory_total: 0
        )
      )
    end
  end

  describe '#restart_if_swapping' do
    it 'issues http request to heroku api if memory total exceeds memory quota' do
      stub_restart_request('todo', 'web.1')

      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)
      subject.restart_if_swapping

      expect_restart_request('todo', 'web.1')
    end

    it 'does nothing if memory total equals memory quota' do
      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 512.0)

      subject.restart_if_swapping

      expect_no_request
    end

    it 'does nothing false if memory total is lower than memory quota' do
      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 256.0)

      subject.restart_if_swapping

      expect_no_request
    end
  end

  describe '#restart' do
    it 'issues http request to heroku api' do
      stub_restart_request('todo', 'web.1')

      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      subject.restart

      expect_restart_request('todo', 'web.1')
    end
  end

  describe '#swapping?' do
    it 'returns true if memory_total exceeds memory_total' do
      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 513.5)

      expect(subject).to be_swapping
    end

    it 'returns false if memory_total equals memory_total' do
      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 512.0)

      expect(subject).not_to be_swapping
    end

    it 'returns false if memory_total is lower than memory_total' do
      subject = described_class.new(source: 'web.1', memory_quota: 512.00, memory_total: 256.0)

      expect(subject).not_to be_swapping
    end
  end

  private

  def web_runtime_metric
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
  end

  def stub_restart_request(app_id_or_name, dyno_id_or_name)
    stub_request(:delete, restart_uri(app_id_or_name, dyno_id_or_name))
      .with(headers: restart_headers)
      .to_return(status: 202)
  end

  def expect_restart_request(app_id_or_name, dyno_id_or_name)
    expect(a_request(:delete, restart_uri(app_id_or_name, dyno_id_or_name))
      .with(headers: restart_headers))
      .to have_been_made.once
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
