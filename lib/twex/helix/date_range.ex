defmodule Twex.Helix.DateRange do
  @moduledoc """
  Contains the start and end date for a analytics report.

  The information includes the following items:

  | Name       | Description                       |
  | :--------- | :-------------------------------- |
  | started_at | The reporting window's start date |
  | ended_at   | The reporting window's end date.  |
  """

  use Twex.Http.Response

  embedded_schema do
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
  end

  @type t() :: %__MODULE__{
          started_at: DateTime.t(),
          ended_at: DateTime.t()
        }

  @spec changeset(
          entity_or_changeset :: t() | Ecto.Changeset.t(t()),
          params :: map()
        ) :: Ecto.Changeset.t(t())
  def changeset(entity_or_changeset, params) do
    cast(entity_or_changeset, params, ~w(started_at ended_at)a)
  end
end
