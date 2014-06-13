require "mj_optimizer/tehai_parse_chitoitsu"
require "mj_optimizer/tehai_parse_kokushi"

module MJOptimizer

  # 手配を解析して面子、対子、などに分解するクラス
  class TehaiParser
    include TehaiParseChitoitsu
    include TehaiParseKokushi

    def initialize(tehai_list)
      @tehai = Tehai.new

      # 3文字ずつ区切ってPaiクラスを作り、Tehaiのpai_listに格納
      tehai_list.scan(/.{3}/).each do |pai|
        @tehai << Pai.new(pai)
      end
    end

    def parse
      if tehai_parse
        @tehai
      else
        nil
      end
    end

    private

    #################################################################################
    # 解析処理メイン
    # 国士無双、七対子、通常形の3つの上がりパターンを検証し、最もシャンテン数が低いものを採用する
    # @return Tehai 解析後のTehaiオブジェクト
    #################################################################################
    def tehai_parse

      # Step.1 国士無双の検証
      kokushi_tehai = nil

      # Step.2 七対子の検証
      chitoitsu_tehai = get_tehai_when_chitoitsu(@tehai.dup)

      # Step.3 通常形の検証
      # normal_tehai = normal_tehai_parse

      # Step.4 一番シャンテン数が低いものを選択する
      # 同率の場合は、通常形＞七対子＞国士無双とする


      # Error/計測不能などの場合はfalse

    end

    #################################################################################
    # 通常形の上がりパターンで最もシャンテン数が低いものを判定する
    # @return Tehai 解析後のTehaiオブジェクト
    #################################################################################
    def normal_tehai_parse()

      _tehai = @tehai.dup
      _tehai.rest_pai_list = _tehai.pai_list

      # TODO: 単独牌を先にsingle_listへ避けることで計算回数を減らす

      # Spte.1 字牌を解析する
      # 解析パターンは1つしか無い（面子・対子しか存在しないので）
      _tehai = normal_jihai_parse(_tehai)

      # Step.2 数牌を解析する
      # 解析パターンが複数あるので最適解を得る
      _tehai = normal_kazuhai_parse(_tehai)


      # Refactor: 槓子の解析方法
      # 暗槓、明槓してたら槓子、そうでなければ面子

      temp_rest_pai_list.each_with_index do |pai, i|
        # 1.順子？
        # 字牌でなく7より小さい
        if pai.type != "j" && pai.number >= 7
          syuntsu = [pai]
          next_pai = temp_rest_pai_list.find{|p| p.same_with_direction?(pai.next)}
          if next_pai
            syuntsu << next_pai
            next_next_pai = temp_rest_pai_list.find{|p| p.same_with_direction?(pai.next.next)}
            if next_next_pai
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

    #################################################################################
    # 通常上がり形の字牌解析
    # @param _tehai 現在の手牌オブジェクト
    # @return Tehai 面子構成と残り手牌を更新したTehaiオブジェクト
    #################################################################################
    def normal_jihai_parse(_tehai)
      # 残り手牌から字牌だけを取り出す
      jihai_list = get_jihai(_tehai.rest_pai_list)
      # 字牌が1枚もなかったら終了
      return _tehai if jihai_list.count == 0

      # Step.1 最初の1枚と同じ牌が何枚あるか
      selected_pai_list = _tehai.rest_pai_list.select{|p| p.same_with_direction?(jihai_list[0])}

      case selected_pai_list.count
        # Step.1-1 4枚ある?
        when 4
          # TODO: 槓子かどうかの判定
          # 今はとりあえず面子+1枚と判定する
          _tehai.single_list << selected_pai_list.pop
          _tehai.mentsu_list << Mentsu.new(selected_pai_list)
        # Step.1-2 3枚ある?
        when 3
          _tehai.mentsu_list << Mentsu.new(selected_pai_list)
        # Step.1-3 2枚ある?
        when 2
          _tehai.toitsu_list << Toitsu.new(selected_pai_list)
        # Step.1-4 1枚ある?
        when 1
          _tehai.single_list << selected_pai_list.pop
        else
          raise Exception
      end

      # 見つかった牌を残りの手牌から引く
      _tehai.rest_pai_list = _tehai.rest_pai_list - selected_pai_list

      # 再帰的に処理を続ける
      normal_jihai_parse(_tehai)
    end

    #################################################################################
    # 通常上がり形の数牌解析
    # @param _tehai 現在の手牌オブジェクト
    # @return Tehai 面子構成と残り手牌を更新したTehaiオブジェクト
    #################################################################################
    def normal_kazuhai_parse(_tehai)
      # 残り手牌から数牌だけを取り出す
      kazuhai_list = get_kazuhai(_tehai.rest_pai_list)

      # 残り牌がなくなったのでベストな面子か評価する
      if kazuhai_list.count == 0
        # @tehaiとシャンテン数を比較
        # 解析結果のほうが良ければ@tehaiに代入する


      end


      # 槓子・面子がある?
      selected_pai_list = _tehai.rest_pai_list.select{|p| p.same_with_direction?(kazuhai_list[0])}

      if selected_pai_list.count == 4
        # 仮の手牌リストを作成
        _next_tehai = _tehai.dup

        # TODO: 槓子かどうかの判定
        # 今はとりあえず面子+1枚と判定する
        _next_tehai.mentsu_list << Mentsu.new(same_pai_list)

        # 見つかった牌を残りの手牌から引く
        _next_tehai.rest_pai_list = _tehai.rest_pai_list - selected_pai_list

        # 再帰的に処理を続ける
        normal_kazuhai_parse(_next_tehai)
      end

      if selected_pai_list.count >= 3
        # 仮の手牌リストを作成
        _next_tehai = _tehai.dup

        # 刻子扱いなので1枚減らす
        if selected_pai_list.count == 4
          same_pai_list.shift
        end

        # 面子を登録
        _next_tehai.mentsu_list << Mentsu.new(same_pai_list)

        # 見つかった牌を残りの手牌から引く
        _next_tehai.rest_pai_list = _tehai.rest_pai_list - selected_pai_list

        # 再帰的に処理を続ける
        normal_kazuhai_parse(_next_tehai)
      end

      if selected_pai_list.count == 2
        # 仮の手牌リストを作成
        _next_tehai = _tehai.dup

        # 対子を登録
        _next_tehai.toitsu_list << Toitsu.new(same_pai_list)

        # 見つかった牌を残りの手牌から引く
        _next_tehai.rest_pai_list = _tehai.rest_pai_list - selected_pai_list

        # 再帰的に処理を続ける
        normal_kazuhai_parse(_next_tehai)
      end

      if selected_pai_list.count == 1
        # 仮の手牌リストを作成
        _next_tehai = _tehai.dup

        # 対子を登録
        _next_tehai.single_list << Toitsu.new(same_pai_list)

        # 見つかった牌を残りの手牌から引く
        _next_tehai.rest_pai_list = _tehai.rest_pai_list - selected_pai_list

        # 再帰的に処理を続ける
        normal_kazuhai_parse(_next_tehai)
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
            _tehai.mentsu_list  << Mentsu.new(syuntsu, "s")
            # 面子分を手牌から引く
            _tehai.rest_pai_list = _tehai.rest_pai_list - syuntsu
            # 再帰的に処理を実行
            normal_kazuhai_parse(_tehai)
          end
        end
      end

      _tehai.single_list << _tehai.rest_pai_list
      _tehai.rest_pai_list = []



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

    # 手配リストから刻子を見つける
    def get_kotsu(tehai_list)

    end

  end
end