module MJOptimizer
  class Mentsu

    MENTSU_TYPE_SHUNTSU = 's'   # 順子系面子(順子, チー)
    MENTSU_TYPE_KOUTSU  = 'k'   # 刻子系面子(刻子、ポン)
    # MENTSU_TYPE_KANTSU  = '4'   # 槓子系面子(暗槓、明槓)
    # MENTSU_TYPE_TOITSU  = 't'   # 対子系面子(対子)
    # MENTSU_TYPE_TOKUSYU = 'y'   # 特殊系面子(国士無双、十三不塔)

    attr_accessor :pai_list,
                  :type

    def initialize(pai_list, type)
      self.pai_list = pai_list
      self.type = type
    end
  end
end
