$:.unshift(File.expand_path('../app', __FILE__))

require 'proxy'

run Proxy.new
