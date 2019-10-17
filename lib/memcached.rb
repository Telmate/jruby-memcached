require 'java'
require 'memcached/version'
require File.expand_path('../../target/spymemcached-ext-0.0.1.jar', __FILE__)
require 'com/openfeint/memcached/memcached'

class Memcached::Rails
  attr_reader :logger

  def logger=(logger)
    @logger = logger
  end
end

class Memcached::RailsPooled
  def initialize(options = {})
    @pool_size = options.delete(:pool).to_i
    @pool_size = 1 if @pool_size < 1
    @pool_clients  = []
    @pool_size.times { @pool_clients << Memcached::Rails.new(options) }
  end

  def __get_client__
    @pool_clients[Thread.current.object_id % @pool_size]
  end

  def method_missing(m, *args, &block)
    __get_client__.__send__(m, *args, &block)
  end
end