defmodule Twex.Helix.Pagination do
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
          entity_or_changeset :: t() | Ecto.Changeset.t(t()),
          params :: map()
        ) :: Ecto.Changeset.t(t())
  def changeset(entity_or_changeset, params) do
    cast(entity_or_changeset, params, ~w(cursor)a)
  end
end
