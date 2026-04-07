local addonName, addon = ...

local ANCHOR_DATA = {
    TOPLEFT = {
        point = "TOPLEFT",
        relPoint = "TOPLEFT",
        xDir = 1,
        yDir = -1,
        toastGrowth = -1,   -- toasts stack downward
        slideX = -1,        -- slides in from left
        slideY = 0,
    },
    TOPRIGHT = {
        point = "TOPRIGHT",
        relPoint = "TOPRIGHT",
        xDir = -1,
        yDir = -1,
        toastGrowth = -1,
        slideX = 1,
        slideY = 0,
    },
    BOTTOMLEFT = {
        point = "BOTTOMLEFT",
        relPoint = "BOTTOMLEFT",
        xDir = 1,
        yDir = 1,
        toastGrowth = 1,    -- toasts stack upward
        slideX = -1,
        slideY = 0,
    },
    BOTTOMRIGHT = {
        point = "BOTTOMRIGHT",
        relPoint = "BOTTOMRIGHT",
        xDir = -1,
        yDir = 1,
        toastGrowth = 1,
        slideX = 1,
        slideY = 0,
    },
}

function addon.GetAnchorData(position)
    return ANCHOR_DATA[position] or ANCHOR_DATA["TOPLEFT"]
end

local MARGIN = 10

function addon.AnchorToCorner(frame, position, xOffset, yOffset)
    local data = addon.GetAnchorData(position)
    local mx = (xOffset or 0) + MARGIN * data.xDir
    local my = (yOffset or 0) + MARGIN * data.yDir
    frame:ClearAllPoints()
    frame:SetPoint(data.point, UIParent, data.relPoint, mx, my)
end
