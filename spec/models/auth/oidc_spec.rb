require 'rails_helper'

describe Auth::Oidc, type: :model do
  describe '#parse_hash_groups' do
    context 'with correct groups' do
      let(:env_hash) do
        { 'OIDC_edu_person_entitlements' \
           => File.read(File.join(MOCK_DIR, 'groups')) }
      end

      let(:groups) { Auth::Oidc.send(:parse_hash_groups, env_hash) }

      it 'returns not nil' do
        expect(groups).not_to be_nil
      end

      it 'returns 1 groups' do
        expect(groups.keys.size).to eq(1)
      end

      it 'returns good group' do
        expect(groups['fedcloud.egi.eu']).to eq(%w[vm_operator member])
      end
    end

    context 'with incorrect groups' do
      let(:env_hash) do
        { 'OIDC_edu_person_entitlements' \
          => File.read(File.join(MOCK_DIR, 'wrong_groups')) }
      end

      let(:groups) { Auth::Oidc.send(:parse_hash_groups, env_hash) }

      it 'returns not nil' do
        expect(groups).not_to be_nil
      end

      it 'returns 0 groups' do
        expect(groups.keys.size).to eq(0)
      end
    end
  end
end
