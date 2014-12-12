require 'spec_helper'
require 'representable/test_cache'

describe Representable::TestCache do
  let(:hash){ {'key' => 'value'} }
  subject{ described_class.new hash }

  describe "#get" do
    it "returns a value" do
      subject.get('key').should eq 'value'
    end
  end
  describe "#set" do
    it "sets a value" do
      subject.set('new_key', 'new_value')
      hash['new_key'].should eq 'new_value'
    end
  end
end

