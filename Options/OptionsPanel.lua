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
    return {
        name = "BazNotificationCenter",
        type = "group",
        args = {
            desc1 = {
                order = 1,
                type = "description",
                name = "A modern, polished notification center for World of Warcraft. " ..
                    "BazNotificationCenter captures game events and displays them as " ..
                    "toasts and in a notification panel, keeping your UI clean and organized.",
                fontSize = "medium",
            },
            gettingStarted = {
                order = 2,
                type = "header",
                name = "Getting Started",
            },
            desc2 = {
                order = 3,
                type = "description",
                name = "A bell icon appears on your screen. Left-click it to open the notification panel. " ..
                    "Right-click it to clear all notifications. " ..
                    "Toasts pop up briefly when new notifications arrive.",
            },
            panelHeader = {
                order = 4,
                type = "header",
                name = "Notification Panel",
            },
            desc3 = {
                order = 5,
                type = "description",
                name = "The panel shows your recent notifications grouped by module. " ..
                    "Click a notification to interact with it — some support item tooltips, " ..
                    "TomTom waypoints, or custom actions. The History tab stores notifications across sessions.",
            },
            dndHeader = {
                order = 6,
                type = "header",
                name = "Do Not Disturb",
            },
            desc4 = {
                order = 7,
                type = "description",
                name = "DND mode suppresses toasts and sounds while still logging notifications. " ..
                    "Toggle manually with /bnc dnd, or set it to auto-enable during combat " ..
                    "or boss encounters in the Settings tab.",
            },
            commandsHeader = {
                order = 8,
                type = "header",
                name = "Slash Commands",
            },
            desc5 = {
                order = 9,
                type = "description",
                name = "/bnc — Toggle notification panel\n" ..
                    "/bnc test — Send a test notification\n" ..
                    "/bnc testall — Send test notifications from all modules\n" ..
                    "/bnc dnd — Toggle Do Not Disturb\n" ..
                    "/bnc clear — Clear all notifications\n" ..
                    "/bnc history — Open notification history\n" ..
                    "/bnc options — Open this settings panel\n" ..
                    "/bnc scaffold <name> — Print a module template for developers",
            },
            devHeader = {
                order = 10,
                type = "header",
                name = "For Addon Developers",
            },
            desc6 = {
                order = 11,
                type = "description",
                name = "Any addon can push notifications to BazNotificationCenter. " ..
                    "Use /bnc scaffold <ModuleName> to generate a complete module template, " ..
                    "or call BNC:RegisterModule() and BNC:Push() directly.",
            },
        },
    }
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
                }
            end
        end

        return {
            name = module.name,
            type = "group",
            args = args,
        }
    end

    BazCore:RegisterOptionsTable("BNC_" .. moduleId, GetModuleOptionsTable)
    BazCore:AddToSettings("BNC_" .. moduleId, module.name, "BNC")

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
    BazCore:RegisterOptionsTable("BNC", GetMainOptionsTable)
    BazCore:AddToSettings("BNC", "BazNotificationCenter")

    -- Settings subcategory
    BazCore:RegisterOptionsTable("BNC_Settings", GetSettingsOptionsTable)
    BazCore:AddToSettings("BNC_Settings", "Settings", "BNC")

    -- Modules subcategory
    BazCore:RegisterOptionsTable("BNC_Modules", GetModulesOptionsTable)
    BazCore:AddToSettings("BNC_Modules", "Modules", "BNC")

    -- Profiles subcategory
    if BazCore.GetProfileOptionsTable then
        BazCore:RegisterOptionsTable("BNC_Profiles", function()
            return BazCore:GetProfileOptionsTable("BazNotificationCenter")
        end)
        BazCore:AddToSettings("BNC_Profiles", "Profiles", "BNC")
    end

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
    BazCore:OpenOptionsPanel("BNC")
end
