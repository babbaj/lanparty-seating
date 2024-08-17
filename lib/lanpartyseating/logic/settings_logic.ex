defmodule Lanpartyseating.SettingsLogic do
  import Ecto.Query
  require Logger
  alias Lanpartyseating.Setting, as: Setting
  alias Lanpartyseating.LastAssignedSeat, as: LastAssignedSeat
  alias Lanpartyseating.Repo, as: Repo

  def get_settings do
    settings =
      Setting
      |> last(:inserted_at)
      |> Repo.one()

    case settings do
      nil -> {:error, "No settings found"}
      _ -> {:ok, settings}
    end
  end

  # returns an Ecto.Multi that has to be written
  def save_settings(
        grid,
        station_count,
        row_padding,
        column_padding,
        horizontal_trailing,
        vertical_trailing
      ) do
    las =
      LastAssignedSeat
      |> Repo.one()

    settings =
      Setting
      |> last(:inserted_at)
      |> Repo.one()

    las =
      Ecto.Changeset.change(las,
        last_assigned_station: 0,
        last_assigned_station_date: DateTime.truncate(DateTime.utc_now(), :second)
      )

    settings =
      Ecto.Changeset.change(settings,
        station_count: station_count,
        row_padding: row_padding,
        column_padding: column_padding,
        horizontal_trailing: horizontal_trailing,
        vertical_trailing: vertical_trailing
      )
    layout_multi = grid
      |> Enum.map(fn {{x, y}, num} -> %Lanpartyseating.StationLayout{station_number: num, x: x, y: y} end)
      |> Enum.reduce(Ecto.Multi.new(), fn row, multi -> Ecto.Multi.insert(multi, {:insert_position, row.station_number}, row) end)

    Ecto.Multi.new()
      |> Ecto.Multi.insert_or_update(:set_last_assigned_station, las)
      |> Ecto.Multi.insert_or_update(:insert_settings, settings)
      |> Ecto.Multi.append(layout_multi)
  end
end
