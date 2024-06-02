defmodule Twex.Helix.Bits do
  @moduledoc """
  This module contains all bit related endpoints.
  """

  defmodule BitsLeaderboardResponse do
    @moduledoc """
    This module defines a struct with the following fields:

    | Name       | Description                                                                                                                                                                                                                         |
    | :--------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | data       | A list of leaderboard leaders. The leaders are returned in rank order by how much they've cheered. The array is empty if nobody has cheered bits.                                                                                   |
    | date_range | The reporting window's start and end dates. The dates are calculated by using the started_at and period query parameters. If you don't specify the started_at query parameter, the fields contain empty strings.                    |
    | total      | The number of ranked users in data. This is the value in the count query parameter or the total number of entries on the leaderboard, whichever is less.                                                                            |
    """

    use Twex.Http.Response

    alias Twex.Helix.DateRange

    defmodule BitsLeaderboardEntry do
      @moduledoc """
      This module defines a struct with the following fields:

      | Name       | Description                                      |
      | :--------- | :----------------------------------------------- |
      | user_id    | An ID that identifies a user on the leaderboard. |
      | user_login | The user's login name.                           |
      | user_name  | The user's display name.                         |
      | rank       | The user's position on the leaderboard.          |
      | score      | The number of Bits the user has cheered.         |
      """

      use Twex.Http.Response

      embedded_schema do
        field :user_id, :string
        field :user_login, :string
        field :user_name, :string
        field :rank, :integer
        field :score, :integer
      end

      @type t() :: %__MODULE__{
              user_id: String.t(),
              user_login: String.t(),
              user_name: String.t(),
              rank: integer(),
              score: integer()
            }

      @spec changeset(
              entity_or_changeset :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(entity_or_changeset, params) do
        entity_or_changeset
        |> cast(params, ~w(user_id user_login user_name rank score)a)
        |> validate_required(~w(user_id user_login user_name rank score)a)
      end
    end

    embedded_schema do
      embeds_many :data, BitsLeaderboardEntry
      embeds_one :date_range, DateRange
      field :total, :integer
    end

    @type t() :: %__MODULE__{
            data: BitsLeaderboardEntry.t(),
            date_range: DateRange.t(),
            total: integer()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(total)a)
      |> cast_embed(:data)
      |> cast_embed(:date_range)
      |> validate_required(~w(total)a)
    end
  end

  @doc """
  Gets the Bits leaderboard for the authenticated broadcaster.

  ## Hint

  Requires a user access token that includes the `bits:read` scope.

  ## Filter options

  | Name       | Data type      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
  | :--------- | :------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | count      | `t:integer/0`  | The number of results to return. The minimum count is 1 and the maximum is 100. The default is 10.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
  | period     | `t:String.t/0` | The time period over which data is aggregated (uses the PST time zone). Possible values are: `day` — A day spans from 00:00:00 on the day specified in started_at and runs through 00:00:00 of the next day. `week` — A week spans from 00:00:00 on the Monday of the week specified in started_at and runs through 00:00:00 of the next Monday. `month` — A month spans from 00:00:00 on the first day of the month specified in started_at and runs through 00:00:00 of the first day of the next month. `year` — A year spans from 00:00:00 on the first day of the year specified in started_at and runs through 00:00:00 of the first day of the next year. `all` — Default. The lifetime of the broadcaster's channel. |
  | started_at | `t:String.t/0` | The start date, in RFC3339 format, used for determining the aggregation period. Specify this parameter only if you specify the period query parameter. The start date is ignored if period is all.Note that the date is converted to PST before being used, so if you set the start time to 2022-01-01T00:00:00.0Z and period to month, the actual reporting period is December 2021, not January 2022. If you want the reporting period to be January 2022, you must set the start time to 2022-01-01T08:00:00.0Z or 2022-01-01T00:00:00.0-08:00.If your start date uses the ‘+’ offset operator (for example, 2022-01-01T00:00:00.0+05:00), you must URL encode the start date.                                            |
  | user_id    | `t:String.t/0` | An ID that identifies a user that cheered bits in the channel. If count is greater than 1, the response may include users ranked above and below the specified user. To get the leaderboard’s top leaders, don’t specify a user ID.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-bits-leaderboard
  """
  @spec get_bits_leaderboard(http_client :: Tesla.Client.t()) ::
          Twex.Http.response(BitsLeaderboardResponse.t(), term()) | {:error, :invalid_response}
  @spec get_bits_leaderboard(
          http_client :: Tesla.Client.t(),
          filter_options :: keyword()
        ) :: Twex.Http.response(BitsLeaderboardResponse.t(), term()) | {:error, :invalid_response}
  def get_bits_leaderboard(http_client, filter_options \\ []) do
    http_client
    |> Tesla.get("/bits/leaderboard", query: filter_options)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, response} ->
        %BitsLeaderboardResponse{}
        |> BitsLeaderboardResponse.changeset(response)
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule Cheermote do
    @moduledoc """
    This module defines a struct with the following fields:

    | Name          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    | :------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | prefix        | The name portion of the Cheermote string that you use in chat to cheer Bits. The full Cheermote string is the concatenation of {prefix} + {number of Bits}. For example, if the prefix is “Cheer” and you want to cheer 100 Bits, the full Cheermote string is Cheer100. When the Cheermote string is entered in chat, Twitch converts it to the image associated with the Bits tier that was cheered.                                                                                                                                                                              |
    | tiers         | A list of tier levels that the Cheermote supports. Each tier identifies the range of Bits that you can cheer at that tier level and an image that graphically identifies the tier level.                                                                                                                                                                                                                                                                                                                                                                                            |
    | type          | The type of Cheermote. Possible values are:global_first_party — A Twitch-defined Cheermote that is shown in the Bits card.global_third_party — A Twitch-defined Cheermote that is not shown in the Bits card.channel_custom — A broadcaster-defined Cheermote.display_only — Do not use; for internal use only.sponsored — A sponsor-defined Cheermote. When used, the sponsor adds additional Bits to the amount that the user cheered. For example, if the user cheered Terminator100, the broadcaster might receive 110 Bits, which includes the sponsor's 10 Bits contribution. |
    | order         | The order that the Cheermotes are shown in the Bits card. The numbers may not be consecutive. For example, the numbers may jump from 1 to 7 to 13. The order numbers are unique within a Cheermote type (for example, global_first_party) but may not be unique amongst all Cheermotes in the response.                                                                                                                                                                                                                                                                             |
    | last_updated  | The date and time, in RFC3339 format, when this Cheermote was last updated.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    | is_charitable | A Boolean value that indicates whether this Cheermote provides a charitable contribution match during charity campaigns.                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
    """

    use Twex.Http.Response

    defmodule Tier do
      @moduledoc """
      This module defines a struct with the following fields:

      | Name              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | :---------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
      | min_bits          | The minimum number of Bits that you must cheer at this tier level. The maximum number of Bits that you can cheer at this level is determined by the required minimum Bits of the next tier level minus 1. For example, if min_bits is 1 and min_bits for the next tier is 100, the Bits range for this tier level is 1 through 99. The minimum Bits value of the last tier is the maximum number of Bits you can cheer using this Cheermote. For example, 10000. |
      | id                | The tier level. Possible tiers are: 1, 100, 500, 1000, 5000, 10000, 100000                                                                                                                                                                                                                                                                                                                                                                                       |
      | color             | The hex code of the color associated with this tier level (for example, #979797).                                                                                                                                                                                                                                                                                                                                                                                |
      | images            | The animated and static image sets for the Cheermote. The dictionary of images is organized by theme, format, and size. The theme keys are dark and light. Each theme is a dictionary of formats: animated and static. Each format is a dictionary of sizes: 1, 1.5, 2, 3, and 4. The value of each size contains the URL to the image.                                                                                                                          |
      | can_cheer         | A Boolean value that determines whether users can cheer at this tier level.                                                                                                                                                                                                                                                                                                                                                                                      |
      | show_in_bits_card | A Boolean value that determines whether this tier level is shown in the Bits card. Is true if this tier level is shown in the Bits card.                                                                                                                                                                                                                                                                                                                         |
      """

      use Twex.Http.Response

      embedded_schema do
        field :min_bits, :integer
        field :id, :string
        field :color, :string
        field :images, :map
        field :can_cheer, :boolean
        field :show_in_bits_card, :boolean
      end

      @type t() :: %__MODULE__{
              min_bits: integer(),
              id: String.t(),
              color: String.t(),
              images: map(),
              can_cheer: boolean(),
              show_in_bits_card: boolean()
            }

      @spec changeset(
              entity_or_changeset :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(entity_or_changeset, params) do
        entity_or_changeset
        |> cast(params, ~w(min_bits id color images can_cheer show_in_bits_card)a)
        |> validate_required(~w(min_bits id color images can_cheer show_in_bits_card)a)
      end
    end

    embedded_schema do
      field :prefix, :string
      embeds_many :tiers, Tier
      field :type, :string
      field :order, :integer
      field :last_updated, :string
      field :is_charitable, :boolean
    end

    @type t() :: %__MODULE__{
            prefix: String.t(),
            tiers: list(Tier.t()),
            type: String.t(),
            order: integer(),
            last_updated: String.t(),
            is_charitable: boolean()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w(prefix type order last_updated is_charitable)a)
      |> cast_embed(:tiers)
      |> validate_required(~w(prefix type order last_updated is_charitable)a)
    end
  end

  @doc """
  Gets a list of Cheermotes that users can use to cheer Bits in any Bits-enabled channel's chat room.
  Cheermotes are animated emotes that viewers can assign Bits to.

  ## Hint

  Requires an app access token or user access token.

  ## Filter options

  | Name           | Data type      | Description                                                                                                                                                                                                                                                                                                                                                                     |
  | :------------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | broadcaster_id | `t:String.t/0` | The ID of the broadcaster whose custom Cheermotes you want to get. Specify the broadcaster's ID if you want to include the broadcaster's Cheermotes in the response (not all broadcasters upload Cheermotes). If not specified, the response contains only global Cheermotes.If the broadcaster uploaded Cheermotes, the type field in the response is set to `channel_custom`. |

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-cheermotes
  """
  @spec get_cheermotes(http_client :: Tesla.Client.t()) ::
          Twex.Http.response(list(Cheermote.t()), term()) | {:error, :invalid_response}
  @spec get_cheermotes(http_client :: Tesla.Client.t(), filter_options :: keyword()) ::
          Twex.Http.response(list(Cheermote.t()), term()) | {:error, :invalid_response}
  def get_cheermotes(http_client, filter_options \\ []) do
    http_client
    |> Tesla.get("/bits/cheermotes", query: filter_options)
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, %{"data" => cheermote_entries}} ->
        cheermote_entries
        |> Enum.map(&Cheermote.changeset(%Cheermote{}, &1))
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end

  defmodule ExtensionTransactionsResponse do
    @moduledoc """
    This module defines a struct with the following fields:

    | Name       | Description                                                                                                                                       |
    | :--------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
    | data       | The list of transactions.                                                                                                                         |
    | pagination | Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through. Read More |
    """

    use Twex.Http.Response

    alias Twex.Helix.Pagination

    defmodule ExtensionTransaction do
      @moduledoc """
      This module defines a struct with the following fields:

      | Name              | Description                                                                     |
      | :---------------- | :------------------------------------------------------------------------------ |
      | id                | An ID that identifies the transaction.                                          |
      | timestamp         | The UTC date and time (in RFC3339 format) of the transaction.                   |
      | broadcaster_id    | The ID of the broadcaster that owns the channel where the transaction occurred. |
      | broadcaster_login | The broadcaster's login name.                                                   |
      | broadcaster_name  | The broadcaster's display name.                                                 |
      | user_id           | The ID of the user that purchased the digital product.                          |
      | user_login        | The user's login name.                                                          |
      | user_name         | The user's display name.                                                        |
      | product_type      | The type of transaction. Possible values are:BITS_IN_EXTENSION                  |
      | product_data      | Contains details about the digital product.                                     |
      """

      use Twex.Http.Response

      defmodule ProductData do
        @moduledoc """
        This module defines a struct with the following fields:

        | Name          | Description                                                                                                                                      |
        | :------------ | :----------------------------------------------------------------------------------------------------------------------------------------------- |
        | sku           | An ID that identifies the digital product.                                                                                                       |
        | domain        | Set to twitch.ext. + <the extension's ID>.                                                                                                       |
        | cost          | Contains details about the digital product's cost.                                                                                               |
        | inDevelopment | A Boolean value that determines whether the product is in development. Is true if the digital product is in development and cannot be exchanged. |
        | displayName   | The name of the digital product.                                                                                                                 |
        | expiration    | This field is always empty since you may purchase only unexpired products.                                                                       |
        """

        use Twex.Http.Response

        defmodule Cost do
          @moduledoc """
          This module defines a struct with the following fields:

          | Name   | Description                                                 |
          | :----- | :---------------------------------------------------------- |
          | amount | The amount exchanged for the digital product.               |
          | type   | The type of currency exchanged. Possible values are: `bits` |
          """

          use Twex.Http.Response

          embedded_schema do
            field :amount, :integer
            field :type, :string
          end

          @type t() :: %__MODULE__{
                  amount: integer(),
                  type: String.t()
                }

          @spec changeset(
                  entity_or_changeset :: t() | Ecto.Changeset.t(t()),
                  params :: map()
                ) :: Ecto.Changeset.t(t())
          def changeset(entity_or_changeset, params) do
            entity_or_changeset
            |> cast(params, ~w(amount type)a)
            |> validate_required(~w(amount type)a)
          end
        end

        defmodule Expiration do
          @moduledoc """
          This module defines a struct with the following fields:

          | Name      | Description                                                                                                                                           |
          | :-------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- |
          | broadcast | A Boolean value that determines whether the data was broadcast to all instances of the extension. Is true if the data was broadcast to all instances. |
          """

          use Twex.Http.Response

          embedded_schema do
            field :broadcast, :boolean
          end

          @type t() :: %__MODULE__{
                  broadcast: boolean()
                }

          @spec changeset(
                  entity_or_changeset :: t() | Ecto.Changeset.t(t()),
                  params :: map()
                ) :: Ecto.Changeset.t(t())
          def changeset(entity_or_changeset, params) do
            entity_or_changeset
            |> cast(params, ~w(broadcast)a)
            |> validate_required(~w(broadcast)a)
          end
        end

        embedded_schema do
          field :sku, :string
          field :domain, :string
          embeds_one :cost, Cost
          field :inDevelopment, :boolean
          field :displayName, :string
          embeds_one :expiration, Expiration
        end

        @type t() :: %__MODULE__{
                sku: String.t(),
                domain: String.t(),
                cost: Cost.t(),
                inDevelopment: boolean(),
                displayName: String.t(),
                expiration: Expiration.t()
              }

        @spec changeset(
                entity_or_changeset :: t() | Ecto.Changeset.t(t()),
                params :: map()
              ) :: Ecto.Changeset.t(t())
        def changeset(entity_or_changeset, params) do
          entity_or_changeset
          |> cast(params, ~w(sku domain inDevelopment displayName)a)
          |> cast_embed(:cost)
          |> cast_embed(:expiration)
          |> validate_required(~w(sku domain inDevelopment displayName)a)
        end
      end

      embedded_schema do
        field :id, :string
        field :timestamp, :string
        field :broadcaster_id, :string
        field :broadcaster_login, :string
        field :broadcaster_name, :string
        field :user_id, :string
        field :user_login, :string
        field :user_name, :string
        field :product_type, :string
        embeds_one :product_data, ProductData
      end

      @type t() :: %__MODULE__{
              id: String.t(),
              timestamp: String.t(),
              broadcaster_id: String.t(),
              broadcaster_login: String.t(),
              broadcaster_name: String.t(),
              user_id: String.t(),
              user_login: String.t(),
              user_name: String.t(),
              product_type: String.t(),
              product_data: ProductData.t()
            }

      @spec changeset(
              entity_or_changeset :: t() | Ecto.Changeset.t(t()),
              params :: map()
            ) :: Ecto.Changeset.t(t())
      def changeset(entity_or_changeset, params) do
        entity_or_changeset
        |> cast(
          params,
          ~w(id timestamp broadcaster_id broadcaster_login broadcaster_name user_id user_login user_name product_type)a
        )
        |> cast_embed(:product_data)
        |> validate_required(
          ~w(id timestamp broadcaster_id broadcaster_login broadcaster_name user_id user_login user_name product_type)a
        )
      end
    end

    embedded_schema do
      embeds_many :data, ExtensionTransaction
      embeds_one :pagination, Pagination
    end

    @type t() :: %__MODULE__{
            data: ExtensionTransaction.t(),
            pagination: Pagination.t()
          }

    @spec changeset(
            entity_or_changeset :: t() | Ecto.Changeset.t(t()),
            params :: map()
          ) :: Ecto.Changeset.t(t())
    def changeset(entity_or_changeset, params) do
      entity_or_changeset
      |> cast(params, ~w()a)
      |> cast_embed(:data)
      |> cast_embed(:pagination)
    end
  end

  @doc """
  Gets an extension's list of transactions.
  A transaction records the exchange of a currency (for example, Bits) for a digital product.

  ## Hint

  Requires an app access token.

  ## Filter options

  | Name  | Data type      | Description                                                                                                                                                        |
  | :---- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | id    | `t:String.t/0` | A transaction ID used to filter the list of transactions. Specify this parameter for each transaction you want to get.                                             |
  | first | `t:integer/0`  | The maximum number of items to return per page in the response. The minimum page size is 1 item per page and the maximum is 100 items per page. The default is 20. |
  | after | `t:String.t/0` | The cursor used to get the next page of results. The Pagination object in the response contains the cursor's value. Read More                                      |

  ## Reference

  https://dev.twitch.tv/docs/api/reference/#get-extension-transactions
  """
  @spec get_extension_transactions(http_client :: Tesla.Client.t(), extension_id :: String.t()) ::
          Twex.Http.response(ExtensionTransactionsResponse.t(), term()) | {:error, :invalid_response}
  @spec get_extension_transactions(
          http_client :: Tesla.Client.t(),
          extension_id :: String.t(),
          filter_options :: keyword()
        ) :: Twex.Http.response(ExtensionTransactionsResponse.t(), term()) | {:error, :invalid_response}
  def get_extension_transactions(http_client, extension_id, filter_options \\ []) do
    joined_ids = filter_options |> Keyword.get(:id, []) |> Enum.join("&id=")

    ids_string =
      if String.length(joined_ids) == 0 do
        ""
      else
        "?id=" <> joined_ids
      end

    cleaned_filter_options = Keyword.delete(filter_options, :id)
    filter_options_with_extension_id = Keyword.put(cleaned_filter_options, :extension_id, extension_id)

    http_client
    |> Tesla.get("/extensions/transactions" <> ids_string, query: filter_options_with_extension_id)
    |> dbg()
    |> Twex.Http.process_tesla_response()
    |> case do
      {:ok, response} ->
        %ExtensionTransactionsResponse{}
        |> ExtensionTransactionsResponse.changeset(response)
        |> Twex.Http.Response.validate_changesets()

      error_value ->
        error_value
    end
  end
end
