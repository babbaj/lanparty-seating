defmodule LanpartyseatingWeb.SelfSignLive do
  use LanpartyseatingWeb, :live_view
  alias Lanpartyseating.SettingsLogic, as: SettingsLogic
  alias Lanpartyseating.StationLogic, as: StationLogic
  alias Lanpartyseating.ReservationLogic, as: ReservationLogic
  alias Lanpartyseating.PubSub, as: PubSub

  def mount(_params, _session, socket) do
    {:ok, settings} = SettingsLogic.get_settings()
    {:ok, stations} = StationLogic.get_all_stations()

    if connected?(socket) do
      Phoenix.PubSub.subscribe(PubSub, "station_status")
      Phoenix.PubSub.subscribe(PubSub, "station_update")
    end

    socket =
      socket
      |> assign(:columns, if(settings.is_diagonally_mirrored, do: settings.rows, else: settings.columns))
      |> assign(:rows, if(settings.is_diagonally_mirrored, do: settings.columns, else: settings.rows))
      |> assign(:col_trailing, settings.vertical_trailing)
      |> assign(:row_trailing, settings.horizontal_trailing)
      |> assign(:colpad, settings.column_padding)
      |> assign(:rowpad, settings.row_padding)
      |> assign(:stations, stations)
      |> assign(:registration_error, nil)

    {:ok, socket}
  end

  def handle_event(
        "reserve_station",
        %{"station_number" => station_number, "uid" => uid},
        socket
      ) do
    ReservationLogic.create_reservation(
      String.to_integer(station_number),
      String.to_integer("45"),
      uid
    )

    socket =
      socket
      |> assign(:registration_error, nil)

    {:noreply, socket}
  end

  def handle_info({:stations, stations}, socket) do
    {:noreply, assign(socket, :stations, stations)}
  end

  def render(assigns) do
    ~H"""
    <div class="jumbotron">
      <h1 style="font-size:30px">Stations</h1>
      <div class="flex flex-wrap w-full">

        <h1 style="font-size:20px">Please select an available station / Veuillez sélectionner une station disponible:</h1>
        <%= for r <- 0..(@rows-1) do %>
          <div class={"#{if rem(r,@rowpad) == rem(@row_trailing, @rowpad) and @rowpad != 1, do: "mb-4", else: ""} flex flex-row w-full"}>
            <%= for c <- 0..(@columns-1) do %>
              <div class={"#{if rem(c,@colpad) == rem(@col_trailing, @colpad) and @colpad != 1, do: "mr-4", else: ""} flex flex-col h-14 flex-1 grow mx-1"}>
                <% station_data = @stations |> Enum.at(r * @columns + c) %>
                <%= if !is_nil(station_data) do %>
                  <SelfSignModalComponent.modal
                    error={@registration_error}
                    reservation={station_data.reservation}
                    station={station_data.station}
                    status={station_data.status}
                  />
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
        <h1 style="font-size:20px">Legend / Légende:</h1>
        <div class="mb-4 flex flex-row w-full ">
        <label class="btn btn-info mr-4">
            Available / Disponible
          </label>
          <label class="btn btn-warning mr-4">
            Occupied / Occupée
          </label>

          </div>
          <div class="mb-4 flex flex-row w-full ">
          <label class="btn btn-error mr-4">
            Broken / Brisée
          </label>
          <label class="btn btn-active mr-4">
            Reserved for tournament / Réservée pour un tournois
          </label>
        </div>
      </div>
    </div>
    """
  end
end
