local SE_Chat = SimpleExtension.Create("SE_CHAT", 1)

SE_Chat.CHAT = {
    NEVER_FADE       = 0,
    DEFAULT_BEGIN    = 25,
    DEFAULT_DURATION = 2,

    setFadeness = function(begin, duration)
        for tabIndex, tabObject in ipairs(CHAT_SYSTEM.primaryContainer.windows) do
            tabObject.buffer:SetLineFade(begin, duration)
        end
    end
}

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
                obj:toggleAlwaysPresent()
            end
        },
    })

    return obj
end

function SE_Chat:Run()
    EVENT_MANAGER:RegisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED, function()
        self.backupCreateNewChatTab = CHAT_SYSTEM.CreateNewChatTab
        self.customCreateNewChatTab = function(instance, ...)
            self.createNewChatTabBackup(instance, ...)
            self.CHAT.setFadeness(self.CHAT.NEVER_FADE, self.CHAT.NEVER_FADE)
        end

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
    if self.settings.is_always_present then
        CHAT_SYSTEM.CreateNewChatTab = self.customCreateNewChatTab
        self.CHAT.setFadeness(self.CHAT.NEVER_FADE, self.CHAT.NEVER_FADE)
    else
        CHAT_SYSTEM.CreateNewChatTab = self.backupCreateNewChatTab
        self.CHAT.setFadeness(self.CHAT.DEFAULT_BEGIN, self.CHAT.DEFAULT_DURATION)
    end
end