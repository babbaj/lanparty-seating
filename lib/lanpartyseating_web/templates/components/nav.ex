defmodule NavComponent do
  use Phoenix.Component

  # Optionally also bring the HTML helpers
  # use Phoenix.HTML

  def nav(assigns) do
    ~H"""
    <nav class="navbar bg-base-300">
      <div class="navbar-start">
        <div class="flex-1">
          <a class="text-xl normal-case btn btn-ghost primary-content" href="#">LAN Party Seating</a>
        </div>
      </div>
      <div class="navbar-end">
        <ul class="p-0 menu menu-horizontal">
        <%= for {menu_txt, path} <- assigns.nav_menu do %>
          <li class={"nav-item #{if path == assigns.nav_menu_active_path, do: "font-bold"}"}>
            <%= live_redirect menu_txt, to: path, class: "nav-link" %>
          </li>
        <% end %>
        </ul>
      </div>
    </nav>
    """
  end
end
