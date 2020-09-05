require 'httpclient'

require 'config'

class ExternalApi
  class << self
    def make_query(path, params)
      client = HTTPClient.new
      uri = URI.join(self.site, path)

      merged_params = queryize_params(self.base_params.merge(params))
      client.get_content(uri, merged_params)
    end

    def cache_ttl_for_path(path)
      ttl_key = Config.get('SPECIFIC_CACHE_TTL_SECONDS').keys.find{|k| path.start_with? k }
      if ttl_key.nil?
        Config.get('PROXY_CACHE_TTL_SECONDS')
      else
        Config.get('SPECIFIC_CACHE_TTL_SECONDS')[ttl_key]
      end
    end

    protected

    def base_params
      { 'api_key' => Config.get('PROXIED_API_KEY') }
    end

    def site
      Config.get('PROXIED_API_BASENAME')
    end

    def queryize_params(params)
      queryized_params = {}

      params.each do |k, v|
        decoded_key = URI.unescape(k)
        if v.is_a?(Hash)
          v.each do |subkey, subval|
            decoded_subvalue = URI.unescape(subval)
            queryized_subkey = "#{decoded_key}[#{subkey}]"
            queryized_params[queryized_subkey] = decoded_subvalue
          end
        else
          queryized_params[decoded_key] = URI.unescape(v)
        end
      end

      queryized_params
    end
  end
end
