defmodule Lanpartyseating.Station do
  use Ecto.Schema
  import Ecto.Changeset
  alias Lanpartyseating.Reservation, as: Reservation
  alias Lanpartyseating.TournamentReservation, as: TournamentReservation

  @primary_key {:station_number, :integer, autogenerate: false}
  @foreign_key_type :integer

  schema "stations" do
    field :is_closed, :boolean, default: false
    field :deleted_at, :utc_datetime
    has_many :reservations, Reservation, foreign_key: :station_id
    has_many :tournament_reservations, TournamentReservation, foreign_key: :station_id
    timestamps()
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:station_number, :is_displayed, :is_closed, :deleted_at])
    |> validate_required([:station_number])
    |> validate_number(:station_number, greater_than: 0)
  end
end
