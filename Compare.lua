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
local W, H = 1300, 880
local ROW_H, TOP = 36, -100
local ICON = 32
local MID = W / 2
local GAP = 22        -- от середины до иконки: в щели стоят камни обеих сторон
local GEM = 10        -- иконка камня
local MODEL_W = 300
local BOTTOM = TOP - 16 * ROW_H - 12 -- верх нижнего блока: плашки и диаграмма

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

local frame, rows, boxes = nil, {}, { bis = {}, cur = {} }
local snap -- снимок сборки для своего спека

local function EnchantFrom(data)
    if not (data and data.lines and ENCH_PAT) then return nil end
    for _, line in ipairs(data.lines) do
        local text = line.leftText
        local m = text and text:match(ENCH_PAT)
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
        side.icon:SetPoint("TOPRIGHT", parent, "TOPLEFT", MID - GAP, y)
        side.bar:SetPoint("TOPRIGHT", side.icon, "TOPLEFT", -3, 0)
        side.name:SetPoint("TOPRIGHT", side.bar, "TOPLEFT", -6, 1)
        for i, g in ipairs(side.gems) do
            g:SetPoint("TOPLEFT", side.icon, "TOPRIGHT", 3, -(i - 1) * (GEM + 1))
        end
    else
        side.icon:SetPoint("TOPLEFT", parent, "TOPLEFT", MID + GAP, y)
        side.bar:SetPoint("TOPLEFT", side.icon, "TOPRIGHT", 3, 0)
        side.name:SetPoint("TOPLEFT", side.bar, "TOPRIGHT", 6, 1)
        for i, g in ipairs(side.gems) do
            g:SetPoint("TOPRIGHT", side.icon, "TOPLEFT", -3, -(i - 1) * (GEM + 1))
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

-- ── Плашки характеристик ───────────────────────────────────────────────────
local function MakeBox(parent, x, y)
    local S = ns.Style or {}
    local C = S.C or {}
    local b = CreateFrame("Frame", nil, parent)
    b:SetSize(70, 52)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
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
    local _, specName, _, _, _, classFile = GetSpecializationInfoByID(snap.specID)
    local _, pClassFile = UnitClass("player")
    local cc = C_ClassColor and C_ClassColor.GetClassColor(classFile or pClassFile)
    local className = ns.ClassName and ns.ClassName(classFile or pClassFile) or ""
    frame.lTitle:SetText(L"BiS-сборка")
    frame.lClass:SetText(string.format("%s (%s)", className, specName or ""))
    frame.rTitle:SetText(UnitName("player") or "")
    local ownIdx = GetSpecialization and GetSpecialization()
    local ownSpec = ownIdx and select(2, GetSpecializationInfo(ownIdx)) or ""
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
            bisEnch = C_TooltipInfo and EnchantFrom(C_TooltipInfo.GetHyperlink(bisLink))
            if not bisEnch and s.ench then bisEnch = L(s.ench.ru or "") end
            local ok = HAND[key] and pcall(model.TryOn, model, bisLink, HAND[key])
            if not ok then pcall(model.TryOn, model, bisLink) end
            sumBis = sumBis + (s.item.ilvl or 0)
            nBis = nBis + 1
        end
        PaintSide(row.l, bisLink, bisName or "…", s and s.item.ilvl, bisGems, bisEnch, false, row.emptyTex, mark)

        local curName, curIlvl, curGems, curEnch
        if curLink then
            curName = curLink:match("%[(.-)%]")
            curIlvl = C_Item.GetDetailedItemLevelInfo(curLink)
            curGems = {}
            for gi = 1, 4 do
                local _, gemLink = C_Item.GetItemGem(curLink, gi)
                if gemLink then curGems[#curGems + 1] = { icon = IconOf(gemLink), ref = gemLink } end
            end
            curEnch = C_TooltipInfo and EnchantFrom(C_TooltipInfo.GetInventoryItem("player", row.invID))
        end
        PaintSide(row.r, curLink, curName, curIlvl, curGems, curEnch, s and s.ench ~= nil, row.emptyTex, mark)
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

    -- Крестик сам по себе прячет своего родителя - слой со строками, а не окно.
    -- Так и было 23 сентября: слой пропадал, окно с моделями оставалось.
    local close = CreateFrame("Button", nil, content, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", content, "TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() frame:Hide() end)

    -- Разделитель посередине.
    local line = content:CreateTexture(nil, "BACKGROUND", nil, 2)
    line:SetColorTexture(0.25, 0.27, 0.30, 0.6)
    line:SetPoint("TOP", content, "TOPLEFT", MID, -14)
    line:SetSize(1, H - 28)

    -- Шапки сторон: название, класс, большой средний уровень предметов.
    local function Header(cx)
        local t = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        t:SetPoint("TOP", content, "TOPLEFT", cx, -12)
        local c = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        c:SetPoint("TOP", t, "BOTTOM", 0, -3)
        local i = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        i:SetPoint("TOP", c, "BOTTOM", 0, -4)
        i:SetTextColor(0.25, 0.60, 1.0)
        return t, c, i
    end
    frame.lTitle, frame.lClass, frame.lIlvl = Header(W / 4)
    frame.rTitle, frame.rClass, frame.rIlvl = Header(W * 3 / 4)
    frame.rTitle:SetTextColor(1, 1, 1)

    for i, key in ipairs(ROWS) do
        local y = TOP - (i - 1) * ROW_H
        local invID, emptyTex = GetInventorySlotInfo(INV[key])
        rows[i] = { key = key, invID = invID, emptyTex = emptyTex,
                    l = MakeSide(content, y, true), r = MakeSide(content, y, false) }
    end

    -- Низ: у каждой стороны плашки сеткой три на два у края окна и диаграмма
    -- итога сборки ближе к середине - та же, что в окне BiS.
    for i = 1, #BOX_KEYS do
        local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
        local y = BOTTOM - row * 58
        boxes.bis[i] = MakeBox(content, 30 + col * 76, y)
        boxes.cur[i] = MakeBox(content, W - 30 - 3 * 76 + 6 + col * 76, y)
    end
    if ns.MakeRadar then
        frame.lRadar = ns.MakeRadar(content, 44)
        frame.lRadar:SetPoint("CENTER", content, "TOPLEFT", MID - 150, BOTTOM - 70)
        frame.rRadar = ns.MakeRadar(content, 44)
        frame.rRadar:SetPoint("CENTER", content, "TOPLEFT", MID + 150, BOTTOM - 70)
    end
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
    C_Timer.After(0, ns.RefreshCompare) -- модели подгружаются кадром позже
end

-- Надел или снял вещь - правая сторона и плашки обновляются сразу.
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
watcher:SetScript("OnEvent", function() ns.RefreshCompare() end)
