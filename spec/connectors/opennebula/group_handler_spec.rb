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

  describe '.find_all', :vcr do
    it 'returns all groups (other than excluded)' do
      groups = handler.find_all
      expect(groups.count).to eq(4)
    end
  end
end
