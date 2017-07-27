require 'rails_helper'

describe Auth::Oidc, type: :model do
  describe '#parse_hash_groups' do
    context 'with correct groups' do
      let(:env_hash) do
        { 'OIDC_edu_person_entitlements' \
           => %(urn:mace:egi.eu:www.egi.eu:fedcloud-users:member@egi.eu;
                urn:mace:egi.eu:www.egi.eu:fedcloud-tf:member@egi.eu;
                urn:mace:egi.eu:www.egi.eu:fedcloud-devel:member@egi.eu;
                urn:mace:egi.eu:www.egi.eu:rocci-support:member@egi.eu;
                urn:mace:egi.eu:aai.egi.eu:vm_operator@fedcloud.egi.eu;
                urn:mace:egi.eu:aai.egi.eu:member@fedcloud.egi.eu) }
      end

      let(:groups) { @groups = Auth::Oidc.send(:parse_hash_groups, env_hash) }

      it 'returns not nil' do
        expect(groups).not_to be_nil
      end

      it 'returns 2 groups' do
        expect(groups.keys.size).to eq(2)
      end
    end
  end
end
