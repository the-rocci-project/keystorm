require 'rails_helper'

describe V3::Auth::TokensController, :vcr, type: :controller do
  it_behaves_like 'acceptable' do
    let(:request_path) { v3_auth_tokens_path }
    let(:method) { :post }
  end

  it_behaves_like 'project_accessible'
  it_behaves_like 'timestampable'

  describe 'POST create', type: :request do
    let(:headers) { JSON_HEADERS }

    before do
      post v3_auth_tokens_path, params: body, headers: headers
    end

    context 'with missing project id' do
      let(:body) { load_request 'tokens01.json' }

      it 'returns bad request code' do
        expect(response).to have_http_status :bad_request
      end
    end

    context 'with nonexisting project id' do
      let(:body) { load_request 'tokens02.json' }

      it 'returns bad request code' do
        expect(response).to have_http_status :bad_request
      end
    end

    context 'with missing token' do
      let(:body) { load_request 'tokens03.json' }

      it 'returns unauthorized code' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with invalid token' do
      let(:body) { load_request 'tokens04.json' }

      it 'returns unauthorized code' do
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with correct request' do
      let(:body) { load_request 'tokens05.json' }

      it 'returns created status code' do
        expect(response).to have_http_status :created
      end

      it 'sets correct headers' do
        expect(response.headers['X-Subject-Token']).not_to be_empty
      end

      it 'sets a valid token as header' do
        keystorm_token = response.headers['X-Subject-Token']
        cloud_token = Utils::Tokenator.from_token keystorm_token, parse: false
        expect(cloud_token).to eq(Connectors::Opennebula::UserHandler.new.find_by_name('aaa')['LOGIN_TOKEN/TOKEN'])
      end
    end
  end
end
