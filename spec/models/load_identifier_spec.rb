require 'rails_helper'

describe LoadIdentifier do
  describe 'destroying' do
    let(:load_board) { LoadBoard.create(name: 'TQL') }

    it 'sets deleted_at' do
      load_identifier = described_class.create!(identifier: '123', load_board: load_board)
      expect { load_identifier.destroy }.to(change { load_identifier.deleted_at })
    end

    it 'soft-deletes with #destroy' do
      load_identifier = described_class.create!(identifier: '123', load_board: load_board)
      expect { load_identifier.destroy }.not_to(change { described_class.count })
    end

    it 'soft-deletes with #destroy!' do
      load_identifier = described_class.create!(identifier: '123', load_board: load_board)
      expect { load_identifier.destroy! }.not_to(change { described_class.count })
    end
  end
end
