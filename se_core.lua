SimpleExtension = {
    SE_MAJOR = 1,
    SE_MINOR = 1,
    SE_NAME = "SimpleExtensions",
    SE_PANEL = "SimpleExtensionsPanel",
    SE_VERSION = "1.1",
    SE_WEBSITE = "https://github.com/pcastellazzi/simpleextensions",

    _controls = {},
    _extensions = {},
    _lam = LibStub("LibAddonMenu-2.0"),
    _settings = {},

    Base = ZO_Object:Subclass(),
}

function SimpleExtension.Create(name, version)
    local extension = ZO_Object.MultiSubclass(SimpleExtension.Base)
    extension.SE_NAME = name
    extension.SE_VERSION = version

    table.insert(SimpleExtension._extensions, extension)

    return extension
end

function SimpleExtension.Execute()
    SimpleExtension._settings = ZO_SavedVars:NewAccountWide(
        SimpleExtension.SE_NAME, SimpleExtension.SE_MAJOR, nil, {})

    SimpleExtension._lam:RegisterAddonPanel(SimpleExtension.SE_PANEL, {
		type = "panel",
		name = "Simple Extensions",
		displayName = "Simple Extensions",
		author = "CastePablo",
		version = SimpleExtension.SE_VERSION,
		website = SimpleExtension.SE_WEBSITE,
    })

    for _, extension in ipairs(SimpleExtension._extensions) do
        local e = extension:New()
        if e:enabled() then
            e:Run()
            _G[e.SE_NAME] = e
        end
    end

    SimpleExtension._lam:RegisterOptionControls(
        SimpleExtension.SE_PANEL, SimpleExtension._controls)
end
