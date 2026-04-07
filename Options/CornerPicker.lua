local addonName, addon = ...

local Colors = addon.Colors
local GRID_SIZE = 36
local GRID_SPACING = 4

local CORNERS = {
    { key = "TOPLEFT",     row = 1, col = 1, label = "Top Left" },
    { key = "TOPRIGHT",    row = 1, col = 2, label = "Top Right" },
    { key = "BOTTOMLEFT",  row = 2, col = 1, label = "Bottom Left" },
    { key = "BOTTOMRIGHT", row = 2, col = 2, label = "Bottom Right" },
}

local BACKDROP_CORNER = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

function addon.CreateCornerPicker(parent)
    local container = CreateFrame("Frame", nil, parent)
    local totalWidth = GRID_SIZE * 2 + GRID_SPACING
    local totalHeight = GRID_SIZE * 2 + GRID_SPACING
    container:SetSize(280, totalHeight + 24)

    -- Title
    container.label = container:CreateFontString(nil, "OVERLAY")
    container.label:SetFontObject(GameFontNormal)
    container.label:SetTextColor(unpack(Colors.textPrimary))
    container.label:SetText("Panel Position")
    container.label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

    -- Grid container (centered)
    container.grid = CreateFrame("Frame", nil, container)
    container.grid:SetSize(totalWidth, totalHeight)
    container.grid:SetPoint("TOP", container, "TOP", 0, -20)

    container.buttons = {}

    for _, corner in ipairs(CORNERS) do
        local btn = CreateFrame("Button", nil, container.grid, "BackdropTemplate")
        btn:SetSize(GRID_SIZE, GRID_SIZE)
        btn:SetBackdrop(BACKDROP_CORNER)
        btn.cornerKey = corner.key

        local x = (corner.col - 1) * (GRID_SIZE + GRID_SPACING)
        local y = -((corner.row - 1) * (GRID_SIZE + GRID_SPACING))
        btn:SetPoint("TOPLEFT", container.grid, "TOPLEFT", x, y)

        -- Dot indicator in the correct corner of the button
        btn.dot = btn:CreateTexture(nil, "OVERLAY")
        btn.dot:SetSize(8, 8)
        btn.dot:SetColorTexture(1, 1, 1, 0.8)

        local dotPoint = corner.key
        local dotXOff = corner.col == 1 and 6 or -6
        local dotYOff = corner.row == 1 and -6 or 6
        btn.dot:SetPoint(dotPoint, btn, dotPoint, dotXOff, dotYOff)

        -- Tooltip
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:AddLine(corner.label)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        btn:SetScript("OnClick", function()
            addon.SetDBValue("position", corner.key)
            container:Refresh()
        end)

        container.buttons[corner.key] = btn
    end

    function container:Refresh()
        local current = addon.db and addon.db.position or "TOPLEFT"
        for key, btn in pairs(self.buttons) do
            if key == current then
                btn:SetBackdropColor(unpack(Colors.accent))
                btn:SetBackdropBorderColor(unpack(Colors.accent))
            else
                btn:SetBackdropColor(unpack(Colors.cardBg))
                btn:SetBackdropBorderColor(unpack(Colors.cardBorder))
            end
        end
    end

    return container
end
