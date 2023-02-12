# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DarkKnight::DynoRepo do
  describe 'update_repo_with_logs' do
    it 'adds dyno to repo if it hasnt been seen before' do
      subject = described_class.new

      subject.update_repo_from_logs([parsed_log_runtime_metric])

      expect(subject.dynos.keys).to include('heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
    end

    it 'updates dyno if seen before' do
      subject = described_class.new

      subject.update_repo_from_logs(
        [
          parsed_log_runtime_metric(memory_total: 32.0),
          parsed_log_runtime_metric(memory_total: 64.0)
        ]
      )

      dyno = subject.dynos.fetch('heroku.15253441.a85b9e33-817d-479d-8bd9-d6c7d368b94e')
      expect(dyno.memory_total).to be(64.0)
    end
  end
end
