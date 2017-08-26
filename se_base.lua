function SimpleExtension.Base:Initialize(defaults)
    if SimpleExtension._settings[self.SE_NAME] == nil then
        SimpleExtension._settings[self.SE_NAME] = defaults
        SimpleExtension._settings[self.SE_NAME]["_enabled"] = true
    end
    self.settings = SimpleExtension._settings[self.SE_NAME]
end

function SimpleExtension.Base:controls(header, controls)
    table.insert(SimpleExtension._controls, {
        type = "header",
        name = header
    })

    table.insert(SimpleExtension._controls, {
        type = "checkbox",
        name = "Enable extension",
        tooltip = "Enable extension.",
        requiresReload = true,

        getFunc = function()
            local value = SimpleExtension._settings[self.SE_NAME]["_enabled"]
            return (value == nil) or value
        end,

        setFunc = function(value)
            SimpleExtension._settings[self.SE_NAME]["_enabled"] = (value == nil) or value
        end,
    })

    if self:enabled() then
        for _, control in ipairs(controls) do
            table.insert(SimpleExtension._controls, control)
        end
    end

    table.insert(SimpleExtension._controls, {
        type = "custom",
    })
end

function SimpleExtension.Base:debug(format, ...)
    if self.SE_NAME then
        format = self.SE_NAME .. ": " .. format
    end
    d(string.format(format, ...))
end

function SimpleExtension.Base:enabled()
    return SimpleExtension._settings[self.SE_NAME]["_enabled"]
end
