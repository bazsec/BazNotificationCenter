-- SPDX-License-Identifier: GPL-2.0-or-later
-- ==========================================================================
-- BNC-Collections: Alerts for new mounts, pets, toys, and transmog appearances.
-- Events: NEW_MOUNT_ADDED, NEW_PET_ADDED, NEW_TOY_ADDED, TRANSMOG_COLLECTION_SOURCE_ADDED
-- ==========================================================================
local addonName, addon = ...

local MODULE_ID = "collections"
local MODULE_NAME = "Collections"
local MODULE_ICON = "Interface\\Icons\\MountJournalPortrait"

local ICON_MOUNT = "Interface\\Icons\\MountJournalPortrait"
local ICON_PET = "Interface\\Icons\\INV_Pet_Achievement_CaptureAPetFromEachFamily"
local ICON_TOY = "Interface\\Icons\\INV_Misc_Toy_10"
local ICON_TRANSMOG = "Interface\\Icons\\INV_Chest_Cloth_17"

local GetSetting = BNC:CreateGetSetting(MODULE_ID)

local function OnNewMount(event, mountID)
    if GetSetting("showMounts") == false then return end
    if not mountID then return end

    local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID)

    BNC:Push({
        module = MODULE_ID,
        title = "New Mount!",
        message = name or "Unknown Mount",
        icon = icon and tostring(icon) or ICON_MOUNT,
        priority = "high",
        duration = GetSetting("mountDuration") or 6,
        silent = GetSetting("mountToasts") == false,
    })
end

local function OnNewPet(event, petGUID)
    if GetSetting("showPets") == false then return end

    local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon = C_PetJournal.GetPetInfoByPetID(petGUID)

    BNC:Push({
        module = MODULE_ID,
        title = "New Pet!",
        message = name or "Unknown Pet",
        icon = icon and tostring(icon) or ICON_PET,
        priority = "high",
        duration = GetSetting("petDuration") or 6,
        silent = GetSetting("petToasts") == false,
    })
end

local function OnNewToy(event, itemID)
    if GetSetting("showToys") == false then return end

    local _, name, icon = C_ToyBox.GetToyInfo(itemID)

    BNC:Push({
        module = MODULE_ID,
        title = "New Toy!",
        message = name or "Unknown Toy",
        icon = icon and tostring(icon) or ICON_TOY,
        priority = "normal",
        duration = GetSetting("toyDuration") or 5,
        silent = GetSetting("toyToasts") == false,
    })
end

local function OnTransmogCollected(event, itemModifiedAppearanceID)
    if GetSetting("showTransmog") == false then return end

    local sourceInfo = C_TransmogCollection.GetSourceInfo and C_TransmogCollection.GetSourceInfo(itemModifiedAppearanceID) or nil

    local name = "New Appearance"
    local icon = ICON_TRANSMOG

    local transmogItemLink = nil
    if sourceInfo and sourceInfo.itemID then
        local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(sourceInfo.itemID)
        if itemName then name = itemName end
        if itemTexture then icon = itemTexture end
        transmogItemLink = itemLink
    end

    BNC:Push({
        module = MODULE_ID,
        title = "New Transmog!",
        message = name,
        icon = icon,
        priority = "normal",
        duration = GetSetting("transmogDuration") or 4,
        silent = GetSetting("transmogToasts") == false,
        itemLink = transmogItemLink,
    })
end

local function SetupCollectionSuppression()
    if GetSetting("hideDefaultPopups") == false then return end

    BNC:HookAlertSystem(NewMountAlertSystem, function() return GetSetting("hideDefaultPopups") ~= false end)
    BNC:HookAlertSystem(NewPetAlertSystem, function() return GetSetting("hideDefaultPopups") ~= false end)
    BNC:HookAlertSystem(NewToyAlertSystem, function() return GetSetting("hideDefaultPopups") ~= false end)
    BNC:HookAlertSystem(NewRecipeLearnedAlertSystem, function() return GetSetting("hideDefaultPopups") ~= false end)
end

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pcall(function() eventFrame:RegisterEvent("NEW_MOUNT_ADDED") end)
pcall(function() eventFrame:RegisterEvent("NEW_PET_ADDED") end)
pcall(function() eventFrame:RegisterEvent("NEW_TOY_ADDED") end)
pcall(function() eventFrame:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED") end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        SetupCollectionSuppression()
        return
    end
    if event == "NEW_MOUNT_ADDED" then
        OnNewMount(event, ...)
    elseif event == "NEW_PET_ADDED" then
        OnNewPet(event, ...)
    elseif event == "NEW_TOY_ADDED" then
        OnNewToy(event, ...)
    elseif event == "TRANSMOG_COLLECTION_SOURCE_ADDED" then
        OnTransmogCollected(event, ...)
    end
end)

BNC:RegisterModule({
    id = MODULE_ID,
    name = MODULE_NAME,
    icon = MODULE_ICON,
})

BNC:RegisterModuleOptions(MODULE_ID, {
    { key = "hideDefaultPopups", label = "Hide Default Collection Popups", type = "toggle", default = true },
    { key = "showMounts",        label = "Show New Mounts",             type = "toggle", default = true },
    { key = "showPets",          label = "Show New Pets",               type = "toggle", default = true },
    { key = "showToys",          label = "Show New Toys",               type = "toggle", default = true },
    { key = "showTransmog",      label = "Show New Transmog",           type = "toggle", default = true },
    { key = "mountToasts",       label = "Toast on New Mount",          type = "toggle", default = true },
    { key = "petToasts",         label = "Toast on New Pet",            type = "toggle", default = true },
    { key = "toyToasts",         label = "Toast on New Toy",            type = "toggle", default = true },
    { key = "transmogToasts",    label = "Toast on New Transmog",       type = "toggle", default = true },
    { key = "mountDuration",     label = "Mount Toast Duration",        type = "slider", default = 6, min = 1, max = 15, step = 1 },
    { key = "petDuration",       label = "Pet Toast Duration",          type = "slider", default = 6, min = 1, max = 15, step = 1 },
    { key = "toyDuration",       label = "Toy Toast Duration",          type = "slider", default = 5, min = 1, max = 15, step = 1 },
    { key = "transmogDuration",  label = "Transmog Toast Duration",     type = "slider", default = 4, min = 1, max = 15, step = 1 },
})
