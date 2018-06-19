defmodule GmexTest do
  use ExUnit.Case
  doctest Gmex

  test "Check image info" do

    image_info = Gmex.open( "test/images/blossom.jpg" )
      |> Gmex.get_info()

    assert image_info == [:ok, [width: 640, height: 480, size: "86.5Ki", format: :jpeg, compression_quality: 92]]

  end

  test "Check GraphicsMagick executable" do

    { status, _ } = Gmex.test_gm()

    assert status == :ok

  end

end
