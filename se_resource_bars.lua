local wm = GetWindowManager()
local hp = ZO_PlayerAttributeHealth
local mp = ZO_PlayerAttributeMagicka
local sp = ZO_PlayerAttributeStamina

local SE_ResourceBars = SimpleExtension.Create("SE_RESOURCE_BARS", 1)

function SE_ResourceBars:New()
    local obj = ZO_Object.New(self)

    obj:Initialize({
        always_show = true,
        show_centered = true,
        size_locked = true,
    })

    obj:controls("Resource Bars", {
        {
            type = "checkbox",
            name = "Always show",
            tooltip = "Always show.",
            getFunc = function() return obj.settings.always_show end,
            setFunc = function(value) obj:toggleAlwaysShow(value) end,
        },
        {
            type = "checkbox",
            name = "Show centered",
            tooltip = "Show centered.",
            getFunc = function() return obj.settings.show_centered end,
            setFunc = function(value) obj:toggleShowCentered(value) end,
        },
        {
            type = "checkbox",
            name = "Size locked",
            tooltip = "Size locked.",
            getFunc = function() return obj.settings.size_locked end,
            setFunc = function(value) obj:toggleSizeLock(value) end,
        },
    })

    obj.default_anchors = {}
    obj.default_sizes = {}

    return obj
end

function SE_ResourceBars:Run()
    EVENT_MANAGER:RegisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(self.SE_NAME, EVENT_PLAYER_ACTIVATED)
        self:saveDefaultAnchors()
        self:toggleAlwaysShow()
        self:toggleShowCentered()
        self:toggleSizeLock()
    end)
end

function SE_ResourceBars:toggleAlwaysShow(value)
    if (value ~= nil) then
        self.settings.always_show = value
    end

    if self.settings.always_show then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "0")
    else
        SetSetting(SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "1")
    end
end

function SE_ResourceBars:toggleShowCentered(value)
    if (value ~= nil) then
        self.settings.show_centered = value
    end

    local rb = hp:GetParent()

    if self.settings.show_centered then
        local anchors = {
            [hp] = {CENTER  , rb, CENTER    ,  0,  0},
            [sp] = {LEFT    , hp, RIGHT     ,  8,  0},
            [mp] = {RIGHT   , hp, LEFT      , -8,  0},
        }
        for bar, data in pairs(anchors) do
            local w, h = bar:GetDimensions()
            bar:ClearAnchors()
            bar:SetAnchor(unpack(data))
        end
    else
        self:restoreDefaultAnchors()
    end
end

function SE_ResourceBars:saveDefaultAnchors()
    for _, bar in ipairs({hp, sp, mp}) do
        local isValid, point, relTo, relPoint, offsX, offsY = bar:GetAnchor()
        self.default_anchors[bar] = {point, relTo, relPoint, offsX, offsY}
    end
end

function SE_ResourceBars:restoreDefaultAnchors()
    for bar, data in pairs(self.default_anchors) do
        bar:ClearAnchors()
        bar:SetAnchor(unpack(data))
    end
end

function SE_ResourceBars:toggleSizeLock(value)
    if (value ~= nil) then
        self.settings.size_locked = value
    end

    for k, v in pairs(PLAYER_ATTRIBUTE_BARS.attributeVisualizer.visualModules) do
		if (v.expandedWidth) then
            if (not self.default_sizes.expandedWidth or not self.default_sizes.shrunkWidth) then
			    self.default_sizes.expandedWidth = v.expandedWidth
                self.default_sizes.shrunkWidth = v.shrunkWidth
			end

			if (self.settings.size_locked) then
                v.expandedWidth, v.shrunkWidth = v.normalWidth, v.normalWidth
                for stat, _ in pairs(v.barControls) do
                    v.barInfo[stat].state = ATTRIBUTE_BAR_STATE_NORMAL
                end
			else
                v.expandedWidth = self.default_sizes.expandedWidth
                v.shrunkWidth = self.default_sizes.shrunkWidth
                v.barInfo = {}
                v:OnUnitChanged()
			end
            v:OnUnitChanged()
		end
	end
end
