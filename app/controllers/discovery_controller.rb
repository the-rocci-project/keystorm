class DiscoveryController < ApplicationController
  include Describable

  def index
    respond_with api_description
  end
end
