require 'rails_helper'

describe V3::Auth::FederationController do
  it_behaves_like 'timestampable'

  describe 'GET #voms', type: :request do
    let(:headers) { JSON_HEADERS.merge(voms_env) }

    context 'with normal headers' do
      let(:voms_env) do
        { 'GRST_CRED_0' => %(X509USER 1492646400 1526731200 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535),
          'GRST_CRED_1' => %(GSIPROXY 1500381287 1500424487 1 /DC=org/DC=terena/DC=tcs/C=CZ/O=CESNET/CN=Michal Kimle 1535/CN=99672074),
          'GRST_CRED_2' => %(VOMS 1500381287 1500424487 0 /fedcloud.egi.eu/Role=NULL/Capability=NULL),
          'GRST_VOMS_FQANS' => '/fedcloud.egi.eu/Role=actor/Capability=NULL' }
      end

      context 'behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = true
          stub_const('Auth::Voms::HEADERS_FILTERS', %w[HTTP_SSL HTTP_GRST])
        end

        it 'fails' do
          get voms_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'not behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = false
          stub_const('Auth::Voms::HEADERS_FILTERS', %w[SSL GRST])
        end

        it 'will be successful' do
          get voms_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :success
        end

        it 'will have X-Subject-Token set' do
          get voms_v3_auth_federation_index_path, headers: headers
          expect(response.headers['X-Subject-Token']).not_to be_nil
        end
      end
    end
  end

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

      context 'behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = true
          stub_const('Auth::Oidc::HEADERS_FILTERS', ['HTTP_OIDC'])
        end

        it 'fail' do
          get oidc_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'not behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = false
          stub_const('Auth::Oidc::HEADERS_FILTERS', ['OIDC'])
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

      context 'behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = true
          stub_const('Auth::Oidc::HEADERS_FILTERS', ['HTTP_OIDC'])
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

      context 'not behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = false
          stub_const('Auth::Oidc::HEADERS_FILTERS', ['OIDC'])
        end

        it 'will fail' do
          get oidc_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
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

      context 'behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = true
          stub_const('Auth::Oidc::HEADERS_FILTERS', ['HTTP_OIDC'])
        end

        it 'will fail' do
          get oidc_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'not behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = false
          stub_const('Auth::Oidc::HEADERS_FILTERS', ['OIDC'])
        end

        it 'will fail' do
          get oidc_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
      end
    end
  end
end
