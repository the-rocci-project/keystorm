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
end
