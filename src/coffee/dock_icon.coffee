#
# The current application's icon in the dock or system tray.
#
Scribe.DockIcon::_getBadge = ->
  OSX.NSApp.dockTile.badgeLabel?.toString()

Scribe.DockIcon::_setBadge = (label) ->
  OSX.NSApp.dockTile.setBadgeLabel(label)

Scribe.DockIcon::_setUrl = (url) ->

Scribe.DockIcon::_getUrl = (url) ->

Scribe.DockIcon::_setContextMenu = (menu) ->

Scribe.DockIcon::_getContextMenu = ->
  @_menu

Scribe.DockIcon::_bounce = ->
  OSX.NSApp.requestUserAttention(OSX.NSCriticalRequest)
