defmodule Gmex.Image do

  @type t :: %Gmex.Image{
    image: String.t,
    options: list( String.t )
  }

  defstruct [
    image: nil,
    options: [],
  ]

  @spec append_option( %Gmex.Image{}, list( String.t )) :: %Gmex.Image{}
  def append_option( image = %Gmex.Image{}, new_option ) do
    %{ image |
      :options => image.options ++ new_option
    }
  end

end
