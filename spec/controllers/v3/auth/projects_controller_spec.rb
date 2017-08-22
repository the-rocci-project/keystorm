require 'rails_helper'

describe V3::Auth::ProjectsController, :vcr, type: :controller do
  it_behaves_like 'authenticable' do
    let(:request_path) { v3_auth_projects_path }
  end

  it_behaves_like 'acceptable' do
    let(:request_path) { v3_auth_projects_path }
    let(:method) { :get }
  end

  it_behaves_like 'project_accessible'

  describe 'GET index', type: :request do
    let(:token) { load_token 'token01.base64' }
    let(:headers) { JSON_HEADERS.merge('X-Auth-Token' => token) }

    before do
      get v3_auth_projects_path, headers: headers
    end

    context 'with no groups from cloud' do
      it 'returns response successfuly' do
        expect(response).to have_http_status :success
      end

      it 'returns response with empty projects' do
        expect(response.body).to have_json_size(0).at_path('projects')
      end
    end

    context 'with no groups from auth' do
      let(:token) { load_token 'token02.base64' }

      it 'returns response successfuly' do
        expect(response).to have_http_status :success
      end

      it 'returns response with empty projects' do
        expect(response.body).to have_json_size(0).at_path('projects')
      end
    end

    context 'with no intersecting groups' do
      it 'returns response successfuly' do
        expect(response).to have_http_status :success
      end

      it 'returns response with empty projects' do
        expect(response.body).to have_json_size(0).at_path('projects')
      end
    end

    context 'with intersecting groups' do
      let(:token) { load_token 'token03.base64' }

      it 'returns response successfuly' do
        expect(response).to have_http_status :success
      end

      it 'returns response with correct number of projects' do
        expect(response.body).to have_json_size(2).at_path('projects')
      end

      it 'returns response with correct project (1)' do
        expect(response.body).to include_json(load_response('projects01.json')).at_path('projects')
      end

      it 'returns response with correct project (2)' do
        expect(response.body).to include_json(load_response('projects02.json')).at_path('projects')
      end
    end
  end
end
