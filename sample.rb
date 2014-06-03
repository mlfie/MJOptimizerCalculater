
tehai = "m1tm2tm3ts1ts2ts3t1pt2pt3ptj4tj4tj1tj1lj1t"

mjo = MJ::Optimizer.new(tehai)

mjo.analysis do |result|
  p result
end


result = mjo.analysis

=begin
{result:
  syanten_count: 2, # あと2枚で上がれる
  mentsus: [
    {
      # ...pendding
    }
  ],
  sutehais: [
    {
      position: 3 # 左から数えて
      sutehai: "m3" # 捨てる牌
    },
    {
      position: 3 # 左から数えて
      hai: ""
    },
  ]
  machihais: ["m2","m5"] # 引くとシャンテン数を下げることができる牌。雀頭がない場合は多くなる
}
=end