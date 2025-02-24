

--[[
=head1 NAME

applets.ScreenLock.ScreenLockApplet - Screen Lock

=head1 DESCRIPTION

=head1 FUNCTIONS


=cut
--]]

-- stuff we use
local pairs                 = pairs
local setmetatable          = setmetatable
local type                  = type

local oo                    = require("loop.simple")
local string                = require("jive.utils.string")
local debug                 = require("jive.utils.debug")

local Applet                = require("jive.Applet")
local Framework             = require("jive.ui.Framework")
local Icon                  = require("jive.ui.Icon")
local Label                 = require("jive.ui.Label")
local Textarea              = require("jive.ui.Textarea")
local Tile                  = require("jive.ui.Tile")
local Surface               = require("jive.ui.Surface")
local Popup                 = require("jive.ui.Popup")
local Timer                 = require("jive.ui.Timer")

local LAYOUT_CENTER         = jive.ui.LAYOUT_CENTER
local WH_FILL               = jive.ui.WH_FILL

local appletManager         = appletManager
local jiveMain              = jiveMain
local jnt                   = jnt

module(..., Framework.constants)
oo.class(_M, Applet)

-- define useful variables
local imgpath = "applets/ScreenLock/"

-- defines a new style that inherrits from an existing style
local function _uses(parent, value)
    if parent == nil then
        log:warn("nil parent in _uses at:\n", debug.traceback())
    end
    local style = {}
    setmetatable(style, { __index = parent })
    for k,v in pairs(value or {}) do
        if type(v) == "table" and type(parent[k]) == "table" then
            -- recursively inherrit from parent style
            style[k] = _uses(parent[k], v)
        else
            style[k] = v
        end
    end

    return style
end

function init(self)
    log:info("initializing listener")

    Framework:addListener(EVENT_KEY_PRESS,
                          function(event)
                               local keycode = event:getKeycode()
                               log.info("got keycode")

                               if keycode == (KEY_ADD | KEY_PLAY) then
                                   log:info("activating screen lock")
                                   Framework:playSound("WINDOWSHOW")
                                   self:lockScreen()
                                   return EVENT_CONSUME
                               end

                               return EVENT_UNUSED
                          end)
end

function _loadImage(self, file)
    return Surface:loadImage(imgpath .. file)
end

function _showTimedLockIconPopup(self, p, ms)
    self.lockTimer = Timer(ms,
                            function()
                                p:hide()
                                self.showinglockScreen = false
                            end, 
                            true)
    p:show()
    self.showinglockScreen = true
    self.lockTimer:restart()
end

function _createPopup(self)
    local screenWidth, screenHeight = Framework:getScreenSize()

    local s = {}
    s.img = {}
    s.img.blackBackground = Tile:fillColor(0x000000ff)
    s.base_popup = {
                            w = screenHeight,
                            h = screentWidth,
                            border = {0, 0, 0, 0},
    }
    s.transparent_popup = _uses(s.base_popup, {
        bgImg = false,
        maskImg = false,
    })
    s.black_popup = _uses(s.base_popup, {
        bgImg = s.img.blackBackground,
        maskImg = s.img.blackBackground,
    })
    s._icon = {
        w = WH_FILL,
        align = "center",
        position = LAYOUT_CENTER,
        padding = {0, 25, 0, 5},
    }
    s.icon_locked = _uses(s._icon, {
        img = self:_loadImage("icon_locked_grey.png")
    })
    s.icon_unlocked = _uses(s._icon, {
        img = self:_loadImage("icon_unlocked_grey.png")
    })
    self.skin = s
end

function lockScreen(self)
    -- lock
    if self.skin == nil then
        self:_createPopup()
    end

    self.lockIconPopup = Popup("black_popup")
    self.lockIconPopup:setAllowScreensaver(false)
    self.lockIconPopup:setAlwaysOnTop(true)
    self.lockIconPopup:setAutoHide(false)
    self.lockIconPopup:setTransparent(true)
    self.lockIconPopup:addWidget(Icon("icon_locked", self:_loadImage("icon_locked_grey.png")))
    self.lockIconPopup:addWidget(Label("text", self:string("BSP_SCREEN_LOCKED")))
--    self.lockIconPopup:addWidget(Textarea("help_text", self:string("BSP_SCREEN_LOCKED_HELP")))

    self:_showTimedLockIconPopup(self.lockIconPopup, 1000)

    self.lockedListener =
            Framework:addListener(EVENT_KEY_DOWN | EVENT_KEY_PRESS | EVENT_SCROLL, 
                                    function(event)
                                            if event:getType() == EVENT_KEY_PRESS and event:getKeycode() == (KEY_ADD | KEY_PLAY) then
                                                log:info("removing screen lock")
                                                self:_showTimedLockIconPopup(self.lockIconPopup, 1000)
                                                self.lockIconPopup:playSound("WINDOWHIDE")
                                                self:unlockScreen()
                                                return EVENT_CONSUME
                                            end

                                            if not self.showinglockScreen then
                                                log:info("nothing to do, just show message")
                                                self:_showTimedLockIconPopup(self.lockIconPopup, 3000)
                                            end
                                            return EVENT_CONSUME
                                    end,
                                    true)
end

function unlockScreen(self)
    if self.lockIconPopup then
        -- unlock
        Framework:removeListener(self.lockedListener)
        self.lockTimer:stop()
        self.lockIconPopup:hide()

        self.lockIconPopup = nil
        self.lockTimer = nil
        self.lockedListener = nil
    end
end
