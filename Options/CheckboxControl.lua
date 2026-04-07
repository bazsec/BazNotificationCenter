local addonName, addon = ...

local Colors = addon.Colors

function addon.CreateCheckboxControl(parent, label, dbKey)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(280, 26)

    -- Checkbox button
    container.check = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    container.check:SetSize(22, 22)
    container.check:SetPoint("LEFT", container, "LEFT", 0, 0)

    -- Label
    container.label = container:CreateFontString(nil, "OVERLAY")
    container.label:SetFontObject(GameFontNormal)
    container.label:SetTextColor(unpack(Colors.textPrimary))
    container.label:SetText(label)
    container.label:SetPoint("LEFT", container.check, "RIGHT", 6, 0)

    container.check:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        addon.SetDBValue(dbKey, checked)
    end)

    function container:Refresh()
        if addon.db then
            container.check:SetChecked(addon.db[dbKey] ~= false)
        end
    end

    return container
end
