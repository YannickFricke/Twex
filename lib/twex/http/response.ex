defmodule Twex.Http.Response do
  @moduledoc """
  Contains utility functions for working with HTTP responses.

  The `__using__` macro manages all the Ecto stuff.

  The `validate_changesets/1` validates the given list of `t:Ecto.Changeset.t/0` and transforms them into their underlying struct.
  """

  @doc """
  Imports `Ecto.Schema` and `Ecto.Changeset` and disables the primary key.
  """
  @spec __using__(opts :: term()) :: Macro.t()
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key false
    end
  end

  @doc """
  Validates the given changeset or list of changesets.

  When one of the changesets is invalid it returns `{:error, :invalid_response}`.

  Otherwise it returns `{:ok, struct()}`.

  The structs in this case are the defined embeded Ecto schemas which are typed API responses.
  """
  @spec validate_changesets(changeset_or_changesets :: Ecto.Changeset.t() | list(Ecto.Changeset.t())) ::
          {:ok, struct()}
          | {:error, :invalid_response}
  def validate_changesets(changeset) when is_struct(changeset, Ecto.Changeset) do
    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, validated_data_structure} ->
        {:ok, validated_data_structure}

      {:error, _reason} ->
        {:error, :invalid_response}
    end
  end

  def validate_changesets(changesets) do
    Enum.reduce(changesets, {:ok, []}, fn
      _changeset, {:error, reason} ->
        {:error, reason}

      changeset, {:ok, validated_data_structures} ->
        case validate_changesets(changeset) do
          {:ok, validated_data_structure} ->
            {:ok, validated_data_structures ++ [validated_data_structure]}

          {:error, reason} ->
            {:error, reason}
        end
    end)
  end
end
