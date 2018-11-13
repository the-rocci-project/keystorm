# frozen_string_literal: true

require 'rails_helper'

describe UnifiedCredentials, type: :model do
  let(:credentials_hash) do
    { id: '1',
      email: 'ben.dover@majl.ru',
      groups: 'group',
      authentication: 'federation',
      name: 'Ben Dover',
      identity: '1',
      expiration: '123456789',
      issuer: 'gogol.com',
      acr: 'goglo.com' }
  end

  describe '#new' do
    it 'wont raise error' do
      expect { UnifiedCredentials.new(credentials_hash) }.not_to raise_error
    end

    context 'with proper variables' do
      let(:credentials) { UnifiedCredentials.new(credentials_hash) }

      it 'will set proper variables' do
        expect(credentials.to_hash).to eq(credentials_hash)
      end
    end

    it 'will raise error' do
      expect { UnifiedCredentials.new }.to raise_error(KeyError)
    end
  end

  describe '#to_hash' do
    it 'will generate same hash' do
      expect(UnifiedCredentials.new(credentials_hash).to_hash).to eq(credentials_hash)
    end
  end
end
