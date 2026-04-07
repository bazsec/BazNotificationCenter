local addonName, addon = ...

local SCROLL_SPEED = 40
local LERP_SPEED = 8

function addon.CreateScrollContainer(parent, width, height)
    -- Clip frame
    local clipFrame = CreateFrame("Frame", nil, parent)
    clipFrame:SetSize(width, height)
    clipFrame:SetClipsChildren(true)

    -- Content frame (moves up/down inside clip frame)
    local content = CreateFrame("Frame", nil, clipFrame)
    content:SetWidth(width)
    content:SetHeight(1)  -- grows dynamically
    content:SetPoint("TOPLEFT", clipFrame, "TOPLEFT", 0, 0)

    -- Scroll state
    local scroll = {
        clipFrame = clipFrame,
        content = content,
        offset = 0,
        targetOffset = 0,
        maxOffset = 0,
    }

    function scroll:UpdateMaxOffset()
        local contentHeight = self.content:GetHeight()
        local viewHeight = self.clipFrame:GetHeight()
        self.maxOffset = math.max(0, contentHeight - viewHeight)
        -- Clamp current offset
        if self.targetOffset > self.maxOffset then
            self.targetOffset = self.maxOffset
        end
    end

    function scroll:ScrollTo(offset)
        self.targetOffset = math.max(0, math.min(offset, self.maxOffset))
    end

    function scroll:ScrollToTop()
        self.targetOffset = 0
    end

    function scroll:SetContentHeight(height)
        self.content:SetHeight(height)
        self:UpdateMaxOffset()
    end

    -- Mouse wheel handler
    clipFrame:EnableMouseWheel(true)
    clipFrame:SetScript("OnMouseWheel", function(self, delta)
        scroll:ScrollTo(scroll.targetOffset - delta * SCROLL_SPEED)
    end)

    -- Smooth scroll via OnUpdate
    local isScrolling = false
    clipFrame:SetScript("OnUpdate", function(self, elapsed)
        if math.abs(scroll.offset - scroll.targetOffset) < 0.5 then
            scroll.offset = scroll.targetOffset
            if isScrolling then
                isScrolling = false
            end
        else
            scroll.offset = scroll.offset + (scroll.targetOffset - scroll.offset) * math.min(1, elapsed * LERP_SPEED)
            isScrolling = true
        end
        content:SetPoint("TOPLEFT", clipFrame, "TOPLEFT", 0, scroll.offset)
    end)

    return scroll
end
