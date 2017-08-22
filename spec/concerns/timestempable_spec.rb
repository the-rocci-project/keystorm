require 'rails_helper'

shared_examples_for 'timestampable' do
  let(:controller) { described_class.new }

  describe '.timestamp' do
    context 'with Time object' do
      let(:time) { Time.zone.at(1_503_049_996) }

      it 'returns time in a specified format' do
        expect(controller.timestamp(time)).to eq('2017-08-18T09:53:16.000000Z')
      end
    end

    context 'with time in seconds since epoch' do
      let(:time) { 1_503_049_996 }

      it 'returns time in a specified format' do
        expect(controller.timestamp(time)).to eq('2017-08-18T09:53:16.000000Z')
      end
    end

    context 'with time in seconds since epoch (string)' do
      let(:time) { '1503049996' }

      it 'returns time in a specified format' do
        expect(controller.timestamp(time)).to eq('2017-08-18T09:53:16.000000Z')
      end
    end
  end
end
