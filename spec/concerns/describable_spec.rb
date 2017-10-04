require 'rails_helper'

shared_examples_for 'describable', type: :request do
  let(:headers) { JSON_HEADERS }

  before do
    allow(Rails.configuration.keystorm).to receive(:[]).with('endpoint').and_return('https://over.the.rainbow:1234')
  end

  it 'returns correct response code' do
    get request_path, headers: headers
    expect(response).to have_http_status :success
  end

  it 'returns correct information about API' do
    get request_path, headers: headers
    expect(response.body).to be_json_eql(load_response('describable01.json'))
  end
end
