# require 'spec_helper'
require 'mj_optimizer'
include MJOptimizer

describe "Type" do

  describe "#suhai_types" do
    it "should be Type::Manzu" do
      suhai_types = Type.suhai_types
      expect(suhai_types).to match_array([Type::Manzu, Type::Pinzu, Type::Souzu])
    end
    it "should be Type::Pinzu" do

    end
  end
end