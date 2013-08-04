require 'spec_helper'
require 'dalli'
require 'representable/cache'

describe "configuration" do
  context "cache engine" do
    it "should be able to set cache engine" do
      Representable::Cache.cache_engine = Dalli::Client.new('localhost:11211', :namespace => "app_v1", :compress => true)
      Representable::Cache.cache.should be_kind_of Dalli::Client
    end

    it "should raise error if engine not resposne to get/set" do
      expect {
        Representable::Cache.cache_engine =  "123"
      }.to raise_error RuntimeError

    end
  end

  context "cache" do
    it "should be able to set and get from cache" do
      Representable::Cache.cache_engine = Dalli::Client.new('localhost:11211', :namespace => "Representable::CacheTest", :compress => true)
      Representable::Cache.cache.set("test_set", "test_set")
      Representable::Cache.cache.get("test_set").should eq "test_set"
    end
  end

  context "default_cache_key" do
    it "should support default cache key" do
      Representable::Cache.default_cache_key = [:id, :updated_at]
      Representable::Cache.default_cache_key.should eq [:id, :updated_at]
    end
  end

  context "enable" do
    it "should support enable or disable it" do
      Representable::Cache.enable = false
      Representable::Cache.enable.should be_false
      Representable::Cache.enable = true
      Representable::Cache.enable.should be_true
    end
  end
end
