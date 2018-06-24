defmodule Gmex do

  @moduledoc """
  A simple wrapper for GraphicsMagick in Elixir.
  """

  @default_open_options [
      gm_path: "gm"
  ]

  @default_resize_options [
    width: :auto,
    height: :auto,
    resize: :fill
  ]

  @type image :: { :ok, Gmex.Image }
  @type gmex_error :: { :error, any() }
  @type image_info :: [ width: Integer.t, height: Integer.t, size: String.t, format: String.t, quality: Integer.t ]
  @type resize_options :: [ width: Integer.t, height: Integer.t, type: :fill | :fit ]
  @type open_options :: [ gm_path: String.t() ]

  @doc false

  def test_gm( options \\ [] ) do

    final_options = Keyword.merge( @default_open_options, options )
    executable = Keyword.get( final_options, :gm_path )

    if System.find_executable( executable ) == nil do
      { :error, "graphicsmagick executable not found at:#{executable}" }
    else
      { :ok, executable }
    end

  end

  @doc """
  Opens image source.

  ## Options
    * `:gm_path` - path to GraphicsMagick executable, defaults to `gm`, if the executable is missing an error will be returned.
  ## Example
      iex> Gmex.open( "test/images/blossom.jpg" )
      { :ok, %Gmex.Image{ image: "test/images/blossom.jpg", options: [ "gm" ] } }

      iex> Gmex.open( "test/images/blossom.jpg", gm_path: "/404/gm" )
      { :error, "graphicsmagick executable not found at:/404/gm" }

      iex> Gmex.open( "non-existing.png" )
      { :error, :enoent }

  """

  @spec open( String.t(), [ open_options ] ) :: image | gmex_error

  def open( src_path, options \\ [] ) do
    with { :ok, executable } <- test_gm( options )
    do
      if File.exists?( src_path ) do

        { :ok, %Gmex.Image{
          image: src_path,
          options: [ executable ]
        } }
      else
        { :error, :enoent }
      end
    end
  end


  @doc """
  Saves the modified image

  ## Example
      iex> Gmex.open( "test/images/blossom.jpg" )
      iex> |> Gmex.save( "newimage.jpg" )
      { :ok, nil }

  """

  @spec save( image, String.t() ) :: image | gmex_error

  def save( image, dest_path ) do

    with { :ok, image_struct } <- image
    do

      [ executable | final_options ] = image_struct.options

      final_options =  [ "convert" | [ image_struct.image | final_options ] ] ++ [ dest_path ]

      { result, status_code } = System.cmd executable, final_options , stderr_to_stdout: true

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

  @spec get_info( image ) ::  { :ok, image_info } | gmex_error

  def get_info( image ) do

    with { :ok, image_struct } <- image
    do

      [ executable | _ ] = image_struct.options

      { image_data, status_code } = System.cmd executable, [ "identify", "-format", "width=%w,height=%h,size=%b,format=%m,quality=%Q", image_struct.image ], stderr_to_stdout: true

      image_data = image_data
        |> String.replace( "\r", "" )
        |> String.replace( "\n", "" )

      if status_code == 0 do

        { :ok,
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

            end ) }

      else
        { :error, image_data }
      end

    end

  end

  @doc """
  Resizes image

  ## Options
    * `:width` - (Optional) width of the resized image, if not specified will be calculated based on proportions.
    * `:height` - (Optional) height of the resized image, if not specified will be calculated based on proportions.
    * `:type` - (Optional) resize type, can be either :fill or :fit, defaults to :fill.
      * `:fill` - Generates images of the specified size with cropping.
      * `:fit` - Generates an image that will fit in the specified size, no cropping.

  ## Example
      iex> Gmex.open( "test/images/blossom.jpg" )
      iex> |> Gmex.resize( width: 300, height: 200, type: :fill )
      iex> |> Gmex.save( "newimage.jpg" )
      { :ok, nil }

  """

  @spec resize( image, resize_options ) :: image | gmex_error

  def resize( image, options \\ [] ) do
    with { :ok, _ } <- image
    do

      options = Keyword.merge( @default_resize_options, options )

      { _ ,image_data } = image |> get_info


      src_width = image_data |> Keyword.get( :width )
      src_height = image_data |> Keyword.get( :height )

      tar_width = options |> Keyword.get( :width, :auto )
      tar_height = options |> Keyword.get( :height, :auto )

      src_ratio = src_width / src_height

      resize_type = options |> Keyword.get( :type, :fill )

      tar_width = cond do
        tar_width == :auto and tar_height == :auto -> src_width
        tar_width == :auto and tar_height != :auto -> src_width * tar_height / src_height
        true -> tar_width
      end

      tar_height = cond do
        tar_height == :auto and tar_width == :auto -> src_width
        tar_height == :auto and tar_width != :auto -> src_height * tar_width / src_width
        true -> tar_height
      end

      tar_ratio = tar_width / tar_height


      case resize_type do
        :fill ->

          { resize_width, resize_height } = if src_ratio >= tar_ratio do
            { src_width / ( src_height / tar_height ), tar_height }
          else
            { tar_width, src_height / ( src_width / tar_width ) }
          end

          image
            |> option( { :resize, resize_width, resize_height } )
            |> option( { :gravity, "center" } )
            |> option( { :crop, tar_width, tar_height, 0, 0 } )

        :fit ->
          image
            |> option( { :resize, tar_width, tar_height } )
        _ -> { :error, "unknown resize type" }
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
      { :ok, %Gmex.Image{ image: "test/images/blossom.jpg", options: [ "gm", "-negate", "-resize", "50x50", "-strip", "-format", "jpg" ] } }

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

  @spec option( image, Option ) :: image | gmex_error

  def option( image, option ) do

    with { :ok, image } <- image
    do

      new_option = case option do

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

          width = Kernel.round( width )
          height = Kernel.round( height )

          [ "-crop", "#{width}x#{height}" ]

        { :crop, width, height, x_offset, y_offset } ->

          width = Kernel.round( width )
          height = Kernel.round( height )

          x_offset = Kernel.round( x_offset )
          y_offset = Kernel.round( y_offset )

          x_offset = if x_offset >= 0, do: "+#{x_offset}", else: x_offset
          y_offset = if y_offset >= 0, do: "+#{y_offset}", else: y_offset

          [ "-crop", "#{width}x#{height}#{x_offset}#{y_offset}" ]

        { :edge, radius } ->
          [ "-edge", radius ]

        { :extent, width, height } ->

          width = Kernel.round( width )
          height = Kernel.round( height )

          [ "-extent", "#{width}x#{height}" ]

        { :extent, width, height, x_offset, y_offset } ->

          width = Kernel.round( width )
          height = Kernel.round( height )

          x_offset = Kernel.round( x_offset )
          y_offset = Kernel.round( y_offset )

          x_offset = if x_offset >= 0, do: "+#{x_offset}", else: x_offset
          y_offset = if y_offset >= 0, do: "+#{y_offset}", else: y_offset

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

          width = Kernel.round( width )
          height = Kernel.round( height )

          [ "-resize", "#{width}x#{height}" ]

        { :resize, percents } ->
          [ "-resize", "#{percents}%" ]

        { :rotate, degrees } ->
          [ "-rotate", degrees ]

        { :size, width, height } ->

          width = Kernel.round( width )
          height = Kernel.round( height )

          [ "-size", "#{width}x#{height}" ]

        { :size, width, height, offset } ->

          width = Kernel.round( width )
          height = Kernel.round( height )

          offset = Kernel.round( offset )

          [ "-size", "#{width}x#{height}+#{offset}" ]

        { :thumbnail, width, height } ->

          width = Kernel.round( width )
          height = Kernel.round( height )

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

      if new_option == :unknown_option do
        { :error, :unknown_option }
      else
        { :ok, Gmex.Image.append_option( image, new_option ) }
      end

    end

  end

end
