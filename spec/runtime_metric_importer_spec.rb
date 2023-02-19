# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::RuntimeMetricImporter do
  describe 'call' do
    it 'adds dyno to repo if it hasnt been seen before' do
      subject = described_class.new

      subject.call([build_runtime_metric])

      expect(
        DarkKnight::Dyno.first(dyno: 'heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
      ).to exist
    end

    it 'updates dyno if seen before' do
      subject = described_class.new

      subject.call(
        [
          build_runtime_metric(memory_total: 32.0),
          build_runtime_metric(memory_total: 64.0)
        ]
      )

      expect(
        DarkKnight::Dyno.first(
          dyno: 'heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e',
          memory_total: 64
        )
      ).to exist
    end

    it 'forgets dyno if it hasnt received a log for 5 minutes' do
      subject = described_class.new

      subject.call([build_runtime_metric(dyno: 'heroku.1')])

      Timecop.freeze(Time.now + (5 * 60)) do
        subject.call([build_runtime_metric(dyno: 'heroku.2')])
      end

      expect(DarkKnight::Dyno.select(:dyno).map(&:dyno)).to eql(['heroku.2'])
    end
  end
end
