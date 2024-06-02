defmodule Twex.Helix.Channels do
  @moduledoc """
  This module contains all channels related endpoints.
  """

  defmodule ChannelInformation do
    @moduledoc """
    Contains information about one specific channel.

    The information includes the following items:

    | Name                          | Description                                                                                                                                                                                                                                                                                                                |
    | :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | broadcaster_id                | The user id of the user                                                                                                                                                                                                                                                                                                    |
    | broadcaster_login             | The unique name of the user                                                                                                                                                                                                                                                                                                |
    | broadcaster_name              | The localized name of the user                                                                                                                                                                                                                                                                                             |
    | broadcaster_language          | The user's preferred language. The value is an ISO 639-1 two-letter language code (for example, "en" for English).                                                                                                                                                                                                         |
    | game_id                       | The last category of the user. It will be empty when the user has never streamed.                                                                                                                                                                                                                                          |
    | game_name                     | The human readable name of the category. It will be empty when the user has never streamed.                                                                                                                                                                                                                                |
    | title                         | The user-readable stream title. It will be empty when the user has never streamed.                                                                                                                                                                                                                                         |
    | delay                         | The value of the user's stream delay setting, in seconds. This field’s value defaults to zero unless 1) the request specifies a user access token, 2) the ID in the broadcaster_id query parameter matches the user ID in the access token, and 3) the user has partner status and they set a non-zero stream delay value. |
    | tags                          | The tags applied to the channel                                                                                                                                                                                                                                                                                            |
    | content_classification_labels | The content classification labels applied to the channel                                                                                                                                                                                                                                                                   |
    | is_branded_content            | Boolean flag indicating if the channel has branded content.                                                                                                                                                                                                                                                                |

    ## Hint

    When the `broadcaster_login` field contains non-ascii letters (for example: japanese, chinese, korean, cyrillic letters)
    the `broadcaster_name` contains their localized name in ASCII characters.
    """

    use Twex.Http.Response

    embedded_schema do
      field :broadcaster_id, :string
      field :broadcaster_login, :string
      field :broadcaster_name, :string
      field :broadcaster_language, :string
      field :game_id, :string
      field :game_name, :string
      field :title, :string
      field :delay, :integer
      field :tags, {:array, :string}
      field :content_classification_labels, {:array, :string}
      field :is_branded_content, :boolean
    end

    @type t() :: %__MODULE__{
            broadcaster_id: String.t(),
            broadcaster_login: String.t(),
            broadcaster_name: String.t(),
            broadcaster_language: String.t(),
            game_id: String.t(),
            game_name: String.t(),
            title: String.t(),
            delay: non_neg_integer(),
            tags: list(String.t()),
            content_classification_labels: list(String.t()),
            is_branded_content: boolean()
          }

    @spec changeset(entity_or_changeset :: t() | Ecto.Changeset.t(t()), params :: map()) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(
        params,
        ~w(broadcaster_id broadcaster_login broadcaster_name broadcaster_language game_id game_name title delay tags content_classification_labels is_branded_content)a
      )
      |> validate_required(
        ~w(broadcaster_id broadcaster_login broadcaster_name delay tags content_classification_labels is_branded_content)a
      )
      |> validate_number(:delay, greater_than_or_equal_to: 0)
    end
  end

  @doc """
  Gets information about one or more channels.

  Each entry of the list is a struct of `t:Twex.Helix.Channels.ChannelInformation.t/0`.

  An ID will be skipped when Twitch could not found the corresponding broadcaster.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-channel-information
  """
  @spec get_channel_information(http_client :: Tesla.Client.t(), broadcaster_ids :: list(String.t())) ::
          Twex.Http.response(list(ChannelInformation.t()), term())
          | {:error, :invalid_response}
  def get_channel_information(http_client, broadcaster_ids) do
    query_param = Enum.map_join(broadcaster_ids, "&", &("broadcaster_id=" <> &1))

    http_client
    |> Tesla.get("/channels?" <> query_param)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"data" => entries}} ->
        entries
        |> Enum.map(&ChannelInformation.changeset(%ChannelInformation{}, &1))
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  @doc """
  Returns the channel information for the given broadcaster ID.

  In case of success the following tuple will be returned:

  ```elixir
  {:ok, %Twex.Helix.Channels.ChannelInformation{}}
  ```

  When the broadcaster with the given ID could not be found it returns the following tuple:

  ```elixir
  {:error, :channel_not_found}
  ```
  """
  @spec get_single_channel_information(http_client :: Tesla.Client.t(), broadcaster_id :: String.t()) ::
          Twex.Http.response(ChannelInformation.t(), term())
          | {:error, :invalid_response}
          | {:error, :channel_not_found}
  def get_single_channel_information(http_client, broadcaster_id) do
    case get_channel_information(http_client, [broadcaster_id]) do
      {:ok, []} ->
        {:error, :channel_not_found}

      {:ok, [channel_information]} ->
        {:ok, channel_information}

      error_value ->
        error_value
    end
  end

  @doc """
  Updates a channel's properties.

  Look at the referenced URL to check which fields can be updated.

  ## Hint

  Requires a user access token that includes the `channel:manage:broadcast` scope.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#modify-channel-information
  """
  @spec modify_channel_information(
          http_client :: Tesla.Client.t(),
          broadcaster_id :: String.t(),
          fields_to_update :: map()
        ) ::
          :ok
          | {:error, :invalid_response}
          | Twex.Http.error_response(term())
  def modify_channel_information(http_client, broadcaster_id, fields_to_update) do
    http_client
    |> Tesla.patch("/channels?", fields_to_update, query: [broadcaster_id: broadcaster_id])
    |> Twex.Http.process_tesla_response(204)
    |> case do
      {:ok, ""} ->
        :ok

      error_value ->
        error_value
    end
  end

  defmodule ChannelEditor do
    @moduledoc """
    Contains information about one single channel editor.

    The information includes the following items:

    | Name       | Description                                                            |
    | :--------- | :--------------------------------------------------------------------- |
    | user_id    | The unique identifier of the user with editor permissions              |
    | user_name  | The unique name of the user                                            |
    | created_at | The timestamp when the broadcaster gave editor permissions to the user |
    """

    use Twex.Http.Response

    embedded_schema do
      field :user_id, :string
      field :user_name, :string
      field :created_at, :utc_datetime
    end

    @type t() :: %__MODULE__{
            user_id: String.t(),
            user_name: String.t(),
            created_at: DateTime.t()
          }

    @spec changeset(entity_or_changeset :: t() | Ecto.Changeset.t(t()), params :: map()) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(user_id user_name created_at)a)
      |> validate_required(~w(user_id user_name created_at)a)
    end
  end

  @doc """
  Gets the broadcaster's list editors.

  Each entry is a struct instance of `Twex.Helix.Channels.ChannelEditor`.

  ## Hint

  Requires a user access token that includes the `channel:read:editors` scope.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-channel-editors
  """
  @spec get_channel_editors(http_client :: Tesla.Client.t(), broadcaster_id :: String.t()) ::
          Twex.Http.response(list(ChannelEditor.t()), map()) | {:error, :invalid_response}
  def get_channel_editors(http_client, broadcaster_id) do
    http_client
    |> Tesla.get("/channels/editors", query: [broadcaster_id: broadcaster_id])
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"data" => channel_editors}} ->
        channel_editors
        |> Enum.map(&ChannelEditor.changeset(%ChannelEditor{}, &1))
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule FollowedChannelsResponse do
    @moduledoc """
    The successful response when the followed channels could be retrieved.
    """

    use Twex.Http.Response

    alias Twex.Helix.Channels.FollowedChannelsResponse.FollowedChannel
    alias Twex.Helix.Channels.FollowedChannelsResponse.Pagination

    defmodule FollowedChannel do
      @moduledoc """
      Contains information about a channel which was followed by a user.

      The information includes the following data:

      | Name              | Description                                          |
      | :---------------- | :--------------------------------------------------- |
      | broadcaster_id    | The unique identifier of the followed broadcaster    |
      | broadcaster_login | The unique name of the broadcaster                   |
      | broadcaster_name  | The localized name of the broadcaster                |
      | followed_at       | The timestamp when the user followed the broadcaster |
      """

      use Twex.Http.Response

      embedded_schema do
        field :broadcaster_id, :string
        field :broadcaster_login, :string
        field :broadcaster_name, :string
        field :followed_at, :utc_datetime
      end

      @type t() :: %__MODULE__{
              broadcaster_id: String.t(),
              broadcaster_login: String.t(),
              broadcaster_name: String.t(),
              followed_at: DateTime.t()
            }

      @spec changeset(
              schema :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(schema, params) do
        schema
        |> cast(params, ~w(broadcaster_id broadcaster_login broadcaster_name followed_at)a)
        |> validate_required(~w(broadcaster_id broadcaster_login broadcaster_name followed_at)a)
      end
    end

    defmodule Pagination do
      @moduledoc """
      Contains the information used to page through the list of results.
      """

      use Twex.Http.Response

      embedded_schema do
        field :cursor, :string
      end

      @type t() :: %__MODULE__{
              cursor: String.t()
            }

      @spec changeset(
              schema :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(schema, params), do: cast(schema, params, ~w(cursor)a)
    end

    embedded_schema do
      embeds_many :data, FollowedChannel
      embeds_one :pagination, Pagination
      field :total, :integer
    end

    @type t() :: %__MODULE__{
            data: list(FollowedChannel.t()),
            pagination: Pagination.t() | nil,
            total: non_neg_integer()
          }

    @spec changeset(entity_or_changeset :: t() | Ecto.Changeset.t(t()), params :: map()) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(total)a)
      |> cast_embed(:data)
      |> cast_embed(:pagination)
      |> validate_required(~w(total)a)
    end
  end

  @doc """
  Gets a list of broadcasters that the specified user follows. You can also use this endpoint to see whether a user follows a specific broadcaster.

  The `opts` argument supports the following optional keys:

  | Name           | Type              | Description                                                                                                                                                                                                                                             |
  | :------------- | :---------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | broadcaster_id | `t:String.t/0`    | A broadcaster's ID. Use this parameter to see whether the user follows this broadcaster. If specified, the response contains this broadcaster if the user follows them. If not specified, the response contains all broadcasters that the user follows. |
  | first          | `t:pos_integer/0` | The maximum number of items to return per page in the response. The minimum page size is 1 item per page and the maximum is 100. The default is 20.                                                                                                     |
  | after          | `t:String.t/0`    | The cursor used to get the next page of results. The `pagination` object in the response contains the cursor's value.                                                                                                                                   |

  ## Hint

  The response might be paginated! So make sure to check if the `pagination` value is nil!

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-followed-channels
  """
  @spec get_followed_channels(http_client :: Tesla.Client.t(), user_id :: String.t()) ::
          Twex.Http.response(FollowedChannelsResponse.t(), map()) | {:error, :invalid_response}
  @spec get_followed_channels(http_client :: Tesla.Client.t(), user_id :: String.t(), opts :: keyword()) ::
          Twex.Http.response(FollowedChannelsResponse.t(), map()) | {:error, :invalid_response}
  def get_followed_channels(http_client, user_id, opts \\ []) do
    query_params = Keyword.put(opts, :user_id, user_id)

    http_client
    |> Tesla.get("/channels/followed", query: query_params)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, response_data} ->
        %FollowedChannelsResponse{}
        |> FollowedChannelsResponse.changeset(response_data)
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule ChannelFollowersResponse do
    @moduledoc """
    The successful response when the channel followers could be retrieved.
    """
    use Twex.Http.Response

    alias Twex.Helix.Channels.ChannelFollowersResponse.ChannelFollower
    alias Twex.Helix.Channels.ChannelFollowersResponse.Pagination

    embedded_schema do
      embeds_many :data, ChannelFollower, primary_key: false do
        field :user_id, :string
        field :user_login, :string
        field :user_name, :string
        field :followed_at, :utc_datetime
      end

      embeds_one :pagination, Pagination, primary_key: false do
        field :cursor, :string
      end

      field :total, :integer
    end

    @type channel_follower() :: %ChannelFollower{
            user_id: String.t(),
            user_login: String.t(),
            user_name: String.t(),
            followed_at: DateTime.t()
          }

    @type pagination() :: %Pagination{
            cursor: String.t()
          }

    @type t() :: %__MODULE__{
            data: list(channel_follower()),
            pagination: pagination() | nil,
            total: non_neg_integer()
          }

    @spec changeset(entity_or_changeset :: t() | Ecto.Changeset.t(t()), params :: map()) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(total)a)
      |> cast_embed(:data, with: &channel_follower_changeset/2)
      |> cast_embed(:pagination, with: &pagination_changeset/2)
      |> validate_required(~w(total)a)
    end

    @spec channel_follower_changeset(
            schema :: channel_follower() | Ecto.Changeset.t(channel_follower()),
            params :: map()
          ) :: Ecto.Changeset.t(channel_follower())
    def channel_follower_changeset(schema, params) do
      schema
      |> cast(params, ~w(user_id user_login user_name followed_at)a)
      |> validate_required(~w(user_id user_login user_name followed_at)a)
    end

    @spec pagination_changeset(
            schema :: pagination() | Ecto.Changeset.t(pagination()),
            params :: map()
          ) :: Ecto.Changeset.t(pagination())
    def pagination_changeset(schema, params), do: cast(schema, params, ~w(cursor)a)
  end

  @doc """
  This endpoint will return specific follower information only if both of the above are true. If a scope is not provided or the user isn’t the broadcaster or a moderator for the specified channel, only the total follower count will be included in the response.

  The `opts` argument supports the following optional keys:

  | Name    | Type              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
  | :------ | :---------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | user_id | `t:String.t/0`    | A user’s ID. Use this parameter to see whether the user follows this broadcaster. If specified, the response contains this user if they follow the broadcaster. If not specified, the response contains all users that follow the broadcaster. Using this parameter requires both a user access token with the moderator:read:followers scope and the user ID in the access token match the broadcaster_id or be the user ID for a moderator of the specified broadcaster. |
  | first   | `t:pos_integer/0` | The maximum number of items to return per page in the response. The minimum page size is 1 item per page and the maximum is 100. The default is 20.                                                                                                                                                                                                                                                                                                                        |
  | after   | `t:String.t/0`    | The cursor used to get the next page of results. The `pagination` object in the response contains the cursor's value.                                                                                                                                                                                                                                                                                                                                                      |

  ## Hint

  Requires a user access token that includes the `moderator:read:followers` scope.

  The ID in the `broadcaster_id` query parameter must match the user ID in the access token or the user ID in the access token must be a moderator for the specified broadcaster.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-channel-followers
  """
  @spec get_channel_followers(
          http_client :: Tesla.Client.t(),
          broadcaster_id :: String.t()
        ) :: Twex.Http.response(ChannelFollowersResponse.t(), map()) | {:error, :invalid_response}
  @spec get_channel_followers(
          http_client :: Tesla.Client.t(),
          broadcaster_id :: String.t(),
          opts :: keyword()
        ) :: Twex.Http.response(ChannelFollowersResponse.t(), map()) | {:error, :invalid_response}
  def get_channel_followers(http_client, broadcaster_id, opts \\ []) do
    query_params = Keyword.put(opts, :broadcaster_id, broadcaster_id)

    http_client
    |> Tesla.get("/channels/followers", query: query_params)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, response_data} ->
        %ChannelFollowersResponse{}
        |> ChannelFollowersResponse.changeset(response_data)
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end
end
