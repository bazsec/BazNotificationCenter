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
    historyBuffer = {},  -- small buffer, flushed to BNC-History on logout
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

-- Flush history buffer to BNC-History on logout
local function FlushHistoryBuffer()
    if not addon.db or not addon.db.historyBuffer or #addon.db.historyBuffer == 0 then return end

    -- Load the BNC-History addon if not already loaded
    if not BNC_History_AppendEntries then
        C_AddOns.LoadAddOn("BNC-History")
    end

    -- Append buffered entries to persistent storage
    if BNC_History_AppendEntries then
        BNC_History_AppendEntries(addon.db.historyBuffer)
        wipe(addon.db.historyBuffer)
    end
    -- If BNC_History_AppendEntries still doesn't exist, keep buffer for next time
end

-- Migrate old history data if it exists
local function MigrateOldHistory()
    if addon.db.history and type(addon.db.history) == "table" and #addon.db.history > 0 then
        if not addon.db.historyBuffer then
            addon.db.historyBuffer = {}
        end
        for _, entry in ipairs(addon.db.history) do
            table.insert(addon.db.historyBuffer, entry)
        end
    end
    addon.db.history = nil
    addon.db.maxHistoryLog = nil
end

addon.RegisterEvent("ADDON_LOADED", function(event, loadedAddon)
    if loadedAddon ~= addonName then return end

    -- Initialize saved variables
    if not BazNotificationCenterDB then
        BazNotificationCenterDB = {}
    end

    MergeDefaults(BazNotificationCenterDB, DEFAULTS)

    addon.db = BazNotificationCenterDB

    -- Migrate old history format
    MigrateOldHistory()

    addon.UnregisterEvent("ADDON_LOADED")
    addon.Events:Trigger("CORE_LOADED")
end)

addon.RegisterEvent("PLAYER_ENTERING_WORLD", function(event, isLogin, isReload)
    addon.Events:Trigger("PLAYER_READY", isLogin, isReload)
end)

addon.RegisterEvent("PLAYER_LOGOUT", function()
    FlushHistoryBuffer()
end)

-- Expose for use by HistoryPanel
addon.FlushHistoryBuffer = FlushHistoryBuffer
addon.historyLoaded = false

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
