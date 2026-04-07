local addonName, addon = ...

function BNC:Push(data)
    if not data or not data.module then return end

    -- Check module exists and is enabled
    if not addon.modules[data.module] then return end
    if not BNC:IsModuleEnabled(data.module) then return end

    local realTime = time()
    local now = GetTime()

    -- Deduplication: check for a recent notification with same module + title
    local DEDUPE_WINDOW = 5  -- seconds
    for _, existing in ipairs(addon.notifications) do
        if existing.module == data.module
            and existing.title == (data.title or "")
            and (now - existing.timestamp) < DEDUPE_WINDOW then
            -- Update existing notification instead of creating a duplicate
            existing.message = data.message or existing.message
            existing.timestamp = now
            existing.realTime = realTime
            existing.dupeCount = (existing.dupeCount or 1) + 1
            existing.priority = data.priority or existing.priority

            -- Save to persistent history even for deduped entries
            if addon.History_AppendEntries then
                addon.History_AppendEntries({
                    {
                        module = existing.module,
                        title = existing.title,
                        message = existing.message,
                        icon = existing.icon,
                        priority = existing.priority,
                        realTime = realTime,
                    },
                })
            end

            addon.Events:Trigger("NOTIFICATION_UPDATED", existing)
            return existing
        end
    end

    addon.notificationCounter = addon.notificationCounter + 1

    local notification = {
        id = addon.notificationCounter,
        module = data.module,
        title = data.title or "",
        message = data.message or "",
        icon = data.icon or addon.modules[data.module].icon,
        priority = data.priority or "normal",
        timestamp = now,
        realTime = realTime,
        onClick = data.onClick,
        read = false,
        dismissed = false,
        silent = data.silent or false,
        duration = data.duration,
        waypoint = data.waypoint,
        itemLink = data.itemLink,
        dupeCount = 1,
    }

    -- Insert at beginning (newest first)
    table.insert(addon.notifications, 1, notification)

    -- Trim to max notifications in panel
    if addon.db then
        local max = addon.db.maxHistory or 50
        while #addon.notifications > max do
            table.remove(addon.notifications)
        end
    end

    -- Save to persistent history
    if addon.History_AppendEntries then
        addon.History_AppendEntries({
            {
                module = notification.module,
                title = notification.title,
                message = notification.message,
                icon = notification.icon,
                priority = notification.priority,
                realTime = realTime,
            },
        })
    end

    -- Notify UI
    addon.Events:Trigger("NOTIFICATION_ADDED", notification)

    -- Check per-module overrides for toast and sound
    local moduleSettings = addon.db and addon.db.modules[data.module]
    local toastsEnabled = addon.db and addon.db.toastsEnabled
    local soundEnabled = addon.db and addon.db.soundEnabled

    -- Module-level overrides (if set) take priority over global
    if moduleSettings then
        if moduleSettings.toastsEnabled ~= nil then
            toastsEnabled = moduleSettings.toastsEnabled
        end
        if moduleSettings.soundEnabled ~= nil then
            soundEnabled = moduleSettings.soundEnabled
        end
    end

    -- Do Not Disturb suppresses toasts and sounds (notifications still logged)
    local dnd = addon.IsDND and addon.IsDND()

    -- Request toast if not silent and not in DND
    if not notification.silent and toastsEnabled and not dnd then
        addon.Events:Trigger("TOAST_REQUESTED", notification)
    end

    -- Play priority-based sound if enabled (with cooldown)
    if not notification.silent and soundEnabled and not dnd then
        local now = GetTime()
        if not addon.lastSoundTime or (now - addon.lastSoundTime) > 1.0 then
            addon.lastSoundTime = now
            local soundID = addon.db and addon.db.soundNormal or 618
            if notification.priority == "high" then
                soundID = addon.db and addon.db.soundHigh or 8959
            elseif notification.priority == "low" then
                soundID = addon.db and addon.db.soundLow or 0
            end
            if soundID and soundID > 0 then
                PlaySound(soundID, "SFX")
            end
        end
    end

    return notification
end

function BNC:DismissNotification(id)
    for i, notif in ipairs(addon.notifications) do
        if notif.id == id then
            table.remove(addon.notifications, i)
            addon.Events:Trigger("NOTIFICATION_DISMISSED", id)
            return true
        end
    end
    return false
end

function BNC:DismissAll(moduleId)
    if moduleId then
        for i = #addon.notifications, 1, -1 do
            if addon.notifications[i].module == moduleId then
                table.remove(addon.notifications, i)
            end
        end
    else
        wipe(addon.notifications)
    end
    addon.Events:Trigger("NOTIFICATIONS_CLEARED", moduleId)
end

function BNC:GetNotifications(moduleFilter)
    if not moduleFilter then
        return addon.notifications
    end

    local filtered = {}
    for _, notif in ipairs(addon.notifications) do
        if notif.module == moduleFilter then
            table.insert(filtered, notif)
        end
    end
    return filtered
end

function BNC:GetUnreadCount()
    return #addon.notifications
end

function BNC:GetNotificationsByModule()
    local grouped = {}
    local order = {}
    for _, notif in ipairs(addon.notifications) do
        if not grouped[notif.module] then
            grouped[notif.module] = {}
            table.insert(order, notif.module)
        end
        table.insert(grouped[notif.module], notif)
    end
    return grouped, order
end

-- History is built-in, always available
function BNC:LoadHistory()
    return true
end

function BNC:ClearHistory()
    addon.History_PurgeAll()
    addon.Events:Trigger("HISTORY_CLEARED")
end
