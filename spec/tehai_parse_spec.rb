# require 'spec_helper'
require 'mj_optimizer'
include MJOptimizer

describe "TehaiParser" do
  describe "#initialize" do
    # TehaiParserクラスのインスタンスが生成される
    it "creates the new TehaiParser instance" do
      tp = TehaiParser.new("m1tm2tm3ts4ts5ts6tp7tp8tp9tj1tj7t")
      expect(tp).to be_an_instance_of(TehaiParser)
    end
  end

  describe "#tehai_parse" do

  end

  describe "#normal_tehai_parse"

  describe "#normal_jihai_parse" do
    # 字牌が1枚もない場合
    context "when not found jihai" do
      # 面子を1つも返さない
      it "does not return mentsu" do
        tp = TehaiParser.new("m1tm1tm1tm1tm1tm1tm1tm1tm1tm1tm1tm1tm1tm1t")
        pai_list = tp.pai_list
        expect(tp.send(:normal_jihai_parse, pai_list).mentsu.size).to eq 0
      end
    end


    # 字牌が1枚の場合

    # 字牌が同一2枚の場合

    # 字牌が同一3枚の場合

    # 字牌が別の2枚である場合

    # 字牌が同一の2枚が2組ある場合

    # 字牌が同一の2枚が3組ある場合


  end
end