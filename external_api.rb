require 'httpclient'
require 'yaml'

class ExternalApi
  class << self
    def config(key)
      @config ||= YAML.load_file('api_config.yml')

      @config.fetch(key)
    end

    def base_params
      {
          api_key: self.config('proxied_api_key')
      }
    end

    def site
      self.config('proxied_api_basename')
    end

    def make_query(path, params)
      client = HTTPClient.new
      uri = URI.join(self.site, path)

      params = self.base_params.merge(params)

      client.get_content(uri, params)  # we'll worry about error handling later
    end

    def cache_ttl_for_path(path)
      ttl_key = self.config('specific_cache_ttl_seconds').keys.find{|k| k.start_with? path }
      if ttl_key.nil?
        self.config('proxy_cache_ttl_seconds')
      else
        self.config('specific_cache_ttl_seconds')[ttl_key]
      end
    end
  end
end
