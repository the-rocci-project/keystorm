require 'rails_helper'

describe Auth::Voms, type: :model do
  describe '.unified_credentials' do
    context 'with correct credentials' do
      context 'normal' do
        let(:voms) { described_class.new(load_envs('voms_noproxy.json')) }

        it 'wont raise error' do
          expect { voms.unified_credentials }.not_to raise_error
        end
      end

      context 'robot not in puspfile' do
        let(:voms) { described_class.new(load_envs('voms_robot_correct.json')) }

        it 'wont raise error' do
          expect { voms.unified_credentials }.not_to raise_error
        end

        it 'will be robot' do
          expect(voms.send(:robot?)).to be_truthy
        end
      end

      context 'robot in puspfile' do
        let(:voms) do
          stub_const('Utils::Pusp::PUSP_FILE_PATH', File.join(MOCK_DIR, 'puspfiles', 'pusp0'))
          described_class.new(load_envs('voms_robot_correct.json'))
        end

        it 'wont raise error' do
          expect { voms.unified_credentials }.not_to raise_error
        end

        it 'will be robot' do
          expect(voms.send(:robot?)).to be_truthy
        end

        it 'will parse right' do
          creds = voms.unified_credentials
          expect(creds.name).to eq('/C=IT/O=INFN/OU=Robot/L=Catania/CN=Robot: Catania Science Gateway - Johnny Tester/CN=eToken:User1')
        end
      end
    end

    context 'with incorrect credentials' do
      context 'with wrong dn' do
        let(:voms) { described_class.new(load_envs('voms_noproxy_incorrect.json')) }

        it 'will raise error' do
          expect { voms.unified_credentials }.to raise_error(Errors::AuthenticationError)
        end
      end

      context 'not verified' do
        let(:voms) { described_class.new(load_envs('voms_noproxy_incorrect.json')) }

        it 'will raise error' do
          expect { voms.unified_credentials }.to raise_error(Errors::AuthenticationError)
        end
      end
    end
  end
end
