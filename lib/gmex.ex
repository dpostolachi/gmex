defmodule Gmex do

  @moduledoc """
  A simple wrapper for GraphicsMagick in Elixir.
  """


  @doc """
    Opens image source.

  ## Example
      iex> Gmex.open( "test/images/blossom.jpg" )
      { :ok, [ "test/images/blossom.jpg" ] }

      iex> Gmex.open( "non-existing.png" )
      { :error, :enoent }
  """

  @spec open( String.t() ) :: Image | { :error, :enoent }

  def open ( src_path ) do
    if File.exists?( src_path ) do
      { :ok, [ src_path ] }
    else
      { :error, :enoent }
    end
  end


  @doc """
  Saves the modified image

  ## Example
      iex> Gmex.open( "test/images/blossom.jpg" )
      iex> |> Gmex.save( "newimage.jpg" )
      { :ok, nil }

  """

  @spec save( Image, String.t() ) ::  { :ok, nil } | { :error, String.t() }

  def save( image, dest_path ) do

    with { :ok, options } <- image do

      new_options = options ++ [ dest_path ]

      { result, status_code } = System.cmd "gm", [ "convert" ] ++ new_options, stderr_to_stdout: true

      result = result
        |> String.replace( "\r", "" )
        |> String.replace( "\n", "" )

      if status_code == 0 do
        { :ok, nil }
      else
        { :error, result }
      end

    end

  end


  @doc """
    Returns a keywords list with information about the image like width, height, size, format and quality.
  """

  @spec get_info( Image ) ::  { :ok, [ width: Integer.t(), height: Integer.t(), size: String.t(), format: String.t(), quality: Integer.t() ] } | { :error, String.t() }

  def get_info( image ) do

    with { :ok, options } <- image do

      [ src_path | _ ] = options

      { image_data, status_code } = System.cmd "gm", [ "identify", "-format", "width=%w,height=%h,size=%b,format=%m,quality=%Q", src_path ], stderr_to_stdout: true

      image_data = image_data
        |> String.replace( "\r", "" )
        |> String.replace( "\n", "" )

      if status_code == 0 do

        [   :ok,
          String.split( image_data, "," )
            |> Enum.reduce( [], fn ( row, acc ) ->

              [ field , value ] = String.split( row, "=" )

              case field do

                "width" ->
                  width = value
                    |> String.to_integer()
                  acc ++ [ width: width ]

                "height" ->
                  width = value
                    |> String.to_integer()
                  acc ++ [ height: width ]

                "format" ->
                  format = value
                    |> String.downcase()
                    |> String.to_atom()
                  acc ++ [ format: format ]

                "quality" ->
                  quality = value
                    |> String.to_integer()

                  acc ++ [ compression_quality: quality ]

                "size" ->
                  acc ++ [ size: value ]

                _ -> acc

              end

            end ) ]

      else
        { :error, image_data }
      end

    end

  end

  @doc """
  Apply a GraphicsMagick option to the given image.

  ## Example
      iex> Gmex.open( "test/images/blossom.jpg" )
      iex> |> Gmex.option( :negate )
      iex> |> Gmex.option( { :resize, 50, 50 } )
      iex> |> Gmex.option( :strip )
      iex> |> Gmex.option( { :format, "jpg" } )
      { :ok, [ "test/images/blossom.jpg", "-negate", "-resize", "50x50", "-strip", "-format", "jpg" ] }

  List of available options:

  | Option | GraphicsMagick |
  | ---- | ---- |
  | :plus_adjoin | +adjoin |
  | :adjoin | -adjoin |
  | { :blur, radius, sigma } | -blur radiusxsigma |
  | { :blur, radius } | -blur radius |
  | { :crop, width, height, x_offset, y_offset } | -crop widthxheight+x_offset+y_offset |
  | { :crop, width, height } | -crop widthxheight |
  | { :edge, edge } | -edge edge |
  | { :extent, width, height, x_offset, y_offset } | -extent widthxheight+x_offset+y_offset |
  | { :extent, width, height } | -extent widthxheight |
  | flatten | -flatten |
  | { :fill, color } | -fill color |
  | :strip | -strip |
  | :flip | -flip |
  | { :format, format } | -format format |
  | { :gravity, gravity } | -gravity gravity |
  | magnify | -magnify |
  | plus_matte | +matte |
  | matte | -matte |
  | negate | -negate |
  | { :opaque, color } | -opaque color |
  | { :quality, quality } | -quality quality |
  | { :resize, width, height } | -resize widthxheight |
  | { :resize, percents } | -resize percents% |
  | { :rotate, degrees } | -rotate degrees |
  | { :size, width, height } | -size widthxheight |
  | { :size, width, height, offset } | -size widthxheight+offset |
  | { :thumbnail, width, height } | -thumbnail widthxheight |
  | { :thumbnail, percents } | -thumbnail percents% |
  | { :transparent, color } | -transparent color |
  | { :type, type } | -type type |
  | { :custom, [ arg1, arg2, arg3... ] } | arg1 arg2 arg3 ... |
  """

  @spec option( Image, Option ) :: Image | { :error, any() }

  def option( image, option ) do

    with { :ok, options } <- image do

      append = case option do

        :plus_adjoin ->
          [ "+adjoin" ]

        :adjoin ->
          [ "-adjoin" ]

        { :background, color } ->
          [ "-background", color ]

        { :blur, radius, sigma } ->
          [ "-blur", "#{radius}x#{sigma}" ]

        { :blur, radius } ->
          [ "-blur", "#{radius}" ]

        { :crop, width, height } ->
          [ "-crop", "#{width}x#{height}" ]

        { :crop, width, height, x_offset, y_offset } ->

          x_offset = if x_offset > 0, do: "+#{x_offset}", else: x_offset
          y_offset = if y_offset > 0, do: "+#{y_offset}", else: y_offset

          [ "-crop", "#{width}x#{height}#{x_offset}#{y_offset}" ]

        { :edge, radius } ->
          [ "-edge", radius ]

        { :extent, width, height } ->
          [ "-extent", "#{width}x#{height}" ]

        { :extent, width, height, x_offset, y_offset } ->

          x_offset = if x_offset > 0, do: "+#{x_offset}", else: x_offset
          y_offset = if y_offset > 0, do: "+#{y_offset}", else: y_offset

          [ "-extent", "#{width}x#{height}#{x_offset}#{y_offset}" ]


        :flatten ->
          [ "-flatten" ]

        { :fill, color } ->
          [ "-flatten", color ]

        :strip ->
          [ "-strip" ]

        :flip ->
          [ "-flip" ]

        { :format, format } ->
          [ "-format", format ]

        { :gravity, gravity } ->
          [ "-gravity", gravity ]

        :magnify ->
          [ "magnify" ]

        :plus_matte ->
          [ "+matte" ]

        :matte ->
          [ "-matte" ]

        :negate ->
          [ "-negate" ]

        { :opaque, color } ->
          [ "-opaque", color ]

        { :quality, quality } ->
          [ "-quality", quality ]

        { :resize, width, height } ->
          [ "-resize", "#{width}x#{height}" ]

        { :resize, percents } ->
          [ "-resize", "#{percents}%" ]

        { :rotate, degrees } ->
          [ "-rotate", degrees ]

        { :size, width, height } ->
          [ "-size", "#{width}x#{height}" ]

        { :size, width, height, offset } ->
          [ "-size", "#{width}x#{height}+#{offset}" ]

        { :thumbnail, width, height } ->
          [ "-thumbnail", "#{width}x#{height}" ]

        { :thumbnail, percents } ->
          [ "-thumbnail", "#{percents}%" ]

        { :transparent, color } ->
          [ "-transparent", color ]

        { :type, type } ->
          [ "-type", type ]

        { :custom, other_options } ->
          other_options

        _ -> :unknown_option

      end

      if append == :unknown_option do
        { :error, :unknown_option }
      else
        { :ok, options ++ append }
      end

    end

  end

end
