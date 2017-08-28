function SimpleExtension.Base:Initialize(defaults)
    if SimpleExtension._settings[self.SE_NAME] == nil then
        SimpleExtension._settings[self.SE_NAME] = defaults
        SimpleExtension._settings[self.SE_NAME]._debug = false
        SimpleExtension._settings[self.SE_NAME]._enabled = true
    else
        -- remove obsolete keys
        for key, _ in pairs(SimpleExtension._settings[self.SE_NAME]) do
            if string.sub(key, 1, 1) ~= "_" and defaults[key] == nil then
                SimpleExtension._settings[self.SE_NAME][key] = nil
            end
        end

        -- set new keys to its default value
        for key, value in pairs(defaults) do
            if SimpleExtension._settings[self.SE_NAME][key] == nil then
                SimpleExtension._settings[self.SE_NAME][key] = value
            end
        end
    end

    self.settings = SimpleExtension._settings[self.SE_NAME]
    self._cache = {}
end


function SimpleExtension.Base:addDebugOption()
    local checkbox = self:buildBooleanOption(
        "Enable debug", SimpleExtension._settings[self.SE_NAME], "_debug")
    table.insert(SimpleExtension._controls, checkbox)
end


function SimpleExtension.Base:addEnableOption()
    local checkbox = self:buildBooleanOption(
        "Enable extension", SimpleExtension._settings[self.SE_NAME], "_enabled")
    checkbox.requiresReload = true
    table.insert(SimpleExtension._controls, checkbox)
end


function SimpleExtension.Base:buildBooleanOption(name, storage, flag)
    local checkbox = {
        type = "checkbox",
        name = name,

        getFunc = function()
            local value = storage[flag]
            return (value == nil) or value
        end,

        setFunc = function(value)
            storage[flag] = (value == nil) or value
        end,
    }
    return checkbox
end


function SimpleExtension.Base:cache(cacheName, cacheKey, cacheAction)
    if self._cache[cacheName] == nil then
        self._cache[cacheName] = {}
    end

    if self._cache[cacheName][cacheKey] == nil then
        self._cache[cacheName][cacheKey] = cacheAction()
    end

    return self._cache[cacheName][cacheKey]
end


function SimpleExtension.Base:controls(header, controls)
    table.insert(SimpleExtension._controls, {
        type = "header",
        name = header
    })

    self:addEnableOption()
    if self:isEnabled() then
        self:addDebugOption()
        for _, control in ipairs(controls) do
            table.insert(SimpleExtension._controls, control)
        end
    end

    table.insert(SimpleExtension._controls, {
        type = "custom",
    })
end


function SimpleExtension.Base:debugAction(action)
    if self:hasDebug() then
        action()
    end
end


function SimpleExtension.Base:debugMessage(format, ...)
    if self:hasDebug() then
        if self.SE_NAME then
            format = self.SE_NAME .. ": " .. format
        end
        d(string.format(format, ...))
    end
end


function SimpleExtension.Base:hasDebug()
    return SimpleExtension._settings[self.SE_NAME]["_debug"]
end


function SimpleExtension.Base:isEnabled()
    return SimpleExtension._settings[self.SE_NAME]["_enabled"]
end
