-- http://esoapi.uesp.net/100019/data/k/e/y/KeybindingsManager.IsChordingAlwaysEnabled.html
-- https://en.wikipedia.org/wiki/Chorded_keyboard
function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
	return true
end

EVENT_MANAGER:RegisterForEvent("SimpleExtensions", EVENT_ADD_ON_LOADED, function (event, name)
    if (name == "SimpleExtensions") then
        EVENT_MANAGER:UnregisterForEvent(name, event)
        SimpleExtension.Execute()
    end
end)