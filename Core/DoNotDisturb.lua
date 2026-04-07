-- ==========================================================================
-- DoNotDisturb: Suppresses toasts and sounds when active.
-- Can be toggled manually or auto-enabled in combat / rated instances.
-- ==========================================================================
local addonName, addon = ...

-- Runtime DND state (not saved — auto-DND resets on combat/instance end)
addon.dndActive = false

--- Check whether DND is currently in effect (manual toggle OR auto-triggered).
function addon.IsDND()
    if addon.db and addon.db.dndEnabled then return true end
    return addon.dndActive
end

--- Toggle manual DND on/off. Persists across sessions via saved variable.
function BNC:ToggleDND(state)
    if not addon.db then return end
    if state ~= nil then
        addon.db.dndEnabled = state
    else
        addon.db.dndEnabled = not addon.db.dndEnabled
    end
    addon.Events:Trigger("SETTING_CHANGED", "dndEnabled", addon.db.dndEnabled)
    addon.Events:Trigger("SETTING_CHANGED_dndEnabled", addon.db.dndEnabled)

    local status = addon.db.dndEnabled and "ON" or "OFF"
    print("|cff00aaff[BNC]|r Do Not Disturb: " .. status)
end

function BNC:IsDND()
    return addon.IsDND()
end

-- Auto-DND: combat
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function(self, event)
    if not addon.db or not addon.db.dndAutoCombat then return end
    if event == "PLAYER_REGEN_DISABLED" then
        addon.dndActive = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        addon.dndActive = false
    end
end)

-- Auto-DND: rated PvP / challenging instance content
local instanceFrame = CreateFrame("Frame")
instanceFrame:RegisterEvent("ENCOUNTER_START")
instanceFrame:RegisterEvent("ENCOUNTER_END")
instanceFrame:SetScript("OnEvent", function(self, event)
    if not addon.db or not addon.db.dndAutoInstance then return end
    if event == "ENCOUNTER_START" then
        addon.dndActive = true
    elseif event == "ENCOUNTER_END" then
        addon.dndActive = false
    end
end)

-- Slash command: /bnc dnd
addon.Events:Register("CORE_LOADED", function()
    local origSlashHandler = SlashCmdList["BNC"]
    if origSlashHandler then
        SlashCmdList["BNC"] = function(msg)
            if msg and msg:lower():match("^dnd") then
                BNC:ToggleDND()
            else
                origSlashHandler(msg)
            end
        end
    end
end)
