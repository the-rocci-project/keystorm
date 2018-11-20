# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'respondable', type: :request do
  let(:headers) { JSON_HEADERS }

  context 'with missing response format' do
    let(:headers) { JSON_HEADERS.select { |key, _value| key == 'CONTENT_TYPE' } }

    it 'returns not acceptable status code' do
      send(method, request_path, headers: headers)
      expect(response).to have_http_status :not_acceptable
    end
  end

  context 'with wrong response format' do
    let(:headers) { JSON_HEADERS.merge('ACCEPT' => 'text/plain') }

    it 'returns not acceptable status code' do
      send(method, request_path, headers: headers)
      expect(response).to have_http_status :not_acceptable
    end
  end
end
