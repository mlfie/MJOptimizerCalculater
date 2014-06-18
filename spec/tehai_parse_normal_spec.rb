# require 'spec_helper'
require 'mj_optimizer'
include MJOptimizer

describe "TehaiParseNormal" do
  before :each do
    @tp = TehaiParse.new
    @tehai = Tehai.new
  end

  # 未実装
  # .get_tehai_normal
  describe "#get_tehai_normal" do
    context "when single pai more than 5" do
      it "return @tehai" do
        # Tehai.stub_chain(:single_list, :count).and_return(5)
        # Array.stub_chain(:count).and_return(5)
        # pp @tehai.single_list.count # => 0
        # expect(@tp.get_tehai_normal(@tehai)).to eq @tehai
      end
    end
    context "when single pai less than 5"
  end

  # .parse_single
  describe "#parse_single" do
    # 字牌の単独牌がない
    context "without jihai" do
      it "does not have single" do
        @tehai.rest_pai_list = [
            Pai.new("j2t"),
            Pai.new("j2t"),
            Pai.new("j3t"),
            Pai.new("j3t"),
            Pai.new("j3t")
        ]
        tehai = @tp.parse_single(@tehai)
        expect(tehai.single_list.size).to eq 0
      end
    end

    # 字牌の単独牌がある
    context "with jihai" do
      it "has 1 single" do
        @tehai.rest_pai_list = [
          Pai.new("j1t"),
          Pai.new("j2t"),
          Pai.new("j2t"),
          Pai.new("j3t"),
          Pai.new("j3t"),
          Pai.new("j3t")
        ]
        tehai = @tp.parse_single(@tehai)
        expect(tehai.single_list.size).to eq 1
      end
    end

    # 数牌の単独牌がない
    context "without single kazuhai" do
      it "does not have single" do
        @tehai.rest_pai_list = [
            Pai.new("m1t"),
            Pai.new("m2t"),
            Pai.new("s3t"),
            Pai.new("s4t"),
            Pai.new("p6t"),
            Pai.new("p8t"),
            Pai.new("m9t"),
            Pai.new("m9t")
        ]
        tehai = @tp.parse_single(@tehai)
        expect(tehai.single_list.size).to eq 0
      end
    end

    # 数牌の単独牌がある
    context "with kazuhai single" do
      it "dees not have single" do
        @tehai.rest_pai_list = [
            Pai.new("m1t"),
            Pai.new("p2t"),
            Pai.new("s3t"),
            Pai.new("s6t"),
            Pai.new("s6t"),
            Pai.new("s7t"),
            Pai.new("s7t"),
            Pai.new("s7t")
        ]
        tehai = @tp.parse_single(@tehai)
        expect(tehai.single_list.size).to eq 3
      end
    end
  end

  # .parse_jihai
  describe "#parse_jihai" do
    it "has 1 mentsu, 1 toitsu" do
      @tehai.rest_pai_list = [
        Pai.new("j1t"),
        Pai.new("j1t"),
        Pai.new("j1t"),
        Pai.new("j2t"),
        Pai.new("j2t")
      ]
      tehai = @tp.parse_jihai(@tehai)
      expect(tehai.mentsu_list.size).to eq 1
      expect(tehai.toitsu_list.size).to eq 1
    end
  end

  # .parse_mentsu
  describe "#parse_mentsu" do
    it "has 1 mentsu" do
      @tehai.rest_pai_list = [
          Pai.new("m1t"),
          Pai.new("m1t"),
          Pai.new("m1t"),
          Pai.new("m2t"),
          Pai.new("m2t"),
          Pai.new("m3t")
      ]
      tehai = @tp.parse_mentsu(@tehai)
      expect(tehai.mentsu_list.size).to eq 1
    end
  end

  # .parse_syuntsu
  describe "#parse_syuntsu" do
    it "has 1 syuntsu" do
      @tehai.rest_pai_list = [
          Pai.new("m1t"),
          Pai.new("m1t"),
          Pai.new("m1t"),
          Pai.new("m2t"),
          Pai.new("m2t"),
          Pai.new("m2t"),
          Pai.new("m3t"),
          Pai.new("m3t"),
          Pai.new("m3t")
      ]
      tehai = @tp.parse_syuntsu(@tehai)
      expect(tehai.mentsu_list.size).to eq 3
    end
  end

  # .parse_ryanmenchan
  describe "#parse_ryanmenchan" do
    it "has 1 ryanmenchan" do
      @tehai.rest_pai_list = [
          Pai.new("m1t"),
          Pai.new("m2t"),
          Pai.new("m3t"),
          Pai.new("m4t")
      ]
      tehai = @tp.parse_ryanmenchan(@tehai)
      expect(tehai.tatsu_list.size).to eq 1
    end
  end

  # .parse_kanchan
  describe "#parse_kanchan" do
    it "has 1 kanchan" do
      @tehai.rest_pai_list = [
          Pai.new("m1t"),
          Pai.new("m3t"),
          Pai.new("m5t"),
          Pai.new("m7t"),
          Pai.new("m9t"),
          Pai.new("s1t"),
          Pai.new("s3t"),
          Pai.new("s5t"),
          Pai.new("s7t"),
          Pai.new("s9t")
      ]
      tehai = @tp.parse_kanchan(@tehai)
      expect(tehai.tatsu_list.size).to eq 4
    end
  end

  # .parse_penchan
  describe "#parse_penchan" do
    it "has 1 penchan" do
      @tehai.rest_pai_list = [
          Pai.new("m1t"),
          Pai.new("m2t"),
          Pai.new("m5t"),
          Pai.new("m8t"),
          Pai.new("m9t"),
          Pai.new("s1t"),
          Pai.new("s2t"),
          Pai.new("s5t"),
          Pai.new("s8t"),
          Pai.new("s9t")
      ]
      tehai = @tp.parse_penchan(@tehai)
      expect(tehai.tatsu_list.size).to eq 4
    end
  end

  # .parse_toitsu
  describe "#parse_toitsu" do
    it "has 1 toitsu" do
      @tehai.rest_pai_list = [
          Pai.new("m1t"),
          Pai.new("m1t"),
          Pai.new("s9t"),
          Pai.new("s9t")
      ]
      tehai = @tp.parse_toitsu(@tehai)
      expect(tehai.toitsu_list.size).to eq 2
    end
  end
end