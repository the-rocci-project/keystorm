require 'rails_helper'

shared_examples_for 'acceptable', type: :request do
  let(:headers) { JSON_HEADERS }

  context 'with missing request format' do
    let(:headers) { JSON_HEADERS.select { |key, _value| key == 'ACCEPT' } }

    it 'returns not acceptable status code' do
      get request_path, headers: headers
      expect(response).to have_http_status :not_acceptable
    end
  end

  context 'with wrong request format' do
    let(:headers) { JSON_HEADERS.merge('ACCEPT' => 'text/plain') }

    it 'returns not acceptable status code' do
      get request_path, headers: headers
      expect(response).to have_http_status :not_acceptable
    end
  end

  context 'with missing provided format' do
    let(:headers) { JSON_HEADERS.select { |key, _value| key == 'CONTENT_TYPE' } }

    it 'returns not acceptable status code' do
      get request_path, headers: headers
      expect(response).to have_http_status :not_acceptable
    end
  end

  context 'with wrong provided format' do
    let(:headers) { JSON_HEADERS.merge('CONTENT_TYPE' => 'text/plain') }

    it 'returns not acceptable status code' do
      get request_path, headers: headers
      expect(response).to have_http_status :not_acceptable
    end
  end
end
