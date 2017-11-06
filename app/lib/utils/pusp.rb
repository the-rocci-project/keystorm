require 'yaml'

module Utils
  class Pusp
    PUSP_FILE_PATH = Rails.configuration.keystorm['voms']['pusp_file'].freeze

    attr_reader :puspfile

    def initialize
      load_pusp
    end

    def allowed?(dn)
      return false unless puspfile

      puspfile.include?(dn)
    end

    private

    def load_pusp
      if PUSP_FILE_PATH.present?
        @puspfile = YAML.safe_load(File.read(PUSP_FILE_PATH))
      else
        Rails.logger.warn('No puspfile given')
      end
    end
  end
end
