require 'rails_helper'

describe Auth::Voms, type: :model do
  before do
    allow(Time).to receive(:now).and_return(Time.zone.at(1_000_000_000))
  end

  describe '#parse_hash_dn!' do
    context 'with correct hash' do
      let(:dn_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0 /fedcloud.egi.eu/Role=NULL/Capability=NULL) }
      end

      it 'will return correct DN' do
        expect(Auth::Voms.send(:parse_hash_dn!, dn_hash)).to \
          eq('/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535')
      end
    end

    context 'with incorrect hash with no X509USER' do
      let(:dn_hash) do
        { 'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0 /fedcloud.egi.eu/Role=NULL/Capability=NULL) }
      end

      it 'will raise error' do
        expect { Auth::Voms.send(:parse_hash_dn!, dn_hash) }.to \
          raise_error(Errors::AuthenticationError)
      end
    end
  end

  describe '#parse_hash_groups!' do
    context 'with valid groups with different capabilities' do
      let(:env_hash) do
        { 'GRST_VOMS_FQANS' => '/coolclub/Role=NULL/Capability=NULL;' \
                               '/nicepeople/Role=model/Capability=full;' \
                               '/others/Role=outofideas/Capability=none' }
      end

      let(:final_groups) do
        [{ id: 'coolclub', roles: %w[] },
         { id: 'nicepeople', roles: %w[model] },
         { id: 'others', roles: %w[outofideas] }]
      end

      it 'will drop out subgroups' do
        expect(Auth::Voms.send(:parse_hash_groups!, env_hash)).to eq(final_groups)
      end
    end

    context 'with group with subgroups' do
      let(:env_hash) do
        { 'GRST_VOMS_FQANS' => '/coolclub/Role=NULL/Capability=NULL;' \
                               '/testers/oldpeople/Role=useless/Capability=NULL' }
      end

      let(:final_groups) do
        [{ id: 'coolclub', roles: %w[] }]
      end

      it 'will drop out subgroups' do
        expect(Auth::Voms.send(:parse_hash_groups!, env_hash)).to eq(final_groups)
      end
    end

    context 'with multiple same groups with same roles' do
      let(:env_hash) do
        { 'GRST_VOMS_FQANS' => '/coolclub/Role=gamers/Capability=NULL;' \
                               '/coolclub/Role=gamers/Capability=NULL' }
      end

      let(:final_groups) do
        [{ id: 'coolclub', roles: %w[gamers] }]
      end

      it 'wont have duplicate roles' do
        expect(Auth::Voms.send(:parse_hash_groups!, env_hash)).to eq(final_groups)
      end
    end

    context 'with invalid groups' do
      let(:env_hash) do
        { 'GRST_VOMS_FQANS' => '/coolclub/Role=NULL/Capability=NUL;' \
                               '/nerds/Roe=LL/Capabili=NLL;' \
                               '/coolclRole=boyz/Capability=NULL;' \
                               '/programmers/Role=useless/Capability=NULL;' \
                               '/programmers/Role=useful/Cability=NULL;' \
                               '/testes/Role=useCapability=NLL' }
      end

      it 'will raise error' do
        expect { Auth::Voms.send(:parse_hash_groups!, env_hash) }.to \
          raise_error(Errors::AuthenticationError)
      end
    end

    context 'with all kinds of groups' do
      let(:env_hash) do
        { 'GRST_VOMS_FQANS' => '/coolclub/Role=NULL/Capability=NULL;' \
                               '/nerds/Role=NULL/Capability=NULL;' \
                               '/coolclub/Role=boyz/Capability=NULL;' \
                               '/programmers/Role=useless/Capability=NULL;' \
                               '/programmers/Role=useful/Capability=NULL;' \
                               '/testers/Role=useless/Capability=NULL' }
      end

      let(:final_groups) do
        [{ id: 'coolclub', roles: %w[boyz] },
         { id: 'nerds', roles: %w[] },
         { id: 'programmers', roles: %w[useless useful] },
         { id: 'testers', roles: %w[useless] }]
      end

      it 'will parse groups correctly' do
        expect(Auth::Voms.send(:parse_hash_groups!, env_hash)).to eq(final_groups)
      end
    end
  end

  describe '#unified_credentials' do
    context 'with correct hash with NULL' do
      let(:env_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0 /fedcloud.egi.eu/Role=NULL/Capability=NULL),
          'GRST_VOMS_FQANS' => '/fedcloud.egi.eu/Role=NULL/Capability=NULL' }
      end

      let(:correct_hash) do
        { id: '6694ddfebb77800c4d0aa0c6e3a7eb35bf7b3df83c312c23b8ca470930c4317b',
          groups: [{ id: 'fedcloud.egi.eu', roles: [] }],
          authentication: { type: 'federation', method: 'voms' },
          name: '/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535',
          identity: '/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535',
          expiration: 1_000_028_800 }
      end

      before do
        stub_const('ENV', ENV.to_hash.merge(env_hash))
      end

      it 'will parse hash correctly' do
        uc = Auth::Voms.unified_credentials(env_hash)
        expect(uc.to_hash).to eq(correct_hash)
      end
    end

    context 'with correct hash' do
      let(:env_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0 /fedcloud.egi.eu/Role=NULL/Capability=NULL),
          'GRST_VOMS_FQANS' => '/fedcloud.egi.eu/Role=actor/Capability=NULL' }
      end

      let(:correct_hash) do
        { id: '6694ddfebb77800c4d0aa0c6e3a7eb35bf7b3df83c312c23b8ca470930c4317b',
          groups: [{ id: 'fedcloud.egi.eu', roles: ['actor'] }],
          authentication: { type: 'federation', method: 'voms' },
          name: '/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535',
          identity: '/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535',
          expiration: 1_000_028_800 }
      end

      before do
        stub_const('ENV', ENV.to_hash.merge(env_hash))
      end

      it 'will parse hash correctly' do
        uc = Auth::Voms.unified_credentials(env_hash)
        expect(uc.to_hash).to eq(correct_hash)
      end
    end
  end
end
