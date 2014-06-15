module MJOptimizer
  class Pai

    # type      : [m|s|p|j|z] m=マンズ,s=ソウズ,p=ピンズ,j=字牌,z=解析失敗
    # number    : [0-9] ただしjの場合は、1-7 = 東南西北白発中。zの場合は0固定
    # direction : [t|r|l|b] t=top,r=right,l=left,b=bottom

    # 牌の種類
    PAI_TYPE_MANZU      = 'm'
    PAI_TYPE_SOUZU      = 's'
    PAI_TYPE_PINZU      = 'p'
    PAI_TYPE_JIHAI      = 'j'
    PAI_TYPE_REVERSE    = 'r'

    # 字牌を表現する数字
    PAI_NUMBER_TON      = 1
    PAI_NUMBER_NAN      = 2
    PAI_NUMBER_SHA      = 3
    PAI_NUMBER_PEI      = 4
    PAI_NUMBER_HAKU     = 5
    PAI_NUMBER_HATSU    = 6
    PAI_NUMBER_CHUN     = 7
    PAI_NUMBER_REVERSE  = 0

    # 牌の向き
    PAI_DIRECT_TOP      = 't'
    PAI_DIRECT_LEFT     = 'l'
    PAI_DIRECT_BUTTOM   = 'b'
    PAI_DIRECT_RIGHT    = 'r'

    attr_accessor :type,    # 牌の種類(m:萬子 s:索子 p:筒子 j:字牌 r:背面牌)
                  :number,  # 数字(字牌の場合 1:東 2:南 3:西 4:北 5:白 6:發 7:中、背面牌の場合 0:背面牌)
                  :naki,    # 鳴き牌かどうか(true, false)
                  # :agari,   # アガリ牌かどうか(true, false)
                  # :is_tsumo,
                  :pai_type

    def initialize(tehai_str)
      if validate(tehai_str)
        self.type     = tehai_str[0,1]
        self.number   = tehai_str[1,1]
        if tehai_str[2,1] == Pai::PAI_DIRECT_TOP || tehai_str[2,1] == Pai::PAI_DIRECT_BUTTOM then
          self.naki   = false
        elsif tehai_str[2,1] == Pai::PAI_DIRECT_LEFT || tehai_str[2,1] == Pai::PAI_DIRECT_RIGHT then
          self.naki   = true
        end
        # self.agari    = false
        self.pai_type = PaiType.get(tehai_str[0,2])
      else
        raise Exception
      end
    end

    # self.typeの次の牌のPayTypeを返す
    # @param times いくつ先のPayか
    # @return PaiType
    def next_pai_type(times = 1)
      if self.type =~ /[msp]/ && self.number < 10 - times
        PaiType.get("#{self.type}#{self.number + times}")
      else
        nil
      end
    end

    # self.typeの前の牌のPayTypeを返す
    # @param times いくつ前のPayか
    # @return PaiType
    def prev_pai_type(times = 1)
      if type =~ /[msp]/ && number > times
        PaiType.get("#{self.type}#{self.number + times}")
      else
        nil
      end
    end

    # ==============================================
    # 以下はmjparserで実装されていたメソッド
    # ==============================================

    def ==(pai)
      return self.pai_type == pai.pai_type unless pai.nil?
      return false
    end

    # 幺九牌の判定
    def yaochu?
      self.pai_type.yaochu?
    end

    # 老頭牌(1,9)の判定
    def raotou?
      self.pai_type.raotou?
    end

    # 中張牌の判定
    def chunchan?
      self.pai_type.chunchan?
    end

    def is_type?(type)
      self.pai_type.is_type?(type)
    end

    # 萬子かどうか
    def manzu?
      self.pai_type.manzu?
    end

    # 索子かどうか
    def souzu?
      self.pai_type.souzu?
    end

    # 筒子かどうか
    def pinzu?
      self.pai_type.pinzu?
    end

    # 字牌かどうか
    def jihai?
      self.pai_type.jihai?
    end

    # 数牌かどうか
    def suhai?
      self.pai_type.suhai?
    end

    # 東かどうか
    def ton?
      self.pai_type.is_code?('j1')
    end

    # 南かどうか
    def nan?
      self.pai_type.is_code?('j2')
    end

    # 西かどうか
    def sha?
      self.pai_type.is_code?('j3')
    end

    # 北かどうか
    def pei?
      self.pai_type.is_code?('j4')
    end

    # 白かどうか
    def haku?
      self.pai_type.is_code?('j5')
    end

    # 發かどうか
    def hatsu?
      self.pai_type.is_code?('j6')
    end

    # 中かどうか
    def chun?
      self.pai_type.is_code?('j7')
    end

    # 三元牌かどうか
    def sangenpai?
      self.pai_type.sangen?
    end

    # 役牌(自風、場風、三元牌)かどうか
    def yakupai?(kyoku)
      return false unless jihai?
      return true if sangenpai?
      kyoku.jikaze?(self) or kyoku.bakaze?(self)
    end

    # ==============================================
    # ここまで
    # ==============================================

    private

    def validate(pai)
      return false unless pai.class == String && pai.length == 3
      return false unless (pai[0] =~ /[msp]/ && pai[1] =~ /[1-9]/) ||
                          (pai[0] =~ /[j]/ && pai[1] =~ /[1-7]/) ||
                          (pai[0] =~ /[r]/ && pai[1] =~ /[0]/)
      return false unless pai[2] =~ /[trlb]/
      true
    end

  end
end