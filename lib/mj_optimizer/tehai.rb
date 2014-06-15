module MJOptimizer

  # 手配解析後のデータ構造クラス
  # 本名はSutehaiSelectResultクラス
  class Tehai
    AGARU_TYPE_NORMAL = "normal"
    AGARU_TYPE_CHITOITSU = "chitoitsu"
    AGARU_TYPE_KOKUSHIMUSO = "kokusimuso"

    attr_accessor :base_pai_list, # 解析前の手牌リスト(Paiのリスト)
                  :rest_pai_list, # 未解析の手牌リスト
                  :mentsu_list,   # 面子のリスト
                  :toitsu_list,   # 対子のリスト
                  :tatsu_list,    # 搭子のリスト
                  :single_list,   # 組み合わせのない牌のリスト
                  :agari_type,    # 上がり形
                  :is_parsed      # 解析が完了したかどうか

    def initialize
      self.base_pai_list = []
      self.rest_pai_list = []
      self.mentsu_list = []
      self.toitsu_list = []
      self.tatsu_list = []
      self.single_list = []
      self.agari_type = nil
      self.is_parsed = false
    end

    def <<(pai)
      return unless pai.class == Pai
      self.base_pai_list << pai
    end

    # === 解析後に使えるメソッド ===

    # あがり判定
    def agari?
      syanten_count = self.syanten_count

      if syanten_count && syanten_count == 0
        true
      else
        false
      end
    end

    # シャンテン数を求める
    def syanten_count
      return 99 unless self.is_parsed

      case self.agari_type
        when AGARU_TYPE_NORMAL
          syanten_count = normal_syanten_count
        when AGARU_TYPE_CHITOITSU
          syanten_count = chitoitsu_syanten_count
        when AGARU_TYPE_KOKUSHIMUSO
          syanten_count = kokushi_syanten_count
        else
          syanten_count = nil
      end

      syanten_count
    end

    private

    # あがり形が通常だった場合のシャンテン数
    def normal_syanten_count
      mentsu_count = 0
      mentsu_kouho_count = 0
      jyanto = 0

      # 面子のカウント
      mentsu_count += self.mentsu_list.count

      # 対子のカウント
      if self.toitsu_list.count > 1
        jyanto = 1
        mentsu_kouho_count += self.toitsu_list.count - 1
      else
        jyanto += self.toitsu_list.count
      end

      # ターツのカウント
      mentsu_kouho_count += self.tatsu_list.count

      # 面子と面子候補の合計が4である（5以上はダメ）
      if mentsu_count + mentsu_kouho_count > 4
        mentsu_kouho_count = 4 - mentsu_count
      end
      9 - (mentsu_count * 2 + mentsu_kouho_count + jyanto)
    end

    # あがり形が七対子だった場合のシャンテン数
    def chitoitsu_syanten_count
      7 - self.toitsu_list.count
    end

    # あがり形が国士無双だった場合のシャンテン数
    def kokushi_syanten_count
      # 重複しないヤオチュウ牌が何種類あるか
      yaochu = {}
      jyanto = 0

      self.single_list.each do |pai|
        yaochu[pai.name] = true if pai.yaochu?
      end

      self.toitsu_list.each do |toitsu|
        if toitsu.pai_list[0].yaochu?
          yaochu[toitsu.pai_list[0].name] = true
          jyanto = 1 # 2つ以上あっても雀頭は1つとカウントする
        end
      end
      14 - (yaochu.count + jyanto)
    end
  end
end