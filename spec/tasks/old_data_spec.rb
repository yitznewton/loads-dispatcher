require 'rails_helper'

Rails.application.load_tasks

# rubocop:disable RSpec/DescribeClass
describe 'old_data.rake' do
  let(:described_task) { Rake::Task['old_data:prune_nil_change_versions'] }

  describe 'prune_nil_change_versions' do
    let!(:load_with_nil_and_non_nil_changes) {
      FactoryBot.create(:load, load_identifier: FactoryBot.create(:load_identifier, identifier: 'ABC123')).tap do |load|
        load.update!(weight: 6000, notes: 'Foo bar')
      end
    }

    let!(:load_with_only_nil_changes) {
      FactoryBot.create(:load, load_identifier: FactoryBot.create(:load_identifier, identifier: 'XYZ789')).tap do |load|
        load.update!(notes: 'Foo bar')
      end
    }

    it 'removes nil-change-only versions' do
      described_task.invoke
      expect(load_with_only_nil_changes.versions.count).to eq(1)
    end

    it 'does not remove versions with some nil and some non-nil changes' do
      described_task.invoke
      expect(load_with_nil_and_non_nil_changes.versions.count).to eq(2)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
