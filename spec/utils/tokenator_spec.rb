require 'rails_helper'
require 'rantly'
require 'rantly/rspec_extensions'

describe Utils::Tokenator, type: :model do
  let(:test_token) { 'BvNYWOVnLepg8St8Le+V2w==' }
  let(:hash_token) do
    'QDcRWzoOx0UoF6UX6CwYm0FNilW+qTKfEWs/uXKFrNvnHa9uYjXY278cjtrZjWzmUpzLYVRVdaLqeIE2yA6Zsw9' \
    'JjaLa2qq0qulNQMFho+Y0BmOpMAaQRdApblIULVHA'
  end
  let(:test_hash) { { id: 0, name: 'dusan', groups: [{ id: 'bros', role: 'leader' }, { id: 'male', role: 'alpha' }] } }

  describe 'tokenizing' do
    it 'to_token and from_token on string are inverse' do
      property_of { string }.check(1000) do |text|
        expect(described_class.from_token(described_class.to_token(text), parse: false)).to eq(text)
      end
    end

    it 'to_token and from_token on hash are inverse' do
      property_of { dict { [Rantly { call(proc { string.to_sym }) }, Rantly { branch :integer, :string }] } }.check(1000) do |hash|
        expect(described_class.from_token(described_class.to_token(hash))).to eq(hash)
      end
    end
  end

  describe '#to_token' do
    it 'wont raise error' do
      expect { described_class.to_token(name: 'John') }.not_to raise_error
    end

    it 'will raise error' do
      expect { described_class.to_token(nil) }.to raise_error(Errors::AuthenticationError)
    end

    context 'with string argument' do
      it 'returns correct token' do
        expect(described_class.to_token('testing')).to eq(test_token)
      end
    end

    context 'with hash argument' do
      it 'returns correct token' do
        expect(described_class.to_token(test_hash)).to eq(hash_token)
      end
    end
  end

  describe '#from_token' do
    context 'from tokenized string' do
      it 'returns correct string' do
        expect(described_class.from_token(test_token, parse: false)).to eq('testing')
      end
    end

    context 'from tokenized hash' do
      it 'returns correct hash' do
        expect(described_class.from_token(hash_token)).to eq(test_hash)
      end
    end

    it 'will raise error' do
      expect { described_class.from_token('  45 czxv12xc3=/`vx""') }.to raise_error(Errors::AuthenticationError)
    end
  end
end
