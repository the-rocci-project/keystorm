require 'rails_helper'

shared_examples_for 'authenticable', type: :request do
  let(:headers) { JSON_HEADERS }

  context 'without unscoped token' do
    it 'returns unauthorized status code' do
      get request_path, headers: headers
      expect(response).to have_http_status :unauthorized
    end
  end

  context 'with unscoped token' do
    let(:headers) { JSON_HEADERS.merge('X-Auth-Token' => load_token('token01.base64')) }

    it 'returns success return code' do
      get request_path, headers: headers
      expect(response).to have_http_status :success
    end
  end
end
