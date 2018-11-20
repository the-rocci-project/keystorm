# frozen_string_literal: true

require 'rails_helper'

describe Auth::Oidc, type: :model do
  describe '.unified_credentials' do
    context 'with correct env' do
      context 'with minimal attributes' do
        let(:oidc) { described_class.new(load_envs('oidc_noproxy_mini.json')) }

        it 'wont raise error' do
          expect { oidc.unified_credentials }.not_to raise_error
        end
      end

      context 'with all attributes' do
        let(:oidc) { described_class.new(load_envs('oidc_noproxy_normal.json')) }

        it 'wont raise error' do
          expect { oidc.unified_credentials }.not_to raise_error
        end
      end
    end

    context 'with incorrect env' do
      context 'with missing required field' do
        let(:oidc) { described_class.new(load_envs('oidc_noproxy_missing.json')) }

        it 'will raise error' do
          expect { oidc.unified_credentials }.to raise_error(Errors::AuthenticationError)
        end
      end
    end
  end
end
