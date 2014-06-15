module MJOptimizer
  module TehaiParseNormal

    #################################################################################
    # 通常形の上がりパターンで最もシャンテン数が低いものを判定する
    # @param tehai 解析前のTehaiオブジェクト
    # @return Tehai 解析後のTehaiオブジェクト
    #################################################################################
    def get_tehai_normal(tehai)

      # TODO: 手牌に槓子を含む場合
      # TODO: フーロを含む場合


      tehai.agari_type = Tehai::AGARU_TYPE_NORMAL

      # 牌リストを残牌リストへコピーする
      tehai.rest_pai_list = tehai.base_pai_list

      # Step.0 単独牌を先にsingle_listへ避けることで計算回数を減らす
      tehai = parse_single(tehai)

      # Step.0-1 もし単独牌が5枚以上であれば計算を終了する
      if tehai.single_list.count >= 5
        return tehai
      end

      # Step.1 字牌を解析する
      tehai = parse_jihai(tehai)

      # Step.2 数牌を解析する
      # 面子優先と順子優先を試して良い方を採用する
      # TODO: 本当は1試行ごとに優先順位を変えないと正確ではない
      tehai1 = parse_kazuhai(tehai, 1)  # 面子優先
      tehai2 = parse_kazuhai(tehai, 2)  # 順子優先

      tehai1.syanten_count > tehai2.syanten_count ? tehai2 : tehai1
    end

    #################################################################################
    # 通常上がり形の単独牌解析
    # @param tehai 現在の手牌オブジェクト
    # @return Tehai 単独牌リストと残り手牌を更新したTehaiオブジェクト
    #################################################################################
    def parse_single(tehai)
      # 字牌で単独牌を抽出
      jihai_list = get_jihai(tehai.rest_pai_list)
      jihai_list.each do |target_pai|
        if jihai_list.select{|pai| pai == target_pai}.count == 1
          tehai.single_list << target_pai
          tehai.rest_pai_list -= target_pai
        end
      end

      # 数牌で単独牌を抽出
      [Pai::Menzu, Pai::Pinzu, Pai::Souzu].each do |pai_type|
        # 重複しない かつ 2つ以内の牌がない
        manzu_list = get_selected_by_type(tehai.rest_pai_list, pai_type)
        manzu_list.each do |target_pai|
          selected_list = manzu_list.select do |pai|
            pai == target_pai ||
            pai.pai_type == target_pai.next_pai_type(1) ||
            pai.pai_type == target_pai.next_pai_type(2) ||
            pai.pai_type == target_pai.prev_pai_type(1) ||
            pai.pai_type == target_pai.prev_pai_type(2)
          end
          if selected_list.count == 1
            tehai.single_list << target_pai
            tehai.rest_pai_list -= target_pai
          end
        end
      end

      tehai
    end

    #################################################################################
    # 通常上がり形の字牌解析
    # @param tehai 現在の手牌オブジェクト
    # @return Tehai 面子構成と残り手牌を更新したTehaiオブジェクト
    #################################################################################
    def parse_jihai(tehai)
      # 残り手牌から字牌だけを取り出す
      jihai_list = get_jihai(tehai.rest_pai_list)
      # 字牌が1枚もなかったら終了
      return tehai if jihai_list.count == 0

      # Step.1 最初の1枚と同じ牌が何枚あるか
      selected_pai_list = tehai.rest_pai_list.select{|pai| pai == jihai_list[0]}

      case selected_pai_list.count
        # Step.1-1 4枚ある場合
        when 4
          # TODO: 槓子かどうかの判定
          # 今はとりあえず面子+1枚と判定する
          tehai.single_list << selected_pai_list.pop
          tehai.mentsu_list << Mentsu.new(selected_pai_list)
        # Step.1-2 3枚ある場合
        when 3
          tehai.mentsu_list << Mentsu.new(selected_pai_list)
        # Step.1-3 2枚ある場合
        when 2
          tehai.toitsu_list << Toitsu.new(selected_pai_list)
        # Step.1-4 1枚ある場合
        when 1
          tehai.single_list << selected_pai_list.pop
        else
          raise Exception
      end

      # 見つかった牌を残りの手牌から引く
      tehai.rest_pai_list = tehai.rest_pai_list - selected_pai_list

      # 再帰的に処理を続ける
      parse_jihai(tehai)
    end

    #################################################################################
    # 通常上がり形の数牌解析
    # @param tehai 現在の手牌オブジェクト
    # @param priority 現在の手牌オブジェクト
    # @return Tehai 面子構成と残り手牌を更新したTehaiオブジェクト
    #################################################################################
    def parse_kazuhai(tehai, priority)
      if priority == 1
        tehai = parse_mentsu(tehai)
        tehai = parse_syuntsu(tehai)
      else
        tehai = parse_syuntsu(tehai)
        tehai = parse_mentsu(tehai)
      end
      tehai = parse_ryanmenchan(tehai)
      tehai = parse_kanchan(tehai)
      tehai = parse_penchan(tehai)
      tehai = parse_toitsu(tehai)

      # 残牌数が0になっていれば正常終了
      if tehai.rest_pai_list.count == 0
        tehai.is_parsed = true
      end

      tehai
    end

    def parse_mentsu(tehai)
      tehai.rest_pai_list.each do |target_pai|
        next if target_pai.nil?
        selected_pai_list = tehai.rest_pai_list.select{|pai| pai == target_pai}
        case selected_pai_list.count
          when 4
            # TODO: 槓子かどうかの判定
            # 今はとりあえず面子+1枚と判定する
            tehai.single_list << selected_pai_list.pop
            tehai.mentsu_list << Mentsu.new(selected_pai_list, "t")
            tehai.rest_pai_list -= selected_pai_list
          when 3
            tehai.mentsu_list << Mentsu.new(selected_pai_list, "t")
            tehai.rest_pai_list -= selected_pai_list
        end
      end
    end

    def parse_syuntsu(tehai)
      tehai.rest_pai_list.each do |target_pai|
        next if target_pai.nil?
        next1 = tehai.rest_pai_list.find{|pai| pai == target_pai.next(1)}
        next2 = tehai.rest_pai_list.find{|pai| pai == target_pai.next(2)}
        if next1 && next2
          tehai.mentsu_list << Mentsu.new([target_pai, next1, next2], "s")
          tehai.rest_pai_list -= [target_pai, next1, next2]
        end
      end
    end

    def parse_ryanmenchan(tehai)
      tehai.rest_pai_list.each do |target_pai|
        next if target_pai.nil?
        next if target_pai.number == 1 || target_pai.number == 8
        next1 = tehai.rest_pai_list.find{|pai| pai == target_pai.next(1)}
        if next1
          tehai.tatsu_list << Tatsu.new([target_pai, next1], "r")
          tehai.rest_pai_list -= [target_pai, next1]
        end
      end
    end

    def parse_kanchan(tehai)
      tehai.rest_pai_list.each do |target_pai|
        next if target_pai.nil?
        next if target_pai.number > 7
        next2 = tehai.rest_pai_list.find{|pai| pai == target_pai.next(2)}
        if next2
          tehai.tatsu_list << Tatus.new([target_pai, next1, next2], "k")
          tehai.rest_pai_list -= [target_pai, next1, next2]
        end
      end
    end

    def parse_penchan(tehai)
      tehai.rest_pai_list.each do |target_pai|
        next if target_pai.nil?
        next unless target_pai.number == 1 || target_pai.number == 8
        next1 = tehai.rest_pai_list.find{|pai| pai == target_pai.next(1)}
        if next1
          tehai.tatsu_list << Tatsu.new([target_pai, next1], "p")
          tehai.rest_pai_list -= [target_pai, next1]
        end
      end
    end

    def parse_toitsu(tehai)
      tehai.rest_pai_list.each do |target_pai|
        next if target_pai.nil?
        selected_pai_list = tehai.rest_pai_list.select{|pai| pai == target_pai}
        case selected_pai_list.count
          when 2
            tehai.toitsu_list << Toitsu.new(selected_pai_list)
            tehai.rest_pai_list -= selected_pai_list
        end
      end
    end
  end
end