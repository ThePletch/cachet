require 'json'

require 'sinatra/base'
require 'sinatra/json'

require 'external_api'
require 'cache_record'
require 'config'

class Proxy < Sinatra::Base
  set :default_headers, {
    'Access-Control-Allow-Origin' => '*',
    'Content-Type' => 'application/json',
  }

  get '/cached_api/*' do
    cache_string = params.to_s
    path = params.delete('splat')[0]
    begin
      result = fetch_cache(cache_string, ttl_seconds: ExternalApi.cache_ttl_for_path(path)) do
        ExternalApi.make_query(path, params)
      end

      [200, Proxy.default_headers, result]
    rescue HTTPClient::BadResponseError => http_error
      halt http_error.res.status
    end
  end

  def record_cache_value(key, value, ttl_seconds:)
    begin
      begin
        CacheRecord.update(key, value: value, expiration: Time.now.to_i + ttl_seconds)
      rescue Dynamoid::Errors::RecordNotFound
        CacheRecord.create(cache_key: key, value: value, expiration: Time.now.to_i + ttl_seconds)
      end

      value
    rescue Dynamoid::Errors::StaleObjectError
      # This will happen if another process updates the cache while we're doing it. This is fine,
      # since we're caching a response to the same API endpoint and the response will presumably be the same,
      # so we don't need to retry. We'll just let the other update suffice.
      value
    end
  end

  def fetch_cache(key, ttl_seconds:)
    begin
      cache_record = CacheRecord.find(key)

      # finding a stale record is the same as not finding one
      raise Dynamoid::Errors::RecordNotFound if cache_record.expiration < Time.now.to_i

      cache_record.value
    rescue Dynamoid::Errors::RecordNotFound
      new_value = yield
      self.record_cache_value(key, new_value, ttl_seconds: ttl_seconds)
    end
  end
end
