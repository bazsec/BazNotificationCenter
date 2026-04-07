-- ==========================================================================
-- BNC-TalkingHead: Captures talking head dialogue as toast notifications.
-- Events: TALKINGHEAD_REQUESTED, PLAYER_ENTERING_WORLD
-- ==========================================================================
local addonName, addon = ...

local MODULE_ID = "talkinghead"
local MODULE_NAME = "Talking Head"
local MODULE_ICON = "Interface\\Icons\\INV_Misc_Book_11"

local GetSetting = BNC:CreateGetSetting(MODULE_ID)

local lastText = ""
local lastTime = 0

local function OnTalkingHeadRequested()
    if not TalkingHeadFrame then return end

    local nameText = TalkingHeadFrame.NameFrame and TalkingHeadFrame.NameFrame.Name
    local msgText = TalkingHeadFrame.TextFrame and TalkingHeadFrame.TextFrame.Text

    local name = nameText and nameText:GetText() or ""
    local message = msgText and msgText:GetText() or ""

    name = BNC.StripEscapes(name)
    message = BNC.StripEscapes(message)

    if name == "" and message == "" then return end

    -- Dedup within 2 seconds
    local now = GetTime()
    local sig = name .. message
    if sig == lastText and (now - lastTime) < 2 then return end
    lastText = sig
    lastTime = now

    BNC:Push({
        module = MODULE_ID,
        title = name ~= "" and name or "Story",
        message = message,
        icon = MODULE_ICON,
        priority = "low",
        duration = GetSetting("duration") or 6,
        silent = GetSetting("toastsEnabled") == false,
    })

    if GetSetting("hideDefault") then
        TalkingHeadFrame:Hide()
        C_Timer.After(0.05, function()
            if TalkingHeadFrame and TalkingHeadFrame:IsShown() then
                TalkingHeadFrame:Hide()
            end
        end)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "TALKINGHEAD_REQUESTED" then
        C_Timer.After(0.1, OnTalkingHeadRequested)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Ensure the TalkingHead addon is loaded (it's load-on-demand)
        if not TalkingHeadFrame then
            UIParentLoadAddOn("Blizzard_TalkingHeadUI")
        end
    end
end)

BNC:RegisterModule({
    id = MODULE_ID,
    name = MODULE_NAME,
    icon = MODULE_ICON,
})

BNC:RegisterModuleOptions(MODULE_ID, {
    { key = "hideDefault",    label = "Hide Default Talking Head",  type = "toggle", default = false },
    { key = "duration",       label = "Toast Duration",             type = "slider", default = 6, min = 2, max = 20, step = 1 },
})
