require 'spec_helper'
require 'dalli'
require 'representable'
require 'representable/json'
require 'representable/cache'

describe Representable::Cache do
  before do
    Representable::Cache.cache_engine = Dalli::Client.new('localhost:11211', :namespace => "Representable::CacheTest", :compress => true)
    Representable::Cache.cache.flush
  end

  let(:cache)  { Representable::Cache.cache }

  context "cache configuration" do
    it "should allow multiple cache_key" do
      @Brand = Class.new(Object) do
        include Representable::JSON
        include Representable::Cache
        attr_accessor :name, :label, :updated_at
        property :name
        property :label
        property :updated_at
        representable_cache :cache_key => [:name, :label]
      end
      brand = @Brand.new
      brand.name = "123"
      brand.label = "321"
      brand.representable_cache_key.should be_include("123-321")
    end
    it "should allow set cache_name" do
      @Brand = Class.new(Object) do
        include Representable::JSON
        include Representable::Cache
        attr_accessor :name, :label, :updated_at
        property :name
        property :label
        property :updated_at
        representable_cache :cache_key => :name, :cache_name => "cache_name_123"
      end
      brand = @Brand.new
      brand.name = "123"
      brand.label = "321"
      brand.representable_cache_key.should be_include("cache_name_123")
    end
  end

  context "simple representable" do
    before do
      @Brand = Class.new(Object) do
        include Representable::JSON
        include Representable::Cache
        attr_accessor :name, :label, :updated_at
        property :name
        property :label
        property :updated_at
        representable_cache :cache_key => :updated_at
      end
    end
    it "should write cache" do
      b = @Brand.new
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      hash = b.to_hash(:wrap => "brand")
      Representable::Cache.cache.get(b.representable_cache_key).should eq hash
    end

    it "to_json should use cache" do
      b = @Brand.new
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      Representable::Cache.cache.set(b.representable_cache_key, {"brand" => {"name"=>"b 2", "label"=>"l 2", "updated_at"=>"2013-08-04 08:55:50 +0800"}})
      json = b.to_json(:wrap => "brand")
      hash = MultiJson.decode(json)
      hash["brand"]["name"].should eq "b 2"
    end
  end

  context "simple DCI" do
    before do
      @Brand = Class.new do
        attr_accessor :name, :label, :updated_at
      end
      @BrandPresenter = Module.new do
        include Representable::JSON
        include Representable::Cache
        property :name
        property :label
        property :updated_at
        representable_cache :cache_key => :updated_at
      end
    end
    it "should write cache" do
      b = @Brand.new
      b.extend @BrandPresenter
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      hash = b.to_hash(:wrap => "brand")
      Representable::Cache.cache.get(b.representable_cache_key).should eq hash
    end

    it "to_json should use cache" do
      b = @Brand.new
      b.extend @BrandPresenter
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      Representable::Cache.cache.set(b.representable_cache_key, {"brand" => {"name"=>"b 2", "label"=>"l 2", "updated_at"=>"2013-08-04 08:55:50 +0800"}})
      json = b.to_json(:wrap => "brand")
      hash = MultiJson.decode(json)
      hash["brand"]["name"].should eq "b 2"
    end
  end

  context "extend DCI" do
    before do
      @Brand = Class.new do
        attr_accessor :name, :label, :updated_at
      end
      brandPresenter = Module.new do
        include Representable::JSON
        include Representable::Cache
        property :name
        property :updated_at
        representable_cache :cache_key => :updated_at
      end
      @BrandPresenter2 = Module.new do
        include Representable::JSON
        include Representable::Cache
        include brandPresenter
        property :label
      end
    end
    it "should write cache" do
      b = @Brand.new
      b.extend @BrandPresenter2
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      hash = b.to_hash(:wrap => "brand")
      Representable::Cache.cache.get(b.representable_cache_key).should eq hash
    end

    it "to_json should use cache" do
      b = @Brand.new
      b.extend @BrandPresenter2
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      Representable::Cache.cache.set(b.representable_cache_key, {"brand" => {"name"=>"b 2", "label"=>"l 2", "updated_at"=>"2013-08-04 08:55:50 +0800"}})
      json = b.to_json(:wrap => "brand")
      hash = MultiJson.decode(json)
      hash["brand"]["name"].should eq "b 2"
      hash["brand"]["label"].should eq "l 2"
    end
  end

  context "collections" do
    let(:product_class)  do
      Class.new do
        attr_accessor :name,:updated_at
      end
    end
    let(:product_presenter_class) do
      Module.new do
        include Representable::JSON
        include Representable::Cache
        property :name
        property :updated_at
        representable_cache :cache_key => :updated_at, :cache_name => "Product"
      end
    end

    before do
      product_class = product_class
      productPresenter = product_presenter_class
      @Brand = Class.new do
        attr_accessor :name, :label, :updated_at,:products
      end
      @BrandPresenter = Module.new do
        include Representable::JSON
        include Representable::Cache
        property :name
        property :label
        property :updated_at
        collection :products, :extend => productPresenter, :class => product_class
        representable_cache :cache_key => :updated_at, :cache_name => "Brand"
      end
    end

    it "should cache each collection object" do
      p1 = product_class.new
      p1.name = "p1"
      p1.updated_at = Time.now
      p2 = product_class.new
      p2.name = "p2"
      p2.updated_at = Time.now
      b = @Brand.new
      b.name = "b1"
      b.label = "l 1"
      b.products = [p1, p2]
      b.updated_at = Time.now

      b.extend @BrandPresenter
      hash = b.to_hash(:wrap => "brand")
      Representable::Cache.cache.get(b.representable_cache_key).should eq hash
      p1_hash = Representable::Cache.cache.get(p1.representable_cache_key)
      p1_hash["name"].should eq "p1"
    end

    it "should get collection object from cache" do
      p1 = product_class.new
      p1.name = "p1"
      p1.updated_at = Time.now
      p1.extend product_presenter_class

      b = @Brand.new
      b.name = "b1"
      b.label = "l 1"
      b.updated_at = Time.now
      b.extend @BrandPresenter
      b.products = [p1]
      Representable::Cache.cache.set(p1.representable_cache_key, {"name"=>"p 2","updated_at"=>"2013-08-04 08:55:50 +0800"})
      json = b.to_json(:wrap => "brand")
      hash = MultiJson.decode(json)
      hash["brand"]["products"].first["name"].should eq "p 2"
    end
  end

  describe "default_cache_key" do
    it "should use default cache_key" do
      Representable::Cache.default_cache_key = [:id, :name]
      @Brand = Class.new(Object) do
        include Representable::JSON
        include Representable::Cache
        attr_accessor :id, :name, :label, :updated_at
        property :id
        property :name
        property :label
        property :updated_at
      end
      brand = @Brand.new
      brand.id = "1"
      brand.name = "123"
      brand.label = "321"
      brand.representable_cache_key.should be_include("1-123")
    end
  end
end

