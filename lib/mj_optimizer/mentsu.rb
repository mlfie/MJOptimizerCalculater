module MJOptimizer
  class Mentsu

    MENTSU_TYPE_SHUNTSU = 's'   # 順子系面子(順子, チー)
    MENTSU_TYPE_KOUTSU  = 'k'   # 刻子系面子(刻子、ポン)
    MENTSU_TYPE_KANTSU  = '4'   # 槓子系面子(暗槓、明槓)
    MENTSU_TYPE_TOITSU  = 't'   # 対子系面子(対子)
    MENTSU_TYPE_TOKUSYU = 'y'   # 特殊系面子(国士無双、十三不塔)

    pai_list = []
    mentsu_type

    def initialize(pai_list, mentsu_type)
      self.pai_list = pai_list
      self.mentsu_type = mentsu_type
    end
  end
end

=begin


搭子（ターツ）・・・順子を構成する3枚のうちの2枚
　両面搭子（リャンメンターツ）・・4.5など
　辺搭子（ペンターツ）・・1.2など
　嵌搭子（カンターツ）・・3.5など

対子（トイツ）・・・同じ牌が2枚
　雀頭（ジャントウ）・・・四面子一雀頭の上がり形に必要な対子

面子（面子）

順子（シュンツ）・・・同種の数牌で数字が連続している3枚
　暗順子（アンシュンツ）・・鳴きなし
　明順子（ミンシュンツ）・・鳴きあり

刻子（コーツ）・・・同じ牌が3枚
　暗刻子（アンコーツ）・・鳴きなし
　明刻子（ミンコーツ）・・鳴きあり

槓子（カンツ）・・・同じ牌が4枚
　暗槓子（アンカンツ）・・鳴きなし
　明槓子（ミンカンツ）・・鳴きあり
=end