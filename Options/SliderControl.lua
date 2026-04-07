local addonName, addon = ...

local Colors = addon.Colors
local SLIDER_HEIGHT = 40
local SLIDER_WIDTH = 200

function addon.CreateSliderControl(parent, label, minVal, maxVal, step, dbKey)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(280, SLIDER_HEIGHT + 20)

    -- Label
    container.label = container:CreateFontString(nil, "OVERLAY")
    container.label:SetFontObject(GameFontNormal)
    container.label:SetTextColor(unpack(Colors.textPrimary))
    container.label:SetText(label)
    container.label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

    -- Value text
    container.value = container:CreateFontString(nil, "OVERLAY")
    container.value:SetFontObject(GameFontHighlightSmall)
    container.value:SetTextColor(unpack(Colors.textSecondary))
    container.value:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    -- Slider
    container.slider = CreateFrame("Slider", nil, container, "MinimalSliderTemplate")
    container.slider:SetSize(SLIDER_WIDTH, 16)
    container.slider:SetPoint("TOPLEFT", container.label, "BOTTOMLEFT", 0, -6)
    container.slider:SetMinMaxValues(minVal, maxVal)
    container.slider:SetValueStep(step)
    container.slider:SetObeyStepOnDrag(true)

    local function UpdateValue(val)
        -- Round to step
        val = math.floor(val / step + 0.5) * step
        container.value:SetText(string.format(step < 1 and "%.2f" or "%d", val))
        if addon.db and addon.db[dbKey] ~= val then
            addon.SetDBValue(dbKey, val)
        end
    end

    container.slider:SetScript("OnValueChanged", function(self, val)
        UpdateValue(val)
    end)

    function container:Refresh()
        if addon.db then
            local val = addon.db[dbKey] or minVal
            container.slider:SetValue(val)
            UpdateValue(val)
        end
    end

    return container
end
