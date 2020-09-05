require 'httpclient'
require 'yaml'

class ExternalApi
  class << self
    def make_query(path, params)
      client = HTTPClient.new
      uri = URI.join(self.site, path)

      merged_params = queryize_params(self.base_params.merge(params))
      client.get_content(uri, merged_params)
    end

    def cache_ttl_for_path(path)
      ttl_key = self.config('specific_cache_ttl_seconds').keys.find{|k| k.start_with? path }
      if ttl_key.nil?
        self.config('proxy_cache_ttl_seconds')
      else
        self.config('specific_cache_ttl_seconds')[ttl_key]
      end
    end

    protected

    def config(key)
      @config ||= YAML.load_file('api_config.yml')

      @config.fetch(key)
    end

    def base_params
      { 'api_key' => self.config('proxied_api_key') }
    end

    def site
      self.config('proxied_api_basename')
    end

    def queryize_params(params)
      queryized_params = {}

      params.each do |k, v|
        if v.is_a?(Hash)
          v.each do |subkey, subval|
            queryized_subkey = "#{k}[#{subkey}]"
            queryized_params[queryized_subkey] = subval
          end
        else
          queryized_params[k] = v
        end
      end

      queryized_params
    end
  end
end
