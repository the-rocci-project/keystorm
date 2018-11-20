# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'project_accessible' do
  let(:controller) { described_class.new }
  let(:credentials) { UnifiedCredentials.new credentials_hash }
  let(:credentials_hash) do
    {
      id: '1',
      email: 'ben.dover@majl.ru',
      groups: [
        { id: 'fedcloud.egi.eu', roles: ['member'] }
      ],
      authentication: { type: 'federation', method: 'oidc' },
      name: 'Ben Dover',
      identity: '1',
      expiration: '123456789',
      issuer: 'gogol.com',
      acr: 'goglo.com'
    }
  end

  describe '.available_projects', :vcr do
    before do
      controller.instance_variable_set(:@cloud, Clouds::CloudProxy.new)
      controller.instance_variable_set(:@credentials, credentials)
    end

    context 'with no projects on cloud side' do
      it 'returns an empty list' do
        expect(controller.available_projects).to be_empty
      end
    end

    context 'with no projects on credentials side' do
      before do
        credentials_hash[:group] = []
      end

      it 'returns an empty list' do
        expect(controller.available_projects).to be_empty
      end
    end

    context 'with no matching projects' do
      it 'returns an empty list' do
        expect(controller.available_projects).to be_empty
      end
    end

    context 'with matching projects' do
      it 'returns list of matching projects' do
        expect(controller.available_projects).to eq(['fedcloud.egi.eu'])
      end
    end
  end
end
