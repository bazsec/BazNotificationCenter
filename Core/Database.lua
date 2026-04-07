local addonName, addon = ...

local DEFAULTS = {
    position = "TOPLEFT",
    toastDuration = 5,
    toastsEnabled = true,
    soundEnabled = true,
    tomtomEnabled = true,
    panelOpacity = 0.85,
    maxHistory = 999,
    scale = 1.0,
    dndEnabled = false,       -- Do Not Disturb: suppress toasts and sounds
    dndAutoCombat = false,    -- Auto-enable DND in combat
    dndAutoInstance = false,  -- Auto-enable DND in rated PvP / M+ boss fights
    soundHigh = 8959,         -- SOUNDKIT: high priority sound ID
    soundNormal = 618,        -- SOUNDKIT: normal priority sound ID (default whoosh)
    soundLow = 0,             -- 0 = no sound for low priority
    modules = {},
    history = { days = {}, dayIndex = {} },
}

local function MergeDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                MergeDefaults(target[key], value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            MergeDefaults(target[key], value)
        end
    end
end

addon.RegisterEvent("ADDON_LOADED", function(event, loadedAddon)
    if loadedAddon ~= addonName then return end

    -- Initialize saved variables
    if not BazNotificationCenterDB then
        BazNotificationCenterDB = {}
    end

    MergeDefaults(BazNotificationCenterDB, DEFAULTS)

    addon.db = BazNotificationCenterDB

    addon.UnregisterEvent("ADDON_LOADED")
    addon.Events:Trigger("CORE_LOADED")
end)

addon.RegisterEvent("PLAYER_ENTERING_WORLD", function(event, isLogin, isReload)
    addon.Events:Trigger("PLAYER_READY", isLogin, isReload)
end)

-- History is always available now (built-in)
addon.historyLoaded = true

function addon.IsHistoryAvailable()
    return true
end

-- Public getter/setter that triggers change events
function addon.SetDBValue(key, value)
    if addon.db then
        addon.db[key] = value
        addon.Events:Trigger("SETTING_CHANGED", key, value)
        addon.Events:Trigger("SETTING_CHANGED_" .. key, value)
    end
end

function addon.GetDBValue(key)
    if addon.db then
        return addon.db[key]
    end
end
