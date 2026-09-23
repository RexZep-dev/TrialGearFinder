-- Compare.lua - BiS-сборка рядом с тем, что надето сейчас.
--
-- Вид - как сравнение персонажей в ChonkyCharacterSheet (просьба пользователя
-- 23 сентября, по его скриншоту): слева наша сборка, справа текущий персонаж.
-- У каждой стороны своя модель, посередине шестнадцать строк слотов: название,
-- уровень предмета, камни и чара. Внизу - плашки характеристик.
--
-- Окно отдельное, к окну BiS не пристыковано: /tgf compare или кнопка
-- «Сравнить» в итоге сборки. Модели стоят позади строк, как у Чонки.
-- Сборку берёт для своего спека сам (ns.ComputeBuild), открывать окно BiS
-- не нужно. Снимок сборки держит у себя - если в окне BiS переключить класс,
-- здесь по-прежнему сравнивается свой спек.

local _, ns = ...
local L = ns.L

-- Ширина с запасом по краям: строки привязаны к середине, модели - к краям,
-- и между ними остаётся зазор (пользователь 23 сентября: фигуры заходили
-- под текст).
local W, H = 1300, 912
-- Строка 40, а не 36: между рамками вещей нужен зазор (пользователь 23 сентября:
-- вещи шли сплошной кашей). Окно из-за этого выше на 32.
local ROW_H, TOP = 40, -100
local ICON = 32
local GEM = 16        -- иконка камня (было 10 - пользователь: мелкие, 23 сентября)
-- От середины до иконки: в щели стоят камни обеих сторон, по два в столбике
-- и до двух столбиков - у Дракончика три шестерёнки, у шлемов и поясов
-- бывает три гнезда.
local GAP = 3 + 2 * (GEM + 2) + 6 -- рамка у разделителя и поле камням внутри рамки
local MODEL_W = 300
local BOTTOM = TOP - 16 * ROW_H - 12 -- верх нижнего блока: плашки и диаграмма
-- Половина полосы строки от середины: камни, иконка, текст и поле. Столько
-- же занимает зебра, её же тонирует подсветка по стату.
local HALF = GAP + ICON + 12 + 240 + 10

-- Порядок строк как у Чонки: голова..запястья, оружие, кисти..аксессуары.
local ROWS = {
    "HEAD", "NECK", "SHOULDER", "BACK", "CHEST", "WRIST", "MAINHAND", "OFFHAND",
    "HANDS", "WAIST", "LEGS", "FEET", "FINGER1", "FINGER2", "TRINKET1", "TRINKET2",
}

local INV = {
    HEAD = "HeadSlot", NECK = "NeckSlot", SHOULDER = "ShoulderSlot",
    BACK = "BackSlot", CHEST = "ChestSlot", WRIST = "WristSlot",
    HANDS = "HandsSlot", WAIST = "WaistSlot", LEGS = "LegsSlot",
    FEET = "FeetSlot", FINGER1 = "Finger0Slot", FINGER2 = "Finger1Slot",
    TRINKET1 = "Trinket0Slot", TRINKET2 = "Trinket1Slot",
    MAINHAND = "MainHandSlot", OFFHAND = "SecondaryHandSlot",
}

-- Оружие примеряется в свою руку, иначе второе одноручное затёрло бы первое.
local HAND = { MAINHAND = "MAINHANDSLOT", OFFHAND = "SECONDARYHANDSLOT" }

-- Плашки внизу. Основная характеристика подставляется по спеку сборки.
local BOX_KEYS = { "stam", "primary", "crit", "haste", "iskus", "vers" }
local BOX_LABEL = { stam = "Вын", str = "Сила", agi = "Лов", int = "Инт",
                    crit = "Крит", haste = "Скор", iskus = "Иск", vers = "Уни" }
local UNIT_STAT = { str = 1, agi = 2, stam = 3, int = 4 }
local RATING = {
    crit = CR_CRIT_MELEE or 9, haste = CR_HASTE_MELEE or 18,
    iskus = CR_MASTERY or 26, vers = CR_VERSATILITY_DAMAGE_DONE or 29,
}

local GREEN = { 0.30, 0.85, 0.35 }
local YELLOW = { 0.95, 0.80, 0.30 }
local GREY = { 0.35, 0.37, 0.40 }
local RED = { 0.90, 0.30, 0.28 }

-- Строка «Чары: %s» из самой игры - так имя чары выходит на языке клиента.
local ENCH_PAT
if ENCHANTED_TOOLTIP_LINE then
    local esc = ENCHANTED_TOOLTIP_LINE:gsub("[%(%)%.%+%-%*%?%[%]%^%$]", "%%%0")
    ENCH_PAT = "^" .. esc:gsub("%%s", "(.+)") .. "$"
end

-- Строка «Уровень предмета: %d» - уровень надетой вещи берём из её подсказки,
-- как ChonkyCharacterSheet (сверено с его исходником). Уровень по одной ссылке
-- у части вещей неверен: «Плащ свирепого йети» выходил 84 вместо 23
-- (пользователь 23 сентября). Без якоря в конце: за числом бывает приписка.
local ILVL_PAT
if ITEM_LEVEL then
    local esc = ITEM_LEVEL:gsub("[%(%)%.%+%-%*%?%[%]%^%$]", "%%%0")
    ILVL_PAT = "^" .. esc:gsub("%%d", "(%%d+)")
end

local frame, rows, boxes = nil, {}, { bis = {}, cur = {} }
local snap -- снимок сборки для своего спека

local function TooltipMatch(data, pat)
    if not (data and data.lines and pat) then return nil end
    for _, line in ipairs(data.lines) do
        local text = line.leftText
        local m = text and text:match(pat)
        if m then return m end
    end
    return nil
end

local function IconOf(itemRef)
    local _, _, _, _, icon = C_Item.GetItemInfoInstant(itemRef)
    return icon
end

-- Ссылка той же сборки, что в окне BiS: номера двадцатки, камни без дырок, чара.
local function LinkFor(s)
    local item = s.item
    local gems = {}
    for i = 1, #(item.socketTypes or {}) do
        gems[i] = s.gems and s.gems[i] or 0
    end
    if ns.BuildItemLink then
        return ns.BuildItemLink(item.itemID, item.bonusIDs or {}, gems, s.ench and s.ench.enchantID)
    end
    return "item:" .. item.itemID
end

local function SetQualityText(fs, name, itemRef)
    local q = itemRef and C_Item.GetItemQualityByID(itemRef)
    if q and C_Item.GetItemQualityColor then
        local r, g, b = C_Item.GetItemQualityColor(q)
        fs:SetTextColor(r, g, b)
    else
        fs:SetTextColor(1, 1, 1)
    end
    fs:SetText(name or "")
end

-- ── Одна сторона строки: иконка, полоска-метка и три строки текста ─────────
local function MakeSide(parent, y, left)
    local side = {}
    -- Рамка вокруг вещи и её камней на тёмной подложке: без неё иконка
    -- и камни сливались с соседними вещами в одну кашу. Качество - полоска
    -- снаружи рамки. Рамка - текстуры на том же кадре, что и иконка, иначе
    -- дочерний кадр лёг бы поверх неё.
    local ST = ns.Style or {}
    local SC = ST.C or {}
    if ST.RoundedTexture then
        side.boxEdge = ST.RoundedTexture(parent, "BACKGROUND", SC.border or { 0.18, 0.20, 0.22 }, 1)
        -- Подложка - цвет фона окна, темнее обеих полос зебры: рамка читается
        -- и на светлой строке, и на тёмной.
        side.boxBody = ST.RoundedTexture(parent, "BACKGROUND", SC.bg or { 0.02, 0.03, 0.03 }, 2)
        local inner = GAP + ICON + 2
        if left then
            side.boxEdge:SetPoint("TOPRIGHT", parent, "TOP", -2, y + 2)
            side.boxEdge:SetPoint("BOTTOMLEFT", parent, "TOP", -inner, y - ICON - 2)
        else
            side.boxEdge:SetPoint("TOPLEFT", parent, "TOP", 2, y + 2)
            side.boxEdge:SetPoint("BOTTOMRIGHT", parent, "TOP", inner, y - ICON - 2)
        end
        side.boxBody:SetPoint("TOPLEFT", side.boxEdge, "TOPLEFT", 1, -1)
        side.boxBody:SetPoint("BOTTOMRIGHT", side.boxEdge, "BOTTOMRIGHT", -1, 1)
    end

    side.icon = parent:CreateTexture(nil, "ARTWORK")
    side.icon:SetSize(ICON, ICON)
    side.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    side.bar = parent:CreateTexture(nil, "ARTWORK")
    side.bar:SetSize(3, ICON)
    side.name = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    side.lvl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    side.ench = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    for _, fs in ipairs({ side.name, side.lvl, side.ench }) do
        fs:SetWidth(240)
        fs:SetWordWrap(false)
        fs:SetJustifyH(left and "RIGHT" or "LEFT")
    end

    -- Камни столбиком рядом с иконкой, в щели посередине - как у Чонки.
    -- Каждый ловит мышь сам: наведение показывает, что это за камень.
    side.gems = {}
    for i = 1, 3 do
        local g = CreateFrame("Frame", nil, parent)
        g:SetSize(GEM, GEM)
        g.tex = g:CreateTexture(nil, "ARTWORK")
        g.tex:SetAllPoints()
        g.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        g:EnableMouse(true)
        g:SetScript("OnEnter", function(self)
            if not self.ref then return end
            GameTooltip:SetOwner(self, left and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.ref)
            GameTooltip:Show()
        end)
        g:SetScript("OnLeave", function() GameTooltip:Hide() end)
        side.gems[i] = g
    end

    if left then
        side.icon:SetPoint("TOPRIGHT", parent, "TOP", -GAP, y)
        side.bar:SetPoint("TOPRIGHT", side.icon, "TOPLEFT", -3, 0)
        side.name:SetPoint("TOPRIGHT", side.bar, "TOPLEFT", -6, 1)
        for i, g in ipairs(side.gems) do
            local col, row = math.floor((i - 1) / 2), (i - 1) % 2
            g:SetPoint("TOPLEFT", side.icon, "TOPRIGHT", 3 + col * (GEM + 2), -row * (GEM + 1))
        end
    else
        side.icon:SetPoint("TOPLEFT", parent, "TOP", GAP, y)
        side.bar:SetPoint("TOPLEFT", side.icon, "TOPRIGHT", 3, 0)
        side.name:SetPoint("TOPLEFT", side.bar, "TOPRIGHT", 6, 1)
        for i, g in ipairs(side.gems) do
            local col, row = math.floor((i - 1) / 2), (i - 1) % 2
            g:SetPoint("TOPRIGHT", side.icon, "TOPLEFT", -3 - col * (GEM + 2), -row * (GEM + 1))
        end
    end
    local anchor = left and "TOPRIGHT" or "TOPLEFT"
    side.lvl:SetPoint(anchor, side.name, left and "BOTTOMRIGHT" or "BOTTOMLEFT", 0, -1)
    side.ench:SetPoint(anchor, side.lvl, left and "BOTTOMRIGHT" or "BOTTOMLEFT", 0, -1)

    -- Подсказка предмета по наведению на иконку.
    side.hit = CreateFrame("Frame", nil, parent)
    side.hit:SetAllPoints(side.icon)
    side.hit:EnableMouse(true)
    side.hit:SetScript("OnEnter", function(self)
        if not side.link then return end
        GameTooltip:SetOwner(self, left and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(side.link)
        GameTooltip:Show()
    end)
    side.hit:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Вклад вещи в стат под мышью в плашках или на диаграмме своей стороны
    -- (пользователь 24 сентября, как у Чонки). Вид - как в окне BiS, где он
    -- пользователю понравился: полоса строки тёплым тоном и «+N» у внешнего
    -- края. Первый вариант, число поверх иконки, закрывал вещь и камни.
    -- Полоса - от середины до края зебры, под рамкой вещи.
    side.hl = parent:CreateTexture(nil, "BACKGROUND", nil, 0)
    local warmC = SC.warm or { 0.85, 0.72, 0.42 }
    side.hl:SetColorTexture(warmC[1], warmC[2], warmC[3], 0.10)
    local bandTop, bandMid = y + 4, y + 4 - ROW_H / 2
    side.pill = CreateFrame("Frame", nil, parent)
    side.pill:SetSize(36, 18)
    if left then
        side.hl:SetPoint("TOPLEFT", parent, "TOP", -HALF + 1, bandTop)
        side.hl:SetPoint("BOTTOMRIGHT", parent, "TOP", -1, bandTop - ROW_H)
        side.pill:SetPoint("LEFT", parent, "TOP", -HALF + 8, bandMid)
    else
        side.hl:SetPoint("TOPLEFT", parent, "TOP", 1, bandTop)
        side.hl:SetPoint("BOTTOMRIGHT", parent, "TOP", HALF - 1, bandTop - ROW_H)
        side.pill:SetPoint("RIGHT", parent, "TOP", HALF - 8, bandMid)
    end
    side.hl:Hide()
    side.pill:SetFrameLevel(side.hit:GetFrameLevel() + 2)
    if ST.RoundedPanel then ST.RoundedPanel(side.pill, SC.bg or { 0.02, 0.03, 0.03 }, SC.warm or { 0.85, 0.72, 0.42 }) end
    side.pill.fs = side.pill:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    side.pill.fs:SetPoint("CENTER", 0, 0)
    side.pill.fs:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
    side.pill:Hide()
    return side
end

local function PaintSide(side, link, name, ilvl, gems, ench, needEnch, emptyTex, mark)
    side.link = link
    if link then
        local _, _, _, _, icon = C_Item.GetItemInfoInstant(link)
        side.icon:SetTexture(icon or 134400)
        side.icon:SetDesaturated(false)
        side.icon:SetAlpha(1)
        SetQualityText(side.name, name, link)
        side.lvl:SetText(ilvl and tostring(ilvl) or "")
    else
        side.icon:SetTexture(emptyTex)
        side.icon:SetDesaturated(true)
        side.icon:SetAlpha(0.4)
        side.name:SetText("")
        side.lvl:SetText("")
    end
    if ench then
        side.ench:SetText(ench)
        side.ench:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
    elseif link and needEnch then
        side.ench:SetText(L"Нет чар")
        side.ench:SetTextColor(RED[1], RED[2], RED[3])
    else
        side.ench:SetText("")
    end
    side.bar:SetColorTexture(mark[1], mark[2], mark[3], link and 0.9 or 0)
    for i, g in ipairs(side.gems) do
        local gem = link and gems and gems[i]
        g.ref = gem and gem.ref
        g.tex:SetTexture(gem and gem.icon)
        g:SetShown(gem ~= nil)
    end
end

-- Вклад надетой вещи по статам - из её подсказки, как у Чонки (сверено
-- с его исходником): каждое «+N» в строке, камни «+2 к силе и +2 к скорости»
-- делятся по «и». Серые строки - неактивное (бонус за гнёзда не по цвету,
-- несобранный комплект), их пропускаем. Ссылке не верим: уровень по ней
-- у части вещей неверен (см. уровень выше).
local PRIMARIES = { "str", "agi", "int" }
function ns.StatsFromTooltip(data)
    local out = {}
    if not (data and data.lines and ns.StemToStatKey) then return out end
    local function Add(k, v) out[k] = (out[k] or 0) + v end
    for _, line in ipairs(data.lines) do
        local text, c = line.leftText, line.leftColor
        local grey = c and c.r and c.g and c.b and c.r > 0.4 and c.r < 0.6
            and math.abs(c.r - c.g) < 0.05 and math.abs(c.g - c.b) < 0.05
        if type(text) == "string" and not grey then
            text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", "")
            text = text:gsub("%s+и%s+", "\n"):gsub("%s+and%s+", "\n"):gsub(",%s*", "\n")
            for part in text:gmatch("[^\n]+") do
                local v, name = part:match("%+(%d+)%s+(.+)$")
                v = tonumber(v)
                local low = name and name:lower()
                if not v then
                    -- числа в этой части нет
                elseif name:find("атак") or name:find("передвиж") or name:find("заклин")
                    or low:find("attack power", 1, true) or low:find("spell power", 1, true)
                    or low:find("movement", 1, true) then
                    -- сила атаки, сила заклинаний, скорость бега - не наши шесть статов
                elseif name:find("всем характеристик") or low:find("all stats", 1, true) then
                    for _, k in ipairs(PRIMARIES) do Add(k, v) end
                    Add("stam", v)
                elseif name:find("основной характеристик") or low:find("primary stat", 1, true) then
                    for _, k in ipairs(PRIMARIES) do Add(k, v) end
                else
                    local k = ns.StemToStatKey(name)
                    if k then Add(k, v) end
                end
            end
        end
    end
    return out
end

-- Наведение на стат: вещи своей стороны, которые его дают, подсвечиваются
-- и показывают «+N» у края строки, остальные гаснут. sideKey - "l" (сборка) или "r" (надетое);
-- statKey = nil возвращает всё как было.
local function ShowStat(sideKey, statKey)
    for _, row in ipairs(rows) do
        local side = row[sideKey]
        local v = math.floor((statKey and side.contrib and side.contrib[statKey] or 0) + 0.5)
        local on = statKey ~= nil and v > 0
        if on then
            side.pill.fs:SetText("+" .. v)
            side.pill:SetWidth((side.pill.fs:GetStringWidth() or 20) + 14)
        end
        side.pill:SetShown(on)
        side.hl:SetShown(on)
        local a = (statKey and not on) and 0.35 or 1
        side.name:SetAlpha(a)
        side.lvl:SetAlpha(a)
        side.ench:SetAlpha(a)
        side.bar:SetAlpha(a)
        for _, g in ipairs(side.gems) do g:SetAlpha(a) end
        side.icon:SetAlpha(side.link and a or 0.4)
    end
end

-- ── Плашки характеристик ───────────────────────────────────────────────────
local function MakeBox(parent)
    local S = ns.Style or {}
    local C = S.C or {}
    local b = CreateFrame("Frame", nil, parent)
    b:SetSize(70, 52)
    if S.RoundedPanel then
        S.RoundedPanel(b, C.block2 or { 0.09, 0.10, 0.11 }, C.borderSoft or { 0.13, 0.14, 0.16 })
    end
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.label:SetPoint("TOP", 0, -5)
    b.value = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    b.value:SetPoint("CENTER", 0, -2)
    b.delta = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.delta:SetPoint("BOTTOM", 0, 4)
    return b
end

local function CurrentStat(key)
    if UNIT_STAT[key] then
        local _, _, pos = UnitStat("player", UNIT_STAT[key])
        return math.floor((pos or 0) + 0.5)
    end
    return math.floor((GetCombatRating(RATING[key]) or 0) + 0.5)
end

-- ── Заполнение ─────────────────────────────────────────────────────────────
local function OwnSpecID()
    local idx = GetSpecialization and GetSpecialization()
    return idx and GetSpecializationInfo(idx) or nil
end

local function EnsureSnapshot()
    local own = OwnSpecID()
    if not (ns.LastBuild and ns.LastBuild.specID == own) and ns.ComputeBuild then
        ns.ComputeBuild()
    end
    if ns.LastBuild and ns.LastBuild.slots and #ns.LastBuild.slots > 0 then
        snap = ns.LastBuild
    end
    return snap
end

function ns.RefreshCompare()
    if not (frame and frame:IsShown() and snap) then return end
    local byKey = {}
    for _, s in ipairs(snap.slots) do
        if s.item then byKey[s.key] = s end
    end

    -- Шапка: слева сборка, справа персонаж.
    local _, _, _, _, _, classFile = GetSpecializationInfoByID(snap.specID)
    -- Спек по словарю аддона: у клиента он на языке клиента, и на русском
    -- клиенте с английским окном выходило «Warrior (Неистовство)».
    local specName = ns.SpecName and ns.SpecName(snap.specID)
    local _, pClassFile = UnitClass("player")
    local cc = C_ClassColor and C_ClassColor.GetClassColor(classFile or pClassFile)
    local className = ns.ClassName and ns.ClassName(classFile or pClassFile) or ""
    frame.lTitle:SetText(L"BiS-сборка")
    frame.lClass:SetText(string.format("%s (%s)", className, specName or ""))
    frame.rTitle:SetText(UnitName("player") or "")
    local ownIdx = GetSpecialization and GetSpecialization()
    local ownSpecID = ownIdx and GetSpecializationInfo(ownIdx)
    local ownSpec = ownSpecID and ns.SpecName and ns.SpecName(ownSpecID) or ""
    frame.rClass:SetText(string.format("%s (%s) " .. L"%d-го уровня", className, ownSpec, UnitLevel("player") or 0))
    if cc then
        frame.lClass:SetTextColor(cc.r, cc.g, cc.b)
        frame.rClass:SetTextColor(cc.r, cc.g, cc.b)
    end

    local sumBis, nBis = 0, 0
    local model = frame.lModel
    model:SetUnit("player")
    if model.Undress then model:Undress() end

    for _, row in ipairs(rows) do
        local key = row.key
        local s = byKey[key]
        local curLink = row.invID and GetInventoryItemLink("player", row.invID)
        local curID = curLink and C_Item.GetItemInfoInstant(curLink)

        -- Полоска: зелёная - надето то же, что в сборке, жёлтая - другое.
        local mark = GREY
        if s then mark = (curID == s.item.itemID) and GREEN or YELLOW end

        local bisLink, bisName, bisEnch, bisGems = nil, nil, nil, {}
        if s then
            bisLink = LinkFor(s)
            bisName = C_Item.GetItemNameByID(s.item.itemID)
            if not bisName and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(s.item.itemID)
                frame.pending = true
            end
            for gi = 1, #(s.item.socketTypes or {}) do
                local gid = s.gems and s.gems[gi]
                if gid and gid ~= 0 then bisGems[#bisGems + 1] = { icon = IconOf(gid), ref = "item:" .. gid } end
            end
            bisEnch = C_TooltipInfo and TooltipMatch(C_TooltipInfo.GetHyperlink(bisLink), ENCH_PAT)
            if not bisEnch and s.ench then bisEnch = L(s.ench.ru or "") end
            local ok = HAND[key] and pcall(model.TryOn, model, bisLink, HAND[key])
            if not ok then pcall(model.TryOn, model, bisLink) end
            sumBis = sumBis + (s.item.ilvl or 0)
            nBis = nBis + 1
        end
        PaintSide(row.l, bisLink, bisName or "…", s and s.item.ilvl, bisGems, bisEnch, false, row.emptyTex, mark)
        row.l.contrib = s and s.contrib or nil

        local curName, curIlvl, curGems, curEnch, curContrib
        if curLink then
            curName = curLink:match("%[(.-)%]")
            local tip = C_TooltipInfo and C_TooltipInfo.GetInventoryItem("player", row.invID)
            curIlvl = tonumber(TooltipMatch(tip, ILVL_PAT)) or C_Item.GetDetailedItemLevelInfo(curLink)
            curGems = {}
            for gi = 1, 4 do
                local _, gemLink = C_Item.GetItemGem(curLink, gi)
                if gemLink then curGems[#curGems + 1] = { icon = IconOf(gemLink), ref = gemLink } end
            end
            curEnch = TooltipMatch(tip, ENCH_PAT)
            curContrib = ns.StatsFromTooltip(tip)
        end
        PaintSide(row.r, curLink, curName, curIlvl, curGems, curEnch, s and s.ench ~= nil, row.emptyTex, mark)
        row.r.contrib = curContrib
    end

    -- Двуручное оружие игра считает в среднем уровне дважды: левой руки
    -- в сборке тогда нет, а слотов всё равно шестнадцать.
    if byKey.MAINHAND and not byKey.OFFHAND then
        sumBis = sumBis + (byKey.MAINHAND.item.ilvl or 0)
        nBis = nBis + 1
    end
    frame.lIlvl:SetText(nBis > 0 and string.format("%.2f", sumBis / 16) or "")
    local _, equipped = GetAverageItemLevel()
    frame.rIlvl:SetText(string.format("%.2f", equipped or 0))

    model:SetRotation(model.rotation or 0.61)
    frame.rModel:SetUnit("player")
    frame.rModel:SetRotation(frame.rModel.rotation or -0.61)

    -- Плашки: сборка (с разницей к надетому) и персонаж.
    local total = snap.total or {}
    for i, k in ipairs(BOX_KEYS) do
        local key = (k == "primary") and (snap.primary or "str") or k
        local bisV = math.floor((total[key] or 0) + 0.5)
        local curV = CurrentStat(key)
        local lb, rb = boxes.bis[i], boxes.cur[i]
        lb.statKey, rb.statKey = key, key
        lb.label:SetText(L(BOX_LABEL[key]))
        rb.label:SetText(L(BOX_LABEL[key]))
        lb.value:SetText(bisV)
        rb.value:SetText(curV)
        local d = bisV - curV
        if d > 0 then
            lb.delta:SetText("+" .. d)
            lb.delta:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        elseif d < 0 then
            lb.delta:SetText(tostring(d))
            lb.delta:SetTextColor(RED[1], RED[2], RED[3])
        else
            lb.delta:SetText("")
        end
        rb.delta:SetText("")
    end

    -- Диаграммы: те же оси, что в окне BiS, - своя основная и пять остальных.
    if frame.lRadar then
        local function Values(get)
            local v = { [snap.primary or "str"] = get(snap.primary or "str") }
            for _, k in ipairs({ "stam", "crit", "haste", "iskus", "vers" }) do v[k] = get(k) end
            return v
        end
        frame.lRadar:Update(Values(function(k) return total[k] or 0 end))
        frame.rRadar:Update(Values(CurrentStat))
    end

    -- Названия и чары подгружаются с сервера не сразу - перерисуем ещё раз.
    -- Не больше четырёх раз: предмет, который сервер так и не отдал, иначе
    -- держал бы окно в вечном опросе.
    if frame.pending and (frame.retries or 0) < 4 then
        frame.retries = (frame.retries or 0) + 1
        C_Timer.After(0.5, ns.RefreshCompare)
    end
    frame.pending = nil
end

local function MakeModel(parent, point, x, rotation)
    local m = CreateFrame("DressUpModel", nil, parent)
    m:SetPoint(point, parent, point, x, TOP)
    m:SetSize(MODEL_W, #ROWS * ROW_H)
    m:SetUnit("player")
    m.rotation = rotation
    m:EnableMouse(true)
    m:EnableMouseWheel(true)
    local function Spin(self)
        local cx = GetCursorPosition()
        self.rotation = (self.rotation or 0) + (cx - (self.lastX or cx)) * 0.010
        self.lastX = cx
        self:SetRotation(self.rotation)
    end
    m:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.lastX = GetCursorPosition()
            self:SetScript("OnUpdate", Spin)
        end
    end)
    m:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    m:SetScript("OnMouseWheel", function(self, delta)
        self.zoom = math.max(0, math.min(0.8, (self.zoom or 0) + delta * 0.15))
        self:SetPortraitZoom(self.zoom)
    end)
    return m
end

local function Build()
    if frame then return frame end
    local S = ns.Style or {}
    local C = S.C or {}

    frame = CreateFrame("Frame", "TrialGearFinderCompare", UIParent)
    frame:SetSize(W, H)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    -- Щелчок поднимает окно над основным, как и основное над ним: оба
    -- в одном слое DIALOG, и открытое кнопкой «Сравнить» окно оказывалось
    -- под основным (пользователь 24 сентября).
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    tinsert(UISpecialFrames, "TrialGearFinderCompare") -- Escape закрывает
    if S.RoundedPanel then
        S.RoundedPanel(frame, C.bg or { 0.02, 0.03, 0.03 }, C.border or { 0.18, 0.20, 0.22 })
    end

    -- Модели - нижний слой, всё остальное на слое над ними: как у Чонки,
    -- фигура стоит позади строк и не наезжает на предметы.
    frame.lModel = MakeModel(frame, "TOPLEFT", 4, 0.61)
    frame.rModel = MakeModel(frame, "TOPRIGHT", -4, -0.61)
    local content = CreateFrame("Frame", nil, frame)
    content:SetAllPoints()
    content:SetFrameLevel(frame.lModel:GetFrameLevel() + 5)
    frame.content = content

    -- Крестик как в главном окне: знак умножения шрифтом окна, белый,
    -- при наведении тёплый. Штатный красный в золотой рамке выбивался
    -- (пользователь 23 сентября). Простая кнопка, а не UIPanelCloseButton:
    -- та сама прячет родителя - слой со строками, а не окно.
    local close = CreateFrame("Button", nil, content)
    close:SetSize(28, 28)
    close:SetPoint("TOPRIGHT", content, "TOPRIGHT", -8, -8)
    close.glyph = close:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    local glyphFont, glyphSize, glyphFlags = close.glyph:GetFont()
    if glyphFont and glyphSize then close.glyph:SetFont(glyphFont, glyphSize * 1.5, glyphFlags) end
    close.glyph:SetPoint("CENTER", close, "CENTER", 0, 0)
    close.glyph:SetText("\195\151") -- U+00D7, знак умножения
    local textC, warmC = C.text or { 0.96, 0.96, 0.96 }, C.warm or { 0.85, 0.72, 0.42 }
    close.glyph:SetTextColor(textC[1], textC[2], textC[3])
    close:SetScript("OnEnter", function(self) self.glyph:SetTextColor(warmC[1], warmC[2], warmC[3]) end)
    close:SetScript("OnLeave", function(self) self.glyph:SetTextColor(textC[1], textC[2], textC[3]) end)
    close:SetScript("OnClick", function() frame:Hide() end)

    -- Галочки «Персонажи» и «Диаграммы» (тестеры, 23 сентября): убрать модели
    -- или диаграммы, чтобы остались одни вещи. Выбор запоминается, по умолчанию
    -- всё видно. Стоят наверху между шапками, столбиком, в рамке тёплого
    -- акцента - пользователь хотел, чтобы они бросались в глаза; в углу и внизу
    -- их не замечали. Разделитель начинается под рамкой.
    local panel = CreateFrame("Frame", nil, content)
    panel:SetPoint("TOP", content, "TOP", 0, -10)
    if S.RoundedPanel then
        S.RoundedPanel(panel, C.block2 or { 0.09, 0.10, 0.11 }, C.warm or { 0.85, 0.72, 0.42 })
    end
    frame.togglePanel = panel

    local function Hidden(key) return TrialGearFinderDB and TrialGearFinderDB[key] end
    local function MakeToggle(ru, key)
        local t = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        t:SetSize(24, 24)
        if S.CheckBox then S.CheckBox(t, 11) end
        t.label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        t.label:SetPoint("LEFT", t, "RIGHT", 4, 0)
        t.label:SetText(L(ru))
        t:SetChecked(not Hidden(key))
        t:SetScript("OnClick", function(self)
            TrialGearFinderDB = TrialGearFinderDB or {}
            TrialGearFinderDB[key] = not self:GetChecked() or nil
            frame.Relayout()
            -- Спрятанная и снова показанная модель теряет примерку и встаёт
            -- в то, что надето, - переодеваем кадром позже, когда она прогрузится.
            C_Timer.After(0, ns.RefreshCompare)
        end)
        return t
    end
    frame.modelToggle = MakeToggle("Персонажи", "compareHideModels")
    frame.radarToggle = MakeToggle("Диаграммы", "compareHideRadars")

    -- Разделитель посередине.
    local line = content:CreateTexture(nil, "BACKGROUND", nil, 2)
    line:SetColorTexture(0.25, 0.27, 0.30, 0.6)
    line:SetWidth(1)
    line:SetPoint("TOP", panel, "BOTTOM", 0, -6)
    line:SetPoint("BOTTOM", content, "BOTTOM", 0, 14)

    -- Шапки сторон: название, класс, большой средний уровень предметов.
    local function Header()
        local t = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        local c = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        c:SetPoint("TOP", t, "BOTTOM", 0, -3)
        local i = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        i:SetPoint("TOP", c, "BOTTOM", 0, -4)
        i:SetTextColor(0.25, 0.60, 1.0)
        return t, c, i
    end
    frame.lTitle, frame.lClass, frame.lIlvl = Header()
    frame.rTitle, frame.rClass, frame.rIlvl = Header()
    frame.rTitle:SetTextColor(1, 1, 1)

    -- Зебра, как в списке главного окна (пользователь 23 сентября): скруглённая
    -- подложка в рамке, чётные строки светлее. Только посередине, от текста
    -- до текста: модели по краям в полосах тонули. Сверху и снизу поле
    -- в 6 пикселей - прямоугольные полосы не срезают скруглённых углов.
    -- Кадр между моделями и слоем строк: под текстом, над моделями.
    local half = HALF
    local listTop = TOP + 4 -- верх первой полосы: рамка вещи начинается на 2 выше иконки
    local listBg = CreateFrame("Frame", nil, frame)
    listBg:SetFrameLevel(frame.lModel:GetFrameLevel() + 2)
    listBg:SetPoint("TOPLEFT", frame, "TOP", -half, listTop + 6)
    listBg:SetPoint("BOTTOMRIGHT", frame, "TOP", half, listTop - #ROWS * ROW_H - 6)
    if S.RoundedPanel then
        S.RoundedPanel(listBg, C.block or { 0.06, 0.07, 0.08 }, C.border or { 0.18, 0.20, 0.22 })
    end
    local stripeColor = C.block2 or { 0.09, 0.10, 0.11 }
    for i = 2, #ROWS, 2 do
        local stripe = listBg:CreateTexture(nil, "BORDER")
        stripe:SetColorTexture(stripeColor[1], stripeColor[2], stripeColor[3], 1)
        stripe:SetPoint("TOPLEFT", listBg, "TOPLEFT", 1, -6 - (i - 1) * ROW_H)
        stripe:SetPoint("TOPRIGHT", listBg, "TOPRIGHT", -1, -6 - (i - 1) * ROW_H)
        stripe:SetHeight(ROW_H)
    end

    for i, key in ipairs(ROWS) do
        local y = TOP - (i - 1) * ROW_H
        local invID, emptyTex = GetInventorySlotInfo(INV[key])
        rows[i] = { key = key, invID = invID, emptyTex = emptyTex,
                    l = MakeSide(content, y, true), r = MakeSide(content, y, false) }
    end

    -- Низ: у каждой стороны плашки сеткой три на два у края окна и диаграмма
    -- итога сборки ближе к середине - та же, что в окне BiS.
    for i = 1, #BOX_KEYS do
        boxes.bis[i] = MakeBox(content)
        boxes.cur[i] = MakeBox(content)
    end
    if ns.MakeRadar then
        frame.lRadar = ns.MakeRadar(content, 44)
        frame.lRadar:SetPoint("CENTER", content, "TOP", -150, BOTTOM - 70)
        frame.rRadar = ns.MakeRadar(content, 44)
        frame.rRadar:SetPoint("CENTER", content, "TOP", 150, BOTTOM - 70)
    end

    -- Наведение на стат в плашках или на диаграмме подсвечивает вещи своей
    -- стороны, которые его дают.
    for i = 1, #BOX_KEYS do
        for sideKey, list in pairs({ l = boxes.bis, r = boxes.cur }) do
            local b = list[i]
            b:EnableMouse(true)
            b:SetScript("OnEnter", function(self) ShowStat(sideKey, self.statKey) end)
            b:SetScript("OnLeave", function() ShowStat(sideKey, nil) end)
        end
    end
    if frame.lRadar then
        frame.lRadar.OnStatEnter = function(k) ShowStat("l", k) end
        frame.lRadar.OnStatLeave = function() ShowStat("l", nil) end
        frame.rRadar.OnStatEnter = function(k) ShowStat("r", k) end
        frame.rRadar.OnStatLeave = function() ShowStat("r", nil) end
    end
    frame.rows, frame.boxes = rows, boxes -- дымовой проверке

    -- Раскладка по галочкам. Строки, разделитель и диаграммы держатся
    -- за середину окна, поэтому ширина меняется без их перестановки; шапки
    -- и плашки встают от края текущей ширины.
    --   с персонажами - 1300: модели по краям;
    --   без персонажей - 1100: плашкам нужно место слева от диаграмм;
    --   без персонажей и диаграмм - 760: строки и плашки.
    function frame.Relayout()
        local models = not Hidden("compareHideModels")
        local radars = not Hidden("compareHideRadars")
        local w = models and W or (radars and 1100 or 760)
        frame:SetWidth(w)
        frame.lModel:SetShown(models)
        frame.rModel:SetShown(models)
        if frame.lRadar then
            frame.lRadar:SetShown(radars)
            frame.rRadar:SetShown(radars)
        end
        frame.lTitle:ClearAllPoints()
        frame.lTitle:SetPoint("TOP", content, "TOP", -w / 4, -12)
        frame.rTitle:ClearAllPoints()
        frame.rTitle:SetPoint("TOP", content, "TOP", w / 4, -12)
        -- Плашки: с диаграммами - у краёв окна, место посередине их; без
        -- диаграмм - по центру своей половины, под строками (пользователь:
        -- у краёв они смотрелись не по центру).
        local blockW = 3 * 76 - 6
        local leftX = radars and -(w / 2 - 30) or (-w / 4 - blockW / 2)
        local rightX = radars and (w / 2 - 30 - blockW) or (w / 4 - blockW / 2)
        for i = 1, #BOX_KEYS do
            local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
            local y = BOTTOM - row * 58
            boxes.bis[i]:ClearAllPoints()
            boxes.bis[i]:SetPoint("TOPLEFT", content, "TOP", leftX + col * 76, y)
            boxes.cur[i]:ClearAllPoints()
            boxes.cur[i]:SetPoint("TOPLEFT", content, "TOP", rightX + col * 76, y)
        end

        -- Галочки столбиком в рамке. Ширина рамки - по длинной подписи:
        -- на двух языках они разные.
        local t1, t2 = frame.modelToggle, frame.radarToggle
        local labelW = math.max(t1.label:GetStringWidth() or 60, t2.label:GetStringWidth() or 60)
        panel:SetSize(8 + 24 + 4 + labelW + 12, 8 + 24 + 4 + 24 + 8)
        t1:ClearAllPoints()
        t1:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -8)
        t2:ClearAllPoints()
        t2:SetPoint("TOPLEFT", t1, "BOTTOMLEFT", 0, -4)
    end
    frame.Relayout()
    return frame
end

function ns.ToggleCompare()
    local f = Build()
    if f:IsShown() then
        f:Hide()
        return
    end
    if not EnsureSnapshot() then
        print(L"|cFF86C7BD[TGF]|r Сначала открой окно BiS и выбери спек: /tgf bis")
        return
    end
    f.retries = 0
    f.content:Show() -- на случай, если слой спрятали отдельно от окна
    f:Show()
    f:Raise()
    -- И ещё раз кадром позже: щелчок по кнопке «Сравнить» поднимает основное
    -- окно, и если игра делает это после нашего Raise, окно сравнения
    -- оказывалось под ним.
    C_Timer.After(0, function() if f:IsShown() then f:Raise() end end)
    C_Timer.After(0, ns.RefreshCompare) -- модели подгружаются кадром позже
end

-- Надел или снял вещь - правая сторона и плашки обновляются сразу.
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
watcher:SetScript("OnEvent", function() ns.RefreshCompare() end)
