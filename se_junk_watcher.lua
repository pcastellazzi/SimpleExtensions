local SE_JunkWatcher = SimpleExtension.Create("SE_JUNK_WATCHER", 1)


function SE_JunkWatcher:New()
    local obj = ZO_Object.New(self)

    obj:Initialize({
        mark_trash_items = true,
        mark_low_level_items = true,
        mark_non_crafted_glyphs = true,
        mark_non_crafted_poisons = true,
        mark_non_crafted_potions = true,
        mark_non_set_items = true,
        mark_low_quality_items = true,
    })

    obj:controls("Junk Watcher", {
        obj:buildBooleanOption("Mark trash items", obj.settings, "mark_trash_items"),
        obj:buildBooleanOption("Mark low level items", obj.settings, "mark_low_level_items"),
        obj:buildBooleanOption("Mark non-crafted glyphs", obj.settings, "mark_non_crafted_glyphs"),
        obj:buildBooleanOption("Mark non-crafted poisons", obj.settings, "mark_non_crafted_poisons"),
        obj:buildBooleanOption("Mark non-crafted potions", obj.settings, "mark_non_crafted_potions"),
        obj:buildBooleanOption("Mark non-set items", obj.settings, "mark_non_set_items"),
        obj:buildBooleanOption("Mark low quality items", obj.settings, "mark_low_quality_items"),
		{
			type = "button",
			name = "Apply",
			func = function() obj:Apply() end,
			width = "full",
		},
    })

    return obj
end


function SE_JunkWatcher:Apply()
	local bagSize = GetBagSize(BAG_BACKPACK)
	for slotId = 0, bagSize - 1 do
		SetItemIsJunk(BAG_BACKPACK, slotId, false)
        self:handlerInventorySingleSlotUpdate(nil, BAG_BACKPACK, slotId, false)
	end
end


function SE_JunkWatcher:Run()
    EVENT_MANAGER:RegisterForEvent(self.SE_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
        return self:handlerInventorySingleSlotUpdate(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.SE_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(self.SE_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
end


function SE_JunkWatcher:getItemData(bagId, slotId)
    local _, stackCount, _, _, _, _, _, quality = GetItemInfo(bagId, slotId)
    if stackCount <= 0 then return nil end

	local link = GetItemLink(bagId, slotId)
    local type = GetItemLinkItemType(link)

    return {
        bagId = bagId,
        link = link,
        quality = quality,
        slotId = slotId,
        type = type,
    }
end


function SE_JunkWatcher:handlerInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem)
    if IsUnderArrest() then return end
    if IsItemJunk(bagId, slotId) then return end
    if IsItemPlayerLocked(bagId, slotId) then return end

    local item = self:getItemData(bagId, slotId)
    if item == nil then return end
    if IsItemLinkCrafted(item.link) then return end

    if item.type == ITEMTYPE_TRASH then
        self:markAsJunk(item, "mark_trash_items")
    elseif item.type == ITEMTYPE_GLYPH_ARMOR or item.type == ITEMTYPE_GLYPH_JEWELRY or item.type == ITEMTYPE_GLYPH_WEAPON then
        if GetItemLinkRequiredChampionPoints(item.link) < 150 then
            self:markAsJunk(item, "mark_low_level_items")
        end
        self:markAsJunk(item, "mark_non_crafted_glyphs")
    elseif item.type == ITEMTYPE_POISON then
        if GetItemLinkRequiredChampionPoints(item.link) < 150 then
            self:markAsJunk(item, "mark_low_level_items")
        end
        self:markAsJunk(item, "mark_non_crafted_poisons")
    elseif item.type == ITEMTYPE_POTION then
        if GetItemLinkRequiredChampionPoints(item.link) < 150 then
            self:markAsJunk(item, "mark_low_level_items")
        end
        self:markAsJunk(item, "mark_non_crafted_potions")
    elseif item.type == ITEMTYPE_ARMOR or item.type == ITEMTYPE_WEAPON then
        if GetItemLinkRequiredChampionPoints(item.link) < 150 then
            self:markAsJunk(item, "mark_low_level_items")
        elseif item.quality <= ITEM_QUALITY_MAGIC then
            self:markAsJunk(item, "mark_low_quality_items")
        elseif not GetItemLinkSetInfo(item.link) then
            self:markAsJunk(item, "mark_non_set_items")
        end
    else
        self:debugMessage("%s (%d) → %s", item.link, item.slotId, "not junk: rules")
    end
end


function SE_JunkWatcher:markAsJunk(item, reason)
    if self.settings[reason] then
        if self:hasDebug() then
            self:debugMessage("%s (%d) → %s", item.link, item.slotId, reason)
        end
        SetItemIsJunk(item.bagId, item.slotId, true)
    end
end
