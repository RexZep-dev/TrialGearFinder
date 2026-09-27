-- Значок вещи над табличкой моба, с которого она падает (пользователь
-- 27 сентября: «показывал над мобом иконку вещи, с которого падает топор»).
-- Отдельным файлом: Core.lua упирается в предел локальных переменных.
--
-- Мобы - вкладка «Добывается с» на Wowhead (снята 27 сентября). Общая
-- добыча Запределья: шанс у всех около 0,01 %, лучший - Солнцелов-жнец
-- в Ботанике (22 из 87 тысяч убийств).

local addonName, ns = ...

ns.DropMarks = {
    -- Поющий хрустальнокованный топор
    [31318] = {
        19509, 18422, 19505, 19508, 19557, 19865,                     -- Ботаника
        20036, 20034, 20031, 20038, 20041, 20047, 20048, 20049,       -- Крепость Бурь
        15547, 15548, 15551, 16170, 16409, 16468, 16471, 16482, 16491, -- Каражан
        16700, 17083, 17671,                                          -- Разрушенные залы
        18323, 18325,                                                 -- Сетеккские залы
        18315, 18331,                                                 -- Гробницы маны
        18631, 18633, 18635,                                          -- Темный лабиринт
        17957, 21126,                                                 -- Узилище
        21225, 21229, 21230, 21339,                                   -- Змеиное святилище
        22845, 22847, 22877, 22882, 22939, 23236,                     -- Черный храм
        17839, 17898, 21408, 25370,                                   -- прочие
    },
}

-- Внутри подземелий Midnight прячет от аддонов, кто этот моб: UnitGUID,
-- UnitName и UnitCreatureID приходят «секретными» (SecretWhenUnitIdentity-
-- Restricted в документации Blizzard; в Ботанике проверено 27 сентября).
-- Открыты уровень, «элитный ли» и само подземелье. Топор - общая добыча,
-- его может уронить любой элитный моб там, поэтому в этих подземельях значок
-- получает каждый элитный противник. Ключ - instanceID (8-е значение
-- GetInstanceInfo); номера по памяти, в игре проверена только Ботаника - нет.
ns.DropMarkInstances = {
    [553] = 31318, -- Ботаника
    [550] = 31318, -- Крепость Бурь
    [532] = 31318, -- Каражан
    [540] = 31318, -- Разрушенные залы
    [556] = 31318, -- Сетеккские залы
    [557] = 31318, -- Гробницы маны
    [555] = 31318, -- Темный лабиринт
    [547] = 31318, -- Узилище
    [548] = 31318, -- Змеиное святилище
    [564] = 31318, -- Черный храм
    [580] = 31318, -- Плато Солнечного Колодца
}

-- npcID -> itemID. ponytail: у моба с несколькими вещами показываем одну,
-- первую попавшуюся; ряд значков - когда вещей в списке станет больше.
local byNpc = {}
for itemID, npcs in pairs(ns.DropMarks) do
    for _, npc in ipairs(npcs) do byNpc[npc] = byNpc[npc] or itemID end
end

-- Табличку игра переиспользует для других мобов, значок висит на ней.
local marks = setmetatable({}, { __mode = "k" })

local function NpcID(unit)
    local guid = UnitGUID(unit)
    -- Midnight: часть данных о юнитах «секретная», сравнивать её нельзя.
    if not guid or (issecretvalue and issecretvalue(guid)) then return nil end
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind ~= "Creature" then return nil end
    return tonumber(id)
end

local function Secret(v) return issecretvalue and issecretvalue(v) end

-- Что показать над мобом: в открытом мире - по номеру моба, в подземелье,
-- где номер скрыт, - по самому подземелью, любому элитному противнику.
local function ItemFor(unit)
    local guid = UnitGUID(unit)
    if not Secret(guid) then return byNpc[NpcID(unit) or 0] end
    local itemID = ns.DropMarkInstances[select(8, GetInstanceInfo()) or 0]
    if not itemID then return nil end
    local cls, enemy = UnitClassification(unit), UnitCanAttack("player", unit)
    if Secret(cls) or Secret(enemy) or not enemy then return nil end
    if cls == "elite" or cls == "rareelite" or cls == "worldboss" then return itemID end
    return nil
end

local function Refresh(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end
    local itemID = ItemFor(unit)
    local mark = marks[plate]
    if not itemID then
        if mark then mark:Hide() end
        return
    end
    if not mark then
        mark = CreateFrame("Frame", nil, plate)
        mark:SetSize(26, 26)
        mark:SetPoint("BOTTOM", plate, "TOP", 0, 2)
        mark.icon = mark:CreateTexture(nil, "OVERLAY")
        mark.icon:SetAllPoints()
        marks[plate] = mark
    end
    mark.icon:SetTexture(C_Item.GetItemIconByID(itemID))
    mark:Show()
end

local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
f:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        Refresh(unit)
    else
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate and marks[plate] then marks[plate]:Hide() end
    end
end)
