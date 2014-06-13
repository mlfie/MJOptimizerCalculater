module MJOptimizer

  # 手配解析後のデータ構造クラス
  class Tehai
    AGARU_TYPE_NORMAL = "normal"
    AGARU_TYPE_CHITOITSU = "chitoitsu"
    AGARU_TYPE_KOKUSHIMUSO = "kokusimuso"

    attr_accessor :pai_list,      # 解析前の手牌リスト(Paiのリスト)
                  :rest_pai_list, # 未解析の手牌リスト
                  :mentsu_list,   # 面子のリスト
                  :toitsu_list,   # 対子のリスト
                  :tatsu_list,    # 搭子のリスト
                  :single_list,   # 組み合わせのない牌のリスト
                  :agari_type,    # 上がり形
                  :is_agari       # 上がりかどうか

    def initialize
      self.pai_list = []
      self.rest_pai_list = []
      self.mentsu_list = []
      self.toitsu_list = []
      self.tatsu_list = []
      self.single_list = []
      self.agari_type = nil
      self.is_agari = false
    end

    def <<(pai)
      return unless pai.class == Pai
      self.pai_list << pai
    end

    # 解析後に使えるメソッド

    def shanten_count
      case self.agari_type
        when AGARU_TYPE_NORMAL
        when AGARU_TYPE_CHITOITSU
          shanten_count = chitoitsu_shanten_count
        when AGARU_TYPE_KOKUSHIMUSO
          shanten_count = kokushi_shanten_count
        else
          shanten_count = nil
      end

      # あがり判定
      if shanten_count && shanten_count == 0
        self.is_agari = true
      end

      shanten_count
    end

    # あがり形が通常だった場合のシャンテン数
    def normal_shanten_count

    end

    # あがり形が七対子だった場合のシャンテン数
    def chitoitsu_shanten_count
      7 - self.toitsu_list.count
    end

    # あがり形が国士無双だった場合のシャンテン数
    def kokushi_shanten_count
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

    def agari?
      self.is_agari
    end
  end
end