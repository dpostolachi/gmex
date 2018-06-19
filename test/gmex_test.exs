defmodule GmexTest do
  use ExUnit.Case
  doctest Gmex

  test "check image info" do

    image_info = Gmex.open( "test/images/blossom.jpg" )
      |> Gmex.get_info()

    assert image_info == [:ok, [width: 640, height: 480, size: "86.5Ki", format: :jpeg, compression_quality: 92]]

  end

  test "check gm executable" do

    assert Gmex.test_gm() == :ok

  end
end
