local SE_QuickSlots = SimpleExtension.Create("SE_QUICK_SLOTS", 1)

SE_QuickSlots.FIRST_SLOT = 1
SE_QuickSlots.LAST_SLOT = 8
SE_QuickSlots.SLOT_IDS = {12, 11, 10, 9, 16, 15, 14, 13}

SE_QuickSlots.SLOTS_TEXT = {
    SE_QUICK_SLOT_1 = 'Set Quick Slot 1',
    SE_QUICK_SLOT_2 = 'Set Quick Slot 2',
    SE_QUICK_SLOT_3 = 'Set Quick Slot 3',
    SE_QUICK_SLOT_4 = 'Set Quick Slot 4',
    SE_QUICK_SLOT_5 = 'Set Quick Slot 5',
    SE_QUICK_SLOT_6 = 'Set Quick Slot 6',
    SE_QUICK_SLOT_7 = 'Set Quick Slot 7',
    SE_QUICK_SLOT_8 = 'Set Quick Slot 8',
    SE_QUICK_SLOT_NEXT = 'Set Next Quick Slot',
    SE_QUICK_SLOT_PREV = 'Set Previous Quick Slot',
}

function SE_QuickSlots:New()
    local obj = ZO_Object.New(self)
    obj:Initialize({})
    obj:controls("Quick Slots", {})
    return obj
end

function SE_QuickSlots:Run()
    for id, text in pairs(self.SLOTS_TEXT) do
        ZO_CreateStringId("SI_BINDING_NAME_" .. id, text)
    end
end

function SE_QuickSlots:get()
    local currentId = GetCurrentQuickslot()

    for i, id in ipairs(self.SLOT_IDS) do
        if id == currentId then
            return i
        end
    end

    return 1
end

function SE_QuickSlots:next()
    local nextSlot = self:get() + 1

    if nextSlot > self.LAST_SLOT then
        nextSlot = self.FIRST_SLOT
    end

    self:set(nextSlot)
end

function SE_QuickSlots:prev()
    local prevSlot = self:get() - 1

    if prevSlot < self.FIRST_SLOT then
        prevSlot = self.LAST_SLOT
    end

    self:set(prevSlot)
end

function SE_QuickSlots:set(slot)
    SetCurrentQuickslot(self.SLOT_IDS[slot])
end
