local addonName, addon = ...

local Colors = addon.Colors
local moduleSubCategories = {}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function CreateScrollableFrame(name)
    local container = CreateFrame("Frame", name, UIParent)
    container:SetAllPoints()
    container:Hide()

    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(scrollFrame:GetWidth() or 580)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    -- Update content width when container resizes
    container:SetScript("OnSizeChanged", function(self, w)
        content:SetWidth(w - 26)
    end)

    container.scrollFrame = scrollFrame
    container.content = content

    return container
end

local function UpdateContentHeight(container)
    local maxBottom = 0
    for _, child in pairs({ container.content:GetChildren() }) do
        if child:IsShown() then
            local _, _, _, _, y = child:GetPoint()
            if y then
                local bottom = math.abs(y) + child:GetHeight()
                if bottom > maxBottom then maxBottom = bottom end
            end
        end
    end
    container.content:SetHeight(maxBottom + 20)
end

local function AddText(frame, yOffset, text, fontObj, color, width)
    local fs = frame:CreateFontString(nil, "OVERLAY")
    fs:SetFontObject(fontObj or GameFontNormal)
    if color then fs:SetTextColor(unpack(color)) end
    fs:SetWidth(width or 500)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    fs:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, yOffset)
    return fs, yOffset - fs:GetStringHeight() - 8
end

local function AddHeader(frame, yOffset, text)
    local fs = frame:CreateFontString(nil, "OVERLAY")
    fs:SetFontObject(GameFontNormal)
    fs:SetTextColor(1, 0.82, 0)
    fs:SetText(text)
    fs:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, yOffset)
    return fs, yOffset - 20
end

---------------------------------------------------------------------------
-- Main Page: User Manual
---------------------------------------------------------------------------

local function CreateMainPage()
    local container = CreateScrollableFrame("BNCOptionsMain")
    local frame = container.content
    local y = -16

    -- Title + version
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(GameFontNormalLarge)
    title:SetTextColor(unpack(Colors.textPrimary))
    title:SetText("BazNotificationCenter")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)

    local version = frame:CreateFontString(nil, "OVERLAY")
    version:SetFontObject(GameFontNormalSmall)
    version:SetTextColor(unpack(Colors.textMuted))
    version:SetText("v" .. (addon.VERSION or "1"))
    version:SetPoint("LEFT", title, "RIGHT", 8, 0)

    y = y - 30

    _, y = AddText(frame, y,
        "A modern, polished notification center for World of Warcraft. " ..
        "BazNotificationCenter captures game events and displays them as " ..
        "toasts and in a notification panel, keeping your UI clean and organized.",
        GameFontHighlight, Colors.textSecondary, 500)

    y = y - 8
    _, y = AddHeader(frame, y, "GETTING STARTED")
    _, y = AddText(frame, y,
        "A bell icon appears on your screen. Left-click it to open the notification panel. " ..
        "Right-click it to clear all notifications. " ..
        "Toasts pop up briefly when new notifications arrive.",
        GameFontHighlight, Colors.textPrimary, 500)

    y = y - 8
    _, y = AddHeader(frame, y, "NOTIFICATION PANEL")
    _, y = AddText(frame, y,
        "The panel shows your recent notifications grouped by module. " ..
        "Click a notification to interact with it — some support item tooltips, " ..
        "TomTom waypoints, or custom actions. The History tab (requires BNC-History) " ..
        "stores notifications across sessions.",
        GameFontHighlight, Colors.textPrimary, 500)

    y = y - 8
    _, y = AddHeader(frame, y, "DO NOT DISTURB")
    _, y = AddText(frame, y,
        "DND mode suppresses toasts and sounds while still logging notifications. " ..
        "Toggle manually with /bnc dnd, or set it to auto-enable during combat " ..
        "or boss encounters in the Settings tab.",
        GameFontHighlight, Colors.textPrimary, 500)

    y = y - 8
    _, y = AddHeader(frame, y, "SLASH COMMANDS")
    _, y = AddText(frame, y,
        "/bnc — Toggle notification panel\n" ..
        "/bnc test — Send a test notification\n" ..
        "/bnc testall — Send test notifications from all modules\n" ..
        "/bnc dnd — Toggle Do Not Disturb\n" ..
        "/bnc clear — Clear all notifications\n" ..
        "/bnc history — Open notification history\n" ..
        "/bnc options — Open this settings panel\n" ..
        "/bnc scaffold <name> — Print a module template for developers",
        GameFontHighlight, Colors.textPrimary, 500)

    y = y - 8
    _, y = AddHeader(frame, y, "FOR ADDON DEVELOPERS")
    _, y = AddText(frame, y,
        "Any addon can push notifications to BazNotificationCenter. " ..
        "Use /bnc scaffold <ModuleName> to generate a complete module template, " ..
        "or call BNC:RegisterModule() and BNC:Push() directly. " ..
        "See the BNC API documentation for full details.",
        GameFontHighlight, Colors.textPrimary, 500)

    container:SetScript("OnShow", function()
        UpdateContentHeight(container)
    end)

    return container
end

---------------------------------------------------------------------------
-- Settings Subcategory
---------------------------------------------------------------------------

-- Two-column layout helper for BNC settings
-- items = array of { widget, height, fullWidth (optional bool) }
local COL_GAP = 16
local COL_PAD = 16

local PANEL_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}
local PANEL_PAD = 10

local function LayoutTwoColumn(frame, items, totalWidth)
    local y = -8

    -- Separate items into groups split by fullWidth items
    local sections = {}
    local currentPair = { left = {}, right = {} }
    local col = 1

    for _, item in ipairs(items) do
        if item.fullWidth then
            -- Flush current pair if it has items
            if #currentPair.left > 0 or #currentPair.right > 0 then
                table.insert(sections, { type = "pair", data = currentPair })
                currentPair = { left = {}, right = {} }
                col = 1
            end
            table.insert(sections, { type = "full", data = item })
        else
            if col == 1 then
                table.insert(currentPair.left, item)
                col = 2
            else
                table.insert(currentPair.right, item)
                col = 1
            end
        end
    end
    -- Flush remaining
    if #currentPair.left > 0 or #currentPair.right > 0 then
        table.insert(sections, { type = "pair", data = currentPair })
    end

    -- Render sections
    local panelWidth = math.floor((totalWidth - COL_PAD * 2 - COL_GAP) / 2)

    local prevType = nil
    for _, section in ipairs(sections) do
        if section.type == "full" then
            -- Extra gap before headers that follow a panel pair
            if prevType == "pair" then
                y = y - 8
            end
            section.data.widget:SetPoint("TOPLEFT", frame, "TOPLEFT", COL_PAD, y)
            section.data.widget:Show()
            y = y - section.data.height - 4
        else
            -- Calculate height for each column
            local leftH = PANEL_PAD
            for _, item in ipairs(section.data.left) do
                leftH = leftH + item.height + 8
            end
            leftH = leftH + PANEL_PAD - 8

            local rightH = PANEL_PAD
            for _, item in ipairs(section.data.right) do
                rightH = rightH + item.height + 8
            end
            rightH = rightH + PANEL_PAD - 8

            local maxH = math.max(leftH, rightH)

            -- Left panel
            local leftPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            leftPanel:SetSize(panelWidth, maxH)
            leftPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", COL_PAD, y)
            leftPanel:SetBackdrop(PANEL_BACKDROP)
            leftPanel:SetBackdropColor(0.04, 0.04, 0.06, 0.4)
            leftPanel:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
            leftPanel:Show()

            local ly = -PANEL_PAD
            for _, item in ipairs(section.data.left) do
                item.widget:SetParent(leftPanel)
                item.widget:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", PANEL_PAD, ly)
                item.widget:Show()
                ly = ly - item.height - 8
            end

            -- Right panel
            local rightPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            rightPanel:SetSize(panelWidth, maxH)
            rightPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", COL_PAD + panelWidth + COL_GAP, y)
            rightPanel:SetBackdrop(PANEL_BACKDROP)
            rightPanel:SetBackdropColor(0.04, 0.04, 0.06, 0.4)
            rightPanel:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
            rightPanel:Show()

            local ry = -PANEL_PAD
            for _, item in ipairs(section.data.right) do
                item.widget:SetParent(rightPanel)
                item.widget:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", PANEL_PAD, ry)
                item.widget:Show()
                ry = ry - item.height - 8
            end

            y = y - maxH - 8
        end
        prevType = section.type
    end

    -- Clean up old divider if it exists
    if frame._bncDivider then
        frame._bncDivider:Hide()
    end

    return y
end

local function CreateSettingsPage()
    local container = CreateScrollableFrame("BNCOptionsSettings")
    local frame = container.content
    local settingsControls = {}
    local items = {}

    -- Title (full width)
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(GameFontNormalLarge)
    title:SetTextColor(1, 0.82, 0)
    title:SetText("Settings")
    local titleFrame = CreateFrame("Frame", nil, frame)
    titleFrame:SetSize(500, 24)
    title:SetPoint("TOPLEFT", titleFrame, "TOPLEFT", 0, 0)
    table.insert(items, { widget = titleFrame, height = 24, fullWidth = true })

    -- Panel Position header (full width)
    local posHeader = frame:CreateFontString(nil, "OVERLAY")
    posHeader:SetFontObject(GameFontNormal)
    posHeader:SetTextColor(1, 0.82, 0)
    posHeader:SetText("PANEL POSITION")
    local posHeaderFrame = CreateFrame("Frame", nil, frame)
    posHeaderFrame:SetSize(500, 20)
    posHeader:SetPoint("TOPLEFT", posHeaderFrame, "TOPLEFT", 0, 0)
    table.insert(items, { widget = posHeaderFrame, height = 20, fullWidth = true })

    -- Corner picker (in a panel, not full width — treated as a single-item pair)
    local cornerPicker = addon.CreateCornerPicker(frame)
    table.insert(settingsControls, cornerPicker)
    table.insert(items, { widget = cornerPicker, height = cornerPicker:GetHeight() })

    -- Sliders (two-column)
    local toastSlider = addon.CreateSliderControl(frame, "Toast Duration (seconds)", 1, 15, 1, "toastDuration")
    table.insert(settingsControls, toastSlider)
    table.insert(items, { widget = toastSlider, height = toastSlider:GetHeight() })

    local opacitySlider = addon.CreateSliderControl(frame, "Panel Opacity", 0.5, 1.0, 0.05, "panelOpacity")
    table.insert(settingsControls, opacitySlider)
    table.insert(items, { widget = opacitySlider, height = opacitySlider:GetHeight() })

    local scaleSlider = addon.CreateSliderControl(frame, "Scale", 0.5, 2.0, 0.1, "scale")
    table.insert(settingsControls, scaleSlider)
    table.insert(items, { widget = scaleSlider, height = scaleSlider:GetHeight() })

    local historySlider = addon.CreateSliderControl(frame, "Max Notifications", 10, 999, 10, "maxHistory")
    table.insert(settingsControls, historySlider)
    table.insert(items, { widget = historySlider, height = historySlider:GetHeight() })

    -- Toggles (two-column)
    local toastCheck = addon.CreateCheckboxControl(frame, "Enable Toast Popups", "toastsEnabled")
    table.insert(settingsControls, toastCheck)
    table.insert(items, { widget = toastCheck, height = toastCheck:GetHeight() })

    local soundCheck = addon.CreateCheckboxControl(frame, "Enable Sounds", "soundEnabled")
    table.insert(settingsControls, soundCheck)
    table.insert(items, { widget = soundCheck, height = soundCheck:GetHeight() })

    local tomtomCheck = addon.CreateCheckboxControl(frame, "Enable TomTom Waypoints", "tomtomEnabled")
    table.insert(settingsControls, tomtomCheck)
    table.insert(items, { widget = tomtomCheck, height = tomtomCheck:GetHeight() })

    -- DND header (full width)
    local dndHeader = frame:CreateFontString(nil, "OVERLAY")
    dndHeader:SetFontObject(GameFontNormal)
    dndHeader:SetTextColor(1, 0.82, 0)
    dndHeader:SetText("DO NOT DISTURB")
    local dndHeaderFrame = CreateFrame("Frame", nil, frame)
    dndHeaderFrame:SetSize(500, 20)
    dndHeader:SetPoint("TOPLEFT", dndHeaderFrame, "TOPLEFT", 0, 0)
    table.insert(items, { widget = dndHeaderFrame, height = 20, fullWidth = true })

    local dndCheck = addon.CreateCheckboxControl(frame, "Enable DND (suppress toasts & sounds)", "dndEnabled")
    table.insert(settingsControls, dndCheck)
    table.insert(items, { widget = dndCheck, height = dndCheck:GetHeight() })

    local dndCombatCheck = addon.CreateCheckboxControl(frame, "Auto-enable in combat", "dndAutoCombat")
    table.insert(settingsControls, dndCombatCheck)
    table.insert(items, { widget = dndCombatCheck, height = dndCombatCheck:GetHeight() })

    local dndInstanceCheck = addon.CreateCheckboxControl(frame, "Auto-enable during encounters", "dndAutoInstance")
    table.insert(settingsControls, dndInstanceCheck)
    table.insert(items, { widget = dndInstanceCheck, height = dndInstanceCheck:GetHeight() })

    -- Sound header (full width)
    local soundHeader = frame:CreateFontString(nil, "OVERLAY")
    soundHeader:SetFontObject(GameFontNormal)
    soundHeader:SetTextColor(1, 0.82, 0)
    soundHeader:SetText("NOTIFICATION SOUNDS")
    local soundHeaderFrame = CreateFrame("Frame", nil, frame)
    soundHeaderFrame:SetSize(500, 20)
    soundHeader:SetPoint("TOPLEFT", soundHeaderFrame, "TOPLEFT", 0, 0)
    table.insert(items, { widget = soundHeaderFrame, height = 20, fullWidth = true })

    local soundHighSlider = addon.CreateSliderControl(frame, "High Priority Sound ID (0 = silent)", 0, 100000, 1, "soundHigh")
    table.insert(settingsControls, soundHighSlider)
    table.insert(items, { widget = soundHighSlider, height = soundHighSlider:GetHeight() })

    local soundNormalSlider = addon.CreateSliderControl(frame, "Normal Priority Sound ID (0 = silent)", 0, 100000, 1, "soundNormal")
    table.insert(settingsControls, soundNormalSlider)
    table.insert(items, { widget = soundNormalSlider, height = soundNormalSlider:GetHeight() })

    local soundLowSlider = addon.CreateSliderControl(frame, "Low Priority Sound ID (0 = silent)", 0, 100000, 1, "soundLow")
    table.insert(settingsControls, soundLowSlider)
    table.insert(items, { widget = soundLowSlider, height = soundLowSlider:GetHeight() })

    -- Layout everything
    LayoutTwoColumn(frame, items, frame:GetWidth() or 580)

    container:SetScript("OnShow", function()
        for _, ctrl in ipairs(settingsControls) do
            if ctrl.Refresh then ctrl:Refresh() end
        end
        UpdateContentHeight(container)
    end)

    return container
end

---------------------------------------------------------------------------
-- Modules Subcategory (enable/disable toggles)
---------------------------------------------------------------------------

local function CreateModulesPage()
    local container = CreateScrollableFrame("BNCOptionsModules")
    local frame = container.content
    container.moduleToggles = {}

    local function RefreshModuleToggles()
        for _, ctrl in ipairs(container.moduleToggles) do
            ctrl:Hide()
            ctrl:SetParent(nil)
        end
        wipe(container.moduleToggles)
        -- Clear leaked font strings from previous renders
        for _, region in pairs({ frame:GetRegions() }) do
            region:Hide()
            region:SetParent(nil)
        end

        local modItems = {}

        -- Title (full width)
        local title = frame:CreateFontString(nil, "OVERLAY")
        title:SetFontObject(GameFontNormalLarge)
        title:SetTextColor(1, 0.82, 0)
        title:SetText("Modules")
        local titleFrame = CreateFrame("Frame", nil, frame)
        titleFrame:SetSize(500, 24)
        title:SetPoint("TOPLEFT", titleFrame, "TOPLEFT", 0, 0)
        table.insert(modItems, { widget = titleFrame, height = 24, fullWidth = true })
        table.insert(container.moduleToggles, titleFrame)

        local desc = frame:CreateFontString(nil, "OVERLAY")
        desc:SetFontObject(GameFontHighlight)
        desc:SetTextColor(unpack(Colors.textSecondary))
        desc:SetWidth(500)
        desc:SetJustifyH("LEFT")
        desc:SetText("Enable or disable notification modules. Each module has its own settings in its sub-tab.")
        local descFrame = CreateFrame("Frame", nil, frame)
        descFrame:SetSize(500, desc:GetStringHeight() + 8)
        desc:SetPoint("TOPLEFT", descFrame, "TOPLEFT", 0, 0)
        table.insert(modItems, { widget = descFrame, height = desc:GetStringHeight() + 8, fullWidth = true })
        table.insert(container.moduleToggles, descFrame)

        -- Sort modules alphabetically
        local sorted = {}
        for id, module in pairs(addon.modules) do
            if id ~= "_test" then
                table.insert(sorted, { id = id, name = module.name })
            end
        end
        table.sort(sorted, function(a, b) return a.name < b.name end)

        for _, info in ipairs(sorted) do
            local ctrl = CreateFrame("Frame", nil, frame)
            ctrl:SetSize(240, 26)

            ctrl.check = CreateFrame("CheckButton", nil, ctrl, "UICheckButtonTemplate")
            ctrl.check:SetSize(22, 22)
            ctrl.check:SetPoint("LEFT", ctrl, "LEFT", 0, 0)

            ctrl.label = ctrl:CreateFontString(nil, "OVERLAY")
            ctrl.label:SetFontObject(GameFontNormal)
            ctrl.label:SetTextColor(unpack(Colors.textPrimary))
            ctrl.label:SetText(info.name)
            ctrl.label:SetPoint("LEFT", ctrl.check, "RIGHT", 6, 0)

            local moduleId = info.id
            local isEnabled = addon.db and addon.db.modules[moduleId] and addon.db.modules[moduleId].enabled ~= false
            ctrl.check:SetChecked(isEnabled ~= false)
            ctrl.check:SetScript("OnClick", function(self)
                if not addon.db.modules[moduleId] then
                    addon.db.modules[moduleId] = {}
                end
                addon.db.modules[moduleId].enabled = self:GetChecked()
                addon.Events:Trigger("MODULE_TOGGLED", moduleId, self:GetChecked())
            end)

            table.insert(container.moduleToggles, ctrl)
            table.insert(modItems, { widget = ctrl, height = 26 })
        end

        LayoutTwoColumn(frame, modItems, frame:GetWidth() or 580)
        UpdateContentHeight(container)
    end

    container:SetScript("OnShow", RefreshModuleToggles)

    return container
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

    local container = CreateScrollableFrame("BNCOptions_" .. moduleId)
    local frame = container.content
    container.optControls = {}
    local items = {}

    -- Title (full width)
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(GameFontNormalLarge)
    title:SetTextColor(1, 0.82, 0)
    title:SetText(module.name)
    local titleFrame = CreateFrame("Frame", nil, frame)
    titleFrame:SetSize(500, 30)
    title:SetPoint("TOPLEFT", titleFrame, "TOPLEFT", 0, 0)
    table.insert(items, { widget = titleFrame, height = 30, fullWidth = true })

    for _, optDef in ipairs(optDefs) do
        if optDef.type == "toggle" then
            local ctrl = CreateFrame("Frame", nil, frame)
            ctrl:SetSize(240, 26)

            ctrl.check = CreateFrame("CheckButton", nil, ctrl, "UICheckButtonTemplate")
            ctrl.check:SetSize(22, 22)
            ctrl.check:SetPoint("LEFT", ctrl, "LEFT", 0, 0)

            ctrl.label = ctrl:CreateFontString(nil, "OVERLAY")
            ctrl.label:SetFontObject(GameFontNormal)
            ctrl.label:SetTextColor(unpack(Colors.textPrimary))
            ctrl.label:SetText(optDef.label)
            ctrl.label:SetPoint("LEFT", ctrl.check, "RIGHT", 6, 0)

            local key = optDef.key
            local default = optDef.default

            function ctrl:Refresh()
                local val = BNC:GetModuleSetting(moduleId, key)
                if val == nil then val = default end
                self.check:SetChecked(val ~= false)
            end

            ctrl.check:SetScript("OnClick", function(self)
                BNC:SetModuleSetting(moduleId, key, self:GetChecked())
            end)

            table.insert(container.optControls, ctrl)
            table.insert(items, { widget = ctrl, height = 26 })

        elseif optDef.type == "slider" then
            local ctrl = CreateFrame("Frame", nil, frame)
            ctrl:SetSize(240, 50)

            ctrl.label = ctrl:CreateFontString(nil, "OVERLAY")
            ctrl.label:SetFontObject(GameFontNormal)
            ctrl.label:SetTextColor(unpack(Colors.textPrimary))
            ctrl.label:SetText(optDef.label)
            ctrl.label:SetPoint("TOPLEFT", ctrl, "TOPLEFT", 0, 0)

            ctrl.value = ctrl:CreateFontString(nil, "OVERLAY")
            ctrl.value:SetFontObject(GameFontHighlightSmall)
            ctrl.value:SetTextColor(unpack(Colors.textSecondary))
            ctrl.value:SetPoint("TOPRIGHT", ctrl, "TOPRIGHT", 0, 0)

            ctrl.slider = CreateFrame("Slider", nil, ctrl, "MinimalSliderTemplate")
            ctrl.slider:SetSize(180, 16)
            ctrl.slider:SetPoint("TOPLEFT", ctrl.label, "BOTTOMLEFT", 0, -6)
            ctrl.slider:SetMinMaxValues(optDef.min or 1, optDef.max or 15)
            ctrl.slider:SetValueStep(optDef.step or 1)
            ctrl.slider:SetObeyStepOnDrag(true)

            local key = optDef.key
            local default = optDef.default
            local step = optDef.step or 1

            function ctrl:Refresh()
                local val = BNC:GetModuleSetting(moduleId, key)
                if val == nil then val = default end
                self.slider:SetValue(val)
                self.value:SetText(string.format(step < 1 and "%.1f" or "%d", val))
            end

            ctrl.slider:SetScript("OnValueChanged", function(self, newVal)
                newVal = math.floor(newVal / step + 0.5) * step
                ctrl.value:SetText(string.format(step < 1 and "%.1f" or "%d", newVal))
                BNC:SetModuleSetting(moduleId, key, newVal)
            end)

            table.insert(container.optControls, ctrl)
            table.insert(items, { widget = ctrl, height = 50 })
        end
    end

    LayoutTwoColumn(frame, items, frame:GetWidth() or 580)

    container:SetScript("OnShow", function()
        for _, ctrl in ipairs(container.optControls) do
            if ctrl.Refresh then ctrl:Refresh() end
        end
        UpdateContentHeight(container)
    end)

    local subCategory = Settings.RegisterCanvasLayoutSubcategory(addon.optionsCategory, container, module.name)
    moduleSubCategories[moduleId] = subCategory
end

---------------------------------------------------------------------------
-- Registration
---------------------------------------------------------------------------

local optionsCategoryReady = false

local function TryCreateAllPendingPages()
    if not optionsCategoryReady then return end
    for moduleId in pairs(addon.moduleOptionDefs) do
        if not moduleSubCategories[moduleId] then
            CreateModuleOptionsPage(moduleId)
        end
    end
end

addon.Events:Register("CORE_LOADED", function()
    -- Main page (user manual)
    local mainFrame = CreateMainPage()
    local category = Settings.RegisterCanvasLayoutCategory(mainFrame, "BazNotificationCenter")
    Settings.RegisterAddOnCategory(category)
    addon.optionsCategory = category

    -- Settings subcategory
    local settingsFrame = CreateSettingsPage()
    Settings.RegisterCanvasLayoutSubcategory(category, settingsFrame, "Settings")

    -- Modules subcategory
    local modulesFrame = CreateModulesPage()
    Settings.RegisterCanvasLayoutSubcategory(category, modulesFrame, "Modules")

    optionsCategoryReady = true
    TryCreateAllPendingPages()
end)

addon.Events:Register("MODULE_REGISTERED", TryCreateAllPendingPages)
addon.Events:Register("MODULE_OPTIONS_REGISTERED", TryCreateAllPendingPages)
addon.Events:Register("PLAYER_READY", TryCreateAllPendingPages)

function addon.OpenOptions()
    if addon.optionsCategory then
        Settings.OpenToCategory(addon.optionsCategory:GetID())
    end
end
