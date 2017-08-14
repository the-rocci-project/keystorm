module V3
  module Auth
    class GarbageController < ApplicationController
      def create
        render_error :bad_request, 'Invalid authentication method'
      end
    end
  end
end
