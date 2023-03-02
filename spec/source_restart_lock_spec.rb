# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::SourceRestartLock do
  describe '.source_unlocked?' do
    it 'returns true no source restart lock exists' do
      expect(described_class.source_unlocked?('web.1')).to eql(true)
    end

    it 'returns true if source restart lock exists but the lock has expired' do
      described_class.create(source: 'web.1', expires_at: one_day_ago)

      expect(described_class.source_unlocked?('web.1')).to eql(true)
    end

    it 'returns false if source restart lock already exists and hasnt expired' do
      described_class.create(source: 'web.1', expires_at: one_minute_from_now)

      expect(described_class.source_unlocked?('web.1')).to eql(false)
    end
  end

  private

  def one_day_ago
    Time.now - (24 * 60 * 60)
  end

  def one_minute_from_now
    Time.now + 60
  end
end
