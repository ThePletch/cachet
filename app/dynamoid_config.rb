require 'dynamoid'

require 'config'

Dynamoid.configure do |config|
  config.region = Config.get('AWS_REGION')
  config.namespace = nil
end
