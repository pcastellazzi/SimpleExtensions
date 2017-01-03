local SE_Chat = SimpleExtension.Create("SE_CHAT", 1)

function SE_Chat:New()
    local obj = ZO_Object.New(self)

    obj:Initialize({
        is_full_resize_enabled = true,
        is_always_present = true,
    })

    obj:controls("Chat", {
        {
            type = "checkbox",
            name = "Enable full resizing",
            tooltip = "Allow chat window to be resized to any size.",

            getFunc = function()
                return obj.settings.is_full_resize_enabled
            end,

            setFunc = function(value)
                obj.settings.is_full_resize_enabled = value
                obj:toggleFullResize()
            end,
        },
        {
            type = "checkbox",
            name = "Always present",
            tooltip = "Ensure the chat windows do not fade away.",

            getFunc = function()
                return obj.settings.is_always_present
            end,

            setFunc = function(value)
                obj.settings.is_always_present = value
            end
        },
    })

    return obj
end

function SE_Chat:Run()
    EVENT_MANAGER:RegisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED, function()
        self:toggleAlwaysPresent()
        EVENT_MANAGER:UnregisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED)
    end)

    self:toggleFullResize()
end

function SE_Chat:toggleFullResize()
    if self.settings.is_full_resize_enabled then
        CHAT_SYSTEM.maxContainerWidth, CHAT_SYSTEM.maxContainerHeight = GuiRoot:GetDimensions()
    else
        for i = 1, #CHAT_SYSTEM.containers do
            CHAT_SYSTEM:ResetContainerPositionAndSize(CHAT_SYSTEM.containers[i])
        end
    end
end

function SE_Chat:toggleAlwaysPresent(begin, duration)
    local NEVER_FADE = 0
    local function setChatFadeness()
        for tabIndex, tabObject in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
            tabObject.buffer:SetLineFade(begin, duration)
        end
    end

    if self.settings.is_always_present then
        if not self.CreateNewChatTabBackup then
            self.CreateNewChatTabBackup = CHAT_SYSTEM.CreateNewChatTab
        end

        CHAT_SYSTEM.CreateNewChatTab = function(instance, ...)
            self.CreateNewChatTabBackup(instance, ...)
            setChatFadeness(NEVER_FADE, NEVER_FADE)
        end

        setChatFadeness(NEVER_FADE, NEVER_FADE)
    else
        -- defaults from:
        -- script d(CHAT_SYSTEM.primaryContainer.windows[1].buffer:GetLineFade())
        if self.CreateNewChatTabBackup then
            self.CreateNewChatTabBackup = CHAT_SYSTEM.CreateNewChatTab
            setChatFadeness(25, 2)
        end
    end
end