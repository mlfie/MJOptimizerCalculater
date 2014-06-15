require 'helpers'
require 'mj_optimizer'
include MJOptimizer

RSpec.configure do |c|
  c.include Helpers
end

describe "Tehai" do
  describe "#initialize" do
    # Tehaiクラスのインスタンスが生成される
    it "creates the new Tehai instance" do
      tehai = Tehai.new
      expect(tehai).to be_an_instance_of(Tehai)
    end
  end

  describe "#<<" do
    before :each do
      @tehai = Tehai.new
    end

    # パラメータがPaiオブジェクトの場合
    context "with Pai object" do
      # pai_listの要素数が1つ増える
      it "increments the pai_list count" do
        expect(@tehai.pai_list.size).to be 0
        @tehai << Pai.new("m1t")
        expect(@tehai.pai_list.size).to be 1
      end
    end

    # パラメータがPaiオブジェクトでない場合
    context "without Pai object" do
      # pai_listの要素数が1つ増える
      it "increments the pai_list count" do
        expect(@tehai.pai_list.size).to be 0
        @tehai << String.new("m1t")
        expect(@tehai.pai_list.size).to be 0
      end
    end
  end

  describe "#shanten_count" do
    before :each do
      @tehai = Tehai.new
    end

    # agari_typeがnil（未解析）の場合
    context "when agari_type is nil" do
      # -1を返す
      it "returns nil" do
        expect(@tehai.shanten_count).to eq nil
      end
    end

    # agari_typeがAGARU_TYPE_NORMALの場合
    context "when agari_type is AGARU_TYPE_NORMAL" do

      before :each do
        @tehai.agari_type = Tehai::AGARU_TYPE_NORMAL
      end

      # 面子*4、対子*1 あがり
      it "has 4 mentsu and 1 janto" do
        @tehai.toitsu_list = [Toitsu.new([Pai.new("m1t"),Pai.new("m1t")])]
        @tehai.mentsu_list = [
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU),
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU),
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU),
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU)
        ]
        expect(@tehai.shanten_count).to eq 0
        expect(@tehai.agari?).to be true
      end
      # 面子*3、対子*2 1シャンテン
      it "has 3 mentsu and 1 toitsu 1 janto" do
        @tehai.toitsu_list = [
          Toitsu.new([Pai.new("m1t"),Pai.new("m1t")]),
          Toitsu.new([Pai.new("m1t"),Pai.new("m1t")])
        ]
        @tehai.mentsu_list = [
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU),
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU),
          Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU)
        ]
        expect(@tehai.shanten_count).to eq 1
        expect(@tehai.agari?).to be false
      end

      # 面子*2、対子*3 2シャンテン
      it "has 2 mentsu and 2 toitsu 1 janto" do
        @tehai.toitsu_list = [
            Toitsu.new([Pai.new("m1t"),Pai.new("m1t")]),
            Toitsu.new([Pai.new("m1t"),Pai.new("m1t")]),
            Toitsu.new([Pai.new("m1t"),Pai.new("m1t")])
        ]
        @tehai.mentsu_list = [
            Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU),
            Mentsu.new([Pai.new("m1t"),Pai.new("m1t"),Pai.new("m1t")],Mentsu::MENTSU_TYPE_SHUNTSU)
        ]
        expect(@tehai.shanten_count).to eq 2
        expect(@tehai.agari?).to be false
      end

      # 面子*1、対子*5 3シャンテン
      it "1 mentsu and 4 toitsu 1 janto"

      # 面子*0、ターツ*6 5シャンテン

    end

    # agari_typeがAGARU_TYPE_CHITOITSUの場合
    context "when agari_type is AGARU_TYPE_CHITOITSU" do
      before do
        @pai = Pai.new("m1t")
        @toitsu = Toitsu.new([@pai, @pai])
      end

      before :each do
        @tehai.agari_type = Tehai::AGARU_TYPE_CHITOITSU
      end

      # 対子が7組の場合
      it "has just 7 toitsu" do
        @tehai.toitsu_list = [@toitsu] * 7
        expect(@tehai.shanten_count).to eq 0
        expect(@tehai.agari?).to be true
      end

      # 対子なし
      it "has just 14 single pai" do
        @tehai.single_list = [@pai] * 14
        expect(@tehai.shanten_count).to eq 7
        expect(@tehai.agari?).to be false
      end
    end

    # agari_typeがAGARU_TYPE_KOKUSHIMUSOの場合
    context "when agari_type is AGARU_TYPE_KOKUSHIMUSO" do

      before :each do
        @tehai.agari_type = Tehai::AGARU_TYPE_KOKUSHIMUSO
      end

      # 全部ヤオチュウ牌（ダブりなし、雀頭あり）
      it "has 13 yaochu and 1 janto" do
        @tehai.toitsu_list = [Toitsu.new([Pai.new("m1t"),Pai.new("m1t")])]
        @tehai.single_list = [
          Pai.new("m9t"),
          Pai.new("s1t"),
          Pai.new("s9t"),
          Pai.new("p1t"),
          Pai.new("p9t"),
          Pai.new("j1t"),
          Pai.new("j2t"),
          Pai.new("j3t"),
          Pai.new("j4t"),
          Pai.new("j5t"),
          Pai.new("j6t"),
          Pai.new("j7t")]
        expect(@tehai.shanten_count).to eq 0
        expect(@tehai.agari?).to be true
      end

      # 全部ヤオチュウ牌（ダブりあり）
      it "has 13 yaochu of duplicated" do
        @tehai.toitsu_list = [
          Toitsu.new([Pai.new("m1t"),Pai.new("m1t")]),
          Toitsu.new([Pai.new("m9t"),Pai.new("m9t")])
        ]
        @tehai.single_list = [
          Pai.new("s9t"),
          Pai.new("p1t"),
          Pai.new("p9t"),
          Pai.new("j1t"),
          Pai.new("j2t"),
          Pai.new("j3t"),
          Pai.new("j4t"),
          Pai.new("j5t"),
          Pai.new("j6t"),
          Pai.new("j7t")]
        expect(@tehai.shanten_count).to eq 1
        expect(@tehai.agari?).to be false
      end

      # 全部中張牌
      it "has 13 chuchan pai" do
        @pai = Pai.new("m5t")
        @tehai.single_list = [@pai] * 14
        expect(@tehai.shanten_count).to eq 14
        expect(@tehai.agari?).to be false
      end
    end
  end
end
