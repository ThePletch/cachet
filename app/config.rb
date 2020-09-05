require 'yaml'

class Config
  class << self
    def get(key)
      @config ||= YAML.load_file('api_config.yml')

      if @config.has_key?(key)
        @config.fetch(key)
      else
        ENV[key]
      end
    end
  end
end
