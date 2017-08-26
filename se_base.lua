SimpleExtension.Base = ZO_Object:Subclass()

function SimpleExtension.Base:Initialize(defaults)
    if SimpleExtension._settings[self.SE_NAME] == nil then
        SimpleExtension._settings[self.SE_NAME] = defaults
    end
    self.settings = SimpleExtension._settings[self.SE_NAME]
end

function SimpleExtension.Create(name, version)
    local extension = ZO_Object.MultiSubclass(SimpleExtension.Base)
    extension.SE_NAME = name
    extension.SE_VERSION = version

    table.insert(SimpleExtension._extensions, extension)
    return extension
end

function SimpleExtension.Base:controls(header, controls)
    table.insert(SimpleExtension._controls, {
        type = "header",
        name = header
    })

    for _, control in ipairs(controls) do
        table.insert(SimpleExtension._controls, control)
    end
end

function SimpleExtension.Base:debug(format, ...)
    if self.SE_NAME then
        format = self.SE_NAME .. ": " .. format
    end
    d(string.format(format, ...))
end
