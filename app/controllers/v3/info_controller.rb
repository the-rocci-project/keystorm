# frozen_string_literal: true

module V3
  class InfoController < ApplicationController
    include Describable

    def index
      respond_with api_description
    end
  end
end
