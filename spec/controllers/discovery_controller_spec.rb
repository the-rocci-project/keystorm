# frozen_string_literal: true

require 'rails_helper'

describe DiscoveryController do
  it_behaves_like 'describable' do
    let(:request_path) { root_path }
  end
end
