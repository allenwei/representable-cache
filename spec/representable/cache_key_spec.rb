require 'spec_helper'
require 'representable'
require 'representable/cache/key'

describe Representable::Cache::Key do
  context "objects responding to #cache_key" do
    let(:an_object) { double('an object', cache_key: 'a_cache_key') }
    let(:subject) { described_class.new(an_object) }

    it { should eq "[a_cache_key]" }
  end

  context "hash parameters" do
    let(:subject) { described_class.new('one'=>1,'two'=>2,'three'=>3) }

    it { should eq 'one=[1]&three=[3]&two=[2]' }
  end
  
  context "array parameters" do
    let(:subject) { described_class.new([1, 2, 3]) }

    it { should eq '[1]&[2]&[3]' }
  end

  context "string parameters" do
    let(:subject) { described_class.new('onetwothree') }

    it { should eq '[onetwothree]' }
  end

  context "nil parameters" do
    context "single values" do
      let(:subject) { described_class.new(nil) }

      it { should eq '[nil]' }
    end

    context "arrays" do
      let(:subject) { described_class.new([nil, nil]) }

      it { should eq '[nil]&[nil]' }
    end

    context "hashes" do
      let(:subject) { described_class.new('nilvalue' => nil) }

      it { should eq 'nilvalue=[nil]' }
    end
  end

  context "nested parameters" do
    context "sub-hash" do
      let(:subject) { described_class.new('one' => 1, 'two' => 2, 'three' => {'name' => 'three', 'value' => 3}) }

      it { should eq 'one=[1]&three=name=[three]&value=[3]&two=[2]' }
    end

    context "sub-array" do
      let(:subject) { described_class.new('one' => 1, 'two' => 2, 'three' => [1,2,3]) }

      it { should eq 'one=[1]&three=[1]&[2]&[3]&two=[2]' }
    end
  end
end
