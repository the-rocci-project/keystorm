require 'rails_helper'

describe Clouds::CloudProxy do
  subject(:cloud_proxy) { described_class.new }

  describe '#new' do
    context 'with unsupported cloud type' do
      before do
        allow(Rails.configuration.keystorm).to receive(:[]).with('cloud').and_return('unknown_cloud_type')
      end

      it 'raises LoadError' do
        expect { described_class.new }.to raise_error Errors::Clouds::LoadError
      end
    end

    context 'with supported cloud type' do
      it 'returns an instance of CloudProxy' do
        is_expected.to be_instance_of described_class
      end
    end
  end
end
