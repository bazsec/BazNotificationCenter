---------------------------------------------------------------------------
-- BazNotificationCenter: Options Panel
-- Uses BazCore:RegisterOptionsTable() for consistent Baz Suite styling
---------------------------------------------------------------------------
local addonName, addon = ...

local moduleSubCategories = {}

---------------------------------------------------------------------------
-- Main Page: User Manual
---------------------------------------------------------------------------

local function GetMainOptionsTable()
    return BazCore:CreateLandingPage("BazNotificationCenter", {
        subtitle = "Notification center",
        description = "A modern, polished notification center for World of Warcraft. " ..
            "Captures game events and displays them as toasts and in a browsable notification panel. " ..
            "20 built-in modules cover loot, achievements, mail, quests, reputation, and more.",
        features = "Toast popups with priority-based sounds and auto-dismiss. " ..
            "Notification panel with grouping, history, and search. " ..
            "Do Not Disturb mode (manual or auto in combat/encounters). " ..
            "Open plugin API — any addon can create notification modules.",
        guide = {
            { "Bell Icon", "Left-click to open the panel. Right-click to clear all" },
            { "Toasts", "Brief popups appear for new events and auto-dismiss" },
            { "History", "Switch to the History tab to browse past notifications" },
            { "DND", "Use |cff00ff00/bnc dnd|r or enable auto-DND in Settings" },
            { "Modules", "Enable or disable individual modules in the Modules tab" },
        },
        commands = {
            { "/bnc", "Toggle notification panel" },
            { "/bnc test", "Send a test notification" },
            { "/bnc testall", "Test all active modules" },
            { "/bnc dnd", "Toggle Do Not Disturb" },
            { "/bnc clear", "Clear all notifications" },
            { "/bnc history", "Open notification history" },
            { "/bnc options", "Open settings" },
            { "/bnc scaffold <name>", "Generate a module template" },
        },
    })
end

---------------------------------------------------------------------------
-- Settings Subcategory
---------------------------------------------------------------------------

local function GetSettingsOptionsTable()
    return {
        name = "Settings",
        type = "group",
        args = {
            positionHeader = {
                order = 1,
                type = "header",
                name = "Panel Position",
            },
            position = {
                order = 2,
                type = "select",
                name = "Screen Corner",
                values = {
                    TOPLEFT = "Top Left",
                    TOPRIGHT = "Top Right",
                    BOTTOMLEFT = "Bottom Left",
                    BOTTOMRIGHT = "Bottom Right",
                },
                get = function() return addon.db and addon.db.position or "TOPLEFT" end,
                set = function(_, val) addon.SetDBValue("position", val) end,
            },
            displayHeader = {
                order = 10,
                type = "header",
                name = "Display",
            },
            toastDuration = {
                order = 11,
                type = "range",
                name = "Toast Duration (seconds)",
                min = 1, max = 15, step = 1,
                get = function() return addon.db and addon.db.toastDuration or 5 end,
                set = function(_, val) addon.SetDBValue("toastDuration", val) end,
            },
            panelOpacity = {
                order = 12,
                type = "range",
                name = "Panel Opacity",
                min = 0.5, max = 1.0, step = 0.05,
                get = function() return addon.db and addon.db.panelOpacity or 0.85 end,
                set = function(_, val) addon.SetDBValue("panelOpacity", val) end,
            },
            scale = {
                order = 13,
                type = "range",
                name = "Scale",
                min = 0.5, max = 2.0, step = 0.1,
                get = function() return addon.db and addon.db.scale or 1.0 end,
                set = function(_, val) addon.SetDBValue("scale", val) end,
            },
            maxHistory = {
                order = 14,
                type = "range",
                name = "Max Notifications",
                min = 10, max = 999, step = 10,
                get = function() return addon.db and addon.db.maxHistory or 999 end,
                set = function(_, val) addon.SetDBValue("maxHistory", val) end,
            },
            historyRetentionDays = {
                order = 14.5,
                type = "range",
                name = "History Retention (Days)",
                desc = "Persisted notification history older than this many days is pruned at login and after each new notification.",
                min = 1, max = 90, step = 1,
                get = function() return addon.db and addon.db.historyRetentionDays or 7 end,
                set = function(_, val)
                    addon.SetDBValue("historyRetentionDays", val)
                    if addon.History_Trim then addon.History_Trim(val) end
                end,
            },
            toastsEnabled = {
                order = 15,
                type = "toggle",
                name = "Enable Toast Popups",
                get = function() return addon.db and addon.db.toastsEnabled ~= false end,
                set = function(_, val) addon.SetDBValue("toastsEnabled", val) end,
            },
            soundEnabled = {
                order = 16,
                type = "toggle",
                name = "Enable Sounds",
                get = function() return addon.db and addon.db.soundEnabled ~= false end,
                set = function(_, val) addon.SetDBValue("soundEnabled", val) end,
            },
            tomtomEnabled = {
                order = 17,
                type = "toggle",
                name = "Enable TomTom Waypoints",
                get = function() return addon.db and addon.db.tomtomEnabled ~= false end,
                set = function(_, val) addon.SetDBValue("tomtomEnabled", val) end,
            },
            dndHeader = {
                order = 20,
                type = "header",
                name = "Do Not Disturb",
            },
            dndEnabled = {
                order = 21,
                type = "toggle",
                name = "Enable DND (suppress toasts & sounds)",
                get = function() return addon.db and addon.db.dndEnabled end,
                set = function(_, val) addon.SetDBValue("dndEnabled", val) end,
            },
            dndAutoCombat = {
                order = 22,
                type = "toggle",
                name = "Auto-enable in combat",
                get = function() return addon.db and addon.db.dndAutoCombat end,
                set = function(_, val) addon.SetDBValue("dndAutoCombat", val) end,
            },
            dndAutoInstance = {
                order = 23,
                type = "toggle",
                name = "Auto-enable during encounters",
                get = function() return addon.db and addon.db.dndAutoInstance end,
                set = function(_, val) addon.SetDBValue("dndAutoInstance", val) end,
            },
            soundHeader = {
                order = 30,
                type = "header",
                name = "Notification Sounds",
            },
            soundHigh = {
                order = 31,
                type = "range",
                name = "High Priority Sound ID (0 = silent)",
                min = 0, max = 100000, step = 1,
                get = function() return addon.db and addon.db.soundHigh or 8959 end,
                set = function(_, val) addon.SetDBValue("soundHigh", val) end,
            },
            soundNormal = {
                order = 32,
                type = "range",
                name = "Normal Priority Sound ID (0 = silent)",
                min = 0, max = 100000, step = 1,
                get = function() return addon.db and addon.db.soundNormal or 618 end,
                set = function(_, val) addon.SetDBValue("soundNormal", val) end,
            },
            soundLow = {
                order = 33,
                type = "range",
                name = "Low Priority Sound ID (0 = silent)",
                min = 0, max = 100000, step = 1,
                get = function() return addon.db and addon.db.soundLow or 0 end,
                set = function(_, val) addon.SetDBValue("soundLow", val) end,
            },
        },
    }
end

---------------------------------------------------------------------------
-- Modules Subcategory (enable/disable toggles)
---------------------------------------------------------------------------

local function GetModulesOptionsTable()
    local args = {
        desc = {
            order = 1,
            type = "description",
            name = "Enable or disable notification modules. Each module has its own settings in its sub-tab.",
        },
    }

    -- Sort modules alphabetically
    local sorted = {}
    for id, module in pairs(addon.modules) do
        if id ~= "_test" then
            table.insert(sorted, { id = id, name = module.name })
        end
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)

    for i, info in ipairs(sorted) do
        local moduleId = info.id
        args["mod_" .. moduleId] = {
            order = 10 + i,
            type = "toggle",
            name = info.name,
            get = function()
                if not addon.db then return true end
                local settings = addon.db.modules[moduleId]
                if not settings then return true end
                return settings.enabled ~= false
            end,
            set = function(_, val)
                if not addon.db.modules[moduleId] then
                    addon.db.modules[moduleId] = {}
                end
                addon.db.modules[moduleId].enabled = val
                addon.Events:Trigger("MODULE_TOGGLED", moduleId, val)
            end,
        }
    end

    return {
        name = "Modules",
        type = "group",
        args = args,
    }
end

---------------------------------------------------------------------------
-- Global Options Subcategory
---------------------------------------------------------------------------

local function GetGlobalOptionsTable()
    return BazCore:CreateGlobalOptionsPage("BazNotificationCenter", {
        getOverrides = function()
            if not addon.db then return {} end
            if not addon.db.globalOverrides then addon.db.globalOverrides = {} end
            return addon.db.globalOverrides
        end,
        setOverride = function(key, field, value)
            if not addon.db then return end
            if not addon.db.globalOverrides then addon.db.globalOverrides = {} end
            if not addon.db.globalOverrides[key] then
                addon.db.globalOverrides[key] = { enabled = false, value = nil }
            end
            addon.db.globalOverrides[key][field] = value
        end,
        overrides = {
            { key = "toastDuration",  label = "Toast Duration",  type = "slider",  default = 5, min = 1, max = 15, step = 1 },
            { key = "soundEnabled",   label = "Play Sound",      type = "toggle",  default = true },
            { key = "toastsEnabled",  label = "Enable Toasts",   type = "toggle",  default = true },
        },
    })
end

---------------------------------------------------------------------------
-- Per-Module Settings Subcategory
---------------------------------------------------------------------------

local function CreateModuleOptionsPage(moduleId)
    local module = addon.modules[moduleId]
    if not module then return end

    local optDefs = addon.moduleOptionDefs[moduleId]
    if not optDefs then return end

    if moduleSubCategories[moduleId] then return end

    local function GetModuleOptionsTable()
        local args = {}

        for i, optDef in ipairs(optDefs) do
            local key = optDef.key
            local default = optDef.default

            -- Disable widget when a global override is active for this key
            local disabledFunc = function()
                return BNC:IsGlobalOverrideActive(key)
            end

            if optDef.type == "toggle" then
                args[key] = {
                    order = i,
                    type = "toggle",
                    name = optDef.label,
                    get = function()
                        local val = BNC:GetModuleSetting(moduleId, key)
                        if val == nil then return default ~= false end
                        return val ~= false
                    end,
                    set = function(_, val)
                        BNC:SetModuleSetting(moduleId, key, val)
                    end,
                    disabled = disabledFunc,
                }
            elseif optDef.type == "slider" then
                args[key] = {
                    order = i,
                    type = "range",
                    name = optDef.label,
                    min = optDef.min or 1,
                    max = optDef.max or 15,
                    step = optDef.step or 1,
                    get = function()
                        local val = BNC:GetModuleSetting(moduleId, key)
                        if val == nil then return default or optDef.min or 1 end
                        return val
                    end,
                    set = function(_, val)
                        BNC:SetModuleSetting(moduleId, key, val)
                    end,
                    disabled = disabledFunc,
                }
            end
        end

        return {
            name = module.name,
            type = "group",
            args = args,
        }
    end

    BazCore:RegisterOptionsTable("BazNotificationCenter-" .. moduleId, GetModuleOptionsTable)
    BazCore:AddToSettings("BazNotificationCenter-" .. moduleId, module.name, "BazNotificationCenter")

    moduleSubCategories[moduleId] = true
end

---------------------------------------------------------------------------
-- Registration
---------------------------------------------------------------------------

local function TryCreateAllPendingPages()
    for moduleId in pairs(addon.moduleOptionDefs) do
        if not moduleSubCategories[moduleId] then
            CreateModuleOptionsPage(moduleId)
        end
    end
end

local optionsReady = false

addon.Events:Register("CORE_LOADED", function()
    -- Main page (user manual) — must be first so parent category exists
    BazCore:RegisterOptionsTable("BazNotificationCenter", GetMainOptionsTable)
    BazCore:AddToSettings("BazNotificationCenter", "BazNotificationCenter")

    -- Settings subcategory
    BazCore:RegisterOptionsTable("BazNotificationCenter-Settings", GetSettingsOptionsTable)
    BazCore:AddToSettings("BazNotificationCenter-Settings", "Settings", "BazNotificationCenter")

    -- Global Options subcategory
    BazCore:RegisterOptionsTable("BazNotificationCenter-GlobalOptions", GetGlobalOptionsTable)
    BazCore:AddToSettings("BazNotificationCenter-GlobalOptions", "Global Options", "BazNotificationCenter")

    -- Modules subcategory
    BazCore:RegisterOptionsTable("BazNotificationCenter-Modules", GetModulesOptionsTable)
    BazCore:AddToSettings("BazNotificationCenter-Modules", "Modules", "BazNotificationCenter")

    -- Now safe to create per-module pages
    optionsReady = true
    TryCreateAllPendingPages()
end)

-- These fire before CORE_LOADED, so guard with optionsReady
addon.Events:Register("MODULE_REGISTERED", function()
    if optionsReady then TryCreateAllPendingPages() end
end)
addon.Events:Register("MODULE_OPTIONS_REGISTERED", function()
    if optionsReady then TryCreateAllPendingPages() end
end)
addon.Events:Register("PLAYER_READY", TryCreateAllPendingPages)

function addon.OpenOptions()
    BazCore:OpenOptionsPanel("BazNotificationCenter")
end
