require 'rails_helper'

describe V3::Auth::FederationController, type: :controller do
  describe 'GET #oidc' do
    let(:oidc_env) do
      { 'OIDC_sub'                     => '1',
        'OIDC_email'                   => 'ben.dover@majl.ru',
        'OIDC_edu_person_entitlements' => 'urn:mace:egi.eu:aai.egi.eu:member@fedcloud.egi.eu',
        'OIDC_access_token_expires'    => '123456789',
        'OIDC_name'                    => 'Ben Dover',
        'OIDC_iss'                     => 'gogol.com',
        'OIDC_acr'                     => 'goglo.com' }
    end

    let(:credentials_hash) do
      { 'id'             => '1',
        'email'          => 'ben.dover@majl.ru',
        'groups'         => { 'fedcloud.egi.eu' => ['member'] },
        'authentication' => 'federation',
        'name'           => 'Ben Dover',
        'identity'       => '1',
        'expiration'     => '123456789',
        'issuer'         => 'gogol.com',
        'acr'            => 'goglo.com' }
    end

    before do
      allow(Rails.configuration)
        .to receive(:keystorm)
        .and_return('token_cipher' => 'AES-128-CBC',
                    'token_key' => '7\xB8c7\x99\xE2\x1Fy\xB3jv[\xEFf\x1E\x92',
                    'token_iv' => '\xEAQ\x1C\xF8\xB0\x84lvp\x88~\xC0L?%\xDD')
      stub_const('ENV', ENV.to_hash.merge(oidc_env))
    end

    it 'will be succesful' do
      get :oidc
      expect(response).to be_success
    end

    it 'will have X-Subject-Token set' do
      get :oidc
      expect(response.headers['X-Subject-Token']).not_to be_nil
    end

    it 'will have correct token set' do
      get :oidc
      expect(::Tokenator.from_token(response.headers['X-Subject-Token'])).to eq(credentials_hash)
    end
  end
end
