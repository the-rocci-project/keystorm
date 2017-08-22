require 'rails_helper'

describe Clouds::Opennebula do
  subject(:opennebula) { described_class.new }

  describe '#new' do
    it 'creates an instance of Clouds::Opennebula' do
      is_expected.to be_instance_of described_class
    end
  end

  describe '.projects', :vcr do
    context 'with some available groups' do
      it 'returns list of available groups' do
        expect(opennebula.projects).to eq(['group01', 'group02', 'test-group', 'test-group2'])
      end
    end

    context 'without any groups' do
      it 'returns an empty list' do
        expect(opennebula.projects).to be_empty
      end
    end
  end

  describe '.token', :vcr do
    let(:username) { 'bandicoot' }
    let(:group) { 'group01' }
    let(:expiration) { (Time.zone.now + 1.month).to_i }

    it 'obtains an auth token' do
      expect(opennebula.token(username, group, expiration)).not_to be_empty
    end
  end

  describe '.autocreate', :vcr do
    let(:credentials) { UnifiedCredentials.new hash }
    let(:hash) do
      {
        id:              'bendicoot',
        email:           'ben.dover@majl.ru',
        groups:          [
          {
            id: 'group01',
            roles: []
          }
        ],
        authentication:  {
          type: 'federation',
          method: 'oidc'
        },
        name:            'Ben Dover',
        identity:        '1234',
        expiration:      '1505726089',
        issuer:          'gogol.com',
        acr:             'goglo.com'
      }
    end
    let(:group) { 'group01' }

    context 'with already existing user' do
      context 'already in the group' do
        it 'does nothing' do
          expect { opennebula.autocreate(credentials, group) }.not_to raise_error
        end
      end

      context 'not in the group' do
        let(:group) { 'test01' }

        it 'adds user to the group' do
          opennebula.autocreate(credentials, group)
          expect(Connectors::Opennebula::UserHandler.new.find_by_name('bendicoot').groups).to include(111)
        end
      end
    end

    context 'with new user' do
      it 'creates a user' do
        opennebula.autocreate(credentials, group)
        expect(Connectors::Opennebula::UserHandler.new.find_by_name('bendicoot')).not_to be_nil
      end

      it 'sets primary group to selected group' do
        opennebula.autocreate(credentials, group)
        expect(Connectors::Opennebula::UserHandler.new.find_by_name('bendicoot').gid).to eq(114)
      end
    end
  end
end
