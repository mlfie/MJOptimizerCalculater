require "mj_optimizer/tehai_parse_chitoitsu"
require "mj_optimizer/tehai_parse_kokushi"
require "mj_optimizer/tehai_parse_normal"

module MJOptimizer

  # 手配を解析して面子、対子、などに分解するクラス
  # 本名：SutehaiSelector
  class SutehaiSelector
    include TehaiParseChitoitsu
    include TehaiParseKokushi
    include TehaiParseNormal

    def initialize
      @tehai = Tehai.new
    end

    # 本番は、Paiのリストが送られてくる
    def select(tehai_list)
      # 3文字ずつ区切ってPaiクラスを作り、Tehaiのpai_listに格納
      tehai_list.scan(/.{3}/).each do |pai|
        @tehai << Pai.new(pai)
      end

      if select_main
        # 本番は、SutehaiSelectResultを返す。それは現在のTehaiクラス
        @tehai
      else
        nil
      end
    end

    private

    #################################################################################
    # 解析処理メイン
    # 国士無双、七対子、通常形の3つの上がりパターンを検証し、最もシャンテン数が低いものを採用する
    # 各パターンの計測で、成功時はTehaiオブジェクトを、失敗時はnilを返す
    # @return Bool
    #################################################################################
    def select_main

      # Step.1 国士無双の検証
      kokushi_tehai = get_tehai_kokushi(@tehai.dup)

      # Step.2 七対子の検証
      chitoitsu_tehai = get_tehai_chitoitsu(@tehai.dup)

      # Step.3 通常形の検証
      normal_tehai = get_tehai_normal(@tehai.dup)

      # Step.4 一番シャンテン数が低いものを選択する
      # 同率の場合は、通常形＞七対子＞国士無双とする
      if normal_tehai.syanten_count <= chitoitsu_tehai.syanten_count &&
         normal_tehai.syanten_count <= kokushi_tehai.syanten_count
        normal_tehai
      elsif chitoitsu_tehai.syanten_count <= kokushi_tehai.syanten_count
        chitoitsu_tehai
      else
        kokushi_tehai
      end
    end


    # 手牌リストから指定したタイプの牌だけを選択する
    def get_selected_by_type(tehai_list, pai_type)
      case pai_type
        when Type::Menzu
          get_manzu(tehai_list)
        when Type::Pinzu
          get_pinzu(tehai_list)
        when Type::Souzu
          get_souzu(tehai_list)
        when Type::Jihai
          get_jihai(tehai_list)
        else
          []
      end
    end

    # 手牌リストから萬子だけを選択する
    def get_manzu(tehai_list)
      tehai_list.select {|pai| pai.manzu? }
    end

    # 手牌リストから筒子だけを選択する
    def get_pinzu(tehai_list)
      tehai_list.select {|pai| pai.pinzu? }
    end

    # 手牌リストから索子だけを選択する
    def get_souzu(tehai_list)
      tehai_list.select {|pai| pai.souzu? }
    end

    # 手牌リストから数牌だけを選択する
    def get_kazuhai(tehai_list)
      get_manzu(tehai_list) + get_pinzu(tehai_list) + get_souzu(tehai_list)
    end

    # 手牌リストから字牌だけを選択する
    def get_jihai(tehai_list)
      tehai_list.select {|pai| pai.jihai? }
    end

  end
end