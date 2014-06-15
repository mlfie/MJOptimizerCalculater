module Helpers
  # sample
  def help
    :available
  end

  def get_tehai(fixture_id)
    # 普通にやったら
    Tehaiクラスにfixturesの識別子を渡してファイルから読み込む
    @tehai = Hehai.new(get_fixture(fixture_id))

  end

  def get_fixture()

  end
end