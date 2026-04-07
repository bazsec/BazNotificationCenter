-- ==========================================================================
-- BNC-Keystone: Mythic+ keystone info, affixes, best runs, and completion notifications.
-- Events: CHALLENGE_MODE_COMPLETED, CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN, ITEM_CHANGED
-- ==========================================================================
local addonName, addon = ...

local MODULE_ID = "keystone"
local MODULE_NAME = "Keystone"
local MODULE_ICON = "Interface\\Icons\\INV_Relics_Hourglass"

local ICON_KEY = "Interface\\Icons\\INV_Relics_Hourglass"
local ICON_DEPLETED = "Interface\\Icons\\Ability_Creature_Cursed_01"
local ICON_UPGRADE = "Interface\\Icons\\Achievement_ChallengeMode_Gold"
local ICON_TIMER = "Interface\\Icons\\Spell_Holy_BorrowedTime"
local ICON_BEST = "Interface\\Icons\\Achievement_ChallengeMode_Platinum"
local ICON_AFFIXES = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"

local GetSetting = BNC:CreateGetSetting(MODULE_ID)

local function GetKeystoneInfo()
    local mapID = C_MythicPlus.GetOwnedKeystoneMapID()
    if not mapID then return nil end

    local level = C_MythicPlus.GetOwnedKeystoneLevel()
    local mapName = C_ChallengeMode.GetMapUIInfo(mapID)

    return {
        mapID = mapID,
        level = level or 0,
        name = mapName or "Unknown Dungeon",
    }
end

local function ShowKeystoneOnLogin()
    if GetSetting("showOnLogin") == false then return end

    C_Timer.After(4, function()
        local key = GetKeystoneInfo()
        if key then
            BNC:Push({
                module = MODULE_ID,
                title = "Your Keystone",
                message = key.name .. " +" .. key.level,
                icon = ICON_KEY,
                priority = "normal",
                duration = GetSetting("loginDuration") or 5,
                silent = GetSetting("loginToasts") == false,
            })
        end
    end)
end

local function ShowAffixes()
    if GetSetting("showAffixes") == false then return end

    C_Timer.After(5, function()
        local affixes = C_MythicPlus.GetCurrentAffixes()
        if not affixes or #affixes == 0 then return end

        local names = {}
        for _, affix in ipairs(affixes) do
            if affix.id then
                local name = C_ChallengeMode.GetAffixInfo(affix.id)
                if name then
                    table.insert(names, name)
                end
            end
        end

        if #names > 0 then
            BNC:Push({
                module = MODULE_ID,
                title = "This Week's Affixes",
                message = table.concat(names, ", "),
                icon = ICON_AFFIXES,
                priority = "low",
                duration = GetSetting("affixDuration") or 6,
                silent = GetSetting("affixToasts") == false,
            })
        end
    end)
end

local function ShowBestRuns()
    if GetSetting("showBestRuns") == false then return end

    C_Timer.After(6, function()
        local runs = C_MythicPlus.GetRunHistory(false, true)
        if not runs or #runs == 0 then return end

        local bestLevel = 0
        local bestDungeon = ""
        for _, run in ipairs(runs) do
            if run.level and run.level > bestLevel then
                bestLevel = run.level
                local name = C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID)
                bestDungeon = name or "Unknown"
            end
        end

        if bestLevel > 0 then
            BNC:Push({
                module = MODULE_ID,
                title = "Season Best",
                message = bestDungeon .. " +" .. bestLevel .. " (" .. #runs .. " runs this season)",
                icon = ICON_BEST,
                priority = "low",
                duration = GetSetting("bestDuration") or 5,
                silent = GetSetting("bestToasts") == false,
            })
        end
    end)
end

-- Track key level changes to detect upgrades vs depletions
local cachedKeyLevel = nil

local function OnKeystoneUpdate()
    local key = GetKeystoneInfo()
    if not key then return end

    if cachedKeyLevel and key.level ~= cachedKeyLevel then
        if GetSetting("showKeyChange") ~= false then
            local upgraded = key.level > cachedKeyLevel
            BNC:Push({
                module = MODULE_ID,
                title = upgraded and "Key Upgraded!" or "Key Changed",
                message = key.name .. " +" .. key.level,
                icon = upgraded and ICON_UPGRADE or ICON_DEPLETED,
                priority = upgraded and "high" or "normal",
                duration = GetSetting("keyChangeDuration") or 5,
                silent = GetSetting("keyChangeToasts") == false,
            })
        end
    end

    cachedKeyLevel = key.level
end

local function OnChallengeModeCompleted()
    if GetSetting("showCompletion") == false then return end

    local mapID, level, time, onTime, keystoneUpgradeLevels, practiceRun =
        C_ChallengeMode.GetCompletionInfo()

    if not mapID then return end

    local name = C_ChallengeMode.GetMapUIInfo(mapID)
    local timeStr = string.format("%d:%02d", math.floor(time / 60000), math.floor((time % 60000) / 1000))

    local title, icon, priority
    if onTime then
        local upgradeText = keystoneUpgradeLevels and keystoneUpgradeLevels > 0
            and (" (+" .. keystoneUpgradeLevels .. " levels)")
            or ""
        title = "Timed!" .. upgradeText
        icon = ICON_UPGRADE
        priority = "high"
    else
        title = "Completed (Overtime)"
        icon = ICON_DEPLETED
        priority = "normal"
    end

    BNC:Push({
        module = MODULE_ID,
        title = title,
        message = (name or "Dungeon") .. " +" .. (level or "?") .. " in " .. timeStr,
        icon = icon,
        priority = priority,
        duration = GetSetting("completionDuration") or 8,
        silent = GetSetting("completionToasts") == false,
    })
end

-- Event frame
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

pcall(function() eventFrame:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD") end)
pcall(function() eventFrame:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN") end)
pcall(function() eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED") end)
pcall(function() eventFrame:RegisterEvent("ITEM_CHANGED") end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isLogin = ...
        C_Timer.After(2, function()
            local key = GetKeystoneInfo()
            if key then cachedKeyLevel = key.level end
        end)

        if isLogin then
            ShowKeystoneOnLogin()
            ShowAffixes()
            ShowBestRuns()
        end
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        OnChallengeModeCompleted()
        C_Timer.After(1, OnKeystoneUpdate)
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        C_Timer.After(0.5, OnKeystoneUpdate)
    elseif event == "ITEM_CHANGED" then
        C_Timer.After(0.5, OnKeystoneUpdate)
    end
end)

BNC:RegisterModule({
    id = MODULE_ID,
    name = MODULE_NAME,
    icon = MODULE_ICON,
})

BNC:RegisterModuleOptions(MODULE_ID, {
    { key = "showOnLogin",         label = "Show Keystone on Login",        type = "toggle", default = true },
    { key = "showAffixes",         label = "Show Affixes on Login",         type = "toggle", default = true },
    { key = "showBestRuns",        label = "Show Season Best on Login",     type = "toggle", default = true },
    { key = "showKeyChange",       label = "Show Key Upgrade/Deplete",      type = "toggle", default = true },
    { key = "showCompletion",      label = "Show M+ Completion",            type = "toggle", default = true },
    { key = "loginToasts",         label = "Toast on Login Info",            type = "toggle", default = true },
    { key = "affixToasts",         label = "Toast on Affixes",              type = "toggle", default = true },
    { key = "bestToasts",          label = "Toast on Season Best",           type = "toggle", default = true },
    { key = "keyChangeToasts",     label = "Toast on Key Change",            type = "toggle", default = true },
    { key = "completionToasts",    label = "Toast on M+ Completion",         type = "toggle", default = true },
    { key = "loginDuration",       label = "Login Toast Duration",           type = "slider", default = 5, min = 1, max = 15, step = 1 },
    { key = "affixDuration",       label = "Affix Toast Duration",           type = "slider", default = 6, min = 1, max = 15, step = 1 },
    { key = "bestDuration",        label = "Best Run Toast Duration",        type = "slider", default = 5, min = 1, max = 15, step = 1 },
    { key = "keyChangeDuration",   label = "Key Change Toast Duration",      type = "slider", default = 5, min = 1, max = 15, step = 1 },
    { key = "completionDuration",  label = "Completion Toast Duration",      type = "slider", default = 8, min = 1, max = 15, step = 1 },
})
