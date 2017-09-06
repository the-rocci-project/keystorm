require 'rails_helper'

describe V3::Auth::FederationController do
  it_behaves_like 'timestampable'

  describe 'GET #oidc', type: :request do
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
        authentication:  { type: 'federation', method: 'oidc' },
        name:            'Ben Dover',
        identity:        '1',
        expiration:      '123456789',
        issuer:          'gogol.com',
        acr:             'goglo.com'
      }
    end

    let(:headers) { JSON_HEADERS.merge(oidc_env) }

    context 'with normal env variables' do
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

      it 'will be succesful' do
        get oidc_v3_auth_federation_index_path, headers: headers
        expect(response).to have_http_status :success
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

    context 'with http env variables' do
      let(:oidc_env) do
        {
          'HTTP_OIDC_sub'                     => '1',
          'HTTP_OIDC_email'                   => 'ben.dover@majl.ru',
          'HTTP_OIDC_edu_person_entitlements' => 'urn:mace:egi.eu:aai.egi.eu:member@fedcloud.egi.eu',
          'HTTP_OIDC_access_token_expires'    => '123456789',
          'HTTP_OIDC_name'                    => 'Ben Dover',
          'HTTP_OIDC_iss'                     => 'gogol.com',
          'HTTP_OIDC_acr'                     => 'goglo.com'
        }
      end

      it 'will be succesful' do
        get oidc_v3_auth_federation_index_path, headers: headers
        expect(response).to have_http_status :success
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

    context 'with mixed env variables' do
      let(:oidc_env) do
        {
          'OIDC_sub'                          => '1',
          'HTTP_OIDC_email'                   => 'ben.dover@majl.ru',
          'OIDC_edu_person_entitlements'      => 'urn:mace:egi.eu:aai.egi.eu:member@fedcloud.egi.eu',
          'HTTP_OIDC_access_token_expires'    => '123456789',
          'OIDC_name'                         => 'Ben Dover',
          'HTTP_OIDC_iss'                     => 'gogol.com',
          'OIDC_acr'                          => 'goglo.com'
        }
      end

      it 'will be succesful' do
        get oidc_v3_auth_federation_index_path, headers: headers
        expect(response).to have_http_status :success
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
end
