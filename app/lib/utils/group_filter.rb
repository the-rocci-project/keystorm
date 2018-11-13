# frozen_string_literal: true

require 'yaml'

module Utils
  class GroupFilter
    FILTER_FILE_PATH = Rails.configuration.keystorm['filter_file'].freeze

    def initialize
      load_filterfile
    end

    def run!(groups)
      return groups unless @filterfile

      groups.each_with_object(groups) do |(key, val), hash|
        next unless @filterfile.key?(key)

        maped = @filterfile[key] || []
        hash[key] = val & maped
      end

      groups.delete_if { |_, val| val == [] }
    end

    private

    def load_filterfile
      if FILTER_FILE_PATH.present?
        @filterfile = YAML.safe_load(File.read(FILTER_FILE_PATH))
      else
        Rails.logger.warn('No filterfile given')
      end
    end
  end
end
