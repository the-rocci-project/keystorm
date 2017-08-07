require 'rails_helper'

describe Utils::Tokenator, type: :model do
  describe '#to_token' do
    it 'wont raise error' do
      expect { described_class.to_token(name: 'John') }.not_to raise_error
    end
  end

  describe '#from_token' do
    it 'will parse token' do
      origin = described_class.to_token(name: 'John')
      expect(described_class.from_token(origin)).to eq('name' => 'John')
    end

    it 'will raise error' do
      expect { described_class.from_token('  45 czxv12xc3=/`vx""') }.to raise_error(Errors::AuthenticationError)
    end
  end
end
