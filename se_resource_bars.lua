local wm = GetWindowManager()
local hp = ZO_PlayerAttributeHealth
local mp = ZO_PlayerAttributeMagicka
local sp = ZO_PlayerAttributeStamina
local ww = ZO_PlayerAttributeWerewolf
local sh = ZO_PlayerAttributeSiegeHealth
local ms = ZO_PlayerAttributeMountStamina

local SE_ResourceBars = SimpleExtension.Create("SE_RESOURCE_BARS", 1)

function SE_ResourceBars:New()
    local obj = ZO_Object.New(self)

    obj:Initialize({
        always_show_resource_bars = true,
        center_resource_bars = true,
    })

    obj:controls("Resource Bars", {
        {
            type = "checkbox",
            name = "Always Show Resource Bars",
            tooltip = "Always Show Center Resource Bars.",

            getFunc = function()
                return obj.settings.always_show_resource_bars
            end,

            setFunc = function(value)
                obj.settings.always_show_resource_bars = value
                obj:toggleAlwaysShowResourceBars()
            end,
        },
        {
            type = "checkbox",
            name = "Center Resource Bars",
            tooltip = "Center Resource Bars.",

            getFunc = function()
                return obj.settings.center_resource_bars
            end,

            setFunc = function(value)
                obj.settings.center_resource_bars = value
                obj:toggleCenterResourceBars()
            end,
        },

    })

    obj.default_anchors = {}

    return obj
end

function SE_ResourceBars:Run()
    self:saveDefaultAnchors()
    self:toggleCenterResourceBars()
    self:toggleAlwaysShowResourceBars()
end

function SE_ResourceBars:toggleAlwaysShowResourceBars()
    if self.settings.always_show_resource_bars then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "0")
    else
        SetSetting(SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "1")
    end
end

function SE_ResourceBars:toggleCenterResourceBars()
    local rb = hp:GetParent()

    if self.settings.center_resource_bars then
        local anchors = {
            [hp] = {TOP     , rb, TOP       ,   0,  0},
            [sp] = {LEFT    , hp, RIGHT     ,  16,  0},
            [mp] = {RIGHT   , hp, LEFT      , -16,  0},
        }
        for bar, data in pairs(anchors) do
            local w, h = bar:GetDimensions()
            bar:ClearAnchors()
            bar:SetAnchor(unpack(data))
        end

        for _, bar in ipairs({sh, ww, ms}) do
            local isValid, point, relTo, relPoint, offsX, offsY = bar:GetAnchor()
            bar:SetAnchor(point, relTo, relPoint, offsX, 2)
        end
    else
        self:restoreDefaultAnchors()
    end
end

function SE_ResourceBars:saveDefaultAnchors()
    for _, bar in ipairs({hp, sp, mp, sh, ww, ms}) do
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