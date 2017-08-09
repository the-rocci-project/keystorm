require 'rails_helper'

describe V3::Auth::FederationController do
  describe 'GET #oidc', type: :request do
    let(:oidc_env) do
      {
        'OIDC_sub'                     => '1',
        'OIDC_email'                   => 'ben.dover@majl.ru',
        'OIDC_edu_person_entitlements' => 'urn:mace:egi.eu:aai.egi.eu:member@fedcloud.egi.eu',
        'OIDC_access_token_expires'    => '123456789',
        'OIDC_name'                    => 'Ben Dover',
        'OIDC_iss'                     => 'gogol.com',
        'OIDC_acr'                     => 'goglo.com'
      }
    end

    let(:credentials_hash) do
      {
        id:              '1',
        email:           'ben.dover@majl.ru',
        groups:
          [
            {
              id: 'fedcloud.egi.eu',
              roles: ['member']
            }
          ],
        authentication:  'federation',
        name:            'Ben Dover',
        identity:        '1',
        expiration:      '123456789',
        issuer:          'gogol.com',
        acr:             'goglo.com'
      }
    end

    let(:headers) { JSON_HEADERS }

    before do
      stub_const('ENV', ENV.to_hash.merge(oidc_env))
    end

    it 'will be succesful' do
      get oidc_v3_auth_federation_index_path, headers: headers
      expect(response).to be_success
    end

    it 'will have X-Subject-Token set' do
      get oidc_v3_auth_federation_index_path, headers: headers
      expect(response.headers['X-Subject-Token']).not_to be_nil
    end

    it 'will have correct token set' do
      get oidc_v3_auth_federation_index_path, headers: headers
      expect(Utils::Tokenator.from_token(response.headers['X-Subject-Token'])).to eq(credentials_hash)
    end
  end
end
