# frozen_string_literal: true

require 'application_responder'

class ApplicationController < ActionController::API
  include Acceptable
  include Errorable
  include Authenticable
end
