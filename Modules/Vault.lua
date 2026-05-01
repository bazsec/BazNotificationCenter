-- SPDX-License-Identifier: GPL-2.0-or-later
-- ==========================================================================
-- BNC-Vault: Great Vault weekly progress tracking and login summary.
-- Events: WEEKLY_REWARDS_UPDATE, PLAYER_ENTERING_WORLD
-- ==========================================================================
local addonName, addon = ...

local MODULE_ID = "vault"
local MODULE_NAME = "Great Vault"
local MODULE_ICON = "Interface\\Icons\\INV_Misc_Lockbox_1"

local ICON_VAULT = "Interface\\Icons\\INV_Misc_Lockbox_1"
local ICON_RAID = "Interface\\Icons\\Achievement_Dungeon_ClassicDungeonMaster"
local ICON_MYTHIC = "Interface\\Icons\\INV_Relics_Hourglass"
local ICON_PVP = "Interface\\Icons\\Achievement_Arena_2v2_7"
local ICON_READY = "Interface\\Icons\\INV_Misc_Coin_17"

local GetSetting = BNC:CreateGetSetting(MODULE_ID)

local activityCache = {}

-- Aggregate vault activities into raid/dungeon/pvp buckets
local function GetVaultSummary()
    local activities = C_WeeklyRewards.GetActivities()
    if not activities then return nil end

    local summary = {
        raid = { progress = 0, threshold = 0 },
        dungeon = { progress = 0, threshold = 0 },
        pvp = { progress = 0, threshold = 0 },
    }

    for _, activity in ipairs(activities) do
        local typeKey
        if activity.type == Enum.WeeklyRewardChestThresholdType.Raid then
            typeKey = "raid"
        elseif activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
            typeKey = "dungeon"
        elseif activity.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            typeKey = "pvp"
        end

        if typeKey then
            if activity.progress > summary[typeKey].progress then
                summary[typeKey].progress = activity.progress
                summary[typeKey].threshold = activity.threshold
            end
        end
    end

    return summary
end

local function CheckVaultProgress()
    local summary = GetVaultSummary()
    if not summary then return end

    for typeKey, data in pairs(summary) do
        local cached = activityCache[typeKey]

        if cached and data.progress > cached and data.threshold > 0 then
            local title, icon
            if typeKey == "raid" then
                title = "Raid Progress"
                icon = ICON_RAID
            elseif typeKey == "dungeon" then
                title = "Dungeon Progress"
                icon = ICON_MYTHIC
            elseif typeKey == "pvp" then
                title = "PvP Progress"
                icon = ICON_PVP
            end

            if GetSetting("showProgress") ~= false then
                -- Count total slots earned across all activity types
                local slotsEarned = 0
                local activities = C_WeeklyRewards.GetActivities()
                if activities then
                    for _, act in ipairs(activities) do
                        if act.progress >= act.threshold then
                            slotsEarned = slotsEarned + 1
                        end
                    end
                end

                BNC:Push({
                    module = MODULE_ID,
                    title = title or "Vault Progress",
                    message = data.progress .. "/" .. data.threshold .. " (" .. slotsEarned .. "/9 slots)",
                    icon = icon or ICON_VAULT,
                    priority = "normal",
                    duration = GetSetting("progressDuration") or 4,
                    silent = GetSetting("progressToasts") == false,
                })
            end
        end

        activityCache[typeKey] = data.progress
    end
end

-- Display vault status summary after login
local function ShowVaultOnLogin()
    if GetSetting("showOnLogin") == false then return end

    C_Timer.After(4, function()
        local summary = GetVaultSummary()
        if not summary then return end

        local parts = {}
        if summary.raid.threshold > 0 then
            table.insert(parts, "Raid: " .. summary.raid.progress .. "/" .. summary.raid.threshold)
        end
        if summary.dungeon.threshold > 0 then
            table.insert(parts, "M+: " .. summary.dungeon.progress .. "/" .. summary.dungeon.threshold)
        end
        if summary.pvp.threshold > 0 then
            table.insert(parts, "PvP: " .. summary.pvp.progress .. "/" .. summary.pvp.threshold)
        end

        if #parts > 0 then
            local hasRewards = C_WeeklyRewards.HasAvailableRewards()

            BNC:Push({
                module = MODULE_ID,
                title = hasRewards and "Great Vault Ready!" or "Great Vault",
                message = table.concat(parts, " | "),
                icon = hasRewards and ICON_READY or ICON_VAULT,
                priority = hasRewards and "high" or "low",
                duration = GetSetting("loginDuration") or 6,
                silent = GetSetting("loginToasts") == false,
            })
        end
    end)
end

local function InitCache()
    local summary = GetVaultSummary()
    if summary then
        for typeKey, data in pairs(summary) do
            activityCache[typeKey] = data.progress
        end
    end
end

-- Event frame
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("WEEKLY_REWARDS_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isLogin, isReload = ...
        C_Timer.After(2, InitCache)
        if isLogin then
            ShowVaultOnLogin()
        end
    elseif event == "WEEKLY_REWARDS_UPDATE" then
        CheckVaultProgress()
    end
end)

BNC:RegisterModule({
    id = MODULE_ID,
    name = MODULE_NAME,
    icon = MODULE_ICON,
})

BNC:RegisterModuleOptions(MODULE_ID, {
    { key = "showOnLogin",       label = "Show Vault Summary on Login",   type = "toggle", default = true },
    { key = "showProgress",      label = "Show Vault Progress Updates",   type = "toggle", default = true },
    { key = "loginToasts",       label = "Toast on Login Summary",        type = "toggle", default = true },
    { key = "progressToasts",    label = "Toast on Progress Update",      type = "toggle", default = true },
    { key = "loginDuration",     label = "Login Toast Duration",          type = "slider", default = 6, min = 1, max = 15, step = 1 },
    { key = "progressDuration",  label = "Progress Toast Duration",       type = "slider", default = 4, min = 1, max = 15, step = 1 },
})
