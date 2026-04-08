---------------------------------------------------------------------------
-- BazNotificationCenter
-- A modern notification center for World of Warcraft
-- Part of the Baz Suite — powered by BazCore
---------------------------------------------------------------------------
local addonName, addon = ...

-- Global API table for module addons to use (created before RegisterAddon)
BazNotificationCenter = {}
BNC = BazNotificationCenter  -- Short alias for module authors

-- Internal state
addon.VERSION = C_AddOns.GetAddOnMetadata("BazNotificationCenter", "Version") or "1"
addon.modules = {}
addon.notifications = {}
addon.notificationCounter = 0
addon.suppressedFrames = {}
addon.db = nil
addon.panel = nil
addon.name = addonName
-- Global toggle function for AddonCompartmentFunc
function BNC_TogglePanel()
    if addon.TogglePanel then
        addon.TogglePanel()
    end
end

---------------------------------------------------------------------------
-- Defaults
---------------------------------------------------------------------------

local DEFAULTS = {
    position = "TOPLEFT",
    toastDuration = 5,
    toastsEnabled = true,
    soundEnabled = true,
    tomtomEnabled = true,
    panelOpacity = 0.85,
    maxHistory = 999,
    scale = 1.0,
    dndEnabled = false,
    dndAutoCombat = false,
    dndAutoInstance = false,
    soundHigh = 8959,
    soundNormal = 618,
    soundLow = 0,
    modules = {},
    globalOverrides = {},
}

---------------------------------------------------------------------------
-- BazCore Registration
---------------------------------------------------------------------------

BazCore:RegisterAddon("BazNotificationCenter", {
    title = "BazNotificationCenter",
    savedVariable = "BazNotificationCenterDB",
    profiles = true,
    defaults = DEFAULTS,

    slash = { "/bnc", "/baznotify" },
    commands = {
        test = {
            desc = "Send a test notification",
            handler = function()
                BNC:Push({
                    module = "_test",
                    title = "Test Notification",
                    message = "BNC is working correctly!",
                    icon = "Interface\\Icons\\INV_Misc_Bell_01",
                    priority = "normal",
                })
            end,
        },
        testall = {
            desc = "Send test notifications from all modules",
            handler = function()
                print("|cff00aaff[BNC]|r Sending test notifications...")
                if addon.SendTestBurst then addon.SendTestBurst() end
            end,
        },
        history = {
            desc = "Open notification history",
            handler = function()
                if addon.ShowHistoryPanel then addon.ShowHistoryPanel() end
            end,
        },
        clear = {
            desc = "Clear all notifications",
            handler = function()
                BNC:DismissAll()
                print("|cff00aaff[BNC]|r All notifications cleared.")
            end,
        },
        dnd = {
            desc = "Toggle Do Not Disturb",
            handler = function()
                BNC:ToggleDND()
            end,
        },
        scaffold = {
            desc = "Print a module template: /bnc scaffold <name>",
            handler = function(args)
                if addon.ScaffoldModule then addon.ScaffoldModule(args) end
            end,
        },
    },
    defaultHandler = function()
        if addon.TogglePanel then addon.TogglePanel() end
    end,

    minimap = {
        label = "BazNotificationCenter",
        icon = "Interface\\Icons\\INV_Misc_Bell_01",
        onClick = function()
            if addon.OpenOptions then addon.OpenOptions() end
        end,
    },

    onLoad = function(self)
        -- History is global (not per-profile) — stored in BazNotificationCenterDB directly
        local sv = _G["BazNotificationCenterDB"] or {}
        _G["BazNotificationCenterDB"] = sv
        if not sv.history then
            sv.history = { days = {}, dayIndex = {} }
        end
        -- Migrate history from old profile data into flat SV if needed
        if self.db and self.db.profile then
            local profileHistory = rawget(self.db.profile, "history")
            if not profileHistory then
                -- Check the actual profile table in BazCoreDB
                local activeProfile = BazCore:GetActiveProfile()
                local coreProfiles = BazCoreDB and BazCoreDB.profiles and BazCoreDB.profiles[activeProfile]
                local bncSection = coreProfiles and coreProfiles["BazNotificationCenter"]
                if bncSection and bncSection.history and bncSection.history.days then
                    sv.history = bncSection.history
                    bncSection.history = nil
                end
            end
        end

        -- Flatten the db proxy: addon.db.X reads directly from active profile
        addon.db = self.db.profile
        addon.bncAddon = self

        -- Register PLAYER_ENTERING_WORLD to bridge to internal PLAYER_READY
        self:On("PLAYER_ENTERING_WORLD", function(event, isLogin, isReload)
            addon.Events:Trigger("PLAYER_READY", isLogin, isReload)
        end)

        -- Fire CORE_LOADED so all internal listeners activate
        addon.Events:Trigger("CORE_LOADED")
    end,

    onReady = function(self)
        -- onReady fires once on PLAYER_LOGIN
    end,
})

---------------------------------------------------------------------------
-- TomTom integration
---------------------------------------------------------------------------

function BNC:HasTomTom()
    return TomTom and TomTom.AddWaypoint and true or false
end

function BNC:SetWaypoint(waypointData)
    if not waypointData then return false end
    if addon.db and not addon.db.tomtomEnabled then return false end
    if not self:HasTomTom() then
        print("|cff00aaff[BNC]|r TomTom is not installed. Install TomTom to use waypoint features.")
        return false
    end

    local mapID = waypointData.mapID
    local x = waypointData.x
    local y = waypointData.y
    local title = waypointData.title or "BNC Waypoint"

    if not mapID or not x or not y then return false end

    if addon.lastWaypoint then
        pcall(function() TomTom:RemoveWaypoint(addon.lastWaypoint) end)
    end

    addon.lastWaypoint = TomTom:AddWaypoint(mapID, x, y, {
        title = title,
        persistent = false,
        minimap = true,
        world = true,
        from = "BNC",
    })

    return true
end
