defmodule Twex.Auth.Scope do
  @moduledoc """
  This module contains utility functions for working with Twitch scopes.

  It also contains the `is_valid_scope?` function for checking if the given input is a valid Twitch scope.
  """

  @type t() :: String.t()

  @spec read_extensions() :: t()
  def read_extensions, do: "analytics:read:extensions"

  @spec read_games() :: t()
  def read_games, do: "analytics:read:games"

  @spec read_bits() :: t()
  def read_bits, do: "bits:read"

  @spec manage_ads() :: t()
  def manage_ads, do: "channel:manage:ads"

  @spec read_ads() :: t()
  def read_ads, do: "channel:read:ads"

  @spec manage_broadcast() :: t()
  def manage_broadcast, do: "channel:manage:broadcast"

  @spec read_charity() :: t()
  def read_charity, do: "channel:read:charity"

  @spec edit_commercial() :: t()
  def edit_commercial, do: "channel:edit:commercial"

  @spec read_editors() :: t()
  def read_editors, do: "channel:read:editors"

  @spec manage_extensions() :: t()
  def manage_extensions, do: "channel:manage:extensions"

  @spec read_goals() :: t()
  def read_goals, do: "channel:read:goals"

  @spec read_guest_star() :: t()
  def read_guest_star, do: "channel:read:guest_star"

  @spec manage_guest_star() :: t()
  def manage_guest_star, do: "channel:manage:guest_star"

  @spec read_hype_train() :: t()
  def read_hype_train, do: "channel:read:hype_train"

  @spec manage_moderators() :: t()
  def manage_moderators, do: "channel:manage:moderators"

  @spec read_polls() :: t()
  def read_polls, do: "channel:read:polls"

  @spec manage_polls() :: t()
  def manage_polls, do: "channel:manage:polls"

  @spec read_predictions() :: t()
  def read_predictions, do: "channel:read:predictions"

  @spec manage_predictions() :: t()
  def manage_predictions, do: "channel:manage:predictions"

  @spec manage_raids() :: t()
  def manage_raids, do: "channel:manage:raids"

  @spec read_redemptions() :: t()
  def read_redemptions, do: "channel:read:redemptions"

  @spec manage_redemptions() :: t()
  def manage_redemptions, do: "channel:manage:redemptions"

  @spec manage_schedule() :: t()
  def manage_schedule, do: "channel:manage:schedule"

  @spec read_stream_key() :: t()
  def read_stream_key, do: "channel:read:stream_key"

  @spec read_channel_subscriptions() :: t()
  def read_channel_subscriptions, do: "channel:read:subscriptions"

  @spec manage_videos() :: t()
  def manage_videos, do: "channel:manage:videos"

  @spec read_vips() :: t()
  def read_vips, do: "channel:read:vips"

  @spec manage_vips() :: t()
  def manage_vips, do: "channel:manage:vips"

  @spec edit_clips() :: t()
  def edit_clips, do: "clips:edit"

  @spec read_moderation() :: t()
  def read_moderation, do: "moderation:read"

  @spec manage_announcements() :: t()
  def manage_announcements, do: "moderator:manage:announcements"

  @spec manage_automod() :: t()
  def manage_automod, do: "moderator:manage:automod"

  @spec read_automod_settings() :: t()
  def read_automod_settings, do: "moderator:read:automod_settings"

  @spec manage_automod_settings() :: t()
  def manage_automod_settings, do: "moderator:manage:automod_settings"

  @spec manage_banned_users() :: t()
  def manage_banned_users, do: "moderator:manage:banned_users"

  @spec read_blocked_terms() :: t()
  def read_blocked_terms, do: "moderator:read:blocked_terms"

  @spec manage_blocked_terms() :: t()
  def manage_blocked_terms, do: "moderator:manage:blocked_terms"

  @spec manage_chat_messages() :: t()
  def manage_chat_messages, do: "moderator:manage:chat_messages"

  @spec read_chat_settings() :: t()
  def read_chat_settings, do: "moderator:read:chat_settings"

  @spec manage_chat_settings() :: t()
  def manage_chat_settings, do: "moderator:manage:chat_settings"

  @spec read_chatters() :: t()
  def read_chatters, do: "moderator:read:chatters"

  @spec read_followers() :: t()
  def read_followers, do: "moderator:read:followers"

  @spec moderator_read_guest_star() :: t()
  def moderator_read_guest_star, do: "moderator:read:guest_star"

  @spec moderator_manage_guest_star() :: t()
  def moderator_manage_guest_star, do: "moderator:manage:guest_star"

  @spec read_shield_mode() :: t()
  def read_shield_mode, do: "moderator:read:shield_mode"

  @spec manage_shield_mode() :: t()
  def manage_shield_mode, do: "moderator:manage:shield_mode"

  @spec read_shoutouts() :: t()
  def read_shoutouts, do: "moderator:read:shoutouts"

  @spec manage_shoutouts() :: t()
  def manage_shoutouts, do: "moderator:manage:shoutouts"

  @spec read_unban_requests() :: t()
  def read_unban_requests, do: "moderator:read:unban_requests"

  @spec edit_user() :: t()
  def edit_user, do: "user:edit"

  @spec edit_follows() :: t()
  def edit_follows, do: "user:edit:follows"

  @spec read_blocked_users() :: t()
  def read_blocked_users, do: "user:read:blocked_users"

  @spec manage_blocked_users() :: t()
  def manage_blocked_users, do: "user:manage:blocked_users"

  @spec read_broadcast() :: t()
  def read_broadcast, do: "user:read:broadcast"

  @spec manage_chat_color() :: t()
  def manage_chat_color, do: "user:manage:chat_color"

  @spec read_email() :: t()
  def read_email, do: "user:read:email"

  @spec read_emotes() :: t()
  def read_emotes, do: "user:read:emotes"

  @spec read_follows() :: t()
  def read_follows, do: "user:read:follows"

  @spec read_moderated_channels() :: t()
  def read_moderated_channels, do: "user:read:moderated_channels"

  @spec read_user_subscriptions() :: t()
  def read_user_subscriptions, do: "user:read:subscriptions"

  @spec manage_whispers() :: t()
  def manage_whispers, do: "user:manage:whispers"

  @spec all() :: list(t())
  def all,
    do: [
      read_extensions(),
      read_games(),
      read_bits(),
      manage_ads(),
      read_ads(),
      manage_broadcast(),
      read_charity(),
      edit_commercial(),
      read_editors(),
      manage_extensions(),
      read_goals(),
      read_guest_star(),
      manage_guest_star(),
      read_hype_train(),
      manage_moderators(),
      read_polls(),
      manage_polls(),
      read_predictions(),
      manage_predictions(),
      manage_raids(),
      read_redemptions(),
      manage_redemptions(),
      manage_schedule(),
      read_stream_key(),
      read_channel_subscriptions(),
      manage_videos(),
      read_vips(),
      manage_vips(),
      edit_clips(),
      read_moderation(),
      manage_announcements(),
      manage_automod(),
      read_automod_settings(),
      manage_automod_settings(),
      manage_banned_users(),
      read_blocked_terms(),
      manage_blocked_terms(),
      manage_chat_messages(),
      read_chat_settings(),
      manage_chat_settings(),
      read_chatters(),
      read_followers(),
      moderator_read_guest_star(),
      moderator_manage_guest_star(),
      read_shield_mode(),
      manage_shield_mode(),
      read_shoutouts(),
      manage_shoutouts(),
      read_unban_requests(),
      edit_user(),
      edit_follows(),
      read_blocked_users(),
      manage_blocked_users(),
      read_broadcast(),
      manage_chat_color(),
      read_email(),
      read_emotes(),
      read_follows(),
      read_moderated_channels(),
      read_user_subscriptions(),
      manage_whispers()
    ]

  @doc """
  Checks if the given input is a valid Twitch scope
  """
  @spec is_valid_scope?(scope_to_check :: String.t()) :: boolean()
  def is_valid_scope?(scope_to_check), do: Enum.member?(all(), scope_to_check)
end
