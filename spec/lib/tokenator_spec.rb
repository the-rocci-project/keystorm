require 'rails_helper'

describe Tokenator, type: :model do
  describe '#to_token' do
    it 'wont raise error' do
      expect { ::Tokenator.to_token(name: 'John') }.not_to raise_error
    end
  end

  describe '#from_token' do
    it 'will parse token' do
      origin = ::Tokenator.to_token(name: 'John')
      expect(::Tokenator.from_token(origin)).to eq('name' => 'John')
    end

    it 'will raise error' do
      expect { ::Tokenator.from_token('  45 czxv12xc3=/`vx""') }.to raise_error(Errors::AuthError)
    end
  end
end
