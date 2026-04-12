-- ==========================================================================
-- BNC-Rares: Alerts for rare spawns, treasures, and events via vignettes.
-- Events: VIGNETTE_MINIMAP_UPDATED, VIGNETTES_UPDATED
-- ==========================================================================
local addonName, addon = ...

local MODULE_ID = "rares"
local MODULE_NAME = "Rares"
local MODULE_ICON = "Interface\\Icons\\INV_Misc_Head_Dragon_01"

local ICON_RARE = "Interface\\Icons\\INV_Misc_Head_Dragon_01"
local ICON_RARE_ELITE = "Interface\\Icons\\Achievement_Boss_Ragnaros"
local ICON_TREASURE = "Interface\\Icons\\INV_Misc_Bag_10_Blue"
local ICON_EVENT = "Interface\\Icons\\INV_Misc_Map_01"

local VIGNETTE_COOLDOWN = 300 -- 5 minutes

local GetSetting = BNC:CreateGetSetting(MODULE_ID)

local vignetteDedup = BNC:CreateDeduplicator(VIGNETTE_COOLDOWN)

local function OnVignetteAdded(event, vignetteGUID)
    if not vignetteGUID then return end

    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
    if not vignetteInfo then return end

    local name = vignetteInfo.name
    local vignetteID = vignetteInfo.vignetteID
    local atlasName = vignetteInfo.atlasName or ""

    local dedupeKey = vignetteID or vignetteGUID
    if vignetteDedup:IsDuplicate(dedupeKey) then return end

    if vignetteInfo.isDead then return end

    -- Lowercase the atlas once (also launders any taint) so our whitelist
    -- checks below are case-insensitive. Real atlas names are CamelCase
    -- like "VignetteKill", "VignetteLoot", "Vignette-MissionNPC", etc.
    local atlas = BNC.SafeLower(atlasName)
    if not atlas or atlas == "" then return end

    -- Whitelist the vignette categories we care about. Anything else
    -- (mission NPCs, vendors, quest markers, minor vignettes, etc.) is
    -- silently dropped — otherwise every weird vignette in Silvermoon
    -- shows up as a "Rare Spawn".
    local isEvent    = string.find(atlas, "vignetteevent", 1, true) ~= nil
    local isTreasure = string.find(atlas, "vignetteloot",  1, true) ~= nil
    local isRare     = string.find(atlas, "vignettekill",  1, true) ~= nil
                    or string.find(atlas, "vignetteboss",  1, true) ~= nil

    if not (isEvent or isTreasure or isRare) then return end

    local icon = ICON_RARE
    local title = "Rare Spawn"
    local priority = "high"

    if isEvent then
        if GetSetting("showEvents") == false then return end
        icon = ICON_EVENT
        title = "Event"
        priority = "normal"
    elseif isTreasure then
        if GetSetting("showTreasures") == false then return end
        icon = ICON_TREASURE
        title = "Treasure"
        priority = "normal"
    else
        if GetSetting("showRares") == false then return end
        if string.find(atlas, "elite", 1, true) or string.find(atlas, "boss", 1, true) then
            icon = ICON_RARE_ELITE
            title = "Rare Elite"
        end
    end

    local waypointData = nil
    local mapID = C_Map.GetBestMapForUnit("player")
    local vignettePos = mapID and C_VignetteInfo.GetVignettePosition(vignetteGUID, mapID)
    if vignettePos and mapID then
        waypointData = {
            mapID = mapID,
            x = vignettePos.x,
            y = vignettePos.y,
            title = (name or "Unknown") .. " (" .. title .. ")",
        }
    end

    local message = name or "Unknown"
    if waypointData and BNC:HasTomTom() then
        message = message .. " (Click for waypoint)"
    end

    BNC:Push({
        module = MODULE_ID,
        title = title,
        message = message,
        icon = icon,
        priority = priority,
        duration = GetSetting("rareDuration") or 8,
        silent = GetSetting("rareToasts") == false,
        waypoint = waypointData,
    })
end

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")

pcall(function() eventFrame:RegisterEvent("VIGNETTES_UPDATED") end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "VIGNETTE_MINIMAP_UPDATED" then
        OnVignetteAdded(event, ...)
    elseif event == "VIGNETTES_UPDATED" then
        local guids = C_VignetteInfo.GetVignettes()
        if guids then
            for _, guid in ipairs(guids) do
                OnVignetteAdded(event, guid)
            end
        end
    end
end)

BNC:RegisterModule({
    id = MODULE_ID,
    name = MODULE_NAME,
    icon = MODULE_ICON,
})

BNC:RegisterModuleOptions(MODULE_ID, {
    { key = "showRares",       label = "Show Rare Spawns",            type = "toggle", default = true },
    { key = "showTreasures",   label = "Show Treasures",              type = "toggle", default = true },
    { key = "showEvents",      label = "Show Events",                 type = "toggle", default = true },
    { key = "rareToasts",      label = "Toast on Rare/Treasure",      type = "toggle", default = true },
    { key = "rareDuration",    label = "Toast Duration",              type = "slider", default = 8, min = 1, max = 15, step = 1 },
})
