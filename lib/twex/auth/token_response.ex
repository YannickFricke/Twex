defmodule Twex.Auth.TokenResponse do
  @moduledoc """
  This module is a struct which contains the following information:

  | Name          | Data type               | Description                                                                                                                                            |
  | :------------ | :---------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------- |
  | access_token  | `t:String.t/0`          | The token for accessing user related resources                                                                                                         |
  | refresh_token | `t:String.t/0` OR `nil` | The token for refreshing the access token                                                                                                              |
  | expires_in    | `t:pos_integer/0`       | The amount of seconds for how long the access token stays valid. After the time has passed you need to refresh the access token with the refresh token |
  | scopes        | `t:list/1`              | The user authorized scopes for the access token                                                                                                        |
  """

  defstruct [:access_token, :refresh_token, :expires_in, :scopes]

  @type t() :: %__MODULE__{
          access_token: String.t(),
          refresh_token: String.t() | nil,
          expires_in: pos_integer(),
          scopes: list(String.t())
        }

  @doc """
  Creates a new TokenResponse struct with the given access token, nilable refresh token, the expires in seconds amount and scopes.

  ## Examples

  ```elixir
  iex> Twex.Auth.TokenResponse.new("at", 1, [])
  %Twex.Auth.TokenResponse{
    access_token: "at",
    refresh_token: nil,
    expires_in: 1,
    scopes: []
  }
  ```

  ```elixir
  iex> Twex.Auth.TokenResponse.new("at", "rt", 1, [])
  %Twex.Auth.TokenResponse{
    access_token: "at",
    refresh_token: "rt",
    expires_in: 1,
    scopes: []
  }
  ```
  """
  @spec new(access_token :: String.t(), expires_in :: pos_integer(), scopes :: list(String.t())) :: t()
  @spec new(
          access_token :: String.t(),
          refresh_token :: String.t() | nil,
          expires_in :: pos_integer(),
          scopes :: list(String.t())
        ) :: t()
  def new(access_token, expires_in, scopes), do: new(access_token, nil, expires_in, scopes)

  def new(access_token, refresh_token, expires_in, scopes),
    do: %__MODULE__{access_token: access_token, refresh_token: refresh_token, expires_in: expires_in, scopes: scopes}
end
