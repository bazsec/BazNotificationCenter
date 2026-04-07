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
    content:SetWidth(540)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

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
    fs:SetTextColor(unpack(Colors.groupHeader))
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

    -- Baz Suite list
    y = y - 8
    _, y = AddHeader(frame, y, "BAZ SUITE")

    local bazAddons = {}
    for name, config in pairs(BazCore.addons) do
        local ver = C_AddOns.GetAddOnMetadata(name, "Version") or "?"
        table.insert(bazAddons, (config.title or name) .. " v" .. ver)
    end
    table.sort(bazAddons)
    local bazText = "|cff3399ffBazCore|r v" .. BazCore.VERSION .. "\n"
    for _, line in ipairs(bazAddons) do
        bazText = bazText .. "|cffffffff" .. line .. "|r\n"
    end
    _, y = AddText(frame, y, bazText, GameFontHighlight, nil, 500)

    container:SetScript("OnShow", function()
        UpdateContentHeight(container)
    end)

    return container
end

---------------------------------------------------------------------------
-- Settings Subcategory
---------------------------------------------------------------------------

local function CreateSettingsPage()
    local container = CreateScrollableFrame("BNCOptionsSettings")
    local frame = container.content
    local settingsControls = {}

    local y = -16

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(GameFontNormalLarge)
    title:SetTextColor(unpack(Colors.textPrimary))
    title:SetText("Settings")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    y = y - 30

    -- Corner picker
    local cornerPicker = addon.CreateCornerPicker(frame)
    cornerPicker:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, cornerPicker)
    y = y - cornerPicker:GetHeight() - 16

    -- Toast duration
    local toastSlider = addon.CreateSliderControl(frame, "Toast Duration (seconds)", 1, 15, 1, "toastDuration")
    toastSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, toastSlider)
    y = y - toastSlider:GetHeight() - 12

    -- Panel opacity
    local opacitySlider = addon.CreateSliderControl(frame, "Panel Opacity", 0.5, 1.0, 0.05, "panelOpacity")
    opacitySlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, opacitySlider)
    y = y - opacitySlider:GetHeight() - 12

    -- Scale
    local scaleSlider = addon.CreateSliderControl(frame, "Scale", 0.5, 2.0, 0.1, "scale")
    scaleSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, scaleSlider)
    y = y - scaleSlider:GetHeight() - 12

    -- Max notifications
    local historySlider = addon.CreateSliderControl(frame, "Max Notifications", 10, 999, 10, "maxHistory")
    historySlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, historySlider)
    y = y - historySlider:GetHeight() - 16

    -- Toggles
    local toastCheck = addon.CreateCheckboxControl(frame, "Enable Toast Popups", "toastsEnabled")
    toastCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, toastCheck)
    y = y - toastCheck:GetHeight() - 8

    local soundCheck = addon.CreateCheckboxControl(frame, "Enable Sounds", "soundEnabled")
    soundCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, soundCheck)
    y = y - soundCheck:GetHeight() - 8

    local tomtomCheck = addon.CreateCheckboxControl(frame, "Enable TomTom Waypoints", "tomtomEnabled")
    tomtomCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, tomtomCheck)
    y = y - tomtomCheck:GetHeight() - 16

    -- DND section
    _, y = AddHeader(frame, y, "DO NOT DISTURB")

    local dndCheck = addon.CreateCheckboxControl(frame, "Enable Do Not Disturb (suppress toasts & sounds)", "dndEnabled")
    dndCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, dndCheck)
    y = y - dndCheck:GetHeight() - 8

    local dndCombatCheck = addon.CreateCheckboxControl(frame, "Auto-enable DND in combat", "dndAutoCombat")
    dndCombatCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, dndCombatCheck)
    y = y - dndCombatCheck:GetHeight() - 8

    local dndInstanceCheck = addon.CreateCheckboxControl(frame, "Auto-enable DND during boss encounters", "dndAutoInstance")
    dndInstanceCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, dndInstanceCheck)
    y = y - dndInstanceCheck:GetHeight() - 16

    -- Sound section
    _, y = AddHeader(frame, y, "NOTIFICATION SOUNDS")

    local soundHighSlider = addon.CreateSliderControl(frame, "High Priority Sound ID (0 = silent)", 0, 100000, 1, "soundHigh")
    soundHighSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, soundHighSlider)
    y = y - soundHighSlider:GetHeight() - 12

    local soundNormalSlider = addon.CreateSliderControl(frame, "Normal Priority Sound ID (0 = silent)", 0, 100000, 1, "soundNormal")
    soundNormalSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, soundNormalSlider)
    y = y - soundNormalSlider:GetHeight() - 12

    local soundLowSlider = addon.CreateSliderControl(frame, "Low Priority Sound ID (0 = silent)", 0, 100000, 1, "soundLow")
    soundLowSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    table.insert(settingsControls, soundLowSlider)
    y = y - soundLowSlider:GetHeight() - 16

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

        local y = -16

        local title = frame:CreateFontString(nil, "OVERLAY")
        title:SetFontObject(GameFontNormalLarge)
        title:SetTextColor(unpack(Colors.textPrimary))
        title:SetText("Modules")
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
        y = y - 24

        local desc = frame:CreateFontString(nil, "OVERLAY")
        desc:SetFontObject(GameFontHighlight)
        desc:SetTextColor(unpack(Colors.textSecondary))
        desc:SetWidth(500)
        desc:SetJustifyH("LEFT")
        desc:SetText("Enable or disable notification modules. Each module has its own settings in its sub-tab.")
        desc:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
        y = y - desc:GetStringHeight() - 16

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
            ctrl:SetSize(400, 26)
            ctrl:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)

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

            ctrl:Show()
            table.insert(container.moduleToggles, ctrl)
            y = y - 30
        end

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

    local y = -16

    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(GameFontNormalLarge)
    title:SetTextColor(unpack(Colors.textPrimary))
    title:SetText(module.name)
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)
    y = y - 40

    for _, optDef in ipairs(optDefs) do
        if optDef.type == "toggle" then
            local ctrl = CreateFrame("Frame", nil, frame)
            ctrl:SetSize(280, 26)
            ctrl:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)

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

            ctrl:Show()
            table.insert(container.optControls, ctrl)
            y = y - 28

        elseif optDef.type == "slider" then
            local ctrl = CreateFrame("Frame", nil, frame)
            ctrl:SetSize(280, 50)
            ctrl:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, y)

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
            ctrl.slider:SetSize(200, 16)
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

            ctrl:Show()
            table.insert(container.optControls, ctrl)
            y = y - 54
        end
    end

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
