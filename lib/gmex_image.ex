defmodule Gmex.Image do

  @type t :: %Gmex.Image{
    image: String.t,
    options: [ String.t ]
  }

  defstruct [
    image: nil,
    options: [],
  ]

  @spec append_option( Gmex.Image, [ String.t ] ) :: Gmex.Image
  def append_option( image, new_option ) do
    image
      |> Map.put( :options, image.options ++ new_option )
  end

end
