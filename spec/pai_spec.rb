# require 'spec_helper'
require 'mj_optimizer'
include MJOptimizer

describe "Pai" do
  describe "#initialize" do

    context "with validation is true" do
      it "should have type, number, and naki" do
        pai = Pai.new("m1t")
        expect(pai.type).to eq Pai::PAI_TYPE_MANZU
        expect(pai.number).to eq 1
        expect(pai.naki).to eq false
      end
    end

    context "with validation is false" do
      it "raise Exception" do
        expect { Pai.new("") }.to raise_error
      end
    end
  end

  describe "#validate" do
    before :each do
      @pai = Pai.new("m1t")
    end

    context "when parameter valid" do
      it "has the suhai" do
        expect(@pai.send(:validate, "m1t")).to be true
        expect(@pai.send(:validate, "s5b")).to be true
        expect(@pai.send(:validate, "p9r")).to be true
      end
      it "has the jihai" do
        expect(@pai.send(:validate, "j1l")).to be true
      end
      it "has the urahai" do
        expect(@pai.send(:validate, "r0t")).to be true
      end
    end

    context "when parameter does not valid" do
      it "should be false" do
        expect(@pai.send(:validate, 1)).to be false
        expect(@pai.send(:validate, "12")).to be false
        expect(@pai.send(:validate, "123")).to be false
        expect(@pai.send(:validate, "m0t")).to be false
        expect(@pai.send(:validate, "j8t")).to be false
      end
    end
  end
end