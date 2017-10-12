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
        expect(user.groups).to include(group.id)
      end
    end

    context 'with group user is not already in' do
      let(:group) { Connectors::Opennebula::GroupHandler.new.find_by_name 'group01' }
      let(:user) { handler.find_by_name 'kile' }

      it 'adds user to specified group' do
        handler.add_group user, group
        user.info!
        expect(user.groups).to include(group.id)
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

  describe '.update', :vcr do
    let(:user) { handler.find_by_name 'bandicoot' }
    let(:template) { '"SPEC_ATTRIBUTE" = "spec_value"' }

    it 'updates user\'s information' do
      handler.update(user, template)
      user.info
      expect(user['TEMPLATE/SPEC_ATTRIBUTE']).to eq('spec_value')
    end
  end

  describe '.token', :vcr do
    let(:username) { 'bandicoot' }
    let(:group) { Connectors::Opennebula::GroupHandler.new.find_by_name 'group01' }
    let(:expiration) { (Time.zone.now + 1.month).to_i }

    it 'requests an auth token' do
      expect(handler.token(username, group, expiration)).not_to be_empty
    end
  end

  describe '.clean_tokens', :vcr do
    let(:user) { described_class.new.find_by_name 'bandicoot' }
    let(:group) { Connectors::Opennebula::GroupHandler.new.find_by_name 'test01' }

    context 'with only tokens for specified group' do
      it 'deletes all tokens' do
        handler.clean_tokens(user, group)
        user.info
        expect(user['LOGIN_TOKEN/TOKEN']).to be_nil
      end
    end

    context 'with no tokens for specified group' do
      it 'doesn\'t delete any tokens' do
        handler.clean_tokens(user, group)
        user.info
        expect(user['LOGIN_TOKEN/TOKEN']).to eq('823ca4e55aab628dca84e7c7b4266c89d51b5fd0')
      end
    end

    context 'with tokens for both specified group and other groups' do
      it 'deletes tokens of specified group and leaves all other tokens' do
        handler.clean_tokens(user, group)
        user.info
        expect(user['LOGIN_TOKEN/TOKEN']).to eq('823ca4e55aab628dca84e7c7b4266c89d51b5fd0')
      end
    end
  end
end
