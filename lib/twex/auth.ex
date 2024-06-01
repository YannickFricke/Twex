defmodule Twex.Auth do
  @moduledoc """
  This module contains helper functions for the authorization flow.
  """

  alias Twex.Auth.Scope

  @doc """
  Builds an authorization URL which should be visited by users in order to connect Twitch to your application.

  The `opts` argument supports the following keys:

  | Name          | Type                               | Description                                                                                                                                                         | Default value |
  | :------------ | :--------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
  | response_type | `t:String.t/0` OR `t:list/1`       | The response type of the Twitch OAuth server                                                                                                                        | `"code"`      |
  | state         | `nil` OR `t:String.t/0`            | The state for identifying a user in the response                                                                                                                    | `nil`         |
  | force_verify  | `t:boolean/0`                      | When set to true the user will see the authorization screen again even when they already have authorized the application (with the same or less scopes than before) | `false`       |


  ## Response types

  As of today (1st June 2024) Twitch supports the following response types:
  - id_token
  - code
  - token

  ## Hint

  We do not validate the `response_type` since Twitch could at some point of time offer more than the currently known.

  ## Reference

  https://dev.twitch.tv/docs/authentication/getting-tokens-oidc/#discovering-supported-claims-and-authorization-uris
  """
  @spec build_authorization_url(
          client_id :: String.t(),
          redirect_uri :: String.t(),
          scopes :: list(Scope.t())
        ) :: String.t()
  @spec build_authorization_url(
          client_id :: String.t(),
          redirect_uri :: String.t(),
          scopes :: list(Scope.t()),
          opts :: Keyword.t()
        ) :: String.t()
  def build_authorization_url(client_id, redirect_uri, scopes, opts \\ []) do
    response_type =
      opts
      |> Keyword.get(:response_type, "code")
      |> encode_response_type()

    state = Keyword.get(opts, :state)
    force_verify = Keyword.get(opts, :force_verify, false)

    query_params = %{
      "response_type" => response_type,
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "scope" => Scope.join(scopes),
      "force_verify" => force_verify
    }

    query_params_with_state =
      if state != nil do
        Map.put(query_params, "state", state)
      else
        query_params
      end

    "https://id.twitch.tv/oauth2/authorize"
    |> URI.new!()
    |> URI.append_query(URI.encode_query(query_params_with_state))
    |> URI.to_string()
  end

  @doc """
  Implements the client credentials grant flow in order to issue an app access token.

  ## Reference

  https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#client-credentials-grant-flow
  """
  @spec get_app_access_token(
          http_client :: Tesla.Client.t(),
          client_id :: String.t(),
          client_secret :: String.t()
        ) ::
          {:ok, access_token :: String.t(), expires_in :: non_neg_integer()}
          | Twex.Http.error_response(map())
  def get_app_access_token(http_client, client_id, client_secret) do
    http_client
    |> Tesla.post("/token", %{
      "client_id" => client_id,
      "client_secret" => client_secret,
      "grant_type" => "client_credentials"
    })
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"access_token" => access_token, "expires_in" => expires_in}} ->
        {:ok, access_token, expires_in}

      error ->
        error
    end
  end

  @doc """
  Encodes the "response_type" parameter for the URL.

  ## Examples

  ```elixir
  iex> Twex.Auth.encode_response_type("code")
  "code"
  ```

  ```elixir
  iex> Twex.Auth.encode_response_type(~w(token id_token))
  "token+id_token"
  ```

  ```elixir
  iex> Twex.Auth.encode_response_type(["token", "id_token"])
  "token+id_token"
  ```
  """
  @spec encode_response_type(response_type_or_response_types :: String.t() | list(String.t())) :: String.t()
  def encode_response_type(response_types) when is_list(response_types), do: Enum.join(response_types, "+")

  def encode_response_type(response_types) when is_binary(response_types), do: response_types
end
