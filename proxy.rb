require 'json'

require 'sinatra/base'
require 'sinatra/json'

require 'external_api'

class Proxy < Sinatra::Base
  set :cache, {}

  get '/cached_api/*' do
    cache_string = params.to_s
    path = params.delete('splat')[0]
    begin
      result = fetch_cache(cache_string, ttl_seconds: ExternalApi.cache_ttl_for_path(path)) do
        ExternalApi.make_query(path, params)
      end

      json JSON.parse(result)
    rescue HTTPClient::BadResponseError => http_error
      halt http_error.res.status
    end
  end

  def fetch_cache(key, ttl_seconds:)
    if Proxy.cache.has_key?(key) and Proxy.cache[key][:expiration] > Time.now
      puts "cache hit for #{key}"
      Proxy.cache[key][:value]
    else
      puts "cache miss for #{key}"
      result = yield
      Proxy.cache[key] = {
        expiration: Time.now + ttl_seconds,
        value: result
      }

      result
    end
  end
end
