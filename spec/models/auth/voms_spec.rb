require 'rails_helper'

describe Auth::Voms, type: :model do
  describe '#parse_hash_dn!' do
    context 'with correct hash' do
      let(:dn_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0
                             /fedcloud.egi.eu/Role=NULL/Capability=NULL) }
      end

      it 'will return correct DN' do
        expect(Auth::Voms.send(:parse_hash_dn!, dn_hash)).to \
          eq('/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535')
      end
    end

    context 'with incorrect hash with no X509USER' do
      let(:dn_hash) do
        { 'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0
                             /fedcloud.egi.eu/Role=NULL/Capability=NULL) }
      end

      it 'will raise error' do
        expect { Auth::Voms.send(:parse_hash_dn!, dn_hash) }.to \
          raise_error(Errors::AuthError)
      end
    end

    context 'with incorrect hash with multiple X509USER' do
      let(:dn_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0
                             /fedcloud.egi.eu/Role=NULL/Capability=NULL),
          'GRST_CRED_3' => %(X509USER 1492623100 1111111111 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Dusan Baran 1234) }
      end

      it 'will raise error' do
        expect { Auth::Voms.send(:parse_hash_dn!, dn_hash) }.to \
          raise_error(Errors::AuthError)
      end
    end
  end

  describe '#parse_hash_exp!' do
    context 'with correct hash' do
      let(:exp_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0
                             /fedcloud.egi.eu/Role=NULL/Capability=NULL) }
      end

      it 'will parse correct time' do
        expect(Auth::Voms.send(:parse_hash_exp!, exp_hash)).to eq('1500424487')
      end
    end

    context 'with incorrect hash with no VOMS variable' do
      let(:exp_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074) }
      end

      it 'will raise error' do
        expect { Auth::Voms.send(:parse_hash_exp!, exp_hash) }.to \
          raise_error(Errors::AuthError)
      end
    end

    context 'with incorrect hash with multiple VOMS variables' do
      let(:exp_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0
                             /fedcloud.egi.eu/Role=NULL/Capability=NULL),
          'GRST_CRED_3' => %(VOMS 1500381287 1111111111 0
                             /fedcloud.egi.eu/Role=FULL/Capability=NULL) }
      end

      it 'will raise error' do
        expect { Auth::Voms.send(:parse_hash_exp!, exp_hash) }.to \
          raise_error(Errors::AuthError)
      end
    end
  end

  describe '#unified_credentials' do
    context 'with correct hash' do
      let(:env_hash) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1
                             /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET
                             /CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0
                             /fedcloud.egi.eu/Role=NULL/Capability=NULL),
          'GRST_VOMS_FQANS' => '/fedcloud.egi.eu/Role=NULL/Capability=NULL' }
      end

      let(:correct_hash) do
        { id: '6694ddfebb77800c4d0aa0c6e3a7eb35bf7b3df83c312c23b8ca470930c4317b',
          email: 'nomail@nomail.com',
          groups: { 'fedcloud.egi.eu' => ['NULL'] },
          authentication: 'federation',
          name: '/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535',
          identity: '/DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535',
          expiration: '1500424487',
          acr: nil,
          issuer: nil }
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
