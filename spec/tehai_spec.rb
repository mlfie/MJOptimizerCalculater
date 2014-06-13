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
    context "when agari_type is AGARU_TYPE_NORMAL"

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
      it "has 13 yaochu and 1 janto"

      # 全部ヤオチュウ牌（ダブりあり）
      it "has 13 yaochu of duplicated"

      # 全部中張牌
      it "has 13 chuchan pai" do
        fixtures :1

        @pai = Pai.new("m5t")
        @tehai.single_list = [@pai] * 14
        expect(@tehai.shanten_count).to eq 14
        expect(@tehai.agari?).to be false
      end
    end
  end
end
