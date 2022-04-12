# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
#
# When I upgraded to Rails 6.1 I noticed the option to switch to `:json`.
# We were using `:marshal` before. Apparently, that's a security vulnerability.
#
# But, when I switched to `:json`, I got a nasty error parsing my old marshaled
# cookie.
#
# > ActionView::Template::Error (809: unexpected token at {I"session_id:ETI"%8792a9....
#
# This setting is not documented well, but it seems `:hybrid` will detect
# marshaled cookies and switch them to JSON.
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
