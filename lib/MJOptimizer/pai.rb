module MJOptimizer
  class Pai
    # type      : [m|s|p|j|z] m=マンズ,s=ソウズ,p=ピンズ,j=字牌,z=解析失敗
    # number    : [0-9] ただしjの場合は、1-7 = 東南西北白発中。zの場合は0固定
    # direction : [t|r|l|b] t=top,r=right,l=left,b=bottom

    attr_reader :type, :number, :direction

    def initialize(pai)
      if validation(pai)
        self.type = pai[0]
        self.number = pai[1]
        self.direction = pai[2]
      else
        raise Exception
      end
    end

    def name
      type + number
    end

    def name_with_direction
      self.name + self.direction
    end

    def same?(hai)
      if self.name == hai.name
        true
      else
        false
      end
    end

    def same_with_direction?(hai)
      if same?(hai) && self.direction == hai.direction
        true
      else
        false
      end
    end

    def next
      if type =~ /[msp]/ && number < 9
        type + (number + 1).to_s
      else
        false
      end
    end

    def next_with_direction
      if self.next
        self.next + direction
      else
        false
      end
    end

    def prev
      if type =~ /[msp]/ && number > 1
        type + (number - 1).to_s
      else
        false
      end
    end

    def prev_with_direction
      if self.prev
        self.prev + direction
      else
        false
      end
    end

    private

    def validation(pai)
      return false unless pai.class == 'Array' && pai.length == 3
      return false unless pai[0] =~ /[mspj]/
      return false unless ((pai[0] =~ /[msp]/ && pai[1] =~ /[1-9]/) || (pai[0] =~ /[j]/ && pai[1] =~ /[1-7]/))
      return false unless pai[2] =~ /[trlb]/
      true
    end
  end
end