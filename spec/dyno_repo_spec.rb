# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::DynoRepo do
  describe 'update_repo' do
    it 'adds dyno to repo if it hasnt been seen before' do
      subject = described_class.new

      subject.update_repo([build_runtime_metric])

      expect(subject.dynos.keys).to include('heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
    end

    it 'updates dyno if seen before' do
      subject = described_class.new

      subject.update_repo(
        [
          build_runtime_metric(memory_total: 32.0),
          build_runtime_metric(memory_total: 64.0)
        ]
      )

      dyno = subject.dynos.fetch('heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
      expect(dyno.memory_total).to be(64.0)
    end

    it 'forgets dyno if it hasnt received a log for 5 minutes' do
      subject = described_class.new

      subject.update_repo([build_runtime_metric(dyno: 'heroku.1')])

      Timecop.freeze(Time.now + (5 * 60)) do
        subject.update_repo([build_runtime_metric(dyno: 'heroku.2')])
      end

      expect(subject.dynos.keys).to eql(['heroku.2'])
    end
  end
end
