---------------------------------------------------------------------------
-- BazNotificationCenter
-- A modern notification center for World of Warcraft
-- Part of the Baz Suite — powered by BazCore
---------------------------------------------------------------------------
local addonName, addon = ...

-- Global API table for module addons to use
BazNotificationCenter = {}
BNC = BazNotificationCenter  -- Short alias for module authors

-- Addon version (read from TOC dynamically)
addon.VERSION = C_AddOns.GetAddOnMetadata("BazNotificationCenter", "Version") or "1"

-- Internal state
addon.modules = {}
addon.notifications = {}
addon.notificationCounter = 0
addon.suppressedFrames = {}

-- Reference to saved variables (set in Database.lua on ADDON_LOADED)
addon.db = nil

-- Panel reference (set in Panel.lua)
addon.panel = nil

-- Store addon namespace for internal use
addon.name = addonName

-- History is always available (built-in)
function addon.IsHistoryAvailable()
    return true
end

-- Global toggle function for AddonCompartmentFunc
function BNC_TogglePanel()
    if addon.TogglePanel then
        addon.TogglePanel()
    end
end

-- Register with BazCore minimap button
if BazCore and BazCore.RegisterMinimapEntry then
    BazCore:RegisterMinimapEntry("BazNotificationCenter", {
        label = "BazNotificationCenter",
        icon = "Interface\\Icons\\INV_Misc_Bell_01",
        onClick = function()
            if addon.OpenOptions then addon.OpenOptions() end
        end,
    })
end

-- TomTom integration
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

    -- Remove previous waypoint if it exists
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
