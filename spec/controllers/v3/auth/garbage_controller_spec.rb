require 'rails_helper'

describe V3::Auth::GarbageController, type: :controller do
  let(:headers) { JSON_HEADERS }

  describe 'POST create', type: :request do
    before do
      post v3_auth_tokens_path, headers: headers
    end

    it 'returns bad request status code' do
      expect(response).to have_http_status :bad_request
    end
  end
end
