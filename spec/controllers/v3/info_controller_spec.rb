# frozen_string_literal: true

require 'rails_helper'

describe V3::InfoController do
  it_behaves_like 'describable' do
    let(:request_path) { v3_root_path }
  end
end
