defmodule Twex.MixProject do
  use Mix.Project

  @repo_url "https://github.com/YannickFricke/twex"

  def project do
    [
      app: :twex,
      version: "0.0.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Twex",
      source_url: @repo_url,
      homepage_url: @repo_url,
      docs: [
        main: "Twex",
        extras: ["README.md"],
        groups_for_modules: [
          Ads: [
            Twex.Helix.Ads,
            Twex.Helix.Ads.StartCommercialResponse,
            Twex.Helix.Ads.AdScheduleEntry,
            Twex.Helix.Ads.SnoozeEntry
          ],
          Analytics: [
            Twex.Helix.Analytics,
            Twex.Helix.Analytics.DateRange,
            Twex.Helix.Analytics.ExtensionAnalyticsResponse,
            Twex.Helix.Analytics.GameAnalyticsResponse
          ],
          Channels: [
            Twex.Helix.Channels,
            Twex.Helix.Channels.ChannelInformation,
            Twex.Helix.Channels.ChannelEditor,
            Twex.Helix.Channels.FollowedChannelsResponse,
            Twex.Helix.Channels.ChannelFollowersResponse
          ]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps,
    do: [
      {:tesla, "~> 1.9"},
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.11"},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
end
