require 'rails_helper'

describe 'Authentication and authorization flow' do
  before do
    allow(Time).to receive(:now).and_return(Time.zone.at(1_507_281_573))
  end

  context 'using OIDC method' do
    context 'with correct credentials' do
      context 'with minimal credentials' do
        let(:oidc_env) { load_envs 'oidc_mini.json' } # In running application stack this is set by Apache
        let(:scoped_req_body) { load_request 'tokens04.json', hash: true }

        it 'generates unscoped token and uses it to generate scoped token', :vcr do
          get '/v3/auth/federation/oidc', headers: JSON_HEADERS.merge(oidc_env)
          expect(response).to have_http_status :success
          unscoped_token = response.headers['X-Subject-Token']
          expect(unscoped_token).not_to be_nil

          params = scoped_req_body
          params[:auth][:identity][:token][:id] = unscoped_token
          post '/v3/auth/tokens', params: params.to_json, headers: JSON_HEADERS
          expect(response).to have_http_status :success
          scoped_token = response.headers['X-Subject-Token']
          expect(scoped_token).not_to be_nil
        end
      end

      context 'with metadata' do
        let(:oidc_env) { load_envs 'oidc_normal.json' } # In running application stack this is set by Apache
        let(:scoped_req_body) { load_request 'tokens04.json', hash: true }

        it 'generates unscoped token and uses it to generate scoped token', :vcr do
          get '/v3/auth/federation/oidc', headers: JSON_HEADERS.merge(oidc_env)
          expect(response).to have_http_status :success
          unscoped_token = response.headers['X-Subject-Token']
          expect(unscoped_token).not_to be_nil

          params = scoped_req_body
          params[:auth][:identity][:token][:id] = unscoped_token
          post '/v3/auth/tokens', params: params.to_json, headers: JSON_HEADERS
          expect(response).to have_http_status :success
          scoped_token = response.headers['X-Subject-Token']
          expect(scoped_token).not_to be_nil
        end
      end
    end
  end

  context 'using VOMS method' do
    context 'with correct credentials' do
      let(:voms_env) { load_envs 'voms_correct.json' } # In running application stack this is set by Apache
      let(:scoped_req_body) { load_request 'tokens04.json', hash: true }

      it 'generates unscoped token and uses it to generate scoped token', :vcr do
        get '/v3/auth/federation/voms', headers: JSON_HEADERS.merge(voms_env)
        expect(response).to have_http_status :success
        unscoped_token = response.headers['X-Subject-Token']
        expect(unscoped_token).not_to be_nil

        params = scoped_req_body
        params[:auth][:identity][:token][:id] = unscoped_token
        post '/v3/auth/tokens', params: params.to_json, headers: JSON_HEADERS
        expect(response).to have_http_status :success
        scoped_token = response.headers['X-Subject-Token']
        expect(scoped_token).not_to be_nil
      end
    end
  end
end
