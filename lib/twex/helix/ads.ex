defmodule Twex.Helix.Ads do
  @moduledoc """
  This module contains all channel advertisement endpoints.
  """

  defmodule StartCommercialResponse do
    @moduledoc """
    Contains information when the broadcaster requested to start a commercial.

    The information includes the following items:

    | Name        | Description                                                                                                                       |
    | :---------- | :-------------------------------------------------------------------------------------------------------------------------------- |
    | length      | The length of the commercial you requested. If you request a commercial that's longer than 180 seconds, the API uses 180 seconds. |
    | message     | A message that indicates whether Twitch was able to serve an ad. It will be empty when the request was successful.                |
    | retry_after | The number of seconds you must wait before running another commercial.                                                            |

    """
    use Twex.Http.Response

    embedded_schema do
      field :length, :integer
      field :message, :string
      field :retry_after, :integer
    end

    @type t() :: %__MODULE__{
            length: integer(),
            message: String.t(),
            retry_after: integer()
          }

    @spec changeset(entity_or_changeset :: t() | Ecto.Changeset.t(t()), params :: map()) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(length retry_after)a)
      |> validate_required(~w(length retry_after)a)
      |> put_change(:message, Map.get(params, "message"))
    end
  end

  @doc """
  Starts a commercial on the specified channel.

  ## Hint

  NOTE: Only partners and affiliates may run commercials and they must be streaming live at the time.

  NOTE: Only the broadcaster may start a commercial; the broadcaster’s editors and moderators may not start commercials on behalf of the broadcaster.

  Requires a user access token that includes the `channel:edit:commercial` scope.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#start-commercial
  """
  @spec start_commercial(
          http_client :: Tesla.Client.t(),
          broadcaster_id :: String.t(),
          commercial_length :: 1..180
        ) ::
          Twex.Http.response(list(StartCommercialResponse.t()), term())
          | {:error, :invalid_response}
  def start_commercial(http_client, broadcaster_id, commercial_length) do
    http_client
    |> Tesla.post("/channels/commercial", %{broadcaster_id: broadcaster_id, length: commercial_length}, [])
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"data" => data}} ->
        data
        |> Enum.map(&StartCommercialResponse.changeset(%StartCommercialResponse{}, &1))
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule AdScheduleEntry do
    @moduledoc """
    Contains information about one single ad schedule.

    The information includes the following items:

    | Name              | Description                                                                                                               |
    | :---------------- | :------------------------------------------------------------------------------------------------------------------------ |
    | snooze_count      | The number of snoozes available for the broadcaster.                                                                      |
    | snooze_refresh_at | The UTC timestamp when the broadcaster will gain an additional snooze.                                                    |
    | next_ad_at        | The UTC timestamp of the broadcaster's next scheduled ad. Nil if the channel has no ad scheduled or is not live.          |
    | last_ad_at        | The UTC timestamp of the broadcaster’s last ad-break. Nil if the channel has not run an ad or is not live.                |
    | duration          | The length in seconds of the scheduled upcoming ad break.                                                                 |
    | preroll_free_time | The amount of pre-roll free time remaining for the channel in seconds. Returns 0 if they are currently not pre-roll free. |
    """

    use Twex.Http.Response

    embedded_schema do
      field :snooze_count, :integer
      field :snooze_refresh_at, :utc_datetime
      field :next_ad_at, :utc_datetime
      field :last_ad_at, :utc_datetime
      field :duration, :integer
      field :preroll_free_time, :integer
    end

    @type t() :: %__MODULE__{
            snooze_count: non_neg_integer(),
            snooze_refresh_at: DateTime.t(),
            next_ad_at: DateTime.t() | nil,
            last_ad_at: DateTime.t() | nil,
            duration: non_neg_integer(),
            preroll_free_time: non_neg_integer()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(snooze_count snooze_refresh_at next_ad_at last_ad_at duration preroll_free_time)a)
      |> validate_required(~w(snooze_count snooze_refresh_at duration preroll_free_time)a)
    end
  end

  @doc """
  This endpoint returns ad schedule related information, including snooze, when the last ad was run, when the next ad is scheduled, and if the channel is currently in pre-roll free time.

  Note that a new ad cannot be run until 8 minutes after running a previous ad.

  ## Hint

  Requires a user access token that includes the `channel:read:ads` scope.
  The `user_id` in the user access token must match the `broadcaster_id`.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-ad-schedule
  """
  @spec get_ad_schedule(
          http_client :: Tesla.Client.t(),
          broadcaster_id :: String.t()
        ) ::
          Twex.Http.response(list(AdScheduleEntry.t()), term())
          | {:error, :invalid_response}
  def get_ad_schedule(http_client, broadcaster_id) do
    http_client
    |> Tesla.get("/channels/ads", query: [broadcaster_id: broadcaster_id])
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"data" => ad_schedule_entries}} ->
        ad_schedule_entries
        |> Enum.map(&AdScheduleEntry.changeset(%AdScheduleEntry{}, &1))
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule SnoozeEntry do
    @moduledoc """
    Contains information about one single ad snooze entry.

    The information includes the following items:

    | Name              | Description                                                            |
    | :---------------- | :--------------------------------------------------------------------- |
    | snooze_count      | The number of snoozes available for the broadcaster.                   |
    | snooze_refresh_at | The UTC timestamp when the broadcaster will gain an additional snooze. |
    | next_ad_at        | The UTC timestamp of the broadcaster’s next scheduled ad.              |
    """
    use Twex.Http.Response

    embedded_schema do
      field :snooze_count, :integer
      field :snooze_refresh_at, :utc_datetime
      field :next_ad_at, :utc_datetime
    end

    @type t() :: %__MODULE__{
            snooze_count: integer(),
            snooze_refresh_at: DateTime.t(),
            next_ad_at: DateTime.t()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(snooze_count snooze_refresh_at next_ad_at)a)
      |> validate_required(~w(snooze_count snooze_refresh_at next_ad_at)a)
    end
  end

  @doc """
  If available, pushes back the timestamp of the upcoming automatic mid-roll ad by 5 minutes.

  This endpoint duplicates the snooze functionality in the creator dashboard’s Ads Manager.

  ## Hint

  Requires a user access token that includes the channel:manage:ads scope.
  The user_id in the user access token must match the broadcaster_id.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#snooze-next-ad
  """
  @spec snooze_next_ad(
          http_client :: Tesla.Client.t(),
          broadcaster_id :: String.t()
        ) :: Twex.Http.response(list(SnoozeEntry.t()), term()) | {:error, :invalid_response}
  def snooze_next_ad(http_client, broadcaster_id) do
    http_client
    |> Tesla.post("/channels/ads/schedule/snooze", "", query: [broadcaster_id: broadcaster_id])
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"data" => snooze_entries}} ->
        snooze_entries
        |> Enum.map(&SnoozeEntry.changeset(%SnoozeEntry{}, &1))
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end
end
