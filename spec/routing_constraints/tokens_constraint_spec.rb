require 'rails_helper'

class DummyRequest
  attr_accessor :raw_post

  def initialize(raw_post)
    @raw_post = raw_post
  end
end

describe RoutingConstraints::TokensConstraint do
  subject(:constraint) { described_class.new 'word' }

  describe '#new' do
    it 'creates an instance of RoutingConstraints::TokensConstraint' do
      is_expected.to be_instance_of described_class
    end
  end

  describe '.matches?' do
    let(:request) { DummyRequest.new body }

    context 'with request without correct structure' do
      let(:body) { '{"some":{"arbitrary":{"structure":true}}}' }

      it 'returns false' do
        expect(constraint.matches?(request)).to be_falsy
      end
    end

    context 'with request with correct structure' do
      context 'without searching keyword' do
        let(:body) { '{"auth":{"identity":{"methods":["phrase","term","vocable"]}}}' }

        it 'returns false' do
          expect(constraint.matches?(request)).to be_falsy
        end
      end

      context 'with searching keyword' do
        let(:body) { '{"auth":{"identity":{"methods":["phrase","word","vocable"]}}}' }

        it 'returns true' do
          expect(constraint.matches?(request)).to be_truthy
        end
      end
    end
  end
end
