defmodule Twex.Auth.TwitchCli do
  @moduledoc """
  Contains authentication related functions for the Twitch CLI mock server.
  """

  alias Twex.Auth.Scope

  @doc """
  Returns in case of success an access token + expires in duration for the given user id.

  ATTENTION: This should only be used for authorizing against the Twitch CLI mock server!
  """
  @spec authorize_user(
          http_client :: Tesla.Client.t(),
          client_id :: String.t(),
          client_secret :: String.t(),
          user_id :: String.t(),
          scopes :: list(Twex.Auth.Scope.t())
        ) ::
          {:ok, access_token :: String.t(), expires_in :: non_neg_integer()}
          | Twex.Http.error_response(map())
  def authorize_user(http_client, client_id, client_secret, user_id, scopes) do
    http_client
    |> Tesla.post("/authorize", "",
      query: [
        client_id: client_id,
        client_secret: client_secret,
        grant_type: "user_token",
        user_id: user_id,
        scope: Scope.join(scopes)
      ]
    )
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok,
       %{
         "access_token" => access_token,
         "expires_in" => expires_in
       }} ->
        {:ok, access_token, expires_in}

      error_value ->
        error_value
    end
  end
end
