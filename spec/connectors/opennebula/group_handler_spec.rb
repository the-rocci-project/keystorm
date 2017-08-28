require 'rails_helper'

describe Connectors::Opennebula::GroupHandler do
  subject(:handler) { described_class.new }

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'initialize pool as GroupPool' do
      expect(handler.pool).to be_instance_of OpenNebula::GroupPool
    end
  end

  describe '.list', :vcr do
    it 'returns all groups that have correct flag and are not excluded' do
      groups = handler.list
      expect(groups.count).to eq(2)
    end
  end
end
