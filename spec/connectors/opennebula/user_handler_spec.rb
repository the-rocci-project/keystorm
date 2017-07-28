require 'rails_helper'

describe Connectors::Opennebula::UserHandler do
  subject(:handler) { described_class.new }

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'initialize pool as UserPool' do
      expect(handler.pool).to be_instance_of OpenNebula::UserPool
    end
  end

  describe '.list', :vcr do
    it 'returns all groups (other than excluded)' do
      groups = handler.list
      expect(groups.count).to eq(3)
    end
  end

  describe '.add_group', :vcr do
    context 'with group user is already in' do
      let(:group) { Connectors::Opennebula::GroupHandler.new.find_by_name 'group02' }
      let(:user) { handler.find_by_name 'kile' }

      it 'does nothing - keeps user in the group' do
        handler.add_group user, group
        user.info!
        expect(user.groups.include?(group.id)).to be_truthy
      end
    end

    context 'with group user is not already in' do
      let(:group) { Connectors::Opennebula::GroupHandler.new.find_by_name 'group01' }
      let(:user) { handler.find_by_name 'kile' }

      it 'adds user to specified group' do
        handler.add_group user, group
        user.info!
        expect(user.groups.include?(group.id)).to be_truthy
      end
    end
  end

  describe '.create', :vcr do
    let(:username) { 'bandicoot' }
    let(:group) { Connectors::Opennebula::GroupHandler.new.find_by_name 'group01' }
    let(:auth) { 'core' }
    let(:password) { 'password' }

    it 'creates a new user and set him primary group' do
      handler.create(username, password, auth, group)
      expect(handler.find_by_name(username)).to be_truthy
    end
  end
end
