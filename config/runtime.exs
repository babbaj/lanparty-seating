import Config

# TZData storage path for prod releases in the nix store
config :tzdata,
       :data_dir,
       System.get_env("STORAGE_DIR")

config :lanpartyseating, LanpartyseatingWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST") || "localhost", port: 4000]

config :lanpartyseating, Lanpartyseating.PromEx,
  grafana: if System.get_env("GRAFANA_ENABLE"), do: [
    host: System.get_env("GRAFANA_HOST", "http://localhost:3000"),
    auth_token: System.get_env("GRAFANA_AUTH_TOKEN", ""),
    upload_dashboards_on_start: true,
    folder_name: "Lanparty Seating",
    annotate_app_lifecycle: true
  ], else: :disabled

config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :otlp

config :opentelemetry_exporter,
  otlp_protocol: :grpc,
  otlp_compression: :gzip,
  otlp_endpoint: "https://api.honeycomb.io:443",
  otlp_headers: [{"x-honeycomb-dataset", "lanparty-seating"}]
