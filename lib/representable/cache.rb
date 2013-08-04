require "representable/cache/version"
require 'representable/binding'
require 'benchmark'

module Representable::Cache
  def self.reset
    @default_cache_key = nil
    @engine = nil
    @enable = nil
    @logger = nil
  end
  def self.cache_engine=(engine)
    raise "engine doesn't response to get" if !engine.respond_to?(:get)
    raise "engine doesn't response to set" if !engine.respond_to?(:set)
    @engine = engine
  end

  def self.default_cache_key=(default_cache_key)
    @default_cache_key = default_cache_key
  end

  def self.default_cache_key
    @default_cache_key
  end

  def self.enable=(enable)
    @enable = enable
  end

  def self.enable
    return true if @enable.nil?
    @enable
  end

  def self.cache
    @engine
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  # include presenter in model
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend ClassMethods
    base.representable_cache_options[:cache_name] ||= base.name
  end

  module ClassMethods
    # DCI
    def extended(base)
      super(base)
      base.instance_eval do
        def representable_cache_options
          @representable_cache_options
        end
        def representable_cache_options=(options)
          @representable_cache_options = options
        end
      end

      base.representable_cache_options ||= self.representable_cache_options
    end

    # inherited representable
    def included(base)
      super(base)
      base.instance_eval do
        def representable_cache_options
          @representable_cache_options
        end
        def representable_cache_options=(options)
          @representable_cache_options = options
        end
      end
      base.representable_cache_options = self.representable_cache_options
      base.representable_cache_options[:cache_name] ||= base.name
    end

    def representable_cache(options={})
      @representable_cache_options = @representable_cache_options.merge options
    end

    def representable_cache_options
      @representable_cache_options ||={}
    end
  end
  module InstanceMethods
    def to_hash(options={}, binding_builder=Representable::Hash::PropertyBinding)
      return super(options, binding_builder) if !Representable::Cache.enable

      key = self.representable_cache_key

      if hash = Representable::Cache.cache.get(key)
        Representable::Cache.logger.debug "[Representable::Cache] cache hit: #{key}"
        return hash
      end

      time = Benchmark.realtime do
        hash = super(options, binding_builder)
      end
      Representable::Cache.cache.set(key, hash)
      Representable::Cache.logger.debug "[Representable::Cache] write cache: #{key} cost: #{time.to_f}"
      hash
    end

    def representable_cache_options
      @representable_cache_options || self.class.representable_cache_options
    end

    def representable_cache_key
      self.representable_cache_options[:cache_key] ||= Representable::Cache.default_cache_key
      self.representable_cache_options[:cache_version] ||= "v1"
      self.representable_cache_options[:cache_name] ||= self.class.name

      keys = [
        self.representable_cache_options[:cache_name],
        self.representable_cache_options[:cache_version]
      ]
      raise "cache_key or default_cache_key is required" if self.representable_cache_options[:cache_key].nil?
      if self.representable_cache_options[:cache_key].kind_of? Array
        keys += self.representable_cache_options[:cache_key].map do |k|
          self.send(k).to_s.gsub(/\s+/,'')
        end
      else
        keys << self.send(self.representable_cache_options[:cache_key]).to_s.gsub(/\s+/,'')
      end
      keys.compact.join("-")
    end
  end
end
