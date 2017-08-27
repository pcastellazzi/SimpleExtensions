local SE_ActionBar = SimpleExtension.Create("SE_ACTION_BAR", 1)


function SE_ActionBar:New()
    local obj = ZO_Object.New(self)

    obj:Initialize({
        hide_bar_swap_button = true,
        hide_key_bindings_background = true,
    })

    obj:controls("Action Bar", {
        {
            type = "checkbox",
            name = "Hide bar swap button",
            tooltip = "Hide bar swap button.",
            getFunc = function() return obj.settings.hide_bar_swap_button end,
            setFunc = function(value) obj:toggleHideBarSwapButton(value) end,
        },
        {
            type = "checkbox",
            name = "Hide key bindings' background",
            tooltip = "Hide key bindings' background.",
            getFunc = function() return obj.settings.hide_key_bindings_background end,
            setFunc = function(value) obj:toggleHideKeyBindingsBackground(value) end,
        },
    })

    return obj
end


function SE_ActionBar:Run()
    EVENT_MANAGER:RegisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED)
        self:toggleHideBarSwapButton()
        self:toggleHideKeyBindingsBackground()
    end)
end


function SE_ActionBar:toggleHideBarSwapButton(value)
    self.settings.hide_bar_swap_button = (value == nil) or value
    if self.settings.hide_bar_swap_button then
        ZO_ActionBar1WeaponSwap:SetAlpha(0)
	    ZO_ActionBar1WeaponSwapLock:SetAlpha(0)
    else
        ZO_ActionBar1WeaponSwap:SetAlpha(1)
	    ZO_ActionBar1WeaponSwapLock:SetAlpha(1)
    end
end


function SE_ActionBar:toggleHideKeyBindingsBackground(value)
    self.settings.hide_key_bindings_background = (value == nil) or value
    if self.settings.hide_key_bindings_background then
        ZO_ActionBar1KeybindBG:SetAlpha(0)
    else
        ZO_ActionBar1KeybindBG:SetAlpha(1)
    end
end
