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
-- Кандидаты берутся из двух баз: гайд главы гильдии (ns.Items) и предметы
-- от сообщества (ns.CommunityItems). Формат записи одинаковый.
local allItemsCache
local function AllItems()
    if not allItemsCache then
        allItemsCache = {}
        for _, it in ipairs(ns.Items or {}) do allItemsCache[#allItemsCache + 1] = it end
        for _, it in ipairs(ns.CommunityItems or {}) do allItemsCache[#allItemsCache + 1] = it end
    end
    return allItemsCache
end

-- itemID -> запись, для ручных поправок ns.BiSPick.
local itemByID
local function ItemByID(id)
    if not itemByID then
        itemByID = {}
        for _, it in ipairs(AllItems()) do itemByID[it.itemID] = it end
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
    for _, item in ipairs(AllItems()) do
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
local S = ns.Style or {} -- палитра и скруглённые текстуры из Core.lua
local C = S.C or {}
local GOLD = C.gold or { 1.0, 0.82, 0.0 } -- как цвет подземелий в основном окне
local PANEL_W = 344
local HEADER_H = 30
local CLASS_COL_W = 44
local ROW_H = 24
local CLASS_ICON = 32

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
    -- Чередование строк блоком палитры, как в основном окне.
    local zebra = row:CreateTexture(nil, "BACKGROUND")
    zebra:SetAllPoints()
    if index % 2 == 0 and C.block2 then
        zebra:SetColorTexture(C.block2[1], C.block2[2], C.block2[3], 0.5)
    else
        zebra:SetColorTexture(0, 0, 0, 0)
    end
    row.hl = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.hl:SetAllPoints()
    local w = C.warm or { 0.85, 0.72, 0.42 }
    row.hl:SetColorTexture(w[1], w[2], w[3], 0.10)
    row.hl:Hide()

    row.slotFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.slotFS:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.slotFS:SetWidth(72)
    row.slotFS:SetJustifyH("LEFT")
    local t3 = C.text3 or { 0.49, 0.52, 0.56 }
    row.slotFS:SetTextColor(t3[1], t3[2], t3[3])

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
    row:HookScript("OnEnter", function(self) if self.itemID then self.hl:Show() end end)
    row:SetScript("OnLeave", function(self)
        self.hl:Hide()
        GameTooltip:Hide()
    end)
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
    local border = C.border or { 0.25, 0.25, 0.28 }
    local t2 = C.text2 or { 0.85, 0.85, 0.88 }
    for _, t in ipairs(panel.specTabs or {}) do
        local on = t.specID == specID
        t.sel:SetShown(on)
        if t.edge then
            if on then
                t.edge:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 1)
            else
                t.edge:SetVertexColor(border[1], border[2], border[3], 1)
            end
        end
        if on then
            t.label:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
        else
            t.label:SetTextColor(t2[1], t2[2], t2[3])
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
            tab = CreateFrame("Button", nil, panel)
            tab:SetSize(94, 22)
            tab.body, tab.edge = nil, nil
            if S.RoundedPanel then
                tab.body, tab.edge = S.RoundedPanel(tab, C.block2, C.border)
            end
            tab.sel = tab:CreateTexture(nil, "BACKGROUND", nil, 2)
            tab.sel:SetPoint("TOPLEFT", 1, -1)
            tab.sel:SetPoint("BOTTOMRIGHT", -1, 1)
            tab.sel:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.16)
            tab.sel:Hide()
            tab.icon = tab:CreateTexture(nil, "ARTWORK")
            tab.icon:SetSize(14, 14)
            tab.icon:SetPoint("LEFT", tab, "LEFT", 5, 0)
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
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", panel.tabAnchor, "TOPLEFT", x, 0)
        tab:SetScript("OnClick", function() SelectSpec(spec.specID) end)
        tab:Show()
        x = x + 98
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

-- Скруглённая заливка с рамкой — из хелпера Core.lua, а если его нет (старый
-- Core), просто сплошной цвет с бордюром.
local function Bevel(frame, fill, border)
    if S.RoundedPanel then
        return S.RoundedPanel(frame, fill, border)
    end
    frame:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    frame:SetBackdropColor(fill[1], fill[2], fill[3], 1)
    frame:SetBackdropBorderColor(border[1], border[2], border[3], 1)
end

local function BuildPanel()
    if panel then return panel end
    local main = _G[MAIN]
    if not main then return end

    -- Дочерний UIParent, а не main: правый край панели заезжает на 16 px под
    -- основное окно и уровнем ниже — скруглённые правые углы прячутся за его
    -- фоном, видна только скруглённая слева «боковина». Показ/скрытие —
    -- хуками OnShow/OnHide основного окна.
    panel = CreateFrame("Frame", "TrialGearFinderBiSFrame", UIParent, "BackdropTemplate")
    panel:SetWidth(PANEL_W)
    panel:SetPoint("TOPRIGHT", main, "TOPLEFT", 16, 0)
    panel:SetPoint("BOTTOMRIGHT", main, "BOTTOMLEFT", 16, 0)
    panel:SetFrameStrata(main:GetFrameStrata())
    panel:SetFrameLevel(math.max(1, main:GetFrameLevel() - 4))
    panel:EnableMouse(true) -- иначе клики проваливаются на мир за окном
    Bevel(panel, C.bg or { 0.02, 0.03, 0.03 }, C.border or { 0.18, 0.20, 0.22 })

    -- Шапка — скруглённый блок, как заголовок основного окна.
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -6)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, -6)
    header:SetHeight(HEADER_H)
    Bevel(header, C.block or { 0.06, 0.07, 0.08 }, C.border or { 0.18, 0.20, 0.22 })
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", header, "LEFT", 10, 0)
    title:SetText("BiS-сборки")
    if C.text then title:SetTextColor(C.text[1], C.text[2], C.text[3]) end

    -- Колонка классов — во всю высоту панели, иконки круглые.
    local classCol = CreateFrame("Frame", nil, panel)
    classCol:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
    classCol:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 6, 8)
    classCol:SetWidth(CLASS_COL_W)

    panel.classButtons = {}
    local classes = AllClasses()
    local colH = main:GetHeight() - HEADER_H - 30
    local step = (colH - CLASS_ICON) / math.max(1, #classes - 1)
    local cy = 0
    for _, cls in ipairs(classes) do
        local btn = CreateFrame("Button", nil, classCol)
        btn:SetSize(CLASS_ICON, CLASS_ICON)
        btn:SetPoint("TOP", classCol, "TOP", 0, cy)
        btn.classID, btn.classFile = cls.classID, cls.classFile

        local ic = btn:CreateTexture(nil, "ARTWORK")
        ic:SetPoint("CENTER")
        ic:SetSize(CLASS_ICON - 4, CLASS_ICON - 4)
        if GetClassAtlas then ic:SetAtlas(GetClassAtlas(cls.classFile)) end
        if S.CIRCLE and btn.CreateMaskTexture then
            local mask = btn:CreateMaskTexture()
            mask:SetTexture(S.CIRCLE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(ic)
            ic:AddMaskTexture(mask)
        end

        -- Кольцо выбранного класса: круг чуть больше иконки, золотом.
        local ring = btn:CreateTexture(nil, "BACKGROUND")
        ring:SetPoint("CENTER")
        ring:SetSize(CLASS_ICON + 4, CLASS_ICON + 4)
        if S.CIRCLE then ring:SetTexture(S.CIRCLE) else ring:SetColorTexture(1, 1, 1, 1) end
        ring:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 1)
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
        cy = cy - step
    end

    local contentX = CLASS_COL_W + 16

    -- Заголовок класса + якорь для вкладок спеков
    panel.classTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.classTitle:SetPoint("TOPLEFT", header, "BOTTOMLEFT", CLASS_COL_W + 10, -6)

    panel.tabAnchor = CreateFrame("Frame", nil, panel)
    panel.tabAnchor:SetPoint("TOPLEFT", panel, "TOPLEFT", contentX, -(HEADER_H + 34))
    panel.tabAnchor:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -(HEADER_H + 34))
    panel.tabAnchor:SetHeight(22)

    -- Строка приоритета статов
    panel.priorityFS = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.priorityFS:SetPoint("TOPLEFT", panel.tabAnchor, "BOTTOMLEFT", 0, -8)
    panel.priorityFS:SetPoint("TOPRIGHT", panel.tabAnchor, "BOTTOMRIGHT", 0, -8)
    panel.priorityFS:SetJustifyH("LEFT")
    panel.priorityFS:SetWordWrap(true)
    local warm = C.warm or { 0.85, 0.72, 0.42 }
    panel.priorityFS:SetTextColor(warm[1], warm[2], warm[3])

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
    btnRow:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", contentX, 20)
    btnRow:SetPoint("RIGHT", panel, "RIGHT", -8, 0)
    btnRow:SetHeight(18)
    local bx = 0
    for _, label in ipairs({ "Гнёзда", "Камни", "Планировщик" }) do
        local b = CreateFrame("Button", nil, btnRow)
        b:SetSize(84, 18)
        b:SetPoint("LEFT", btnRow, "LEFT", bx, 0)
        Bevel(b, C.block2 or { 0.09, 0.10, 0.11 }, C.border or { 0.18, 0.20, 0.22 })
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
    local t3 = C.text3 or { 0.4, 0.4, 0.42 }
    footer:SetTextColor(t3[1] * 0.8, t3[2] * 0.8, t3[3] * 0.8)

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

-- Основное окно уже создано (Core.lua грузится раньше). Панель — дочерний
-- UIParent, поэтому за окном не следует сама: показ/скрытие вешаем хуками.
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
    main:HookScript("OnHide", function()
        if panel then panel:Hide() end
    end)
    UpdateArrow()
end

ns.ToggleBiS = Toggle
