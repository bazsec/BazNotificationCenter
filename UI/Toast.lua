local addonName, addon = ...

local Colors = addon.Colors
local TOAST_WIDTH = 300
local TOAST_HEIGHT = 52
local TOAST_SPACING = 4
local TOAST_PADDING = 8
local TOAST_ICON_SIZE = 24
local MAX_TOASTS = 5

local BACKDROP_TOAST = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local activeToasts = {}

local function CreateToast(index)
    local toast = CreateFrame("Button", "BNCToast" .. index, UIParent, "BackdropTemplate")
    toast:SetSize(TOAST_WIDTH, TOAST_HEIGHT)
    toast:SetBackdrop(BACKDROP_TOAST)
    toast:SetBackdropColor(unpack(Colors.toastBg))
    toast:SetBackdropBorderColor(unpack(Colors.toastBorder))
    toast:SetFrameStrata("HIGH")
    toast:SetFrameLevel(5)
    toast:SetClampedToScreen(true)
    toast:EnableMouse(true)
    toast:RegisterForClicks("LeftButtonUp")
    toast:Hide()

    -- Icon
    toast.icon = toast:CreateTexture(nil, "ARTWORK")
    toast.icon:SetSize(TOAST_ICON_SIZE, TOAST_ICON_SIZE)
    toast.icon:SetPoint("LEFT", toast, "LEFT", TOAST_PADDING, 0)
    toast.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Title
    toast.title = toast:CreateFontString(nil, "OVERLAY")
    toast.title:SetFontObject(GameFontNormal)
    toast.title:SetTextColor(unpack(Colors.textPrimary))
    toast.title:SetJustifyH("LEFT")
    toast.title:SetPoint("TOPLEFT", toast.icon, "TOPRIGHT", 6, 0)
    toast.title:SetPoint("RIGHT", toast, "RIGHT", -TOAST_PADDING, 0)
    toast.title:SetWordWrap(true)

    -- Message
    toast.message = toast:CreateFontString(nil, "OVERLAY")
    toast.message:SetFontObject(GameFontHighlightSmall)
    toast.message:SetTextColor(unpack(Colors.textSecondary))
    toast.message:SetJustifyH("LEFT")
    toast.message:SetPoint("BOTTOMLEFT", toast.icon, "BOTTOMRIGHT", 6, 0)
    toast.message:SetPoint("RIGHT", toast, "RIGHT", -TOAST_PADDING, 0)
    toast.message:SetWordWrap(false)

    -- Priority accent bar (left edge)
    toast.priorityBar = toast:CreateTexture(nil, "OVERLAY")
    toast.priorityBar:SetSize(2, 1)
    toast.priorityBar:SetPoint("TOPLEFT", toast, "TOPLEFT", 0, -1)
    toast.priorityBar:SetPoint("BOTTOMLEFT", toast, "BOTTOMLEFT", 0, 1)
    toast.priorityBar:Hide()

    -- Hover effect + item tooltip
    toast:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(Colors.cardHover))
        -- Pause auto-dismiss on hover
        if self._timer then
            self._timer:Cancel()
            self._timer = nil
        end
        -- Show item tooltip if notification has an itemLink
        local notif = self._notification
        if notif and notif.itemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(notif.itemLink)
            GameTooltip:Show()
        end
    end)

    toast:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(Colors.toastBg))
        -- Resume auto-dismiss
        self._timer = C_Timer.NewTimer(2, function()
            addon.DismissToast(self)
        end)
        GameTooltip:Hide()
    end)

    -- Click: ctrl-click dressing room, shift-click chat link, or run action
    toast:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    toast:SetScript("OnClick", function(self, button)
        local notif = self._notification
        local handled = false

        if notif then
            -- Item interactions
            if notif.itemLink then
                if IsControlKeyDown() then
                    DressUpItemLink(notif.itemLink)
                    addon.DismissToast(self)
                    return
                end
                if IsShiftKeyDown() then
                    ChatEdit_InsertLink(notif.itemLink)
                    addon.DismissToast(self)
                    return
                end
            end
            -- Run onClick callback if present
            if notif.onClick then
                pcall(notif.onClick, notif)
                handled = true
            end
            -- Set TomTom waypoint if present
            if notif.waypoint and BNC:HasTomTom() then
                BNC:SetWaypoint(notif.waypoint)
                handled = true
            end
        end

        addon.DismissToast(self)

        -- Fall back to opening the panel if no action was taken
        if not handled then
            if addon.TogglePanel and not addon.IsPanelShown() then
                addon.TogglePanel()
            end
        end
    end)

    return toast
end

local function ResetToast(toast)
    toast:Hide()
    toast:ClearAllPoints()
    toast.priorityBar:Hide()
    toast._notification = nil
    if toast._timer then
        toast._timer:Cancel()
        toast._timer = nil
    end
end

local toastPool = BazCore:CreateObjectPool(CreateToast, ResetToast)

local function ReanchorToasts()
    if not addon.db then return end
    local anchorData = addon.GetAnchorData(addon.db.position)
    local margin = 10
    local buttonOffset = 32  -- space for the toggle button

    -- If the panel is open, stack toasts below/above the panel instead
    local panelOffset = 0
    if addon.IsPanelShown and addon.IsPanelShown() and addon.panel then
        panelOffset = addon.panel:GetHeight() + 4
    end

    local cumulativeHeight = 0
    for i, toast in ipairs(activeToasts) do
        toast:ClearAllPoints()

        local yOff = cumulativeHeight + buttonOffset + panelOffset
        local xBase = margin * anchorData.xDir
        local yBase = (margin + yOff) * anchorData.yDir

        toast:SetPoint(anchorData.point, UIParent, anchorData.relPoint, xBase, yBase)
        cumulativeHeight = cumulativeHeight + toast:GetHeight() + TOAST_SPACING
    end
end

function addon.DismissToast(toast)
    -- Remove from active list
    for i, t in ipairs(activeToasts) do
        if t == toast then
            table.remove(activeToasts, i)
            break
        end
    end

    addon.Animations.FadeOut(toast, 0.15, function()
        toastPool:Release(toast)
        ReanchorToasts()
    end)
end

function addon.DismissAllToasts()
    -- Dismiss all active toasts immediately
    while #activeToasts > 0 do
        local toast = activeToasts[1]
        table.remove(activeToasts, 1)
        if toast._timer then toast._timer:Cancel() end
        addon.Animations.StopAll(toast)
        toastPool:Release(toast)
    end
end

local function ShowToast(notification)
    -- Limit active toasts
    while #activeToasts >= MAX_TOASTS do
        local oldest = activeToasts[#activeToasts]
        addon.DismissToast(oldest)
    end

    local toast = toastPool:Acquire()

    -- Store notification reference for click actions
    toast._notification = notification

    -- Set content
    if notification.icon then
        toast.icon:SetTexture(notification.icon)
        toast.icon:Show()
    else
        toast.icon:Hide()
    end

    toast.title:SetText(notification.title)
    toast.message:SetText(notification.message)

    -- Calculate dynamic height based on title wrapping
    local titleWidth = TOAST_WIDTH - TOAST_PADDING - TOAST_ICON_SIZE - 6 - TOAST_PADDING
    toast.title:SetWidth(titleWidth)
    local titleHeight = toast.title:GetStringHeight() or 14
    local hasMessage = notification.message and notification.message ~= ""
    local contentHeight = math.max(TOAST_ICON_SIZE, titleHeight + (hasMessage and 14 or 0))
    local dynamicHeight = TOAST_PADDING + contentHeight + TOAST_PADDING
    toast:SetHeight(math.max(TOAST_HEIGHT, dynamicHeight))

    -- Priority accent
    if notification.priority == "high" then
        toast.priorityBar:SetColorTexture(unpack(Colors.priorityHigh))
        toast.priorityBar:Show()
    else
        toast.priorityBar:Hide()
    end

    -- Insert at beginning of active list
    table.insert(activeToasts, 1, toast)
    ReanchorToasts()

    -- Animate in
    addon.Animations.FadeIn(toast, 0.2)

    -- Auto-dismiss timer
    local duration = notification.duration or (addon.db and addon.db.toastDuration) or 5
    toast._timer = C_Timer.NewTimer(duration, function()
        addon.DismissToast(toast)
    end)
end

-- Listen for toast requests
addon.Events:Register("TOAST_REQUESTED", ShowToast)
addon.Events:Register("SETTING_CHANGED_position", ReanchorToasts)
addon.Events:Register("PANEL_SHOWN", ReanchorToasts)
addon.Events:Register("PANEL_HIDDEN", ReanchorToasts)
