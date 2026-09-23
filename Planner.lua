-- Planner.lua - примерка BiS-сборки на своего персонажа.
--
-- Окно устроено как игровое окно персонажа: модель в полный рост посередине,
-- слоты в две колонки. Модель одета в то, что на персонаже сейчас, а поверх
-- примерены вещи сборки. Галочка на слоте - вещь уже надета, значок сумки -
-- лежит в сумках. Внизу - сколько сборки собрано и что фармить дальше.
-- Shift над слотом - игровое сравнение с тем, что надето в этом слоте.
--
-- Образец - Gear Planner из аддона Cap20: игроки просили сравнивать сборку
-- со своим шмотом. Отличие: там цель игрок набирает руками, у нас цель -
-- сборка, которую посчитало окно BiS (ns.LastBuild), вместе с её камнями
-- и чарами. Поэтому здесь ничего не редактируется: сменил спек в окне BiS -
-- примерка переоделась сама.

local _, ns = ...
local L = ns.L

local PANEL_W, PANEL_H = 400, 560
local SLOT, PITCH, TOP = 40, 46, -66

-- Колонки как в игровом окне: слева голова..запястья и оружие, справа
-- кисти..аксессуары. По восемь, чтобы модель стояла ровно посередине.
local LEFT  = { "HEAD", "NECK", "SHOULDER", "BACK", "CHEST", "WRIST", "MAINHAND", "OFFHAND" }
local RIGHT = { "HANDS", "WAIST", "LEGS", "FEET", "FINGER1", "FINGER2", "TRINKET1", "TRINKET2" }

local INV = {
    HEAD = "HeadSlot", NECK = "NeckSlot", SHOULDER = "ShoulderSlot",
    BACK = "BackSlot", CHEST = "ChestSlot", WRIST = "WristSlot",
    HANDS = "HandsSlot", WAIST = "WaistSlot", LEGS = "LegsSlot",
    FEET = "FeetSlot", FINGER1 = "Finger0Slot", FINGER2 = "Finger1Slot",
    TRINKET1 = "Trinket0Slot", TRINKET2 = "Trinket1Slot",
    MAINHAND = "MainHandSlot", OFFHAND = "SecondaryHandSlot",
}

-- Подпись пустого слота: у двуручного оружия левой руки в сборке нет вовсе.
local NAME_RU = {
    HEAD = "Голова", NECK = "Шея", SHOULDER = "Плечи", BACK = "Спина",
    CHEST = "Грудь", WRIST = "Запястья", HANDS = "Кисти", WAIST = "Пояс",
    LEGS = "Ноги", FEET = "Ступни", FINGER1 = "Кольцо 1", FINGER2 = "Кольцо 2",
    TRINKET1 = "Аксессуар 1", TRINKET2 = "Аксессуар 2",
    MAINHAND = "Правая рука", OFFHAND = "Левая рука",
}

-- Оружие примеряется в свою руку: одноручное без подсказки игра надевает
-- в правую, и парное оружие затирало бы само себя.
local HAND = { MAINHAND = "MAINHANDSLOT", OFFHAND = "SECONDARYHANDSLOT" }

local DRAG_ROTATION, DEFAULT_ROTATION = 0.010, 0.61 -- как в примерочной игры
local ZOOM_MAX, ZOOM_STEP = 0.8, 0.15

local GREEN = { 0.30, 0.85, 0.35 }
local AMBER = { 0.95, 0.80, 0.30 }

local panel
local buttons = {}
local owned = {} -- itemID -> "equipped" | "bag"; надетое важнее сумки

local function ScanOwned()
    wipe(owned)
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id then owned[id] = "bag" end
        end
    end
    for slot = 1, 19 do
        local id = GetInventoryItemID("player", slot)
        if id then owned[id] = "equipped" end
    end
end

-- Ссылка той же сборки, что в окне BiS: с номерами двадцатки, камнями и чарой.
-- Камни кладутся без дырок - ссылка читает их по позициям.
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

local function BuildByKey()
    local byKey = {}
    for _, s in ipairs(ns.LastBuild and ns.LastBuild.slots or {}) do
        if s.item then byKey[s.key] = s end
    end
    return byKey
end

local function DressModel(byKey)
    local m = panel.model
    m:SetUnit("player")
    for _, list in ipairs({ LEFT, RIGHT }) do
        for _, key in ipairs(list) do
            local s = byKey[key]
            if s then
                local link = LinkFor(s)
                local ok = HAND[key] and pcall(m.TryOn, m, link, HAND[key])
                if not ok then pcall(m.TryOn, m, link) end
            end
        end
    end
    -- SetUnit сбрасывает камеру - возвращаем поворот и приближение игрока.
    m:SetRotation(m.rotation or DEFAULT_ROTATION)
    if m.zoom then m:SetPortraitZoom(m.zoom) end
end

local function SlotOnEnter(self)
    GameTooltip:SetOwner(self, self.side == "L" and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
    if self.link then
        GameTooltip:SetHyperlink(self.link)
    else
        GameTooltip:AddLine(self.slotName or "")
    end
    GameTooltip:AddLine(" ")
    if self.state == "equipped" then
        GameTooltip:AddLine(L"Уже надето", GREEN[1], GREEN[2], GREEN[3])
    else
        if self.state == "bag" then
            GameTooltip:AddLine(L"Лежит в сумках", AMBER[1], AMBER[2], AMBER[3])
        end
        local cur = self.invID and GetInventoryItemLink("player", self.invID)
        GameTooltip:AddLine(cur and (L"Сейчас в слоте: " .. cur) or L"Слот сейчас пуст", 0.8, 0.8, 0.8, true)
        if cur and self.link then
            GameTooltip:AddLine(L"Shift - сравнить с надетым", 0.6, 0.6, 0.6)
        end
    end
    if self.source then
        GameTooltip:AddLine(L"Источник: " .. self.source, 0.55, 0.78, 1, true)
    end
    GameTooltip:Show()
    -- Игровое сравнение: рядом встаёт карточка того, что надето в этом слоте.
    if self.link and IsShiftKeyDown() and GameTooltip_ShowCompareItem then
        pcall(GameTooltip_ShowCompareItem, GameTooltip)
    end
end

local function MakeSlot(parent, key, side)
    local invID, emptyTex = GetInventorySlotInfo(INV[key])
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(SLOT, SLOT)
    b.key, b.side, b.invID, b.emptyTex = key, side, invID, emptyTex

    b.edge = b:CreateTexture(nil, "BACKGROUND")
    b.edge:SetPoint("TOPLEFT", -1, 1)
    b.edge:SetPoint("BOTTOMRIGHT", 1, -1)

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    b.mark = b:CreateTexture(nil, "OVERLAY")
    b.mark:SetSize(16, 16)
    b.mark:SetPoint("BOTTOMRIGHT", 3, -3)

    b:SetScript("OnEnter", SlotOnEnter)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- Щелчок с Shift кладёт ссылку в чат, с Ctrl - примерочная игры.
    b:SetScript("OnClick", function(self)
        if self.link then HandleModifiedItemClick(self.link) end
    end)
    return b
end

local function PaintSlot(b, s)
    b.link, b.state, b.source = nil, nil, nil
    b.slotName = s and s.name or L(NAME_RU[b.key])
    local edge = ns.Style and ns.Style.C and ns.Style.C.border or { 0.18, 0.20, 0.22 }
    if s then
        b.link = LinkFor(s)
        local _, _, _, _, icon = C_Item.GetItemInfoInstant(s.item.itemID)
        b.icon:SetTexture(icon or 134400)
        b.icon:SetDesaturated(false)
        b.icon:SetAlpha(1)
        b.state = owned[s.item.itemID]
        b.source = s.item.source and L(s.item.source) or nil
    else
        b.icon:SetTexture(b.emptyTex)
        b.icon:SetDesaturated(true)
        b.icon:SetAlpha(0.5)
    end
    if b.state == "equipped" then
        b.mark:SetAtlas("common-icon-checkmark")
        b.mark:Show()
        edge = GREEN
    elseif b.state == "bag" then
        b.mark:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
        b.mark:Show()
        edge = AMBER
    else
        b.mark:Hide()
    end
    b.edge:SetColorTexture(edge[1], edge[2], edge[3], 0.9)
end

function ns.RefreshPlanner()
    if not (panel and panel:IsShown()) then return end
    ScanOwned()
    local byKey = BuildByKey()

    local specID = ns.LastBuild and ns.LastBuild.specID
    local specName = specID and GetSpecializationInfoByID and select(2, GetSpecializationInfoByID(specID))
    panel.sub:SetText(specName and string.format(L"Сборка: %s", specName) or "")

    local total, have, worn, bagged, missing = 0, 0, 0, 0, {}
    for _, b in ipairs(buttons) do
        local s = byKey[b.key]
        PaintSlot(b, s)
        if s then
            total = total + 1
            if b.state then
                have = have + 1
                if b.state == "equipped" then worn = worn + 1 else bagged = bagged + 1 end
            elseif #missing < 3 then
                missing[#missing + 1] = b.slotName .. " - " .. (b.source or "?")
            end
        end
    end

    panel.progress:SetText(string.format(L"Собрано %d из %d: надето %d, в сумках %d",
        have, total, worn, bagged))
    if #missing > 0 then
        panel.nextFS:SetText(L"Дальше: " .. table.concat(missing, "  ·  "))
    else
        panel.nextFS:SetText(total > 0 and L"Вся сборка собрана" or "")
    end
    DressModel(byKey)
end

local function Build()
    if panel then return panel end
    local S = ns.Style or {}
    local C = S.C or {}

    panel = CreateFrame("Frame", "TrialGearFinderPlanner", UIParent)
    panel:SetSize(PANEL_W, PANEL_H)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    tinsert(UISpecialFrames, "TrialGearFinderPlanner") -- Escape закрывает

    if S.RoundedPanel then
        S.RoundedPanel(panel, C.bg or { 0.02, 0.03, 0.03 }, C.border or { 0.18, 0.20, 0.22 })
    end

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", panel, "TOP", 0, -12)
    title:SetText(L"Примерка сборки")

    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)

    panel.sub = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.sub:SetPoint("TOP", title, "BOTTOM", 0, -6)
    local t2 = C.text2 or { 0.68, 0.71, 0.74 }
    panel.sub:SetTextColor(t2[1], t2[2], t2[3])

    -- Модель между колонками, над строками подсчёта.
    local model = CreateFrame("DressUpModel", nil, panel)
    model:SetPoint("TOPLEFT", panel, "TOPLEFT", 14 + SLOT + 10, TOP)
    model:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(14 + SLOT + 10), TOP)
    model:SetHeight(8 * PITCH - 6)
    model:SetUnit("player")
    model.rotation = DEFAULT_ROTATION
    model:EnableMouse(true)
    model:EnableMouseWheel(true)
    local function Spin(self)
        local x = GetCursorPosition()
        self.rotation = (self.rotation or DEFAULT_ROTATION) + (x - (self.lastX or x)) * DRAG_ROTATION
        self.lastX = x
        self:SetRotation(self.rotation)
    end
    model:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.lastX = GetCursorPosition()
            self:SetScript("OnUpdate", Spin)
        end
    end)
    model:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    model:SetScript("OnMouseWheel", function(self, delta)
        self.zoom = math.max(0, math.min(ZOOM_MAX, (self.zoom or 0) + delta * ZOOM_STEP))
        self:SetPortraitZoom(self.zoom)
    end)
    panel.model = model

    for i, key in ipairs(LEFT) do
        local b = MakeSlot(panel, key, "L")
        b:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, TOP - (i - 1) * PITCH)
        buttons[#buttons + 1] = b
    end
    for i, key in ipairs(RIGHT) do
        local b = MakeSlot(panel, key, "R")
        b:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, TOP - (i - 1) * PITCH)
        buttons[#buttons + 1] = b
    end

    panel.progress = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.progress:SetPoint("TOP", panel, "TOP", 0, TOP - 8 * PITCH - 8)
    panel.progress:SetWidth(PANEL_W - 28)

    panel.nextFS = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.nextFS:SetPoint("TOP", panel.progress, "BOTTOM", 0, -6)
    panel.nextFS:SetWidth(PANEL_W - 28)
    panel.nextFS:SetJustifyH("CENTER")

    local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
    hint:SetWidth(PANEL_W - 28)
    hint:SetText(L"Потяни модель - повернуть, колесо - приблизить. Shift над слотом - сравнить с надетым.")

    -- Встаём слева от окна BiS, если оно открыто, иначе посередине экрана.
    local bis = _G.TrialGearFinderBiSFrame
    if bis and bis:IsShown() then
        panel:SetPoint("TOPRIGHT", bis, "TOPLEFT", -8, 0)
    else
        panel:SetPoint("CENTER")
    end
    return panel
end

function ns.TogglePlanner()
    if not (ns.LastBuild and ns.LastBuild.slots and #ns.LastBuild.slots > 0) then
        print(L"|cFF86C7BD[TGF]|r Сначала открой окно BiS и выбери спек: /tgf bis")
        return
    end
    local p = Build()
    if p:IsShown() then
        p:Hide()
        return
    end
    p:Show()
    C_Timer.After(0, ns.RefreshPlanner) -- модель подгружается кадром позже
end

-- Надел, снял или подобрал вещь - галочки и модель обновляются сразу.
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
watcher:RegisterEvent("BAG_UPDATE_DELAYED")
watcher:SetScript("OnEvent", function() ns.RefreshPlanner() end)
