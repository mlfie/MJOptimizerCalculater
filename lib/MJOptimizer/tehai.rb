module MJOptimizer
  class Tehai
    pai_list = []
    mentsu_list = []
    toitsu_list = []
    tatsu_list = []
    rest_pai_list = []

    def initialize(tehai)
      # 3文字ずつ区切ってhais(hai配列)に格納
      tehai.scan(/.{3}/).each do |hai|
        pai_list << Pai.new(hai)
      end
      # ソートしてから解析する
      parse(order_by_type_and_number(pai_list))
    end

    private

    # TODO 実装
    def order_by_type_and_number(pai_list)
      pai_list
    end

    def parse(rest_pai_list)

      # 14枚の中から確定しているメンツを探す
      # 4つある場合はリーチor上がり
      # 3つある場合はリーチの可能性あり

      rest_pai_list = parse_to_mentsu_list(rest_pai_list)
      # parse_to_list(rest_pai_list, result)
    end

    # 手牌から面子を探す
    # @param 手牌, 面子の配列
    # @return 手牌の残り, 面子の配列
    def parse_to_mentsu_list(temp_rest_pai_list, temp_mentsu_list = [])

      # TODO Refactor: 牌の種類ごとに処理を分ける

      # TODO 組み合わせの評価について検討
      # 面子の場合、数が多いほうが評価が高い
      # 対子・搭子をどう評価するか
      # 1.対子は雀頭として1つあったほうが評価が高い
      # ex. 対子1,搭子1 < 対子2
      # ex. 搭子2 < 対子1 ばら2

      # 面子 > 対子 > 搭子 で本当にいいのか？


      temp_rest_pai_list.each_with_index do |pai, i|
        # 1.順子？
        # 字牌でなく7より小さい
        if pai.type != "j" && pai.number >= 7
          syuntsu = [pai]
          if next_pai = temp_rest_pai_list.find{|p| p.same_with_direction?(pai.next)}
            syuntsu << next_pai
            if next_next_pai = temp_rest_pai_list.find{|p| p.same_with_direction?(pai.next.next)}
              syuntsu << next_next_pai

              # 面子確定
              temp_mentsu_list << Mentsu.new(syuntsu, "s")
              # 面子分を手牌から引く
              temp_rest_pai_list = temp_rest_pai_list - syuntsu
              # 再帰的に処理を実行
              parse_to_mentsu_list(temp_rest_pai_list, temp_mentsu_list)
            end
          end
        end

        # 2.刻子？
        # 同じ牌が3つ以上あるか
        kotsu = temp_rest_pai_list.select{|p| p.same_with_direction?(pai)}
        if kotsu.count >= 3
          # 槓子だったら1個減らす
          kotsu.shift if kotsu > 3
          # 面子確定
          temp_mentsu_list << Mentsu.new(kotsu, "k")
          # 面子分を手牌から引く
          temp_rest_pai_list = temp_rest_pai_list - kotsu
          # 再帰的に処理を実行
          parse_to_mentsu_list(temp_rest_pai_list, temp_mentsu_list)
        end

        # 3. 槓子？
        # TODO 実装

        # 4. もう面子はない

        # 手配が3以下になったら評価を終了する
        if temp_rest_pai_list.count <= 3
          # 最適な解析かどうか評価する（単純に面子の数だけ数える）
          if mentsu_list.count < temp_mentsu_list.count
            mentsu_list = temp_mentsu_list
            rest_pai_list = temp_rest_pai_list
            break
        end
      end
    end

  end
end