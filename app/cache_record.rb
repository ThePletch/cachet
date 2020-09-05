require 'dynamoid'

require 'dynamoid_config'

class CacheRecord
  include Dynamoid::Document

  field :cache_key, :string
  field :value, :string
  field :expiration, :integer  # epoch timestamp expressed in seconds

  table name: 'MbtaProxyCache', capacity_mode: :on_demand, key: :cache_key, timestamps: false
end
