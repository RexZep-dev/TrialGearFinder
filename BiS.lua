-- Окно BiS-сборок по классам и спекам. Приклеено слева к основному окну TGF,
-- той же высоты; сворачивается/разворачивается стрелкой на стыке окон
-- (или командой /tgf bis).
--
-- Предметы берутся из базы аддона (Data.lua) — той же, что и основное окно.
-- Это принципиально: надетое у триала ужато сквошем до низкого уровня, а база
-- хранит BiS-версию. Приоритет статов на каждый спек — из гайда гильдии
-- (BiS_Data.lua). По приоритету и ранжируются кандидаты в слот.
--
-- Раскладка окна и перечисление классов/спеков адаптированы из аддона Cap20
-- (BiS/Menu.lua, BiS/Engine.lua) — лицензия MIT, Copyright (c) Josh
-- "Kkthnx" Russell. Данные предметов из Cap20 НЕ взяты.
--
-- Пока временно чёрное, чтобы визуально отличать от основного окна TGF.

local addonName, ns = ...

local MAIN = "TrialGearFinderFrame" -- создаётся в Core.lua раньше этого файла

-- ---------------------------------------------------------------------------
-- Слоты в порядке показа.
-- ---------------------------------------------------------------------------
local SLOTS = {
    { key = "HEAD",     name = "Голова" },
    { key = "NECK",     name = "Шея" },
    { key = "SHOULDER", name = "Плечи" },
    { key = "BACK",     name = "Спина" },
    { key = "CHEST",    name = "Грудь" },
    { key = "WRIST",    name = "Запястья" },
    { key = "HANDS",    name = "Кисти" },
    { key = "WAIST",    name = "Пояс" },
    { key = "LEGS",     name = "Ноги" },
    { key = "FEET",     name = "Ступни" },
    { key = "FINGER1",  name = "Кольцо 1" },
    { key = "FINGER2",  name = "Кольцо 2" },
    { key = "TRINKET1", name = "Аксессуар 1" },
    { key = "TRINKET2", name = "Аксессуар 2" },
    { key = "MAINHAND", name = "Правая рука" },
    { key = "OFFHAND",  name = "Левая рука" },
}

-- equipLoc предмета -> ключ слота. Парные слоты (кольца, аксессуары) собираются
-- в один котёл FINGER / TRINKET, а раскладываются в две строки при показе.
local EQUIPLOC_SLOT = {
    INVTYPE_HEAD = "HEAD", INVTYPE_NECK = "NECK", INVTYPE_SHOULDER = "SHOULDER",
    INVTYPE_CLOAK = "BACK", INVTYPE_CHEST = "CHEST", INVTYPE_ROBE = "CHEST",
    INVTYPE_WRIST = "WRIST", INVTYPE_HAND = "HANDS", INVTYPE_WAIST = "WAIST",
    INVTYPE_LEGS = "LEGS", INVTYPE_FEET = "FEET",
    INVTYPE_FINGER = "FINGER", INVTYPE_TRINKET = "TRINKET",
    INVTYPE_WEAPONMAINHAND = "MAINHAND", INVTYPE_WEAPON = "MAINHAND",
    INVTYPE_2HWEAPON = "MAINHAND", INVTYPE_RANGED = "MAINHAND",
    INVTYPE_RANGEDRIGHT = "MAINHAND",
    INVTYPE_WEAPONOFFHAND = "OFFHAND", INVTYPE_HOLDABLE = "OFFHAND",
    INVTYPE_SHIELD = "OFFHAND",
}

local PAIR_BUCKET = { FINGER1 = "FINGER", FINGER2 = "FINGER", TRINKET1 = "TRINKET", TRINKET2 = "TRINKET" }

-- Двуручное занимает обе руки: при таком выборе в «Левую руку» ничего не ставим.
local TWO_HAND_LOC = {
    INVTYPE_2HWEAPON = true, INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true,
}
local twoHandID = {} -- itemID -> true, заполняется в BuildBuckets

-- Спеки, что носят два двуручных сразу (Titan's Grip). В левую руку кладём
-- вторую двуручку из того же котла, а не запрещаем слот.
local DUAL_2H_SPEC = { [72] = true } -- Воин, Неистовство

-- Слот экипировки для отметки «этот предмет сейчас надет».
local SLOT_INV = {
    HEAD = "HeadSlot", NECK = "NeckSlot", SHOULDER = "ShoulderSlot",
    BACK = "BackSlot", CHEST = "ChestSlot", WRIST = "WristSlot",
    HANDS = "HandsSlot", WAIST = "WaistSlot", LEGS = "LegsSlot",
    FEET = "FeetSlot", FINGER1 = "Finger0Slot", FINGER2 = "Finger1Slot",
    TRINKET1 = "Trinket0Slot", TRINKET2 = "Trinket1Slot",
    MAINHAND = "MainHandSlot", OFFHAND = "SecondaryHandSlot",
}

-- Имя стата в приоритете гайда -> ключ в Data.lua stats.
local PRIO_NAMES = {
    ["Интеллект"] = "int", ["Ловкость"] = "agi", ["Сила"] = "str",
    ["Выносливость"] = "stam", ["Критический удар"] = "crit",
    ["Скорость"] = "haste", ["Искусность"] = "iskus",
    ["Универсальность"] = "vers",
}

-- ---------------------------------------------------------------------------
-- Перечисление классов и спеков берётся у игры, а не пишется таблицей:
-- список и порядок Blizzard меняет, а specID стабилен.
-- ---------------------------------------------------------------------------
local classNameCache = {}
local function ClassName(classID)
    if not classNameCache[classID] then
        local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo
            and C_CreatureInfo.GetClassInfo(classID)
        classNameCache[classID] = info and info.className or ("class " .. classID)
    end
    return classNameCache[classID]
end

local function AllClasses()
    local out = {}
    local n = (GetNumClasses and GetNumClasses()) or 13
    for classID = 1, n do
        local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo
            and C_CreatureInfo.GetClassInfo(classID)
        if info and info.classFile then
            out[#out + 1] = { classID = classID, classFile = info.classFile }
        end
    end
    return out
end

local function SpecsForClass(classID)
    local out = {}
    if not (GetNumSpecializationsForClassID and GetSpecializationInfoForClassID) then
        return out
    end
    for i = 1, (GetNumSpecializationsForClassID(classID) or 0) do
        local id, name, _, icon = GetSpecializationInfoForClassID(classID, i)
        if id then out[#out + 1] = { specID = id, name = name, icon = icon } end
    end
    return out
end

local function PlayerClassSpec()
    local _, classFile, classID = UnitClass("player")
    local specID
    if GetSpecialization and GetSpecializationInfo then
        local idx = GetSpecialization()
        if idx then specID = GetSpecializationInfo(idx) end
    end
    return classFile, classID, specID
end

local function ClassColor(classFile)
    local c = C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(classFile)
    if c then return c.r, c.g, c.b end
    return 1, 1, 1
end

-- ---------------------------------------------------------------------------
-- Кандидаты в слоты из базы аддона
-- ---------------------------------------------------------------------------
local function ClassAllowed(item, classFile)
    -- item.classes == nil у трынек и проков — их пускаем всем.
    if not item.classes then return true end
    for _, c in ipairs(item.classes) do
        if c == classFile then return true end
    end
    return false
end

-- classFile -> { [slotKey] = { item, item, ... } }. Считается один раз: база
-- статична, а equipLoc через GetItemInfoInstant синхронный.
-- itemID -> запись Data.lua, для ручных поправок ns.BiSPick.
local itemByID
local function ItemByID(id)
    if not itemByID then
        itemByID = {}
        for _, it in ipairs(ns.Items or {}) do itemByID[it.itemID] = it end
    end
    return itemByID[id]
end

local CLASS_ARMOR = {
    WARRIOR = "PLATE", PALADIN = "PLATE", DEATHKNIGHT = "PLATE",
    HUNTER = "MAIL", SHAMAN = "MAIL", EVOKER = "MAIL",
    ROGUE = "LEATHER", MONK = "LEATHER", DRUID = "LEATHER", DEMONHUNTER = "LEATHER",
    MAGE = "CLOTH", PRIEST = "CLOTH", WARLOCK = "CLOTH",
}

-- Ручная поправка для слота: спека бьёт класс, класс бьёт тип брони.
-- Возвращает itemID, false (слот пуст) или nil (поправки нет).
local function SlotOverride(classFile, specID, slotKey)
    local t = ns.BiSPick and specID and ns.BiSPick[specID]
    if t and t[slotKey] ~= nil then return t[slotKey] end
    t = ns.BiSPickClass and classFile and ns.BiSPickClass[classFile]
    if t and t[slotKey] ~= nil then return t[slotKey] end
    t = ns.BiSPickArmor and CLASS_ARMOR[classFile or ""]
    t = t and ns.BiSPickArmor[t]
    if t and t[slotKey] ~= nil then return t[slotKey] end
    if ns.BiSPickAll and ns.BiSPickAll[slotKey] ~= nil then return ns.BiSPickAll[slotKey] end
    return nil
end

local bucketCache = {}
local function BuildBuckets(classFile)
    if bucketCache[classFile] then return bucketCache[classFile] end
    local buckets = {}
    for _, item in ipairs(ns.Items or {}) do
        if ClassAllowed(item, classFile) then
            local _, _, _, equipLoc = C_Item.GetItemInfoInstant(item.itemID)
            local slotKey = equipLoc and EQUIPLOC_SLOT[equipLoc]
            if slotKey then
                if TWO_HAND_LOC[equipLoc] then twoHandID[item.itemID] = true end
                buckets[slotKey] = buckets[slotKey] or {}
                table.insert(buckets[slotKey], item)
            end
        end
    end
    bucketCache[classFile] = buckets
    return buckets
end

-- Приоритет гайда -> веса статов: первый стат самый тяжёлый.
local function ParsePriority(s)
    if not s then return nil end
    local order = {}
    for name, key in pairs(PRIO_NAMES) do
        local pos = s:find(name, 1, true)
        if pos then order[#order + 1] = { pos = pos, key = key } end
    end
    table.sort(order, function(a, b) return a.pos < b.pos end)
    local w = {}
    for i, e in ipairs(order) do w[e.key] = #order - i + 1 end
    return w
end

local function ScoreItem(item, w)
    if not w then return 0 end
    local s = 0
    for key, val in pairs(item.stats or {}) do
        s = s + val * (w[key] or 0)
    end
    return s + (item.sockets or 0) * 2 -- гнездо ~ мелкий бонус к статам
end

-- ---------------------------------------------------------------------------
-- Окно
-- ---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local GOLD = { 1.0, 0.82, 0.0 } -- как цвет подземелий в основном окне (C.gold)
local PANEL_W = 340
local HEADER_H = 24
local CLASS_COL_W = 38
local ROW_H = 24

local panel, arrow
local state = { classID = nil, classFile = nil, specID = nil }
local SelectClass -- forward

local function IsCollapsed()
    return TrialGearFinderDB and TrialGearFinderDB.bisCollapsed
end

local function MakeSlotRow(parent, index, y)
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    row:SetBackdrop({ bgFile = WHITE })
    row:SetBackdropColor(1, 1, 1, index % 2 == 0 and 0.03 or 0)

    row.slotFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.slotFS:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.slotFS:SetWidth(72)
    row.slotFS:SetJustifyH("LEFT")
    row.slotFS:SetTextColor(0.55, 0.55, 0.58)

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(16, 16)
    row.icon:SetPoint("LEFT", row.slotFS, "RIGHT", 4, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon:Hide()

    -- Зелёная галочка: этот предмет сейчас надет.
    row.check = row:CreateTexture(nil, "OVERLAY")
    row.check:SetSize(12, 12)
    row.check:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.check:SetAtlas("common-icon-checkmark")
    row.check:Hide()

    row.valueFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.valueFS:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    row.valueFS:SetPoint("RIGHT", row, "RIGHT", -22, 0)
    row.valueFS:SetJustifyH("LEFT")
    row.valueFS:SetWordWrap(false)

    row:SetScript("OnEnter", function(self)
        if not self.itemID then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.hyperlink or ("item:" .. self.itemID))
        if self.entry then
            GameTooltip:AddLine(" ")
            if self.entry.source then
                GameTooltip:AddLine("Источник: " .. self.entry.source, 0.55, 0.78, 1, true)
            end
            if self.entry.note then
                GameTooltip:AddLine(self.entry.note, 0.7, 0.7, 0.7, true)
            end
        end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:SetScript("OnClick", function(self)
        if self.itemLink and IsShiftKeyDown() and ChatEdit_InsertLink then
            ChatEdit_InsertLink(self.itemLink)
        end
    end)
    return row
end

local function RenderRow(row, slot, item)
    row.slotFS:SetText(slot.name)
    row.entry = item
    row.itemID = item and item.itemID or nil
    row.hyperlink = nil
    row.itemLink = nil
    if not item then
        row.icon:Hide()
        row.check:Hide()
        row.valueFS:SetText("—")
        row.valueFS:SetTextColor(0.4, 0.4, 0.42)
        return
    end
    local id = item.itemID
    -- Ссылка с bonusIDs и триальным уровнем — иначе тултип покажет вещь
    -- базового уровня (13-17) с требованием «22-й уровень». Тот же приём,
    -- что в основном окне (Core.lua BuildItemLink).
    local link = ns.BuildItemLink and ns.BuildItemLink(id, item.bonusIDs or {}) or ("item:" .. id)
    row.hyperlink, row.itemLink = link, link

    local _, _, _, _, icon = C_Item.GetItemInfoInstant(id)
    row.icon:SetTexture(icon or 134400)
    row.icon:Show()

    local invName = SLOT_INV[slot.key]
    local sid = invName and GetInventorySlotInfo(invName)
    row.check:SetShown(sid ~= nil and GetInventoryItemID("player", sid) == id)

    row.valueFS:SetText("…")
    row.valueFS:SetTextColor(0.7, 0.7, 0.7)
    local mixin = Item:CreateFromItemLink(link)
    mixin:ContinueOnItemLoad(function()
        if row.itemID ~= id then return end
        row.valueFS:SetText(mixin:GetItemName() or ("item:" .. id))
        local q = mixin:GetItemQualityColor()
        if q then row.valueFS:SetTextColor(q.r, q.g, q.b) end
        local ic = mixin:GetItemIcon()
        if ic then row.icon:SetTexture(ic) end
    end)
end

local function RenderSlots()
    local buckets = state.classFile and BuildBuckets(state.classFile) or {}
    local w = ParsePriority(ns.BiSPriority and ns.BiSPriority[state.specID])

    local ranked = {}
    for slotKey, items in pairs(buckets) do
        local copy = {}
        for _, it in ipairs(items) do copy[#copy + 1] = it end
        table.sort(copy, function(a, b) return ScoreItem(a, w) > ScoreItem(b, w) end)
        ranked[slotKey] = copy
    end

    local mhIs2H = false
    for i, slot in ipairs(SLOTS) do
        local row = panel.slotRows[i]
        local bkey = PAIR_BUCKET[slot.key] or slot.key
        local list = ranked[bkey]
        local idx = (slot.key == "FINGER2" or slot.key == "TRINKET2") and 2 or 1
        local pick = list and (list[idx] or list[1]) or nil

        -- Ручная поправка поверх авторанжирования.
        local ov = SlotOverride(state.classFile, state.specID, slot.key)
        if ov == false then
            pick = nil
        elseif ov then
            pick = ItemByID(ov) or pick
        end

        if slot.key == "OFFHAND" and ov == nil then
            if DUAL_2H_SPEC[state.specID] then
                -- Тот же лучший двуручник во вторую руку: на двадцатке BiS —
                -- две копии одного оружия, а не первое+второе.
                local mh = ranked["MAINHAND"]
                pick = mh and mh[1] or nil
                RenderRow(row, slot, pick)
            elseif mhIs2H then
                RenderRow(row, slot, nil)
                row.valueFS:SetText("— двуручное")
            else
                RenderRow(row, slot, pick)
            end
        else
            RenderRow(row, slot, pick)
        end
        -- MAINHAND идёт раньше OFFHAND в SLOTS, флаг успеет проставиться.
        if slot.key == "MAINHAND" then
            mhIs2H = pick ~= nil and twoHandID[pick.itemID] == true
        end
    end
end

local function ClearSpecTabs()
    for _, t in ipairs(panel.specTabs or {}) do t:Hide() end
end

local function SelectSpec(specID)
    state.specID = specID
    -- Выбранная вкладка — золотой обводкой и текстом, как подземелья
    -- в основном окне. Тонкая заливка 0.14 была почти не видна.
    for _, t in ipairs(panel.specTabs or {}) do
        local on = t.specID == specID
        t.sel:SetShown(on)
        if on then
            t:SetBackdropBorderColor(GOLD[1], GOLD[2], GOLD[3], 1)
            t.label:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
        else
            t:SetBackdropBorderColor(0.25, 0.25, 0.28, 1)
            t.label:SetTextColor(0.85, 0.85, 0.88)
        end
    end
    -- Приоритет статов — из гайда гильдии (BiS_Data.lua), дословно.
    local prio = ns.BiSPriority and ns.BiSPriority[specID]
    panel.priorityFS:SetText(prio and ("Статы: " .. prio) or "")
    RenderSlots()
end

local function BuildSpecTabs(classID)
    ClearSpecTabs()
    panel.specTabs = panel.specTabs or {}
    local specs = SpecsForClass(classID)
    local x = 0
    for i, spec in ipairs(specs) do
        local tab = panel.specTabs[i]
        if not tab then
            tab = CreateFrame("Button", nil, panel, "BackdropTemplate")
            tab:SetSize(90, 22)
            tab:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
            tab.sel = tab:CreateTexture(nil, "BACKGROUND")
            tab.sel:SetAllPoints()
            tab.sel:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.16)
            tab.sel:Hide()
            tab.icon = tab:CreateTexture(nil, "ARTWORK")
            tab.icon:SetSize(14, 14)
            tab.icon:SetPoint("LEFT", tab, "LEFT", 4, 0)
            tab.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            tab.label:SetPoint("LEFT", tab.icon, "RIGHT", 4, 0)
            tab.label:SetPoint("RIGHT", tab, "RIGHT", -3, 0)
            tab.label:SetJustifyH("LEFT")
            panel.specTabs[i] = tab
        end
        tab.specID = spec.specID
        tab.icon:SetTexture(spec.icon or 134400)
        tab.label:SetText(spec.name)
        tab:SetBackdropColor(0.1, 0.1, 0.12, 0.8)
        tab:SetBackdropBorderColor(0.25, 0.25, 0.28, 1)
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", panel.tabAnchor, "TOPLEFT", x, 0)
        tab:SetScript("OnClick", function() SelectSpec(spec.specID) end)
        tab:Show()
        x = x + 94
    end
    return specs
end

SelectClass = function(classID, classFile, preferSpecID)
    if not panel then return end
    state.classID, state.classFile = classID, classFile
    for _, b in ipairs(panel.classButtons or {}) do
        b.ring:SetShown(b.classID == classID)
    end
    local r, g, b = ClassColor(classFile)
    panel.classTitle:SetText(ClassName(classID))
    panel.classTitle:SetTextColor(r, g, b)

    local specs = BuildSpecTabs(classID)
    local chosen = preferSpecID
    local ok = false
    for _, s in ipairs(specs) do if s.specID == chosen then ok = true break end end
    if not ok then chosen = specs[1] and specs[1].specID end
    if chosen then SelectSpec(chosen) end
end

local function Populate()
    if not panel then return end
    local classFile, classID, specID = PlayerClassSpec()
    if classID then
        SelectClass(classID, classFile, specID)
    elseif not state.classID and panel.classButtons[1] then
        local b = panel.classButtons[1]
        SelectClass(b.classID, b.classFile)
    end
end

local function BuildPanel()
    if panel then return panel end
    local main = _G[MAIN]
    if not main then return end

    panel = CreateFrame("Frame", "TrialGearFinderBiSFrame", main, "BackdropTemplate")
    panel:SetWidth(PANEL_W)
    -- Приклеено к левому краю основного окна, той же высоты: тянется от его
    -- верха до низа, так что при смене ширины Мин-Макс (окно центрировано,
    -- левый край едет) панель едет вместе с ним.
    panel:SetPoint("TOPRIGHT", main, "TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", main, "BOTTOMLEFT", 0, 0)
    panel:SetFrameLevel(main:GetFrameLevel() + 5)
    panel:SetBackdrop({
        edgeFile = WHITE, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    panel:SetBackdropBorderColor(0.3, 0.3, 0.32, 1)
    -- Отдельной сплошной заливкой, а не bgFile бэкдропа: сквозь полупрозрачный
    -- бэкдроп просвечивал лист персонажа за окном.
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", -1, 1)
    bg:SetColorTexture(0.03, 0.03, 0.04, 1)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -8)
    title:SetText("BiS-сборки")

    -- Колонка классов слева
    local classCol = CreateFrame("Frame", nil, panel)
    classCol:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -(HEADER_H + 8))
    classCol:SetWidth(CLASS_COL_W)
    classCol:SetPoint("BOTTOM", panel, "BOTTOM", 0, 8)

    panel.classButtons = {}
    local cy = 0
    for _, cls in ipairs(AllClasses()) do
        local btn = CreateFrame("Button", nil, classCol)
        btn:SetSize(28, 28)
        btn:SetPoint("TOP", classCol, "TOP", 0, cy)
        btn.classID, btn.classFile = cls.classID, cls.classFile

        local ic = btn:CreateTexture(nil, "ARTWORK")
        ic:SetAllPoints()
        if GetClassAtlas then ic:SetAtlas(GetClassAtlas(cls.classFile)) end

        local ring = btn:CreateTexture(nil, "OVERLAY")
        ring:SetPoint("CENTER")
        ring:SetSize(32, 32)
        ring:SetAtlas("communities-create-avatar-border-hover")
        ring:Hide()
        btn.ring = ring

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local r, g, b = ClassColor(self.classFile)
            GameTooltip:AddLine(ClassName(self.classID), r, g, b)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        btn:SetScript("OnClick", function(self) SelectClass(self.classID, self.classFile) end)

        panel.classButtons[#panel.classButtons + 1] = btn
        cy = cy - 30
    end

    -- Заголовок класса + якорь для вкладок спеков
    panel.classTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.classTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", CLASS_COL_W + 14, -(HEADER_H + 6))

    panel.tabAnchor = CreateFrame("Frame", nil, panel)
    panel.tabAnchor:SetPoint("TOPLEFT", panel, "TOPLEFT", CLASS_COL_W + 14, -(HEADER_H + 30))
    panel.tabAnchor:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -(HEADER_H + 30))
    panel.tabAnchor:SetHeight(22)

    -- Строка приоритета статов
    panel.priorityFS = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.priorityFS:SetPoint("TOPLEFT", panel.tabAnchor, "BOTTOMLEFT", 0, -8)
    panel.priorityFS:SetPoint("TOPRIGHT", panel.tabAnchor, "BOTTOMRIGHT", 0, -8)
    panel.priorityFS:SetJustifyH("LEFT")
    panel.priorityFS:SetWordWrap(true)
    panel.priorityFS:SetTextColor(0.75, 0.78, 0.55)

    -- Список слотов
    local list = CreateFrame("Frame", nil, panel)
    list:SetPoint("TOPLEFT", panel.priorityFS, "BOTTOMLEFT", 0, -10)
    list:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 40)
    panel.slotRows = {}
    local ry = 0
    for i = 1, #SLOTS do
        panel.slotRows[i] = MakeSlotRow(list, i, ry)
        ry = ry - ROW_H
    end

    -- Ряд кнопок-заглушек внизу
    local btnRow = CreateFrame("Frame", nil, panel)
    btnRow:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", CLASS_COL_W + 14, 20)
    btnRow:SetPoint("RIGHT", panel, "RIGHT", -8, 0)
    btnRow:SetHeight(18)
    local bx = 0
    for _, label in ipairs({ "Гнёзда", "Камни", "Планировщик" }) do
        local b = CreateFrame("Button", nil, btnRow, "BackdropTemplate")
        b:SetSize(84, 18)
        b:SetPoint("LEFT", btnRow, "LEFT", bx, 0)
        b:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
        b:SetBackdropColor(0.12, 0.12, 0.14, 1)
        b:SetBackdropBorderColor(0.28, 0.28, 0.3, 1)
        local fs = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        fs:SetPoint("CENTER")
        fs:SetText(label)
        b:SetScript("OnClick", function()
            print("|cFF86C7BD[TGF]|r " .. label .. ": скоро.")
        end)
        bx = bx + 88
    end

    local footer = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOM", panel, "BOTTOM", 0, 6)
    footer:SetText("раскладка адаптирована из Cap20 (MIT), автор Kkthnx")
    footer:SetTextColor(0.35, 0.35, 0.38)

    return panel
end

-- Стрелка на стыке окон: сворачивает и разворачивает панель.
local function UpdateArrow()
    if not arrow then return end
    local collapsed = IsCollapsed()
    arrow.tex:SetAtlas(collapsed and "common-icon-backarrow" or "common-icon-forwardarrow", true)
end

local function ApplyCollapsed()
    if panel then panel:SetShown(not IsCollapsed()) end
    UpdateArrow()
end

local function SetCollapsed(collapsed)
    TrialGearFinderDB = TrialGearFinderDB or {}
    TrialGearFinderDB.bisCollapsed = collapsed and true or nil
    if not collapsed then
        local main = _G[MAIN]
        if main and not main:IsShown() then main:Show() end
        if not panel then BuildPanel() end
        Populate()
    end
    ApplyCollapsed()
end

local function Toggle()
    SetCollapsed(not IsCollapsed())
end

local function MakeArrow()
    local main = _G[MAIN]
    if not main or arrow then return end
    arrow = CreateFrame("Button", nil, main, "BackdropTemplate")
    arrow:SetSize(16, 44)
    -- Целиком на кромке основного окна, не свисает в мир.
    arrow:SetPoint("LEFT", main, "LEFT", 4, 0)
    arrow:SetFrameLevel(main:GetFrameLevel() + 10)
    arrow:SetBackdrop({
        bgFile = WHITE, edgeFile = WHITE, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    arrow:SetBackdropColor(0, 0, 0, 0.92)
    arrow:SetBackdropBorderColor(0.3, 0.3, 0.32, 1)

    arrow.tex = arrow:CreateTexture(nil, "OVERLAY")
    arrow.tex:SetSize(12, 12)
    arrow.tex:SetPoint("CENTER")

    arrow:SetScript("OnClick", Toggle)
    arrow:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(IsCollapsed() and "Открыть BiS-сборки" or "Свернуть BiS-сборки")
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Основное окно уже создано (Core.lua грузится раньше). Вешаем стрелку и, если
-- панель не свёрнута, поднимаем её вместе с окном.
local main = _G[MAIN]
if main then
    MakeArrow()
    main:HookScript("OnShow", function()
        if not IsCollapsed() then
            if not panel then BuildPanel() end
            Populate()
            ApplyCollapsed()
        end
    end)
    if not IsCollapsed() then
        BuildPanel()
        ApplyCollapsed()
    end
    UpdateArrow()
end

ns.ToggleBiS = Toggle
