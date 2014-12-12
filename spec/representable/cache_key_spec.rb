require 'spec_helper'
require 'representable'
require 'representable/cache/key'

describe Representable::Cache::Key do
  context "hash parameters" do
    let(:subject) { described_class.new('one'=>1,'two'=>2,'three'=>3) }

    it { puts subject; should eq 'one=[1]&three=[3]&two=[2]' }
  end
  
  context "array parameters" do
    let(:subject) { described_class.new([1, 2, 3]) }

    it { should eq '[1]&[2]&[3]' }
  end

  context "string parameters" do
    let(:subject) { described_class.new('onetwothree') }

    it { should eq '[onetwothree]' }
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
