
--[[
=head1 NAME

applets.ScreenLock.ScreenLockMeta

=head1 DESCRIPTION

See L<applets.ScreenLock.ScreenLockApplet>.

=head1 FUNCTIONS

See L<jive.AppletMeta> for a description of standard applet meta functions.

=cut
--]]


local oo            = require("loop.simple")
local AppletMeta    = require("jive.AppletMeta")

local appletManager = appletManager
local jiveMain      = jiveMain

module(...)
oo.class(_M, AppletMeta)

function jiveVersion(self)
    return 1, 1
end

function defaultSettings(self)
    -- noting here, go ahead
end

function registerApplet(self)
    appletManager:loadApplet("ScreenLock")
end
