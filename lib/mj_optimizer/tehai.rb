module MJOptimizer

  # 手配解析後のデータ構造クラス
  class Tehai
    AGARU_TYPE_NORMAL = "nomal"
    AGARU_TYPE_CHITOITSU = "chitoitsu"
    AGARU_TYPE_KOKUSHIMUSO = "kokusimuso"

    attr_accessor :pai_list,      # 解析前の手牌リスト(Paiのリスト)
                  :rest_pai_list, # 未解析の手牌リスト
                  :mentsu_list,   # 面子のリスト
                  :toitsu_list,   # 対子のリスト
                  :tatsu_list,    # 搭子のリスト
                  :single_list,   # 組み合わせのない牌のリスト
                  :agari_type,    # 上がり形
                  :shanten_count  # シャンテン数

    def initialize
      self.pai_list = []
      self.rest_pai_list = []
      self.mentsu_list = []
      self.toitsu_list = []
      self.tatsu_list = []
      self.single_list = []
      self.agari_type = nil
      self.shanten_count = nil
      self.is_agari = nil
    end
  end

  # 手配を解析して面子、対子、などに分解するクラス
  class TehaiParser
    attr_accessor :tehai

    def initialize(tehai_list)
      self.tehai = Tehai.new

      # 3文字ずつ区切ってPaiクラスを作り、Tehaiのpai_listに格納
      tehai_list.scan(/.{3}/).each do |pai|
        self.tehai.pai_list << Pai.new(pai)
      end

      # 解析開始
      self.parse_main
    end

    private

    # 解析処理メイン
    def parse_main

      # 国士無双の検証
      kokushi_tehai = nil

      # 七対子の検証
      chitoitsu_tehai = nil

      # 通常形の検証

      # 14枚の中から確定しているメンツを探す
      # 4つある場合はリーチor上がり
      # 3つある場合はリーチの可能性あり

      normal_tehai = normal_parse
      # parse_to_list(rest_pai_list, result)

      # 一番シャンテン数が低いものを選択する
      self.tehai = normal_tehai
    end

    # 手牌から面子を探す
    # @param 手牌, 面子の配列
    # @return 手牌の残り, 面子の配列
    def normal_parse
      result = self.tehai.dup
      result.rest_pai_list = result.pai_list

      # Refactor: 牌の種類ごとに処理を分ける

      # 字牌を解析する
      result = normal_jihai_parse(result)

      # 数牌を解析する
      result = normal_kazuhai_parse(result)

      # Refactor: 槓子の解析方法
      # 暗槓、明槓してたら槓子、そうでなければ面子

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

        # # 2.刻子？
        # # 同じ牌が3つ以上あるか
        # kotsu = temp_rest_pai_list.select{|p| p.same_with_direction?(pai)}
        # if kotsu.count >= 3
        #   # 槓子だったら1個減らす
        #   kotsu.shift if kotsu > 3
        #   # 面子確定
        #   temp_mentsu_list << Mentsu.new(kotsu, "k")
        #   # 面子分を手牌から引く
        #   temp_rest_pai_list = temp_rest_pai_list - kotsu
        #   # 再帰的に処理を実行
        #   parse_to_mentsu_list(temp_rest_pai_list, temp_mentsu_list)
        # end

        # 3. 槓子？
        # Refactor: 実装

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

    # 通常上がり形の字牌解析
    def normal_jihai_parse(result)

      pai_count = {}
      jihai_pai_list = get_jihai(result.rest_pai_list)

      # 未解析の手牌リストから字牌リストを引く
      result.rest_pai_list = result.rest_pai_list - jihai_pai_list

      # 1枚ずつハッシュにカウントを入れていく
      jihai_pai_list.each do |pai|
        pai_count[pai.name_with_direction].push(pai)
      end

      # 4〜3枚あれば面子、2枚あれば対子、1枚ならバラ
      pai_count.each do |pai|
        case pai.count
          when 4
            # Refactor: 槓子かどうか判定する処理
            if false
              # 暗槓・明槓だったら槓子

              # 未実装

            else
              # そうでなかったら面子+1枚
              result.mentsu_list << Mentsu.new(pai[0], pai[1], pai[2])
              result.single_list << pai[3]
            end
          when 3
            result.mentsu_list << Mentsu.new(pai)
          when 2
            result.toitsu_list << Toitsu.new(pai)
          when 1
            result.single_list << pai[0]
          else
            raise Exception
        end
      end

      return result
    end

    def normal_kazuhai_parse(result)

      result.rest_pai_list.each do |pai|
        # 刻子があるか？
        # あれば面子を作って、手牌から面子分を引いて再帰処理
        kotsu = result.rest_pai_list.select{|p| p.same_with_direction?(pai)}

        if kotsu.count >= 3
          # Refactor: 槓子


          # 槓子でない4枚だったら1枚減らす
          kotsu.shift if kotsu > 3

          # 面子確定
          result.mentsu_list << Mentsu.new(kotsu, "k")

          # 面子分を手牌から引く
          result.rest_pai_list = result.rest_pai_list - kotsu

          # 再帰的に処理を実行
          normal_kazuhai_parse(result)
        end

        # 順子があるか？
        # あれば面子を作って、手牌から面子分を引いて再帰処理
        if pai.number <= 7
          next_pai = temp_rest_pai_list.find{|p| p.same_with_direction?(pai.next)}
          if next_pai
            next_next_pai = temp_rest_pai_list.find{|p| p.same_with_direction?(pai.next.next)}
            if next_next_pai
              syuntsu << pai << next_pai << next_next_pai
              # 面子確定
              result.mentsu_list  << Mentsu.new(syuntsu, "s")
              # 面子分を手牌から引く
              result.rest_pai_list = result.rest_pai_list - syuntsu
              # 再帰的に処理を実行
              normal_kazuhai_parse(result)
            end
          end
        end
      end

      result.single_list << result.rest_pai_list
      result.rest_pai_list = []

      # 残り牌がなくなったのでベストな面子か評価する


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

    # 手牌リストから字牌だけを選択する
    def get_jihai(tehai_list)
      tehai_list.select {|pai| pai.jihai? }
    end

    # 手配リストから刻子を見つける
    def get_kotsu(tehai_list)

    end

  end
end