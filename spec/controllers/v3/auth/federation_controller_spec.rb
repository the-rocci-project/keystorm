require 'rails_helper'

describe V3::Auth::FederationController do
  it_behaves_like 'timestampable'

  it_behaves_like 'respondable' do
    let(:request_path) { oidc_v3_auth_federation_index_path }
    let(:method) { :get }
  end

  it_behaves_like 'respondable' do
    let(:request_path) { voms_v3_auth_federation_index_path }
    let(:method) { :get }
  end

  describe 'GET #voms', type: :request do
    let(:headers) { JSON_HEADERS.merge(voms_env) }

    context 'with env with no prefix' do
      let(:voms_env) { load_envs('voms_noproxy.json') }

      context 'when behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = true
          stub_const('Auth::Voms::HEADERS_FILTERS', %w[HTTP_SSL HTTP_GRST])
        end

        it 'fails' do
          get voms_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'when not behind proxy' do
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

    context 'with env with HTTP_ prefix' do
      let(:voms_env) { load_envs('voms_correct.json') }

      context 'when behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = true
          stub_const('Auth::Voms::HEADERS_FILTERS', %w[HTTP_SSL HTTP_GRST])
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

      context 'when not behind proxy' do
        before do
          Rails.configuration.keystorm['behind_proxy'] = false
          stub_const('Auth::Voms::HEADERS_FILTERS', %w[SSL GRST])
        end

        it 'fails' do
          get voms_v3_auth_federation_index_path, headers: headers
          expect(response).to have_http_status :unauthorized
        end
      end
    end
  end
end
