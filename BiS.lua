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
local communityId = {} -- itemID -> true: пришёл из ns.CommunityItems, не из гайда

-- Тот же тумблер «Комьюнити», что и в основном окне: один флаг на оба окна.
local function CommunityOn()
    return (TrialGearFinderDB and TrialGearFinderDB.showCommunity) and true or false
end

-- Полный список обеих баз. Метка communityId заполняется ВСЕГДА, независимо
-- от тумблера: по ней и рисуется пометка, и отсекаются предметы сообщества
-- при выключенном тумблере. Отбор делает BuildBuckets, а не эта функция -
-- ItemByID должен находить предмет в любом случае.
local function AllItems()
    if not allItemsCache then
        allItemsCache = {}
        for _, it in ipairs(ns.Items or {}) do allItemsCache[#allItemsCache + 1] = it end
        for _, it in ipairs(ns.CommunityItems or {}) do
            allItemsCache[#allItemsCache + 1] = it
            communityId[it.itemID] = true
        end
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

-- Ключ кэша включает состояние тумблера: при выключенном комьюнити котлы
-- другие, и старые брать нельзя.
local bucketCache = {}
local function BuildBuckets(classFile)
    local withComm = CommunityOn()
    local ckey = classFile .. (withComm and "+c" or "")
    if bucketCache[ckey] then return bucketCache[ckey] end
    local buckets = {}
    for _, item in ipairs(AllItems()) do
        if (withComm or not communityId[item.itemID]) and ClassAllowed(item, classFile) then
            local _, _, _, equipLoc = C_Item.GetItemInfoInstant(item.itemID)
            local slotKey = equipLoc and EQUIPLOC_SLOT[equipLoc]
            if slotKey then
                if TWO_HAND_LOC[equipLoc] then twoHandID[item.itemID] = true end
                buckets[slotKey] = buckets[slotKey] or {}
                table.insert(buckets[slotKey], item)
            end
        end
    end
    bucketCache[ckey] = buckets
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

-- Сколько стата даёт один камень на двадцатке. Точного замера обычного
-- бесцветного камня нет (мета в живом шлеме давал +1), поэтому число
-- подобрано по слепку двух гильдий: перебором по слотам, где у кандидатов
-- РАЗНОЕ число гнёзд, и сверкой с тем, что люди реально носят. От 3 кривая
-- выходит на полку, ниже трёх совпадений меньше.
--
-- Проверка держится на живом примере: у паладина при единице побеждал
-- Рогатый викингский шлем (одно гнездо, зато 13 скорости) - его не носит
-- НИКТО, а Шлем вестника надежды с тремя гнёздами носят 14 человек.
-- При тройке порядок становится правильным.
--
-- Совпадение с гильдиями всё равно около 23%: люди носят и то, что просто
-- выпало. Это ориентир, а не истина - потому и вынесено одним именем.
local GEM_VALUE = 3

-- Счёт предмета под веса статов спека. Гнёзда идут двумя отдельными частями,
-- и вторая тяжелее первой:
--   * сам камень на двадцатке даёт мелочь (GEM_VALUE);
--   * бонус за совпадение цвета - настоящий приз, он записан в базе числом
--     (socketBonus), и у шлемов это, например, +8 к скорости.
-- Раньше стояло плоское sockets * 2 без учёта весов и бонуса: предмет с тремя
-- гнёздами и бонусом +8 проигрывал тому, у кого просто статы чуть выше.
-- Роль вещи глава гильдии размечает прямо в заметке: «[ДД] хороший прок силы»,
-- «[Танк] сильно увеличивает запас здоровья». Пометка есть только у аксессуаров,
-- у остальных вещей её нет и не нужно.
local function NoteRole(item)
    local n = item.note or ""
    if n:find("[Танк]", 1, true) then return "TANK" end
    if n:find("[ДД]", 1, true) then return "DAMAGER" end
    return nil -- без пометки: годится любой роли
end

-- Аксессуар чужой роли в сборку не пускаем. Иначе жрецу-хилу в «Аксессуар 2»
-- попадал Талисман Хаоса с пометкой [ДД]: по статам он проходил (искусность 9),
-- а по смыслу спеку не нужен. Хилу не годится ни [ДД], ни [Танк] - остаются
-- вещи без пометки, они и есть общестатовые.
local function RoleAllowed(item, role)
    local want = NoteRole(item)
    if not want or not role then return true end -- нет пометки или роль неизвестна
    return want == role
end

local function ScoreItem(item, w)
    if not w then return 0 end
    local s = 0
    for key, val in pairs(item.stats or {}) do
        s = s + val * (w[key] or 0)
    end
    -- Камни кладут в самый дорогой для спека стат, поэтому гнездо считается
    -- по максимальному весу, а не по тому, что в предмете уже лежит.
    local bestW = 0
    for _, kw in pairs(w) do
        if kw > bestW then bestW = kw end
    end
    s = s + (item.sockets or 0) * GEM_VALUE * bestW
    local sb = item.socketBonus
    if sb and sb.value then s = s + sb.value * (w[sb.key] or 0) end
    return s
end

-- ---------------------------------------------------------------------------
-- Окно
-- ---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local S = ns.Style or {} -- палитра и скруглённые текстуры из Core.lua
local C = S.C or {}
local GOLD = C.gold or { 1.0, 0.82, 0.0 } -- как цвет подземелий в основном окне
-- 366 не хватало: длинные названия с пометкой («Рукавицы Железного лезвия
-- выше гайда») обрезались многоточием, и вкладки спеков тоже жались.
-- 470 - примерно половина основного окна (880), масштаб текста один и тот же.
local PANEL_W = 500
-- Насколько панель заезжает ПОД основное окно. Больше радиуса скругления
-- картинки (10), поэтому правые углы панели и левая рамка окна оказываются
-- накрыты - на стыке ни щели, ни вмятин, два окна читаются как одно.
-- Содержимое панели отступает на столько же, чтобы не залезть за стык.
local SEAM = 12
local HEADER_H = 30
local CLASS_COL_W = 44 -- 8:>=:0 36 ?;NA 7>;>B>5 :>;LF> +4 ?> :@0O<
-- 16 AB@>: 4>;6=K C<5AB8BLAO <564C AB@>:>9 ?@8>@8B5B0 8 ?>4?8ALN 2=87C:
-- ?@8 2KA>B5 >:=0 632 =0 A?8A>: >AB0QBAO >:>;> 462 B>G5:, 462/16 = 28.
local ROW_H = 28
local CLASS_ICON = 36

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

    -- Шрифт и иконка как в основном окне (там GameFontNormal и значок 32):
    -- при мелком шрифте панель выглядела вдвое «легче» соседа. Иконка меньше
    -- тридцати двух, потому что строк шестнадцать и они должны уместиться
    -- в высоту окна.
    row.slotFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.slotFS:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.slotFS:SetWidth(84) -- «Аксессуар 1» крупным шрифтом в 72 не влезало
    row.slotFS:SetJustifyH("LEFT")
    local t3 = C.text3 or { 0.49, 0.52, 0.56 }
    row.slotFS:SetTextColor(t3[1], t3[2], t3[3])

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(22, 22)
    row.icon:SetPoint("LEFT", row.slotFS, "RIGHT", 4, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon:Hide()

    -- Зелёная галочка: этот предмет сейчас надет.
    row.check = row:CreateTexture(nil, "OVERLAY")
    row.check:SetSize(14, 14)
    row.check:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.check:SetAtlas("common-icon-checkmark")
    row.check:Hide()

    row.valueFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
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
            if communityId[self.itemID] then
                GameTooltip:AddLine("Пред-BiS от сообщества — не из гайда гильдии, но выбить может любой.", 0.85, 0.72, 0.42, true)
            end
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

-- mark - откуда взялся предмет сообщества в этом слоте:
--   "gap"  - гайд этот слот вообще не закрывает (шея, кольца);
--   "beat" - гайд закрывает, но вещь сообщества обошла его по статам;
--   nil    - предмет из гайда, помечать нечего.
local function RenderRow(row, slot, item, mark)
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
        local label = mixin:GetItemName() or ("item:" .. id)
        -- Предмет от сообщества, не из гайда главы гильдии. Разделяем два
        -- случая: гайд слот не закрывает вовсе - или закрывает, но эта вещь
        -- посчиталась лучше. Второе и есть ответ «что даёт комьюнити».
        if communityId[id] then
            if mark == "beat" then
                label = label .. "  |cff5fd35fвыше гайда|r"
            elseif mark == "gap" then
                label = label .. "  |cff9a9a9aнет в гайде|r"
            else
                label = label .. "  |cff9a9a9aпред-BiS|r"
            end
        end
        row.valueFS:SetText(label)
        local q = mixin:GetItemQualityColor()
        if q then row.valueFS:SetTextColor(q.r, q.g, q.b) end
        local ic = mixin:GetItemIcon()
        if ic then row.icon:SetTexture(ic) end
    end)
end

local function RenderSlots()
    local buckets = state.classFile and BuildBuckets(state.classFile) or {}
    local w = ParsePriority(ns.BiSPriority and ns.BiSPriority[state.specID])

    local role = state.specID and GetSpecializationRoleByID
        and GetSpecializationRoleByID(state.specID) or nil

    local ranked = {}
    for slotKey, items in pairs(buckets) do
        local copy = {}
        for _, it in ipairs(items) do
            if RoleAllowed(it, role) then copy[#copy + 1] = it end
        end
        table.sort(copy, function(a, b) return ScoreItem(a, w) > ScoreItem(b, w) end)
        ranked[slotKey] = copy
    end

    -- Лучший счёт среди вещей ГАЙДА в этом котле. nil - гайд слот не закрывает.
    -- Список уже отсортирован, поэтому достаточно первой не-комьюнити записи.
    local function BestGuideScore(list)
        for _, it in ipairs(list or {}) do
            if not communityId[it.itemID] then return ScoreItem(it, w) end
        end
        return nil
    end

    -- Чем помечать выбранную вещь сообщества: дырой в гайде или превосходством.
    local function MarkFor(list, pick)
        if not (pick and communityId[pick.itemID]) then return nil end
        local best = BestGuideScore(list)
        if best == nil then return "gap" end
        return ScoreItem(pick, w) > best and "beat" or nil
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
            local forced = ItemByID(ov)
            -- Поправка указывает на вещь сообщества, а тумблер выключен:
            -- поправку игнорируем и оставляем лучшее из гайда по весам спека.
            if forced and communityId[ov] and not CommunityOn() then forced = nil end
            pick = forced or pick
        end

        if slot.key == "OFFHAND" and ov == nil then
            if DUAL_2H_SPEC[state.specID] then
                -- Тот же лучший двуручник во вторую руку: на двадцатке BiS —
                -- две копии одного оружия, а не первое+второе.
                local mh = ranked["MAINHAND"]
                pick = mh and mh[1] or nil
                RenderRow(row, slot, pick, MarkFor(ranked["MAINHAND"], pick))
            elseif mhIs2H then
                RenderRow(row, slot, nil)
                row.valueFS:SetText("— двуручное")
            else
                RenderRow(row, slot, pick, MarkFor(list, pick))
            end
        else
            RenderRow(row, slot, pick, MarkFor(list, pick))
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
    local n = #specs
    -- Ширина вкладки — чтобы все спеки поместились в один ряд. Друид с 4
    -- спеками ужимается сильнее прочих; длинное имя обрезается.
    local usable = panel.tabAnchor:GetWidth()
    if not usable or usable < 10 then usable = PANEL_W - (CLASS_COL_W + 16) - 8 end
    local gap = 3
    local tabW = math.max(52, math.floor((usable - (n - 1) * gap) / math.max(1, n)))
    local x = 0
    for i, spec in ipairs(specs) do
        local tab = panel.specTabs[i]
        if not tab then
            tab = CreateFrame("Button", nil, panel)
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
            tab.icon:SetSize(16, 16)
            tab.icon:SetPoint("LEFT", tab, "LEFT", 4, 0)
            tab.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            tab.label:SetPoint("LEFT", tab.icon, "RIGHT", 3, 0)
            tab.label:SetPoint("RIGHT", tab, "RIGHT", -2, 0)
            tab.label:SetJustifyH("LEFT")
            tab.label:SetWordWrap(false)
            panel.specTabs[i] = tab
        end
        tab.specID = spec.specID
        tab:SetSize(tabW, 26)
        tab.icon:SetTexture(spec.icon or 134400)
        tab.label:SetText(spec.name)
        tab.label:SetShown(tabW >= 64) -- совсем узкие вкладки — только иконка
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", panel.tabAnchor, "TOPLEFT", x, 0)
        tab:SetScript("OnClick", function() SelectSpec(spec.specID) end)
        tab:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(spec.name)
            GameTooltip:Show()
        end)
        tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
        tab:Show()
        x = x + tabW + gap
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

    -- Дочерний основного окна: скрывается вместе с ним, ничего не остаётся
    -- на экране. Той же высоты, уровнем выше окна, чтобы чат за ним
    -- не просвечивал.
    --
    -- Заезжает на SEAM вправо, ПОД основное окно: так накрываются и свои
    -- правые скруглённые углы, и чужая левая рамка. Иначе на стыке видно
    -- то две линии подряд, то вмятины от скругления.
    panel = CreateFrame("Frame", "TrialGearFinderBiSFrame", main, "BackdropTemplate")
    panel:SetWidth(PANEL_W + SEAM)
    panel:SetPoint("TOPRIGHT", main, "TOPLEFT", SEAM, 0)
    panel:SetPoint("BOTTOMRIGHT", main, "BOTTOMLEFT", SEAM, 0)
    panel:SetFrameLevel(main:GetFrameLevel() + 2)
    panel:EnableMouse(true) -- иначе клики проваливаются на мир за окном

    -- Скругление слева, прямой край справа.
    --
    -- Правым маргином среза это НЕ делается: середина 9-среза тогда тянется
    -- из области, куда попадают правые скруглённые углы картинки, и на стыке
    -- сверху и снизу вылезали вмятины (проверено в игре 10 сентября).
    -- Маргины остаются честные 10/10/10/10, а правые углы просто закрываются
    -- сверху прямой заплаткой; линии рамки над и под ней дорисовываются.
    local bgcol = C.bg or { 0.02, 0.03, 0.03 }
    local brd = C.border or { 0.18, 0.20, 0.22 }
    if S.RoundedTexture then
        local edge = S.RoundedTexture(panel, "BACKGROUND", brd, 0)
        edge:SetAllPoints()
        local body = S.RoundedTexture(panel, "BACKGROUND", bgcol, 1)
        body:SetPoint("TOPLEFT", panel, "TOPLEFT", 1, -1)
        body:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -1, 1)

        -- Заплатка ровно в ширину захода под окно: она и выпрямляет правый
        -- край, и лежит поверх левой рамки основного окна.
        local patch = panel:CreateTexture(nil, "BACKGROUND", nil, 2)
        patch:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
        patch:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
        patch:SetWidth(SEAM)
        patch:SetColorTexture(bgcol[1], bgcol[2], bgcol[3], 1)
        -- Рамку продолжаем сверху и снизу до самого края - тогда верх и низ
        -- идут одной прямой через оба окна. Справа рамки нет: там середина.
        for _, side in ipairs({ "TOP", "BOTTOM" }) do
            local line = panel:CreateTexture(nil, "BACKGROUND", nil, 3)
            line:SetHeight(1)
            line:SetWidth(SEAM)
            line:SetPoint(side .. "RIGHT", panel, side .. "RIGHT", 0, 0)
            line:SetColorTexture(brd[1], brd[2], brd[3], 1)
        end
    else
        local pbg = panel:CreateTexture(nil, "BACKGROUND")
        pbg:SetAllPoints()
        pbg:SetColorTexture(bgcol[1], bgcol[2], bgcol[3], 1)
        if S.AddBorder then
            local sides = S.AddBorder(panel, brd)
            if sides and sides.RIGHT then sides.RIGHT:Hide() end
        end
    end

    -- Шапка — скруглённый блок, как заголовок основного окна.
    -- Отступ сверху ровно 8, как у titleBg в Core.lua: верх у обоих окон
    -- на одной высоте, и при шестёрке этот блок торчал на два пикселя выше
    -- соседнего — на стыке это читалось бугорком.
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -8)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(6 + SEAM), -8)
    header:SetHeight(HEADER_H)
    Bevel(header, C.block or { 0.06, 0.07, 0.08 }, C.border or { 0.18, 0.20, 0.22 })
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", header, "CENTER", 0, 0)
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
    panel.tabAnchor:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(8 + SEAM), -(HEADER_H + 34))
    panel.tabAnchor:SetHeight(22)

    -- Строка приоритета статов
    panel.priorityFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.priorityFS:SetPoint("TOPLEFT", panel.tabAnchor, "BOTTOMLEFT", 0, -8)
    panel.priorityFS:SetPoint("TOPRIGHT", panel.tabAnchor, "BOTTOMRIGHT", 0, -8)
    panel.priorityFS:SetJustifyH("LEFT")
    panel.priorityFS:SetWordWrap(true)
    local warm = C.warm or { 0.85, 0.72, 0.42 }
    panel.priorityFS:SetTextColor(warm[1], warm[2], warm[3])

    -- Список слотов
    local list = CreateFrame("Frame", nil, panel)
    list:SetPoint("TOPLEFT", panel.priorityFS, "BOTTOMLEFT", 0, -10)
    list:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -(8 + SEAM), 40)
    panel.slotRows = {}
    local ry = 0
    for i = 1, #SLOTS do
        panel.slotRows[i] = MakeSlotRow(list, i, ry)
        ry = ry - ROW_H
    end

    local footer = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOM", panel, "BOTTOM", 0, 6)
    footer:SetText("раскладка адаптирована из Cap20 (MIT), автор Kkthnx")
    local t3 = C.text3 or { 0.4, 0.4, 0.42 }
    footer:SetTextColor(t3[1] * 0.8, t3[2] * 0.8, t3[3] * 0.8)

    return panel
end

-- Язычок на стыке окон: сворачивает и разворачивает панель.
local function UpdateArrow()
    if not arrow then return end
    -- свёрнуто → «<» (открыть, панель слева); развёрнуто → «>» (свернуть)
    arrow.glyph:SetText(IsCollapsed() and "<" or ">")
end

-- Два окна вместе шире одного, и на узком экране панель уезжала бы за край.
-- Ужимаем ОБА одним масштабом: панель - дитя основного окна, поэтому хватает
-- масштабировать его. Свёрнута - масштаб возвращаем, окно снова во всю величину.
--
-- Ниже 0.6 не опускаемся: мельче текст уже не прочитать, пусть лучше вылезет
-- за край - окно можно подвинуть мышью.
local MIN_SCALE = 0.6
local function FitToScreen()
    local main = _G[MAIN]
    if not main then return end
    if IsCollapsed() then main:SetScale(1) return end
    local have = UIParent:GetWidth()
    local need = main:GetWidth() + PANEL_W
    if not (have and need and need > 0) then return end
    local s = have / need
    main:SetScale(s < 1 and math.max(MIN_SCALE, s) or 1)
end

local function ApplyCollapsed()
    if panel then panel:SetShown(not IsCollapsed()) end
    FitToScreen()
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
    -- Язычок на левой кромке основного окна. Дочерний UIParent (не main и не
    -- панель), самой верхней стратой — иначе панель, которая тоже наверху,
    -- его перекрывала. Показ/скрытие — вместе с основным окном.
    -- Дочерний основного окна: сам скрывается/показывается вместе с ним,
    -- ничего не остаётся на экране после закрытия. Страта выше панели
    -- (та на DIALOG) — тогда язычок поверх неё и без хуков show/hide.
    -- Прижат к левой кромке изнутри: смещение равно своей ширине, поэтому
    -- левый край язычка совпадает с левым краем окна и наружу ничего
    -- не торчит. Было 8 - вылезал на шесть пикселей и висел в пустоте.
    arrow = CreateFrame("Button", nil, main)
    arrow:SetSize(14, 36)
    arrow:SetPoint("RIGHT", main, "LEFT", 14, 0)
    arrow:SetFrameStrata("FULLSCREEN_DIALOG")
    Bevel(arrow, C.block or { 0.06, 0.07, 0.08 }, C.border or { 0.18, 0.20, 0.22 })

    arrow.glyph = arrow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    arrow.glyph:SetPoint("CENTER", 0, 0)
    arrow.glyph:SetTextColor(GOLD[1], GOLD[2], GOLD[3]) -- золотом, как прежняя стрелка

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
    MakeArrow() -- дочерний main, скрывается вместе с ним
    main:HookScript("OnShow", function()
        if not IsCollapsed() then
            if not panel then BuildPanel() end
            Populate()
        end
        ApplyCollapsed()
    end)
    if main:IsShown() then
        if not IsCollapsed() then BuildPanel(); Populate() end
        ApplyCollapsed()
    end
end

ns.ToggleBiS = Toggle

-- Зовёт основное окно, когда переключили тумблер «Комьюнити»: он один на оба
-- окна, а состав котлов от него зависит - готовые кэши надо выбросить.
ns.RefreshBiS = function()
    bucketCache = {}
    if not (panel and panel:IsShown()) then return end
    -- Пересобираем ТУ ЖЕ вкладку, а не прыгаем на свой класс: Populate зовёт
    -- PlayerClassSpec и всегда возвращает на спек игрока, а при переключении
    -- тумблера человек как раз сравнивает шмот в чужой вкладке.
    if state.classFile and state.specID then
        RenderSlots()
    else
        Populate()
    end
end
