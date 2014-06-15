module MJOptimizer
  module TehaiParseChitoitsu

    # 手牌を元に、七対子へのシャンテン数を求める
    def get_tehai_chitoitsu(tehai)
      # 残り枚数が1枚以下
      if tehai.rest_pai_list.count < 2
        # 残り枚数が1枚の場合、最後の1枚をSingleListにセット
        if tehai.rest_pai_list.count == 1
          single_pai = tehai.rest_pai_list[0]
          tehai.single_list << single_pai
          tehai.rest_pai_list -= single_pai
        end

        # あがり形を指定
        tehai.agari_type = Tehai::AGARU_TYPE_CHITOITSU
        tehai.is_parsed = true
        return tehai
      end

      # 先頭の1つの牌と同じ牌を取得する
      current_pai_list = tehai.rest_pai_list.select{|pai| tehai.rest_pai_list[0] == pai}
      case pai_list.count
        when 1
          tehai.single_list << current_pai_list[0]
        when 2
          tehai.toitsu_list << Toitsu.new(current_pai_list)
        when 3
          tehai.toitsu_list << Toitsu.new(current_pai_list[0..1])
          tehai.single_list << current_pai_list[2]
        when 4
          tehai.toitsu_list << Toitsu.new(current_pai_list[0..1])
          tehai.single_list << current_pai_list[2..3]
        else
          raise Exception
      end
      tehai.rest_pai_list -= current_pai_list

      # 再帰処理
      get_tehai_when_chitoitsu(tehai)
    end
  end
end