module MJOptimizer
  class Tatsu
    TATSU_TYPE_RYANMENCHAN = "r"
    TATSU_TYPE_KANCHAN = "k"
    TATSU_TYPE_PENCHAN = "p"

    attr_accessor :pai_list,
                  :type

    def initialize(pai_list, type)
      self.pai_list = pai_list
      self.type = type
    end
  end
end