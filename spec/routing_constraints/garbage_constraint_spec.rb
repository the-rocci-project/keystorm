require 'rails_helper'

class DummyRequest
  attr_accessor :raw_post

  def initialize(raw_post)
    @raw_post = raw_post
  end
end

describe RoutingConstraints::GarbageConstraint do
  subject(:constraint) { described_class.new %w[phrase term vocable] }

  describe '#new' do
    it 'creates an instance of RoutingConstraints::GarbageConstraint' do
      is_expected.to be_instance_of described_class
    end
  end

  describe '.matches?' do
    let(:request) { DummyRequest.new body }

    context 'with request without correct structure' do
      let(:body) { '{"some":{"arbitrary":{"structure":true}}}' }

      it 'returns true' do
        expect(constraint.matches?(request)).to be_truthy
      end
    end

    context 'with request with correct structure' do
      context 'without one of the searching keywords' do
        let(:body) { '{"auth":{"identity":{"methods":["apple","orange","banana"]}}}' }

        it 'returns true' do
          expect(constraint.matches?(request)).to be_truthy
        end
      end

      context 'with one of the searching keywords' do
        let(:body) { '{"auth":{"identity":{"methods":["apple","banana","vocable"]}}}' }

        it 'returns false' do
          expect(constraint.matches?(request)).to be_falsy
        end
      end
    end
  end
end
