defmodule Twex.Auth.Scope do
  @moduledoc """
  This module contains utility functions for working with Twitch scopes.

  It also contains the `is_valid_scope?` function for checking if the given input is a valid Twitch scope.
  """

  @type t() :: String.t()

  @spec analytics_read_extensions() :: t()
  def analytics_read_extensions, do: "analytics:read:extensions"

  @spec analytics_read_games() :: t()
  def analytics_read_games, do: "analytics:read:games"

  @spec bits_read() :: t()
  def bits_read, do: "bits:read"

  @spec channel_manage_ads() :: t()
  def channel_manage_ads, do: "channel:manage:ads"

  @spec channel_read_ads() :: t()
  def channel_read_ads, do: "channel:read:ads"

  @spec channel_manage_broadcast() :: t()
  def channel_manage_broadcast, do: "channel:manage:broadcast"

  @spec channel_read_charity() :: t()
  def channel_read_charity, do: "channel:read:charity"

  @spec channel_edit_commercial() :: t()
  def channel_edit_commercial, do: "channel:edit:commercial"

  @spec channel_read_editors() :: t()
  def channel_read_editors, do: "channel:read:editors"

  @spec channel_manage_extensions() :: t()
  def channel_manage_extensions, do: "channel:manage:extensions"

  @spec channel_read_goals() :: t()
  def channel_read_goals, do: "channel:read:goals"

  @spec channel_read_guest_star() :: t()
  def channel_read_guest_star, do: "channel:read:guest_star"

  @spec channel_manage_guest_star() :: t()
  def channel_manage_guest_star, do: "channel:manage:guest_star"

  @spec channel_read_hype_train() :: t()
  def channel_read_hype_train, do: "channel:read:hype_train"

  @spec channel_manage_moderators() :: t()
  def channel_manage_moderators, do: "channel:manage:moderators"

  @spec channel_read_polls() :: t()
  def channel_read_polls, do: "channel:read:polls"

  @spec channel_manage_polls() :: t()
  def channel_manage_polls, do: "channel:manage:polls"

  @spec channel_read_predictions() :: t()
  def channel_read_predictions, do: "channel:read:predictions"

  @spec channel_manage_predictions() :: t()
  def channel_manage_predictions, do: "channel:manage:predictions"

  @spec channel_manage_raids() :: t()
  def channel_manage_raids, do: "channel:manage:raids"

  @spec channel_read_redemptions() :: t()
  def channel_read_redemptions, do: "channel:read:redemptions"

  @spec channel_manage_redemptions() :: t()
  def channel_manage_redemptions, do: "channel:manage:redemptions"

  @spec channel_manage_schedule() :: t()
  def channel_manage_schedule, do: "channel:manage:schedule"

  @spec channel_read_stream_key() :: t()
  def channel_read_stream_key, do: "channel:read:stream_key"

  @spec channel_read_subscriptions() :: t()
  def channel_read_subscriptions, do: "channel:read:subscriptions"

  @spec channel_manage_videos() :: t()
  def channel_manage_videos, do: "channel:manage:videos"

  @spec channel_read_vips() :: t()
  def channel_read_vips, do: "channel:read:vips"

  @spec channel_manage_vips() :: t()
  def channel_manage_vips, do: "channel:manage:vips"

  @spec clips_edit() :: t()
  def clips_edit, do: "clips:edit"

  @spec moderation_read() :: t()
  def moderation_read, do: "moderation:read"

  @spec moderator_manage_announcements() :: t()
  def moderator_manage_announcements, do: "moderator:manage:announcements"

  @spec moderator_manage_automod() :: t()
  def moderator_manage_automod, do: "moderator:manage:automod"

  @spec moderator_read_automod_settings() :: t()
  def moderator_read_automod_settings, do: "moderator:read:automod_settings"

  @spec moderator_manage_automod_settings() :: t()
  def moderator_manage_automod_settings, do: "moderator:manage:automod_settings"

  @spec moderator_manage_banned_users() :: t()
  def moderator_manage_banned_users, do: "moderator:manage:banned_users"

  @spec moderator_read_blocked_terms() :: t()
  def moderator_read_blocked_terms, do: "moderator:read:blocked_terms"

  @spec moderator_manage_blocked_terms() :: t()
  def moderator_manage_blocked_terms, do: "moderator:manage:blocked_terms"

  @spec moderator_manage_chat_messages() :: t()
  def moderator_manage_chat_messages, do: "moderator:manage:chat_messages"

  @spec moderator_read_chat_settings() :: t()
  def moderator_read_chat_settings, do: "moderator:read:chat_settings"

  @spec moderator_manage_chat_settings() :: t()
  def moderator_manage_chat_settings, do: "moderator:manage:chat_settings"

  @spec moderator_read_chatters() :: t()
  def moderator_read_chatters, do: "moderator:read:chatters"

  @spec moderator_read_followers() :: t()
  def moderator_read_followers, do: "moderator:read:followers"

  @spec moderator_read_guest_star() :: t()
  def moderator_read_guest_star, do: "moderator:read:guest_star"

  @spec moderator_manage_guest_star() :: t()
  def moderator_manage_guest_star, do: "moderator:manage:guest_star"

  @spec moderator_read_shield_mode() :: t()
  def moderator_read_shield_mode, do: "moderator:read:shield_mode"

  @spec moderator_manage_shield_mode() :: t()
  def moderator_manage_shield_mode, do: "moderator:manage:shield_mode"

  @spec moderator_read_shoutouts() :: t()
  def moderator_read_shoutouts, do: "moderator:read:shoutouts"

  @spec moderator_manage_shoutouts() :: t()
  def moderator_manage_shoutouts, do: "moderator:manage:shoutouts"

  @spec moderator_read_unban_requests() :: t()
  def moderator_read_unban_requests, do: "moderator:read:unban_requests"

  @spec user_edit() :: t()
  def user_edit, do: "user:edit"

  @spec user_edit_follows() :: t()
  def user_edit_follows, do: "user:edit:follows"

  @spec user_read_blocked_users() :: t()
  def user_read_blocked_users, do: "user:read:blocked_users"

  @spec user_manage_blocked_users() :: t()
  def user_manage_blocked_users, do: "user:manage:blocked_users"

  @spec user_read_broadcast() :: t()
  def user_read_broadcast, do: "user:read:broadcast"

  @spec user_manage_chat_color() :: t()
  def user_manage_chat_color, do: "user:manage:chat_color"

  @spec user_read_email() :: t()
  def user_read_email, do: "user:read:email"

  @spec user_read_emotes() :: t()
  def user_read_emotes, do: "user:read:emotes"

  @spec user_read_follows() :: t()
  def user_read_follows, do: "user:read:follows"

  @spec user_read_moderated_channels() :: t()
  def user_read_moderated_channels, do: "user:read:moderated_channels"

  @spec user_read_subscriptions() :: t()
  def user_read_subscriptions, do: "user:read:subscriptions"

  @spec user_manage_whispers() :: t()
  def user_manage_whispers, do: "user:manage:whispers"

  @doc """
  Returns a String.t() list of all known scopes.
  """
  @spec all() :: list(t())
  def all,
    do: [
      analytics_read_extensions(),
      analytics_read_games(),
      bits_read(),
      channel_manage_ads(),
      channel_read_ads(),
      channel_manage_broadcast(),
      channel_read_charity(),
      channel_edit_commercial(),
      channel_read_editors(),
      channel_manage_extensions(),
      channel_read_goals(),
      channel_read_guest_star(),
      channel_manage_guest_star(),
      channel_read_hype_train(),
      channel_manage_moderators(),
      channel_read_polls(),
      channel_manage_polls(),
      channel_read_predictions(),
      channel_manage_predictions(),
      channel_manage_raids(),
      channel_read_redemptions(),
      channel_manage_redemptions(),
      channel_manage_schedule(),
      channel_read_stream_key(),
      channel_read_subscriptions(),
      channel_manage_videos(),
      channel_read_vips(),
      channel_manage_vips(),
      clips_edit(),
      moderation_read(),
      moderator_manage_announcements(),
      moderator_manage_automod(),
      moderator_read_automod_settings(),
      moderator_manage_automod_settings(),
      moderator_manage_banned_users(),
      moderator_read_blocked_terms(),
      moderator_manage_blocked_terms(),
      moderator_manage_chat_messages(),
      moderator_read_chat_settings(),
      moderator_manage_chat_settings(),
      moderator_read_chatters(),
      moderator_read_followers(),
      moderator_read_guest_star(),
      moderator_manage_guest_star(),
      moderator_read_shield_mode(),
      moderator_manage_shield_mode(),
      moderator_read_shoutouts(),
      moderator_manage_shoutouts(),
      moderator_read_unban_requests(),
      user_edit(),
      user_edit_follows(),
      user_read_blocked_users(),
      user_manage_blocked_users(),
      user_read_broadcast(),
      user_manage_chat_color(),
      user_read_email(),
      user_read_emotes(),
      user_read_follows(),
      user_read_moderated_channels(),
      user_read_subscriptions(),
      user_manage_whispers()
    ]

  @doc """
  Joins the given list of scopes to a string

  ## Examples

  ```elixir
  iex> Twex.Auth.Scope.join(~w(bits:read clips:edit))
  "bits:read clips:edit"
  ```
  """
  @spec join(scopes :: list(t())) :: String.t()
  def join(scopes), do: Enum.join(scopes, " ")

  @doc """
  Checks if the given input is a valid Twitch scope
  """
  @spec is_valid_scope?(scope_to_check :: String.t()) :: boolean()
  def is_valid_scope?(scope_to_check), do: Enum.member?(all(), scope_to_check)
end
