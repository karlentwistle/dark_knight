# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::SourceRestartLock do
  describe '.if_source_unlocked' do
    it 'yields block if no source restart lock exists' do
      expect { |b| described_class.if_source_unlocked('web.1', &b) }.to yield_control
    end

    it 'yields if source restart lock exists but the lock has expired' do
      described_class.create(source: 'web.1', expires_at: one_day_ago)

      expect { |b| described_class.if_source_unlocked('web.1', &b) }.to yield_control
    end

    it 'doesnt yield block if source restart lock already exists and hasnt expired' do
      described_class.create(source: 'web.1', expires_at: one_minute_from_now)

      expect { |b| described_class.if_source_unlocked('web.1', &b) }.not_to yield_control
    end

    it 'doesnt yield block if Sequel::Plugins::OptimisticLocking::Error is thrown' do
      dbl = double(expires_at: one_day_ago, fetch_expires_at: one_minute_from_now)
      allow(dbl).to receive(:update).and_raise(Sequel::Plugins::OptimisticLocking::Error)
      allow(described_class).to receive(:find).with(source: 'web.1').and_return(dbl)

      expect { |b| described_class.if_source_unlocked('web.1', &b) }.not_to yield_control
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
