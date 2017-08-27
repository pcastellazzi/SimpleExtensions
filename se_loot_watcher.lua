local SE_LootWatcher = SimpleExtension.Create("SE_LOOT_WATCHER", 1)


SE_LootWatcher.WANTED_LOOT_TYPES = {
    [LOOT_TYPE_COLLECTIBLE] = true,
    [LOOT_TYPE_ITEM] = true,
}

SE_LootWatcher.WANTED_ITEM_TYPES = {
    [ITEMTYPE_ARMOR] = true,
    [ITEMTYPE_COLLECTIBLE] = true,
    [ITEMTYPE_RECIPE] = true,
    [ITEMTYPE_TROPHY] = true,
    [ITEMTYPE_WEAPON] = true,
}


function SE_LootWatcher:New()
    local obj = ZO_Object.New(self)
    obj:Initialize({})
    obj:controls("Loot Watcher", {})
    return obj
end


function SE_LootWatcher:Run()
    EVENT_MANAGER:RegisterForEvent(self.SE_NAME, EVENT_LOOT_RECEIVED, function(...)
        return self:handlerLootReceived(...)
    end)
end


function SE_LootWatcher:getItemTraitString(itemName)
    local itemTrait = GetItemLinkTraitInfo(itemName)
    return self:cache("ITEM_TRAIT_STRING", itemTrait, function()
        local itemTraitString = ""
        if itemTrait ~= ITEM_TRAIT_TYPE_NONE then
            itemTraitString = string.format(" %s", GetString("SI_ITEMTRAITTYPE", itemTrait))
        end
        return itemTraitString
    end)
end


function SE_LootWatcher:getCharacterName(character)
    return self:cache("CHARACTER_NAME", character, function()
        return string.format(
            "|H0:character:%s|h%s|h", character, LocalizeString("<<1>>", character));
    end)
end


function SE_LootWatcher:getQuantityString(quantity)
    local quantityString = ""
    if quantity > 1 then
        quantityString = string.format(" x%d", quantity)
    end
    return quantityString
end


function SE_LootWatcher:handlerLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, receivedBySelf, isPickpocketLoot, questItemIcon, itemId)
    self:debugAction(function()
        SE_LootWatcher.last = {
            receivedBy = receivedBy,
            itemName = itemName,
            quantity = quantity,
            lootType = lootType,
            itemId = itemId,
        }
    end)

    if not self.WANTED_LOOT_TYPES[lootType] then return end

    local itemType = GetItemLinkItemType(itemName)
    if not self.WANTED_ITEM_TYPES[itemType] then return end

    local itemQuality = GetItemLinkQuality(itemName)
    if not (itemQuality >= ITEM_QUALITY_ARCANE) then return end

    self:debugAction(function()
        d({
            itemName:gsub("^|H0", "|H1", 1),
            self:getItemTraitString(itemName),
            self:getQuantityString(quantity),
            self:getCharacterName(receivedBy),
        })
    end)
    CHAT_SYSTEM:AddMessage(string.format("[LOOT] %s%s%s → %s",
        itemName:gsub("^|H0", "|H1", 1),
        self:getItemTraitString(itemName),
        self:getQuantityString(quantity),
        self:getCharacterName(receivedBy)
    ));
end
