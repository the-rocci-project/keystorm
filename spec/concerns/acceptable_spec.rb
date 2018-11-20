# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'acceptable', type: :request do
  let(:headers) { JSON_HEADERS }

  context 'with missing provided format' do
    let(:headers) { JSON_HEADERS.select { |key, _value| key == 'ACCEPT' } }

    it 'returns not acceptable status code' do
      send(method, request_path, headers: headers)
      expect(response).to have_http_status :not_acceptable
    end
  end

  context 'with wrong provided format' do
    let(:headers) { JSON_HEADERS.merge('CONTENT_TYPE' => 'text/plain') }

    it 'returns not acceptable status code' do
      send(method, request_path, headers: headers)
      expect(response).to have_http_status :not_acceptable
    end
  end
end
