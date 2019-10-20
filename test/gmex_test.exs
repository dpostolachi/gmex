defmodule GmexTest do
  use ExUnit.Case
  doctest Gmex

  @resize_to_fill_path "test/images/resized-to-fill.jpg"
  @resize_to_fit_path "test/images/resized-to-fit.jpg"
  @resize_default "test/images/resized-default.jpg"

  test "Check image info" do

    image_info = Gmex.open( "test/images/blossom.jpg" )
      |> Gmex.get_info()

    { :ok, [ width: width, height: height, size: size, format: format, compression_quality: _ ] } = image_info

    assert width == 640 and
      height == 480 and
      size == "104.7Ki"
      format == :jpeg

  end

  test "Check GraphicsMagick executable" do

    { status, _ } = Gmex.test_gm()

    assert status == :ok

  end

  test "Resize image to fill" do
    Gmex.open( "test/images/blossom.jpg" )
      |> Gmex.resize( width: 300, height: 200, type: :fill )
      |> Gmex.save( @resize_to_fill_path )

    { :ok, image_info } = Gmex.open( @resize_to_fill_path )
      |> Gmex.get_info()
    assert { Keyword.get( image_info, :width ), Keyword.get( image_info, :height ) } == { 300, 200 }

  end

  test "Resize image to fit" do
    Gmex.open( "test/images/blossom.jpg" )
      |> Gmex.resize( width: 300, height: 200, type: :fit )
      |> Gmex.save( @resize_to_fit_path )

    { :ok, image_info } = Gmex.open( @resize_to_fit_path )
      |> Gmex.get_info()

    assert { Keyword.get( image_info, :width ), Keyword.get( image_info, :height ) } == { 267, 200 }

  end

  test "Resize with default params" do
    Gmex.open( "test/images/blossom.jpg" )
      |> Gmex.resize( width: 300 )
      |> Gmex.save( @resize_default )

    { :ok, image_info } = Gmex.open( @resize_default )
      |> Gmex.get_info()

    assert { Keyword.get( image_info, :width ), Keyword.get( image_info, :height ) } == { 300, 225 }

  end

end
