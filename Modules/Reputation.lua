-- ==========================================================================
-- BNC-Reputation: Reputation gains/losses, standing milestones, renown.
-- Events: PLAYER_ENTERING_WORLD, CHAT_MSG_COMBAT_FACTION_CHANGE,
--         UPDATE_FACTION, MAJOR_FACTION_RENOWN_LEVEL_CHANGED
-- ==========================================================================
local addonName, addon = ...

local MODULE_ID = "reputation"
local MODULE_NAME = "Reputation"
local MODULE_ICON = "Interface\\Icons\\Achievement_Reputation_08"

local ICON_REP_GAIN = "Interface\\Icons\\Achievement_Reputation_08"
local ICON_REP_LOSS = "Interface\\Icons\\Ability_Creature_Cursed_01"
local ICON_MILESTONE = "Interface\\Icons\\Achievement_Reputation_01"
local ICON_RENOWN = "Interface\\Icons\\UI_MajorFaction_CovenantRenown"

local STANDING_LABELS = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local standingCache = {}
local renownCache = {}

local GetSetting = BNC:CreateGetSetting(MODULE_ID)

local repAccumulator = BNC:CreateAccumulator(1.5, function(data)
    for factionName, amount in pairs(data) do
        if GetSetting("showGains") ~= false then
            local sign = amount > 0 and "+" or ""
            BNC:Push({
                module = MODULE_ID,
                title = factionName,
                message = sign .. amount .. " reputation",
                icon = amount > 0 and ICON_REP_GAIN or ICON_REP_LOSS,
                priority = "low",
                duration = GetSetting("gainDuration") or 3,
                silent = GetSetting("gainToasts") == false,
            })
        end
    end
end)

local function OnFactionChange(event, msg)
    if not msg then return end

    local faction, amount = BNC.SafeMatch(msg, "Reputation with (.+) increased by (%d+)")
    if faction and amount then
        amount = tonumber(amount)
        repAccumulator:Add(faction, amount)
        return
    end

    faction, amount = BNC.SafeMatch(msg, "Reputation with (.+) decreased by (%d+)")
    if faction and amount then
        if GetSetting("showLosses") == false then return end
        amount = tonumber(amount)
        repAccumulator:Add(faction, -amount)
    end
end

local function CheckStandingMilestones()
    if GetSetting("showMilestones") == false then return end

    local numFactions = C_Reputation.GetNumFactions()
    for i = 1, numFactions do
        local factionData = C_Reputation.GetFactionDataByIndex(i)
        if factionData and not factionData.isHeader and factionData.factionID then
            local name = factionData.name
            local standingID = factionData.reaction
            local factionID = factionData.factionID

            if name and standingID then
                local cached = standingCache[factionID]

                if cached and cached ~= standingID and standingID > cached then
                    local standingName = STANDING_LABELS[standingID] or ("Standing " .. standingID)

                    BNC:Push({
                        module = MODULE_ID,
                        title = name,
                        message = "Now " .. standingName .. "!",
                        icon = ICON_MILESTONE,
                        priority = "high",
                        duration = GetSetting("milestoneDuration") or 6,
                        silent = GetSetting("milestoneToasts") == false,
                    })
                end

                standingCache[factionID] = standingID
            end
        end
    end
end

local function OnMajorFactionRenown(event, factionID, newRenownLevel, oldRenownLevel)
    if GetSetting("showRenown") == false then return end
    if not factionID then return end

    local factionData = C_MajorFactions.GetMajorFactionData(factionID)
    local factionName = factionData and factionData.name or "Faction"

    local level = newRenownLevel or (factionData and factionData.renownLevel) or "?"

    BNC:Push({
        module = MODULE_ID,
        title = factionName,
        message = "Renown Level " .. level,
        icon = ICON_RENOWN,
        priority = "high",
        duration = GetSetting("renownDuration") or 6,
        silent = GetSetting("renownToasts") == false,
    })
end

local function InitStandingCache()
    wipe(standingCache)
    local numFactions = C_Reputation.GetNumFactions()
    for i = 1, numFactions do
        local factionData = C_Reputation.GetFactionDataByIndex(i)
        if factionData and not factionData.isHeader and factionData.factionID and factionData.reaction then
            standingCache[factionData.factionID] = factionData.reaction
        end
    end
end

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
eventFrame:RegisterEvent("UPDATE_FACTION")
eventFrame:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, InitStandingCache)
    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        OnFactionChange(event, ...)
    elseif event == "UPDATE_FACTION" then
        CheckStandingMilestones()
    elseif event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" then
        OnMajorFactionRenown(event, ...)
    end
end)

BNC:RegisterModule({
    id = MODULE_ID,
    name = MODULE_NAME,
    icon = MODULE_ICON,
})

BNC:RegisterModuleOptions(MODULE_ID, {
    { key = "showGains",         label = "Show Reputation Gains",        type = "toggle", default = true },
    { key = "showLosses",        label = "Show Reputation Losses",       type = "toggle", default = true },
    { key = "showMilestones",    label = "Show Standing Milestones",     type = "toggle", default = true },
    { key = "showRenown",        label = "Show Renown Level Ups",        type = "toggle", default = true },
    { key = "gainToasts",        label = "Toast on Rep Gain",            type = "toggle", default = true },
    { key = "milestoneToasts",   label = "Toast on Milestone",           type = "toggle", default = true },
    { key = "renownToasts",      label = "Toast on Renown Level",        type = "toggle", default = true },
    { key = "gainDuration",      label = "Gain Toast Duration",          type = "slider", default = 3, min = 1, max = 15, step = 1 },
    { key = "milestoneDuration", label = "Milestone Toast Duration",     type = "slider", default = 6, min = 1, max = 15, step = 1 },
    { key = "renownDuration",    label = "Renown Toast Duration",        type = "slider", default = 6, min = 1, max = 15, step = 1 },
})
