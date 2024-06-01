defmodule Twex.Http do
  @moduledoc """
  Contains utility functions for working with Tesla responses
  """

  @type response(successful_type, error_type) ::
          {:ok, successful_type}
          | error_response(error_type)

  @type error_response(error_type) ::
          {:error, response_status_code :: pos_integer(), response_body :: error_type}
          | {:error, {:unknown, tesla_env :: Tesla.Env.t()}}

  @doc """
  Creates a new HTTP client which can be used for authentication related things.

  The first argument (base_url) can be overriden for example to point to the Twitch CLI mocking server.
  """
  @spec create_auth_client() :: Tesla.Client.t()
  @spec create_auth_client(base_url :: String.t()) :: Tesla.Client.t()
  def create_auth_client(base_url \\ "https://id.twitch.tv/oauth2"),
    do:
      Tesla.client([
        {Tesla.Middleware.BaseUrl, base_url},
        {Tesla.Middleware.EncodeFormUrlencoded, []},
        {Tesla.Middleware.DecodeJson, []}
      ])

  @doc """
  Creates a new HTTP client which should be used for regular API calls.

  It has the "Authorization" and "Client-Id" headers set to the given values.
  """
  @spec create_client(access_token :: String.t(), client_id :: String.t()) :: Tesla.Client.t()
  @spec create_client(access_token :: String.t(), client_id :: String.t(), base_url :: String.t()) :: Tesla.Client.t()
  def create_client(access_token, client_id, base_url \\ "https://api.twitch.tv/helix"),
    do:
      Tesla.client([
        {Tesla.Middleware.BaseUrl, base_url},
        {Tesla.Middleware.Headers, [{"Authorization", "Bearer " <> access_token}, {"Client-Id", client_id}]},
        {Tesla.Middleware.EncodeJson, []},
        {Tesla.Middleware.DecodeJson, []}
      ])

  @doc """
  Processes the given Tesla return value from one of the following function calls:
  - delete/3 | delete/4
  - get/3 | get/4
  - post/3 | post/4
  - head/3 | head/4
  - options/3 | options/4
  - patch/3 | patch/4
  - post/3 | post/4
  - put/3 | put/4
  - trace/3 | trace/4
  """
  @spec process_tesla_response(tesla_response :: {:ok, Tesla.Env.t()} | {:error, Tesla.Env.t()}) ::
          response(term(), term())
  @spec process_tesla_response(
          tesla_response :: {:ok, Tesla.Env.t()} | {:error, Tesla.Env.t()},
          successful_status_code :: pos_integer()
        ) :: response(term(), term())
  def process_tesla_response(tesla_response, successfull_status_code \\ 200)

  def process_tesla_response(
        {:ok, %Tesla.Env{status: successful_status_code, body: response_body}},
        successful_status_code
      ),
      do: {:ok, response_body}

  def process_tesla_response(
        {:ok, %Tesla.Env{status: response_status_code, body: response_body}},
        _successful_status_code
      ),
      do: {:error, response_status_code, response_body}

  def process_tesla_response({:error, %Tesla.Env{} = tesla_env}, _successful_status_code),
    do: {:error, {:unknown, tesla_env}}
end
