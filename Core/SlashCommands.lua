local addonName, addon = ...

SLASH_BNC1 = "/bnc"
SLASH_BNC2 = "/baznotify"

local function SendTestBurst()
    -- Simulate a variety of notifications from different modules
    local delay = 0

    -- Zone notification
    if addon.modules["zones"] then
        C_Timer.After(delay, function()
            BNC:Push({
                module = "zones",
                title = "Elwynn Forest",
                message = "Goldshire",
                icon = "Interface\\Icons\\INV_Misc_Map_01",
                priority = "normal",
                duration = 4,
            })
        end)
        delay = delay + 0.3
    end

    -- Loot notifications
    if addon.modules["loot"] then
        C_Timer.After(delay, function()
            BNC:Push({
                module = "loot",
                title = "|cff1eff00Rugged Leather|r",
                message = "x3",
                icon = "Interface\\Icons\\INV_Misc_LeatherScrap_08",
                priority = "low",
                duration = 4,
            })
        end)
        delay = delay + 0.2

        C_Timer.After(delay, function()
            BNC:Push({
                module = "loot",
                title = "|cff0070ddBlade of Valor|r",
                message = "",
                icon = "Interface\\Icons\\INV_Sword_39",
                priority = "normal",
                duration = 4,
            })
        end)
        delay = delay + 0.2

        C_Timer.After(delay, function()
            BNC:Push({
                module = "loot",
                title = "Gold Received",
                message = "|cffffd7002|rg |cffc7c7cf34|rs |cffeda55f15|rc",
                icon = "Interface\\Icons\\INV_Misc_Coin_01",
                priority = "low",
                duration = 3,
            })
        end)
        delay = delay + 0.2

        C_Timer.After(delay, function()
            BNC:Push({
                module = "loot",
                title = "|cffa335eeStaff of Infinite Mysteries|r",
                message = "",
                icon = "Interface\\Icons\\INV_Staff_30",
                priority = "high",
                duration = 5,
            })
        end)
        delay = delay + 0.3
    end

    -- Quest notifications
    if addon.modules["quests"] then
        C_Timer.After(delay, function()
            BNC:Push({
                module = "quests",
                title = "A Threat Within",
                message = "Wolves slain 6/10",
                icon = "Interface\\Icons\\INV_Scroll_02",
                priority = "low",
                duration = 3,
            })
        end)
        delay = delay + 0.3

        C_Timer.After(delay, function()
            BNC:Push({
                module = "quests",
                title = "Quest Completed",
                message = "A Threat Within",
                icon = "Interface\\Icons\\Achievement_Quests_Completed_08",
                priority = "high",
                duration = 5,
            })
        end)
        delay = delay + 0.2
    end

    -- Core test notification
    C_Timer.After(delay, function()
        BNC:Push({
            module = "_test",
            title = "BNC Test Complete",
            message = "All systems working!",
            icon = "Interface\\Icons\\INV_Misc_Bell_01",
            priority = "normal",
        })
    end)
end

SlashCmdList["BNC"] = function(msg)
    local cmd = strtrim(msg):lower()

    if cmd == "options" or cmd == "config" or cmd == "settings" then
        if addon.OpenOptions then
            addon.OpenOptions()
        end
    elseif cmd == "test" then
        -- Single test notification
        BNC:Push({
            module = "_test",
            title = "Test Notification",
            message = "BNC is working correctly!",
            icon = "Interface\\Icons\\INV_Misc_Bell_01",
            priority = "normal",
        })
    elseif cmd == "testall" then
        -- Burst of test notifications from all active modules
        print("|cff00aaff[BNC]|r Sending test notifications...")
        SendTestBurst()
    elseif cmd == "history" then
        if addon.ShowHistoryPanel then
            addon.ShowHistoryPanel()
        end
    elseif cmd == "clear" then
        BNC:DismissAll()
        print("|cff00aaff[BNC]|r All notifications cleared.")
    elseif cmd == "" then
        if addon.TogglePanel then
            addon.TogglePanel()
        end
    elseif cmd:match("^dnd") then
        BNC:ToggleDND()
    elseif cmd:match("^scaffold") then
        local moduleName = cmd:match("^scaffold%s+(.+)")
        if not moduleName or moduleName == "" then
            print("|cff00aaff[BNC]|r Usage: /bnc scaffold MyModule")
            print("  Prints a complete module template to chat. Copy/paste to create your own module.")
            return
        end

        -- Sanitize: strip spaces for ID, keep original for display name
        local displayName = moduleName
        local moduleId = moduleName:lower():gsub("%s+", "")
        local folderName = "BNC-" .. moduleName:gsub("%s+", "")

        print("|cff00aaff[BNC]|r === Module Scaffold: " .. folderName .. " ===")
        print("|cff00aaff[BNC]|r Create folder: Interface/AddOns/" .. folderName)
        print(" ")
        print("|cff88ff88-- FILE: " .. folderName .. "/" .. folderName .. ".toc|r")
        print("## Interface: 120001")
        print("## Title: BazNotificationCenter - " .. displayName)
        print("## Notes: Description of your module.")
        print("## Author: YourName")
        print("## Version: 1")
        print("## RequiredDeps: BazNotificationCenter")
        print("## IconTexture: Interface\\Icons\\INV_Misc_QuestionMark")
        print("## Category: User Interface")
        print(folderName .. ".lua")
        print(" ")
        print("|cff88ff88-- FILE: " .. folderName .. "/" .. folderName .. ".lua|r")
        print('local MODULE_ID = "' .. moduleId .. '"')
        print('local MODULE_NAME = "' .. displayName .. '"')
        print('local MODULE_ICON = "Interface\\\\Icons\\\\INV_Misc_QuestionMark"')
        print(" ")
        print("local GetSetting = BNC:CreateGetSetting(MODULE_ID)")
        print(" ")
        print("BNC:RegisterModule({ id = MODULE_ID, name = MODULE_NAME, icon = MODULE_ICON })")
        print(" ")
        print("BNC:RegisterModuleOptions(MODULE_ID, {")
        print('    { key = "showAlerts", label = "Show Alerts", type = "toggle", default = true },')
        print('    { key = "alertDuration", label = "Alert Duration", type = "slider", default = 5, min = 1, max = 15, step = 1 },')
        print("})")
        print(" ")
        print("-- Listen for events:")
        print('BNC:Listen("YOUR_EVENT_HERE", function(event, ...)')
        print("    if GetSetting(\"showAlerts\") == false then return end")
        print("    BNC:NewNotification(MODULE_ID)")
        print('        :title("Something Happened")')
        print('        :message("Details")')
        print('        :priority("normal")')
        print("        :send()")
        print("end)")
        print(" ")
        print("|cff00aaff[BNC]|r === End Scaffold ===")
    else
        print("|cff00aaff[BNC]|r Commands:")
        print("  /bnc - Toggle notification panel")
        print("  /bnc options - Open settings")
        print("  /bnc history - Open notification history")
        print("  /bnc dnd - Toggle Do Not Disturb")
        print("  /bnc test - Send a test notification")
        print("  /bnc testall - Send test notifications from all modules")
        print("  /bnc clear - Clear all notifications")
        print("  /bnc scaffold <name> - Print a module template")
    end
end
