local addonName, addon = ...

local Colors = addon.Colors
local CARD_WIDTH = 290
local CARD_PADDING = 8
local ICON_SIZE = 28
local CARD_MIN_HEIGHT = 48

local BACKDROP_CARD = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local function CreateCard(index)
    local card = CreateFrame("Button", "BNCCard" .. index, UIParent, "BackdropTemplate")
    card:SetSize(CARD_WIDTH, CARD_MIN_HEIGHT)
    card:SetBackdrop(BACKDROP_CARD)
    card:SetBackdropColor(unpack(Colors.cardBg))
    card:SetBackdropBorderColor(unpack(Colors.cardBorder))
    card:EnableMouse(true)
    card:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    card:Hide()

    -- Icon
    card.icon = card:CreateTexture(nil, "ARTWORK")
    card.icon:SetSize(ICON_SIZE, ICON_SIZE)
    card.icon:SetPoint("TOPLEFT", card, "TOPLEFT", CARD_PADDING, -CARD_PADDING)
    card.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Title
    card.title = card:CreateFontString(nil, "OVERLAY")
    card.title:SetFontObject(GameFontNormal)
    card.title:SetTextColor(unpack(Colors.textPrimary))
    card.title:SetJustifyH("LEFT")
    card.title:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 6, 0)
    card.title:SetPoint("RIGHT", card, "RIGHT", -28, 0)
    card.title:SetWordWrap(true)

    -- Timestamp
    card.timestamp = card:CreateFontString(nil, "OVERLAY")
    card.timestamp:SetFontObject(GameFontNormalSmall)
    card.timestamp:SetTextColor(unpack(Colors.textMuted))
    card.timestamp:SetJustifyH("RIGHT")
    card.timestamp:SetPoint("TOPRIGHT", card, "TOPRIGHT", -CARD_PADDING, -CARD_PADDING)

    -- Message
    card.message = card:CreateFontString(nil, "OVERLAY")
    card.message:SetFontObject(GameFontHighlightSmall)
    card.message:SetTextColor(unpack(Colors.textSecondary))
    card.message:SetJustifyH("LEFT")
    card.message:SetWordWrap(true)
    card.message:SetPoint("TOPLEFT", card.icon, "BOTTOMLEFT", 0, -4)
    card.message:SetPoint("RIGHT", card, "RIGHT", -CARD_PADDING, 0)

    -- Priority accent bar (left edge)
    card.priorityBar = card:CreateTexture(nil, "OVERLAY")
    card.priorityBar:SetSize(2, 1)
    card.priorityBar:SetPoint("TOPLEFT", card, "TOPLEFT", 0, -1)
    card.priorityBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 0, 1)
    card.priorityBar:SetColorTexture(unpack(Colors.accent))
    card.priorityBar:Hide()

    -- Dismiss button
    card.dismissBtn = CreateFrame("Button", nil, card)
    card.dismissBtn:SetSize(16, 16)
    card.dismissBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -4, -4)
    card.dismissBtn:Hide()

    card.dismissBtn.text = card.dismissBtn:CreateFontString(nil, "OVERLAY")
    card.dismissBtn.text:SetFontObject(GameFontNormalSmall)
    card.dismissBtn.text:SetText("x")
    card.dismissBtn.text:SetTextColor(unpack(Colors.dismissNormal))
    card.dismissBtn.text:SetAllPoints()

    card.dismissBtn:SetScript("OnEnter", function(self)
        self.text:SetTextColor(unpack(Colors.dismissHover))
    end)
    card.dismissBtn:SetScript("OnLeave", function(self)
        self.text:SetTextColor(unpack(Colors.dismissNormal))
    end)
    card.dismissBtn:SetScript("OnClick", function()
        if card.notificationId then
            BNC:DismissNotification(card.notificationId)
        end
    end)

    -- Hover effects + item tooltip
    card:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(Colors.cardHover))
        self.dismissBtn:Show()
        -- Show item tooltip if this notification has an itemLink
        if self.itemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.itemLink)
            GameTooltip:Show()
        end
    end)
    card:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(Colors.cardBg))
        self.dismissBtn:Hide()
        if self.itemLink then
            GameTooltip:Hide()
        end
    end)

    -- Click handler: ctrl-click for dressing room, shift-click to link in chat
    card:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if self.notificationId then
                BNC:DismissNotification(self.notificationId)
            end
            return
        end
        -- Item link interactions
        if self.itemLink then
            if IsControlKeyDown() then
                DressUpItemLink(self.itemLink)
                return
            end
            if IsShiftKeyDown() then
                ChatEdit_InsertLink(self.itemLink)
                return
            end
        end
        if self.waypointData then
            BNC:SetWaypoint(self.waypointData)
        elseif self.onClickCallback then
            addon.SafeCall(self.onClickCallback)
        end
    end)

    return card
end

local function ResetCard(card)
    card:Hide()
    card:SetParent(UIParent)
    card:ClearAllPoints()
    card.notificationId = nil
    card.onClickCallback = nil
    card.waypointData = nil
    card.itemLink = nil
    card.priorityBar:Hide()
    card.dismissBtn:Hide()
    card:SetBackdropColor(unpack(Colors.cardBg))
end

-- Create the card pool
addon.CardPool = BazCore:CreateObjectPool(CreateCard, ResetCard)

-- Helper to configure a card with notification data
function addon.SetupCard(card, notifData)
    card.notificationId = notifData.id
    card.onClickCallback = notifData.onClick
    card.waypointData = notifData.waypoint
    card.itemLink = notifData.itemLink

    -- Icon
    if notifData.icon then
        card.icon:SetTexture(notifData.icon)
        card.icon:Show()
    else
        card.icon:Hide()
    end

    -- Text
    card.title:SetText(notifData.title)
    card.message:SetText(notifData.message)
    -- Show time + relative time (e.g. "14:30 - 2m ago")
    local timeStr = addon.FormatRelativeTime(notifData.timestamp)
    if notifData.realTime then
        timeStr = addon.FormatCardTimestamp(notifData.realTime) .. " - " .. timeStr
    end
    card.timestamp:SetText(timeStr)

    -- Store timestamps for refresh
    card.notifTimestamp = notifData.timestamp
    card.notifRealTime = notifData.realTime

    -- Priority accent
    if notifData.priority == "high" then
        card.priorityBar:SetColorTexture(unpack(Colors.priorityHigh))
        card.priorityBar:Show()
    elseif notifData.priority == "low" then
        card.priorityBar:SetColorTexture(unpack(Colors.priorityLow))
        card.priorityBar:Show()
    else
        card.priorityBar:Hide()
    end

    -- Calculate height based on title and message text
    card.title:SetWidth(CARD_WIDTH - CARD_PADDING - ICON_SIZE - 6 - 28)
    local titleHeight = card.title:GetStringHeight() or 14
    card.message:SetWidth(CARD_WIDTH - CARD_PADDING * 2)
    local msgHeight = card.message:GetStringHeight() or 0
    local hasMessage = notifData.message and notifData.message ~= ""
    local contentHeight = math.max(ICON_SIZE, titleHeight)
    local totalHeight = CARD_PADDING + contentHeight + (hasMessage and (4 + msgHeight) or 0) + CARD_PADDING
    card:SetHeight(math.max(CARD_MIN_HEIGHT, totalHeight))

    return card
end

function addon.UpdateCardTimestamp(card)
    if card.notifTimestamp then
        local timeStr = addon.FormatRelativeTime(card.notifTimestamp)
        if card.notifRealTime then
            timeStr = addon.FormatCardTimestamp(card.notifRealTime) .. " - " .. timeStr
        end
        card.timestamp:SetText(timeStr)
    end
end

addon.CARD_WIDTH = CARD_WIDTH
