defmodule Twex.Helix.Analytics do
  @moduledoc """
  This module contains all extension analytics endpoints.
  """

  defmodule ExtensionAnalyticsResponse do
    @moduledoc """
    Contains the data when the `Twex.Helix.Analytics.get_extension_analytics/2` request was successful.

    It contains the following information:

    | Name       | Data type                     | Description                                                                                                                                                                                                                                                                                                                                       |
    | :--------- | :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
    | data       | `t:list/1`                    | A list of reports. The reports are returned in no particular order; however, the data within each report is in ascending order by date (newest first). The report contains one row of data per day of the reporting window; the report contains rows for only those days that the extension was used. The array is empty if there are no reports. |
    | pagination | `t:Twex.Helix.Pagination.t/0` | Contains the information used to page through the list of results. The object is nil if there are no more pages left to page through.                                                                                                                                                                                                             |
    """

    use Twex.Http.Response

    alias Twex.Helix.Analytics.AnalyticsReport
    alias Twex.Helix.Pagination

    defmodule AnalyticsReport do
      @moduledoc """
      Contains information about one analytics report.

      The information includes the following items:

      | Name         | Description                                                                                                                             |
      | :----------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
      | extension_id | The unique identifier of the extension.                                                                                                 |
      | url          | The URL that you use to download the report. The URL is valid for 5 minutes.                                                            |
      | type         | The type of report.                                                                                                                     |
      | date_range   | An object which includes the start and end date of the report.                                                                          |
      | pagination   | Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. |
      """

      use Twex.Http.Response

      alias Twex.Helix.DateRange
      alias Twex.Helix.Pagination

      embedded_schema do
        field :extension_id, :string
        field :url, :string
        field :type, :string
        embeds_one :date_range, DateRange
        embeds_one :pagination, Pagination
      end

      @type t() :: %__MODULE__{
              extension_id: String.t(),
              url: String.t(),
              type: String.t(),
              date_range: DateRange.t(),
              pagination: Pagination.t()
            }

      @spec changeset(
              entity_or_changeset :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(entity_or_changeset, params) do
        updated_params =
          params
          |> Map.put("url", Map.get(params, "URL"))
          |> Map.delete("URL")

        entity_or_changeset
        |> cast(updated_params, ~w(extension_id url type)a)
        |> validate_required(~w(extension_id url type)a)
        |> cast_embed(:date_range, required: true)
      end
    end

    embedded_schema do
      embeds_many :data, AnalyticsReport
      embeds_one :pagination, Pagination
    end

    @type t() :: %__MODULE__{
            data: list(AnalyticsReport.t()),
            pagination: Pagination.t()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, [])
      |> cast_embed(:data)
      |> cast_embed(:pagination)
    end
  end

  @doc """
  Gets an analytics report for one or more extensions.

  The response contains the URLs used to download the reports (CSV files).

  Read more about the CSV fields [here](https://dev.twitch.tv/docs/insights/).

  ## Hint

  Requires a user access token that includes the `analytics:read:extensions` scope.

  The `filter_options` supports the following keys:

  | Name         | Data type         | Description                                                                                                                                                            |
  | :----------- | :---------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | extension_id | `t:String.t/0`    | The unique identifier of the extension to filter for.                                                                                                                  |
  | type         | `t:String.t/0`    | The type of analytics report to get. Possible values are: overview_v2                                                                                                  |
  | started_at   | `t:String.t/0`    | The reporting window's start date, in RFC3339 format. Set the time portion to zeroes (for example, 2021-10-22T00:00:00Z).                                              |
  | ended_at     | `t:String.t/0`    | The reporting window's end date, in RFC3339 format. Set the time portion to zeroes (for example, 2021-10-27T00:00:00Z). The report is inclusive of the end date.       |
  | first        | `t:pos_integer/0` | The maximum number of report URLs to return per page in the response. The minimum page size is 1 URL per page and the maximum is 100 URLs per page. The default is 20. |
  | after        | `t:String.t/0`    | The cursor used to get the next page of results. The Pagination object in the response contains the cursor's value.                                                    |

  ## Hints for the filter options

  ### started_at

  The start date must be on or after January 31, 2018. If you specify an earlier date, the API ignores it and uses January 31, 2018.
  If you specify a start date, you must specify an end date.
  If you don't specify a start and end date, the report includes all available data since January 31, 2018.

  The report contains one row of data for each day in the reporting window.

  ### ended_at

  Specify an end date only if you provide a start date.
  Because it can take up to two days for the data to be available, you must specify an end date that's earlier than today minus one to two days.
  If not, the API ignores your end date and uses an end date that is today minus one to two days.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-extension-analytics
  """
  @spec get_extension_analytics(http_client :: Tesla.Client.t()) ::
          Twex.Http.response(ExtensionAnalyticsResponse.t(), term()) | {:error, :invalid_response}
  @spec get_extension_analytics(
          http_client :: Tesla.Client.t(),
          filter_options :: keyword()
        ) :: Twex.Http.response(ExtensionAnalyticsResponse.t(), term()) | {:error, :invalid_response}
  def get_extension_analytics(http_client, filter_options \\ []) do
    http_client
    |> Tesla.get("/analytics/extensions", query: filter_options)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, extension_analytics_report_response} ->
        %ExtensionAnalyticsResponse{}
        |> ExtensionAnalyticsResponse.changeset(extension_analytics_report_response)
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule GameAnalyticsResponse do
    @moduledoc """
    Contains the data when the `Twex.Helix.Analytics.get_extension_analytics/2` request was successful.

    It contains the following information:

    | Name       | Data type                     | Description                                                                                                                                                                                                                                                                                                                                       |
    | :--------- | :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
    | data       | `t:list/1`                    | A list of reports. The reports are returned in no particular order; however, the data within each report is in ascending order by date (newest first). The report contains one row of data per day of the reporting window; the report contains rows for only those days that the extension was used. The array is empty if there are no reports. |
    | pagination | `t:Twex.Helix.Pagination.t/0` | Contains the information used to page through the list of results. The object is nil if there are no more pages left to page through.                                                                                                                                                                                                             |
    """

    use Twex.Http.Response

    alias Twex.Helix.Analytics.AnalyticsReport
    alias Twex.Helix.Pagination

    defmodule AnalyticsReport do
      @moduledoc """
      Contains information about one analytics report.

      The information includes the following items:

      | Name         | Description                                                                                                                             |
      | :----------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
      | game_id      | The unique identifier of the game.                                                                                                      |
      | url          | The URL that you use to download the report. The URL is valid for 5 minutes.                                                            |
      | type         | The type of report.                                                                                                                     |
      | date_range   | An object which includes the start and end date of the report.                                                                          |
      | pagination   | Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. |
      """

      use Twex.Http.Response

      alias Twex.Helix.DateRange
      alias Twex.Helix.Pagination

      embedded_schema do
        field :game_id, :string
        field :url, :string
        field :type, :string
        embeds_one :date_range, DateRange
        embeds_one :pagination, Pagination
      end

      @type t() :: %__MODULE__{
              game_id: String.t(),
              url: String.t(),
              type: String.t(),
              date_range: DateRange.t(),
              pagination: Pagination.t()
            }

      @spec changeset(
              entity_or_changeset :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(entity_or_changeset, params) do
        updated_params =
          params
          |> Map.put("url", Map.get(params, "URL"))
          |> Map.delete("URL")

        entity_or_changeset
        |> cast(updated_params, ~w(game_id url type)a)
        |> validate_required(~w(game_id url type)a)
        |> cast_embed(:date_range, required: true)
      end
    end

    embedded_schema do
      embeds_many :data, AnalyticsReport
      embeds_one :pagination, Pagination
    end

    @type t() :: %__MODULE__{
            data: list(AnalyticsReport.t()),
            pagination: Pagination.t()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, [])
      |> cast_embed(:data)
      |> cast_embed(:pagination)
    end
  end

  @doc """
  Gets an analytics report for one or more games.

  The response contains the URLs used to download the reports (CSV files).

  ## Hint

  Requires a user access token that includes the `analytics:read:games` scope.

  The `filter_options` supports the following keys:

  | Name         | Data type         | Description                                                                                                                                                            |
  | :----------- | :---------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | game_id      | `t:String.t/0`    | The unique identifier of the game to filter for.                                                                                                                       |
  | type         | `t:String.t/0`    | The type of analytics report to get. Possible values are: overview_v2                                                                                                  |
  | started_at   | `t:String.t/0`    | The reporting window's start date, in RFC3339 format. Set the time portion to zeroes (for example, 2021-10-22T00:00:00Z).                                              |
  | ended_at     | `t:String.t/0`    | The reporting window's end date, in RFC3339 format. Set the time portion to zeroes (for example, 2021-10-27T00:00:00Z). The report is inclusive of the end date.       |
  | first        | `t:pos_integer/0` | The maximum number of report URLs to return per page in the response. The minimum page size is 1 URL per page and the maximum is 100 URLs per page. The default is 20. |
  | after        | `t:String.t/0`    | The cursor used to get the next page of results. The Pagination object in the response contains the cursor's value.                                                    |

  ## Hints for the filter options

  ### started_at

  The start date must be within one year of today’s date.
  If you specify an earlier date, the API ignores it and uses a date that’s one year prior to today’s date.
  If you don’t specify a start and end date, the report includes all available data for the last 365 days from today.

  The report contains one row of data for each day in the reporting window.

  ### ended_at

  Specify an end date only if you provide a start date.
  Because it can take up to two days for the data to be available, you must specify an end date that’s earlier than today minus one to two days.
  If not, the API ignores your end date and uses an end date that is today minus one to two days.

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-game-analytics
  """
  @spec get_game_analytics(
          http_client :: Tesla.Client.t(),
          filter_options :: keyword()
        ) :: Twex.Http.response(GameAnalyticsResponse.t(), term())
  def get_game_analytics(http_client, filter_options) do
    http_client
    |> Tesla.get("/analytics/games", query: filter_options)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, game_analytics_report_response} ->
        %ExtensionAnalyticsResponse{}
        |> ExtensionAnalyticsResponse.changeset(game_analytics_report_response)
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end
end
