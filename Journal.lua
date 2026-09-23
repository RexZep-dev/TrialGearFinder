-- Журнал приключений: значок Путешествия во времени на плитках,
-- вкладка текущего сезона, дамп добычи `/tgf tw` и `/tgf dj`.
--
-- Неделя события — бафф на персонаже (игра вешает его сама, пока идёт
-- Путешествие во времени). Календарь — только чтобы сказать, когда
-- следующая неделя, если баффа нет.
-- Данжи не зашиты: у кого в меню сложности есть «Путешествие во времени».
-- Штатные кнопки не прячем.

local addonName, ns = ...

local TIMEWALK_CURRENCY = 1166

-- Бафф недели → вкладка экспансии в журнале. Номера заклинаний — те, что
-- игра вешает на персонажа, пока событие активно.
local TW_AURA_TIER = {
    [452307]  = 1,  -- Classic
    [335148]  = 2,  -- Burning Crusade
    [335149]  = 3,  -- Wrath of the Lich King
    [335150]  = 4,  -- Cataclysm
    [335151]  = 5,  -- Mists of Pandaria
    [335152]  = 6,  -- Warlords of Draenor
    [359082]  = 7,  -- Legion
    [1223878] = 8,  -- Battle for Azeroth
    [1256081] = 9,  -- Shadowlands
}

local cache = {}
local hooked
local replacing
local scanning
local emptyPanel, emptyText
local nextEvent
local calendarAsked

-- nil в сохранённых настройках — включено: так было до тумблеров.
local function BadgeOn()
    return not TrialGearFinderDB or TrialGearFinderDB.journalTWBadge ~= false
end

local function SeasonOn()
    return not TrialGearFinderDB or TrialGearFinderDB.journalTWSeason ~= false
end

local function TimewalkDifficultyIDs()
    local D = DifficultyUtil and DifficultyUtil.ID
    return (D and D.DungeonTimewalker) or 24, (D and D.RaidTimewalker) or 33
end

local function TimewalkIcon()
    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(TIMEWALK_CURRENCY)
        if info then
            return info.iconFileID or info.iconFile or info.icon
        end
    end
    return "Interface\\Icons\\inv_misc_hourglass"
end

local function SelectedHasTimewalk()
    local dungeon, raid = TimewalkDifficultyIDs()
    local C = C_EncounterJournal
    if C and C.InstanceHasDifficultyID then
        if C.InstanceHasDifficultyID(dungeon) or C.InstanceHasDifficultyID(raid) then
            return true
        end
    end
    if EJ_IsValidInstanceDifficulty then
        return EJ_IsValidInstanceDifficulty(dungeon) or EJ_IsValidInstanceDifficulty(raid)
    end
    return false
end

local function HasTimewalk(instanceID)
    local cached = cache[instanceID]
    if cached ~= nil then return cached end
    if not EJ_SelectInstance then return false end
    EJ_SelectInstance(instanceID)
    local yes = SelectedHasTimewalk() and true or false
    cache[instanceID] = yes
    return yes
end

local function Stamp(button)
    if not button then return end
    local tex = button.TGFTimewalk
    if not BadgeOn() then
        if tex then tex:Hide() end
        return
    end
    if not tex then
        tex = button:CreateTexture(nil, "OVERLAY", nil, 7)
        tex:SetSize(22, 22)
        tex:SetPoint("BOTTOMLEFT", 4, 6)
        tex:SetTexture(TimewalkIcon())
        button.TGFTimewalk = tex
    end
    local id = button.instanceID
    if id and HasTimewalk(id) then
        tex:Show()
    else
        tex:Hide()
    end
end

local function StampVisible()
    local selectFrame = EncounterJournal and EncounterJournal.instanceSelect
    local scrollBox = selectFrame and selectFrame.ScrollBox
    if not scrollBox or not scrollBox.GetFrames then return end
    local frames = scrollBox:GetFrames()
    for i = 1, #frames do
        Stamp(frames[i])
    end
end

local function IsTimewalkTitle(title)
    if type(title) ~= "string" then return false end
    return (title:find("Timewalk", 1, true)
        or title:find("Путешеств", 1, true)
        or title:find("путешеств", 1, true)) and true
end

local TIER_HINTS = {
    { 11, { "War Within", "The War Within", "Война внутри" } },
    { 10, { "Dragonflight", "Драконь" } },
    {  9, { "Shadowlands", "Темные Земли", "Тёмные Земли" } },
    {  8, { "Battle for Azeroth", "Битва за Азерот" } },
    {  7, { "Legion", "Легион" } },
    {  6, { "Warlords", "Draenor", "Дренор" } },
    {  5, { "Pandaria", "Пандари", "Mists" } },
    {  4, { "Cataclysm", "Катаклизм" } },
    {  3, { "Northrend", "Нордскол", "Lich King", "Короля-лича", "Wrath" } },
    {  2, { "Burning Crusade", "Outland", "Запредель", "Burning" } },
    {  1, { "Classic", "классическ" } },
}

local function TitleToTier(title)
    if type(title) ~= "string" then return nil end
    for i = 1, #TIER_HINTS do
        local tier, hints = TIER_HINTS[i][1], TIER_HINTS[i][2]
        for h = 1, #hints do
            if title:find(hints[h], 1, true) then return tier end
        end
    end
    return nil
end

local function EventStamp(t)
    if not t or not t.year or not t.month or not t.monthDay then return nil end
    return time({
        year = t.year,
        month = t.month,
        day = t.monthDay,
        hour = t.hour or 0,
        min = t.minute or 0,
    })
end

-- Месяц и эпоха — словарь аддона, не календарь клиента: иначе при
-- английском окне на русском клиенте объявление остаётся русским.
local MONTH_GENITIVE = {
    "января", "февраля", "марта", "апреля", "мая", "июня",
    "июля", "августа", "сентября", "октября", "ноября", "декабря",
}

local TIER_LABEL = {
    [1]  = "Классика",
    [2]  = "Burning Crusade",
    [3]  = "Гнев Короля-лича",
    [4]  = "Катаклизм",
    [5]  = "Пандария",
    [6]  = "Дренор",
    [7]  = "Легион",
    [8]  = "Битва за Азерот",
    [9]  = "Темные земли",
    [10] = "Драконы",
    [11] = "The War Within",
    [12] = "Midnight",
}

local function FormatDay(t)
    if not t then return "" end
    local name = t.month and MONTH_GENITIVE[t.month]
    if name then
        return t.monthDay .. " " .. ns.L(name)
    end
    return string.format("%d.%d", t.monthDay, t.month)
end

local function ExpansionLabel(tier, fallback)
    local name = tier and TIER_LABEL[tier]
    if name then return ns.L(name) end
    return fallback
end

local function GetActiveTimewalk()
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        for spellID, tier in pairs(TW_AURA_TIER) do
            local info = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if info then
                return {
                    tier = tier,
                    name = info.name,
                    expirationTime = info.expirationTime,
                }
            end
        end
    end
    return nil
end

local function ScanCalendar()
    if scanning then return end
    if not C_Calendar or not C_Calendar.GetDayEvent then return end
    local now = C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime and C_DateAndTime.GetCurrentCalendarTime()
    if not now then return end
    local nowStamp = EventStamp(now)
    if not nowStamp then return end

    scanning = true
    local shown = C_Calendar.GetMonthInfo and C_Calendar.GetMonthInfo(0)
    if C_Calendar.SetAbsMonth then
        C_Calendar.SetAbsMonth(now.month, now.year)
    end

    local upcomingNamed, upcomingAny
    local seen = {}
    for monthOffset = 0, 2 do
        local monthInfo = C_Calendar.GetMonthInfo and C_Calendar.GetMonthInfo(monthOffset)
        local numDays = monthInfo and monthInfo.numDays or 31
        for day = 1, numDays do
            local n = C_Calendar.GetNumDayEvents(monthOffset, day) or 0
            for i = 1, n do
                local e = C_Calendar.GetDayEvent(monthOffset, day, i)
                if e and e.calendarType == "HOLIDAY" and IsTimewalkTitle(e.title) then
                    -- Повтор - это тот же номер И тот же день начала: многодневное
                    -- событие стоит на каждом своём дне. Номер у всех недель
                    -- Путешествия один, и по одному номеру прошедшая сентябрьская
                    -- неделя отбрасывала октябрьскую - вкладка писала «в календаре
                    -- нет», хотя 7 октября оно было (пользователь 24 сентября).
                    local id = tostring(e.eventID or e.title) .. "@"
                        .. tostring(EventStamp(e.startTime) or (monthOffset .. "/" .. day))
                    if not seen[id] then
                        seen[id] = true
                        local s = EventStamp(e.startTime)
                        local title = e.title
                        local tier = TitleToTier(title)
                        if (not tier) and C_Calendar.GetHolidayInfo and monthOffset <= 1 then
                            local hol = C_Calendar.GetHolidayInfo(monthOffset, day, i)
                            if hol then
                                if hol.name then title = hol.name end
                                tier = TitleToTier(hol.name or "") or TitleToTier(hol.description or "")
                            end
                        end
                        if s and s > nowStamp then
                            local rec = {
                                title = title,
                                startTime = e.startTime,
                                stamp = s,
                                tier = tier,
                            }
                            if not upcomingAny or s < upcomingAny.stamp then
                                upcomingAny = rec
                            end
                            if rec.tier and (not upcomingNamed or s < upcomingNamed.stamp) then
                                upcomingNamed = rec
                            end
                        end
                    end
                end
            end
        end
    end
    if shown and C_Calendar.SetAbsMonth then
        C_Calendar.SetAbsMonth(shown.month, shown.year)
    end
    nextEvent = upcomingNamed or upcomingAny
    scanning = false
end

-- Для проверок и отладки: прогнать разбор календаря и вернуть найденное.
function ns.ScanTimewalkCalendar()
    ScanCalendar()
    return nextEvent
end

local function AskCalendar()
    if calendarAsked then return end
    if C_Calendar and C_Calendar.OpenCalendar then
        calendarAsked = true
        C_Calendar.OpenCalendar()
    end
end

local function IsCurrentSeasonTier()
    if not EJ_GetCurrentTier or not EJ_GetNumTiers then return false end
    return EJ_GetCurrentTier() == EJ_GetNumTiers()
end

local function IsDungeonTab()
    if EncounterJournal_IsDungeonTabSelected and EncounterJournal then
        return EncounterJournal_IsDungeonTabSelected(EncounterJournal)
    end
    return true
end

local function EnsureChrome()
    local parent = EncounterJournal and EncounterJournal.instanceSelect
    if not parent then return end

    local scrollBox = parent.ScrollBox
    if scrollBox and not emptyPanel then
        emptyPanel = CreateFrame("Frame", nil, scrollBox)
        emptyPanel:SetPoint("CENTER")
        emptyPanel:SetSize(560, 220)
        emptyPanel:EnableMouse(false)
        emptyText = emptyPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        emptyText:SetPoint("CENTER")
        emptyText:SetWidth(540)
        emptyText:SetJustifyH("CENTER")
        emptyText:SetJustifyV("MIDDLE")
        emptyText:SetWordWrap(true)
        emptyText:SetSpacing(10)
        local font, size, flags = emptyText:GetFont()
        if font and size then
            emptyText:SetFont(font, size * 2, flags)
        end
    end
end

local function UpdateSeasonMessage(active)
    EnsureChrome()
    if not SeasonOn() then
        if emptyPanel then emptyPanel:Hide() end
        return
    end
    local onSeason = EncounterJournal and EncounterJournal.instanceSelect
        and EncounterJournal.instanceSelect:IsShown()
        and IsCurrentSeasonTier() and IsDungeonTab()
    if not emptyPanel then return end
    if not onSeason or active then
        emptyPanel:Hide()
        return
    end
    local text
    if nextEvent then
        local which = ExpansionLabel(nextEvent.tier, nextEvent.title)
        text = ns.L("Сейчас нет Путешествия во времени") .. "\n\n"
            .. ns.L("Следующее: %s"):format(which) .. "\n"
            .. FormatDay(nextEvent.startTime)
    else
        text = ns.L("В календаре пока нет ближайшего Путешествия во времени")
    end
    emptyText:SetText(text)
    emptyPanel:Show()
end

local function FillTimewalkInstances(tier)
    local list = {}
    if not tier or not EJ_SelectTier or not EJ_GetInstanceByIndex then return list end
    EJ_SelectTier(tier)
    local i = 1
    while true do
        local id, name, desc, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(i, false)
        if not id then break end
        if name and not (name:find("ключ", 1, true) or name:find("keystone", 1, true)
            or name:find("Keystone", 1, true)) and HasTimewalk(id) then
            list[#list + 1] = {
                instanceID = id,
                name = name,
                description = desc,
                buttonImage = buttonImage,
                link = link,
                mapID = mapID,
            }
        end
        i = i + 1
    end
    return list
end

-- Вкладка текущего сезона: не ключи Midnight, а данжи текущей недели.
-- Список пересобираем здесь же, иначе игра уже нарисовала ключи.
local function ReplaceSeasonList()
    if not SeasonOn() then
        if emptyPanel then emptyPanel:Hide() end
        return
    end
    if not IsCurrentSeasonTier() or not IsDungeonTab() then
        UpdateSeasonMessage(nil)
        return
    end
    local selectFrame = EncounterJournal and EncounterJournal.instanceSelect
    local scrollBox = selectFrame and selectFrame.ScrollBox
    if not scrollBox or not scrollBox.SetDataProvider or not CreateDataProvider then
        return
    end

    local active = GetActiveTimewalk()
    local dataProvider = CreateDataProvider()
    if active and active.tier then
        local saved = EJ_GetCurrentTier()
        local list = FillTimewalkInstances(active.tier)
        if saved then EJ_SelectTier(saved) end
        for i = 1, #list do
            dataProvider:Insert(list[i])
        end
    end
    scrollBox:Show()
    scrollBox:SetDataProvider(dataProvider)
    UpdateSeasonMessage(active)
end

local function Setup()
    if hooked or not EncounterJournal then return end
    hooked = true

    local prev = EncounterJournal.localizeInstanceButton
    EncounterJournal.localizeInstanceButton = function(button)
        if prev then prev(button) end
        Stamp(button)
    end

    if EncounterJournal_ListInstances then
        hooksecurefunc("EncounterJournal_ListInstances", function()
            if replacing then return end
            replacing = true
            ReplaceSeasonList()
            StampVisible()
            replacing = false
        end)
    end

    local scrollBox = EncounterJournal.instanceSelect and EncounterJournal.instanceSelect.ScrollBox
    if scrollBox and scrollBox.RegisterCallback then
        scrollBox:RegisterCallback("OnAcquiredFrame", function(_, frame)
            Stamp(frame)
        end)
    end

    EnsureChrome()
    if SeasonOn() then AskCalendar() end
end

local function LoadJournalAddon()
    if C_AddOns and C_AddOns.LoadAddOn then
        C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
    elseif LoadAddOn then
        LoadAddOn("Blizzard_EncounterJournal")
    end
    return EJ_SelectInstance and EJ_GetInstanceByIndex
end

local function StripColor(s)
    if type(s) ~= "string" then return s end
    return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1"))
end

local function LootAt(index)
    local C = C_EncounterJournal
    if C and C.GetLootInfoByIndex then
        local ok, info = pcall(C.GetLootInfoByIndex, index)
        if ok and type(info) == "table" and info.itemID then return info end
    end
    if EJ_GetLootInfoByIndex then
        local name, _, slot, armorType, itemID, link, encounterID = EJ_GetLootInfoByIndex(index)
        if itemID then
            return {
                name = name, slot = slot, armorType = armorType,
                itemID = itemID, link = link, encounterID = encounterID,
            }
        end
    end
end

local STAT_ORD = { "int", "agi", "str", "stam", "crit", "haste", "iskus", "vers" }

-- Журнал красит ссылку «|cnIQ3:|Hitem:…|h[имя]|h|r». С такой строки
-- клиент не отдаёт ни уровень, ни статы — «ур?» и «статов нет», хотя имя
-- уже есть. На скан — голая «|Hitem:id:хвост|h|r». Тултип из таймера
-- иногда пустой: дыры закрывает C_Item.GetItemStats той же ссылки.
local STAT_FROM_API = {
    ITEM_MOD_STRENGTH_SHORT = "str",
    ITEM_MOD_AGILITY_SHORT = "agi",
    ITEM_MOD_INTELLECT_SHORT = "int",
    ITEM_MOD_STAMINA_SHORT = "stam",
    ITEM_MOD_CRIT_RATING_SHORT = "crit",
    ITEM_MOD_HASTE_RATING_SHORT = "haste",
    ITEM_MOD_MASTERY_RATING_SHORT = "iskus",
    ITEM_MOD_VERSATILITY = "vers",
    ITEM_MOD_VERSATILITY_SHORT = "vers",
    ITEM_MOD_CR_VERSATILITY_SHORT = "vers",
    ITEM_MOD_STRENGTH = "str",
    ITEM_MOD_AGILITY = "agi",
    ITEM_MOD_INTELLECT = "int",
    ITEM_MOD_STAMINA = "stam",
    ITEM_MOD_CRIT_RATING = "crit",
    ITEM_MOD_HASTE_RATING = "haste",
    ITEM_MOD_MASTERY_RATING = "iskus",
}

local function BareItem(link)
    if type(link) ~= "string" then return nil end
    return link:match("|H(item:[^|]+)|h") or (link:find("^item:") and link) or nil
end

local function StatsRaw(link)
    if not link or not C_Item.GetItemStats then return end
    local raw = C_Item.GetItemStats(link)
    if raw then
        for _ in pairs(raw) do return raw end
    end
    local bare = BareItem(link)
    if bare and bare ~= link then
        raw = C_Item.GetItemStats(bare)
        if raw then
            for _ in pairs(raw) do return raw end
        end
    end
    return raw
end

local function FillFromAPI(link, live)
    live = live or { stats = {}, socketTypes = {} }
    live.stats = live.stats or {}
    if not link then return live end
    if not live.ilvl then
        live.ilvl = C_Item.GetDetailedItemLevelInfo(link)
        if not live.ilvl then
            local bare = BareItem(link)
            if bare then live.ilvl = C_Item.GetDetailedItemLevelInfo(bare) end
        end
    end
    local raw = StatsRaw(link)
    if not raw then return live end
    local had
    for _ in pairs(live.stats) do had = true break end
    if not had then
        for k, v in pairs(raw) do
            local key = STAT_FROM_API[k]
            if key and type(v) == "number" and v ~= 0 then
                live.stats[key] = math.floor(v + 0.5)
            end
        end
    end
    if not live.sockets or live.sockets == 0 then
        local n = 0
        for k, v in pairs(raw) do
            if type(k) == "string" and k:sub(1, 12) == "EMPTY_SOCKET" then
                n = n + (tonumber(v) or 0)
            end
        end
        if n > 0 then live.sockets = n end
    end
    return live
end

-- Журнал в одном кадре отдаёт номер, а имя и ссылку — после загрузки
-- вещи в кэш клиента. Печатать сразу = «id N» и «статов нет» у почти всех,
-- хотя плитка в Путеводителе уже видна. Ждём кэш, ссылку без хвоста
-- достраиваем по соседней вещи того же данжа или той же экспансии.
local SKIP_LOC = {
    INVTYPE_NON_EQUIP_IGNORE = true,
    INVTYPE_BAG = true,
    INVTYPE_AMMO = true,
}

local dumpBusy

local function LinkTail(link)
    if type(link) ~= "string" then return nil end
    return link:match("|Hitem:%d+(:[^|]*)")
end

local function MakeLink(itemID, tail)
    if not itemID or not tail then return nil end
    return "|Hitem:" .. itemID .. tail .. "|h|r"
end

-- Номер после «1:28:» в хвосте ссылки журнала. Снято с живого дампа
-- 22 сентября, когда журнал ссылку отдал. Пандария в том дампе ссылок
-- не дала вовсе — 442, как у Катаклизма 441 и Дренора 738, соседние
-- по той же схеме. Индекс = номер вкладки журнала (Классика = 1).
local EXP_BONUS = { 2872, 778, 717, 441, 442, 738, 2949, 3595, 5383, 6053 }

local function PlayerTail(expBonus)
    if not expBonus then return nil end
    local level = UnitLevel("player") or 20
    local spec = 0
    if GetSpecialization and GetSpecializationInfo then
        local idx = GetSpecialization()
        if idx then spec = GetSpecializationInfo(idx) or 0 end
    end
    return string.format("::::::::%d:%d::22:1:3524:1:28:%d:::::", level, spec, expBonus)
end

local function BonusByTierName(tierName)
    local n = (tierName or ""):lower()
    if n:find("classic", 1, true) or n:find("классик", 1, true) then return 2872 end
    if n:find("burning", 1, true) or n:find("crusade", 1, true) then return 778 end
    if n:find("wrath", 1, true) or n:find("lich", 1, true) then return 717 end
    if n:find("cataclysm", 1, true) or n:find("катаклизм", 1, true) then return 441 end
    if n:find("mists", 1, true) or n:find("pandaria", 1, true) or n:find("пандар", 1, true) then return 442 end
    if n:find("draenor", 1, true) or n:find("warlords", 1, true) or n:find("дренор", 1, true) then return 738 end
    if n:find("legion", 1, true) or n:find("легион", 1, true) then return 2949 end
    if n:find("azeroth", 1, true) or n:find("азерот", 1, true) then return 3595 end
    if n:find("shadow", 1, true) or n:find("темных земель", 1, true) then return 5383 end
    if n:find("dragon", 1, true) or n:find("дракон", 1, true) then return 6053 end
end

-- Журнал отдаёт имя экспансии по-английски (Classic, Legion), а команду
-- пишут по-русски. Без таблицы синонимов `/tgf tw катаклизм` ничего не
-- находил и снимал все 67 данжей. Короткие ярлыки (bc, mop, sl) только
-- точное совпадение: иначе `bc` ищется внутри чужого имени.
local function Lower(s)
    if type(s) ~= "string" then return "" end
    s = (strlower and strlower(s) or s:lower())
    return s:gsub("ё", "е"):gsub("Ё", "е")
end

local TW_ERAS = {
    { ru = "Классика",         cmd = "классика",  words = { "classic", "классика", "классик", "класика" } },
    { ru = "Burning Crusade",  cmd = "bc",        words = { "burning crusade", "burning", "crusade", "tbc", "bc", "пылающий", "поход" } },
    { ru = "Гнев Короля-лича", cmd = "гнев",      words = { "wrath of the lich king", "wrath", "lich", "wotlk", "гнев", "лича", "лич" } },
    { ru = "Катаклизм",        cmd = "катаклизм", words = { "cataclysm", "cata", "катаклизм" } },
    { ru = "Пандария",         cmd = "пандария",  words = { "mists of pandaria", "pandaria", "mists", "mop", "пандария", "пандар" } },
    { ru = "Дренор",           cmd = "дренор",    words = { "warlords of draenor", "draenor", "warlords", "wod", "дренор", "вождей" } },
    { ru = "Легион",           cmd = "легион",    words = { "legion", "легион" } },
    { ru = "Битва за Азерот",  cmd = "азерот",    words = { "battle for azeroth", "azeroth", "bfa", "азерот", "битва" } },
    { ru = "Темные земли",     cmd = "темные",    words = { "shadowlands", "shadow", "sl", "темных земель", "темные", "земель" } },
    { ru = "Драконы",          cmd = "драконы",   words = { "dragonflight", "dragon", "df", "драконов", "дракон", "драконы" } },
}

-- Обычные данжи: те же эпохи плюс текущие вкладки журнала. Время Хроми
-- нужно старым экспансиям (Терраса магистров без него не того уровня);
-- текущим — нет.
local DJ_ERAS = {
    TW_ERAS[1], TW_ERAS[2], TW_ERAS[3], TW_ERAS[4], TW_ERAS[5],
    TW_ERAS[6], TW_ERAS[7], TW_ERAS[8], TW_ERAS[9], TW_ERAS[10],
    { ru = "The War Within", cmd = "война",   needsChromie = false, words = { "the war within", "war within", "tww", "война" } },
    { ru = "Midnight",       cmd = "полночь", needsChromie = false, words = { "midnight", "полночь" } },
}

local function FindEra(want, eras)
    local w = Lower(want)
    w = w:match("^%s*(.-)%s*$") or w
    if w == "" then return nil, "help" end
    if w == "все" or w == "all" then return nil, "all" end
    for i = 1, #eras do
        local era = eras[i]
        for j = 1, #era.words do
            local a = era.words[j]
            if w == a then return era, "ok" end
            if #w >= 4 and #a >= 4 and (a:find(w, 1, true) or w:find(a, 1, true)) then
                return era, "ok"
            end
        end
    end
    return nil, "unknown"
end

local function FindTwEra(want)
    return FindEra(want, TW_ERAS)
end

local function FindDjEra(want)
    return FindEra(want, DJ_ERAS)
end

local function TierInEra(tierName, era)
    local n = Lower(tierName)
    for i = 1, #era.words do
        local a = era.words[i]
        if #a >= 4 and n:find(a, 1, true) then return true end
    end
    return false
end

local function PrintTwHelp(unknown)
    if unknown and unknown ~= "" then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Не знаю экспансию «%s». Так:", unknown))
    else
        print(ns.L"|cFF86C7BD[TGF]|r Какую экспансию снять — одна команда, не все сразу:")
    end
    for i = 1, #TW_ERAS do
        print("|cFFFFD100[TGF]|r /tgf tw " .. TW_ERAS[i].cmd)
    end
    print(ns.L"|cFFFFD100[TGF]|r /tgf tw все  — все экспансии сразу")
end

local function PrintDjHelp(unknown)
    if unknown and unknown ~= "" then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Не знаю экспансию или данж «%s». Так:", unknown))
    else
        print(ns.L"|cFF86C7BD[TGF]|r Обычные подземелья — одно дополнение или один данж:")
    end
    for i = 1, #DJ_ERAS do
        print("|cFFFFD100[TGF]|r /tgf dj " .. DJ_ERAS[i].cmd)
    end
    print(ns.L"|cFFFFD100[TGF]|r /tgf dj кузня душ  — один данж")
    print(ns.L"|cFFFFD100[TGF]|r /tgf dj список  — чеклист по данжам")
    print(ns.L"|cFFFFD100[TGF]|r /tgf dj все  — все экспансии сразу")
    print(ns.L"|cFFFFD100[TGF]|r Старые экспансии снимай со включённым Временем Хроми той же эпохи: без него лут вроде Террасы магистров не того уровня.")
end

local function ChromieState()
    local on = false
    if C_PlayerInfo and C_PlayerInfo.IsPlayerInChromieTime then
        on = C_PlayerInfo.IsPlayerInChromieTime() and true or false
    end
    local id = UnitChromieTimeID and UnitChromieTimeID("player") or 0
    local name = ns.L"Настоящее"
    if on and C_ChromieTime and C_ChromieTime.GetChromieTimeExpansionOptions then
        local options = C_ChromieTime.GetChromieTimeExpansionOptions()
        if options then
            for i = 1, #options do
                local o = options[i]
                if o and o.id == id then
                    name = o.name or name
                    break
                end
            end
        end
    end
    return on, name, id
end

local function ChromieMatchesEra(era, chromieName)
    if not era then return false end
    local n = Lower(chromieName)
    for i = 1, #era.words do
        local a = era.words[i]
        if #a >= 4 and n:find(a, 1, true) then return true end
    end
    return false
end

local function EraNeedsChromie(era)
    if not era then return true end
    return era.needsChromie ~= false
end

local function IsKeystoneName(name)
    local n = Lower(name)
    return n:find("ключ", 1, true) or n:find("keystone", 1, true)
end

local function FillDungeonInstances(tier)
    local list = {}
    if not tier or not EJ_SelectTier or not EJ_GetInstanceByIndex then return list end
    EJ_SelectTier(tier)
    local i = 1
    while true do
        local id, name = EJ_GetInstanceByIndex(i, false)
        if not id then break end
        if name and not IsKeystoneName(name) then
            list[#list + 1] = { instanceID = id, name = name }
        end
        i = i + 1
    end
    return list
end

local function IsCataclysmTier(tierName)
    for i = 1, #DJ_ERAS do
        if DJ_ERAS[i].cmd == "катаклизм" and TierInEra(tierName, DJ_ERAS[i]) then
            return true
        end
    end
    return false
end

local function EraForTierName(tierName)
    for i = 1, #DJ_ERAS do
        if TierInEra(tierName, DJ_ERAS[i]) then return DJ_ERAS[i] end
    end
end

local function FindJournalDungeons(want)
    local w = Lower(want)
    w = w:match("^%s*(.-)%s*$") or w
    local exact, partial = {}, {}
    if w == "" or not EJ_GetNumTiers then return exact end
    local saved = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local numTiers = EJ_GetNumTiers() or 0
    for tier = 1, numTiers do
        local tierName = (EJ_GetTierInfo and select(1, EJ_GetTierInfo(tier))) or tostring(tier)
        local list = FillDungeonInstances(tier)
        for i = 1, #list do
            local inst = list[i]
            local n = Lower(inst.name)
            local hit = {
                instanceID = inst.instanceID,
                name = inst.name,
                tierName = tierName,
                tier = tier,
            }
            if n == w then
                exact[#exact + 1] = hit
            elseif #w >= 3 and n:find(w, 1, true) then
                partial[#partial + 1] = hit
            end
        end
    end
    if saved then EJ_SelectTier(saved) end
    if #exact > 0 then return exact end
    return partial
end

local function PrintDungeonChecklist()
    if not LoadJournalAddon() then
        print(ns.L"|cFFFFD100[TGF]|r Журнал подземелий недоступен.")
        return
    end
    local chromieOn, chromieName = ChromieState()
    local lines = {
        "# TrialGearFinder: чеклист обычных подземелий",
        "# сложность обычная; старые экспансии — со Временем Хроми той же эпохи",
        "# Катаклизм — только аксессуары: отображение как у шлема Кузни Душ",
        "# Кузня Душ — шлем (Шлем удара духа): тултип врёт вверх",
        chromieOn and ("# время хроми сейчас: " .. chromieName) or "# время хроми сейчас: выкл",
        "",
    }
    local saved = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local numTiers = EJ_GetNumTiers and EJ_GetNumTiers() or 0
    local n = 0
    for tier = 1, numTiers do
        local tierName = (EJ_GetTierInfo and select(1, EJ_GetTierInfo(tier))) or tostring(tier)
        local list = FillDungeonInstances(tier)
        if #list > 0 then
            local head = tierName
            if IsCataclysmTier(tierName) then
                head = head .. " — только аксессуары"
            end
            lines[#lines + 1] = head
            for i = 1, #list do
                local note = ""
                local ln = Lower(list[i].name)
                if ln:find("кузня душ", 1, true) or ln:find("forge of souls", 1, true) then
                    note = "  — шлем, тултип врёт"
                end
                lines[#lines + 1] = "[ ] " .. list[i].name .. note
                n = n + 1
            end
            lines[#lines + 1] = ""
        end
    end
    if saved then EJ_SelectTier(saved) end
    print(string.format(ns.L"|cFFFFD100[TGF]|r Чеклист: %d данжей. Скопировать: Ctrl+C в открывшемся окне.", n))
    if ns.ShowCopyText then
        ns.ShowCopyText(table.concat(lines, "\n"), #lines)
    end
end

local function NormalDifficultyID()
    local D = DifficultyUtil and DifficultyUtil.ID
    return (D and D.DungeonNormal) or 1
end

local function SelectedHasNormal(diff)
    if EJ_IsValidInstanceDifficulty then
        return EJ_IsValidInstanceDifficulty(diff)
    end
    local C = C_EncounterJournal
    if C and C.InstanceHasDifficultyID then
        return C.InstanceHasDifficultyID(diff)
    end
    return true
end

-- Общая догрузка кэша и окно копирования: и `/tgf tw`, и `/tgf dj`.
local function BeginDumpScan(ctx)
    local rows = ctx.rows
    local tails = ctx.tails
    local opts = ctx.opts
    dumpBusy = true
    print(string.format(ns.L"|cFFFFD100[TGF]|r Гружу %d вещей из журнала, подожди несколько секунд.", #rows))

    local left = #rows
    local finishing
    local function Finish()
        if not dumpBusy or finishing then return end
        finishing = true

        local function RowTail(row)
            return LinkTail(row.link)
                or tails[row.dungeon]
                or tails["tier:" .. (row.tierName or "")]
                or PlayerTail(EXP_BONUS[row.tier] or BonusByTierName(row.tierName))
        end

        local function ScanOne(row)
            local tail = RowTail(row)
            local link = MakeLink(row.itemID, tail)
            row.built = link
            local live = (opts.scan and link and opts.scan(link)) or { stats = {}, socketTypes = {} }
            live = FillFromAPI(link, live)
            row.live = live
        end

        local function HasRowStats(row)
            local st = row.live and row.live.stats
            if not st then return false end
            for o = 1, #STAT_ORD do
                if st[STAT_ORD[o]] then return true end
            end
            return false
        end

        local function PrintOut()
            dumpBusy = false
            local lines = {}
            for h = 1, #ctx.headers do
                lines[h] = ctx.headers[h]
            end
            local nOk = 0
            for r = 1, #rows do
                local row = rows[r]
                local live = row.live or { stats = {}, socketTypes = {} }
                local sp = {}
                for o = 1, #STAT_ORD do
                    local k = STAT_ORD[o]
                    if live.stats and live.stats[k] then
                        sp[#sp + 1] = k .. "=" .. live.stats[k]
                    end
                end
                if #sp > 0 then nOk = nOk + 1 end
                local name = row.name
                    or (C_Item.GetItemNameByID and C_Item.GetItemNameByID(row.itemID))
                    or ("id " .. row.itemID)
                lines[#lines + 1] = string.format(
                    "%s | %s | %s | %s | %d | %s | ур%s | %s | гнёзд %d",
                    row.tierName or "?",
                    row.dungeon or "?",
                    (row.boss ~= "" and row.boss) or "—",
                    name,
                    row.itemID,
                    row.equipLoc,
                    tostring(live.ilvl or "?"),
                    (#sp > 0) and table.concat(sp, " ") or "статов нет",
                    live.sockets or #(live.socketTypes or {}))
                if row.built then
                    lines[#lines + 1] = "ссылка: " .. row.built:gsub("|", "!")
                end
            end
            lines[#lines + 1] = string.format(
                "# данжей %d, добычи %d, уже в базе %d, новых %d, со статами %d",
                ctx.nDungeons, ctx.nLooted, ctx.nKnown, #rows, nOk)
            print(string.format(ns.L(ctx.resultL), #rows, ctx.nLooted))
            if ns.ShowCopyText then
                ns.ShowCopyText(table.concat(lines, "\n"), #lines)
            end
        end

        local function RetryHoles()
            local holes = {}
            for r = 1, #rows do
                if rows[r].built and not HasRowStats(rows[r]) then
                    holes[#holes + 1] = r
                end
            end
            if #holes == 0 then
                PrintOut()
                return
            end
            local h = 1
            local function StepH()
                local stop = math.min(h + 7, #holes)
                while h <= stop do
                    ScanOne(rows[holes[h]])
                    h = h + 1
                end
                if h <= #holes then
                    C_Timer.After(0, StepH)
                    return
                end
                PrintOut()
            end
            C_Timer.After(0.4, StepH)
        end

        local function AfterLinkLoad()
            local i = 1
            local function Step()
                local stop = math.min(i + 19, #rows)
                while i <= stop do
                    ScanOne(rows[i])
                    i = i + 1
                end
                if i <= #rows then
                    C_Timer.After(0, Step)
                    return
                end
                RetryHoles()
            end
            Step()
        end

        local pending, started = 0, false
        local function Go()
            if started then return end
            started = true
            AfterLinkLoad()
        end
        for r = 1, #rows do
            local row = rows[r]
            local link = MakeLink(row.itemID, RowTail(row))
            row.built = link
            if link and Item and Item.CreateFromItemLink then
                local it = Item:CreateFromItemLink(link)
                if it and it.ContinueOnItemLoad
                    and not (it.IsItemDataCached and it:IsItemDataCached()) then
                    pending = pending + 1
                    it:ContinueOnItemLoad(function()
                        pending = pending - 1
                        if pending <= 0 then Go() end
                    end)
                end
            end
        end
        if pending == 0 then
            Go()
        elseif C_Timer and C_Timer.After then
            C_Timer.After(6, Go)
        else
            Go()
        end
    end

    local function Loaded(row)
        if row.done then return end
        row.done = true
        if not row.name and C_Item.GetItemNameByID then
            row.name = C_Item.GetItemNameByID(row.itemID)
        end
        left = left - 1
        if left <= 0 then Finish() end
    end

    for i = 1, #rows do
        local row = rows[i]
        if C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, row.itemID)
        end
        local item = Item and Item.CreateFromItemID and Item:CreateFromItemID(row.itemID)
        if item and item.IsItemDataCached and item:IsItemDataCached() then
            Loaded(row)
        elseif item and item.ContinueOnItemLoad then
            item:ContinueOnItemLoad(function() Loaded(row) end)
        else
            Loaded(row)
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(8, function()
            if not dumpBusy then return end
            for i = 1, #rows do Loaded(rows[i]) end
        end)
    elseif left > 0 then
        Finish()
    end
end

-- Добыча Путешествия во времени из журнала приключений.
-- Игра сама знает, у какого данжа есть эта сложность: тот же признак,
-- что у значка на плитке. Статы — тултип ссылки журнала на этом персонаже,
-- не армори; эталон по-прежнему слепок гильдии. Уже заведённые вещи
-- пропускаем: дамп — дыры, а не вся база заново.
-- Без слова печатает список экспансий и ничего не снимает: полный прогон
-- на 67 данжах оставляет дыры в кэше. Одна экспансия — `/tgf tw классика`.
function ns.DumpTimewalkLoot(opts)
    opts = opts or {}
    local era, how = FindTwEra(opts.want)
    if how == "help" then
        PrintTwHelp()
        return
    end
    if how == "unknown" then
        PrintTwHelp(opts.want)
        return
    end
    if dumpBusy then
        print(ns.L"|cFFFFD100[TGF]|r Дамп уже идёт, подожди.")
        return
    end
    if not LoadJournalAddon() then
        print(ns.L"|cFFFFD100[TGF]|r Журнал подземелий недоступен.")
        return
    end
    if era then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Снимаю %s.", era.ru))
    else
        print(ns.L"|cFFFFD100[TGF]|r Снимаю все экспансии.")
    end

    local savedTier = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local savedDiff = EJ_GetDifficulty and EJ_GetDifficulty()
    local savedClass, savedSpec
    if EJ_GetLootFilter then savedClass, savedSpec = EJ_GetLootFilter() end

    if EJ_SetLootFilter then pcall(EJ_SetLootFilter, 0, 0) end
    if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
        C_EncounterJournal.ResetSlotFilter()
    end

    local dungeonTW = TimewalkDifficultyIDs()

    local rows, seen = {}, {}
    local tails = {}
    local nKnown, nDungeons, nLooted = 0, 0, 0

    local function RememberTail(dungeon, tierName, link)
        local tail = LinkTail(link)
        if not tail then return end
        if dungeon and not tails[dungeon] then tails[dungeon] = tail end
        local tk = "tier:" .. (tierName or "")
        if not tails[tk] then tails[tk] = tail end
    end

    local function TakeLoot(dungeon, tierName, tier)
        local n = (EJ_GetNumLoot and EJ_GetNumLoot()) or 0
        for i = 1, n do
            local info = LootAt(i)
            if info and info.itemID and not seen[info.itemID] then
                seen[info.itemID] = true
                nLooted = nLooted + 1
                if opts.known and opts.known(info.itemID) then
                    nKnown = nKnown + 1
                else
                    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(info.itemID)
                    if equipLoc and equipLoc ~= "" and not SKIP_LOC[equipLoc] then
                        local boss = ""
                        if info.encounterID and EJ_GetEncounterInfo then
                            boss = StripColor(select(1, EJ_GetEncounterInfo(info.encounterID)) or "") or ""
                        end
                        if info.link then RememberTail(dungeon, tierName, info.link) end
                        rows[#rows + 1] = {
                            tierName = tierName,
                            tier = tier,
                            dungeon = dungeon,
                            boss = boss,
                            itemID = info.itemID,
                            name = StripColor(info.name),
                            link = info.link,
                            equipLoc = equipLoc,
                        }
                    end
                end
            end
        end
        return n
    end

    local numTiers = EJ_GetNumTiers and EJ_GetNumTiers() or 0
    for tier = 1, numTiers do
        local tierName = (EJ_GetTierInfo and select(1, EJ_GetTierInfo(tier))) or tostring(tier)
        if not era or TierInEra(tierName, era) then
            local list = FillTimewalkInstances(tier)
            for d = 1, #list do
                local inst = list[d]
                EJ_SelectInstance(inst.instanceID)
                if EJ_SetDifficulty then EJ_SetDifficulty(dungeonTW) end
                if SelectedHasTimewalk() then
                    nDungeons = nDungeons + 1
                    if EJ_SelectEncounter then pcall(EJ_SelectEncounter, 0) end
                    local got = TakeLoot(inst.name, tierName, tier)
                    if got == 0 and EJ_GetEncounterInfoByIndex then
                        local e = 1
                        while true do
                            local encName, _, encID = EJ_GetEncounterInfoByIndex(e)
                            if not encName then break end
                            if encID and EJ_SelectEncounter then EJ_SelectEncounter(encID) end
                            TakeLoot(inst.name, tierName, tier)
                            e = e + 1
                        end
                    end
                end
            end
        end
    end

    if savedClass and EJ_SetLootFilter then EJ_SetLootFilter(savedClass, savedSpec or 0) end
    if savedTier and EJ_SelectTier then EJ_SelectTier(savedTier) end
    if savedDiff and EJ_SetDifficulty then pcall(EJ_SetDifficulty, savedDiff) end

    if nDungeons == 0 then
        if era then
            print(string.format(ns.L"|cFFFFD100[TGF]|r В журнале нет подземелий Путешествия во времени для «%s».", era.ru))
        else
            print(ns.L"|cFFFFD100[TGF]|r В журнале нет подземелий с Путешествием во времени.")
        end
        return
    end
    if nLooted == 0 then
        print(ns.L"|cFFFFD100[TGF]|r Журнал не отдал добычу. Открой Путеводитель приключений и повтори /tgf tw.")
        return
    end
    if #rows == 0 then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Путешествие во времени: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне.",
            0, nLooted))
        return
    end

    BeginDumpScan({
        rows = rows,
        tails = tails,
        nDungeons = nDungeons,
        nLooted = nLooted,
        nKnown = nKnown,
        opts = opts,
        headers = {
            "# TrialGearFinder: добыча Путешествия во времени из журнала",
            "# статы — тултип ссылки журнала на этом персонаже, не армори",
            "# только вещи, которых нет в Data.lua, BiS_Community.lua и Timewalk.lua",
        },
        resultL = "|cFFFFD100[TGF]|r Путешествие во времени: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне.",
    })
end

-- Обычные подземелья журнала, сложность обычная. Не путешествие во времени.
-- Статы — тултип ссылки на этом персонаже. Старые экспансии без Времени
-- Хроми той же эпохи снимают неверный уровень (Терраса магистров).
-- Имя данжа — один инстанс; «список» — чеклист. Катаклизм — только аксессуары.
function ns.DumpDungeonLoot(opts)
    opts = opts or {}
    local want = Lower(opts.want or "")
    want = want:match("^%s*(.-)%s*$") or want
    if want == "список" or want == "list" or want == "чек" or want == "чеклист" then
        PrintDungeonChecklist()
        return
    end
    local era, how = FindDjEra(opts.want)
    local wantInst
    if how == "unknown" then
        if not LoadJournalAddon() then
            print(ns.L"|cFFFFD100[TGF]|r Журнал подземелий недоступен.")
            return
        end
        local matches = FindJournalDungeons(opts.want)
        if #matches == 0 then
            PrintDjHelp(opts.want)
            return
        end
        if #matches > 1 then
            print(string.format(ns.L"|cFFFFD100[TGF]|r Подходит несколько, уточни (%d):", #matches))
            for i = 1, #matches do
                print("|cFFFFD100[TGF]|r /tgf dj " .. matches[i].name)
            end
            return
        end
        wantInst = matches[1]
        era = EraForTierName(wantInst.tierName)
        how = "dungeon"
    end
    if how == "help" then
        PrintDjHelp()
        return
    end
    if how == "unknown" then
        PrintDjHelp(opts.want)
        return
    end
    if dumpBusy then
        print(ns.L"|cFFFFD100[TGF]|r Дамп уже идёт, подожди.")
        return
    end
    if not LoadJournalAddon() then
        print(ns.L"|cFFFFD100[TGF]|r Журнал подземелий недоступен.")
        return
    end

    local chromieOn, chromieName = ChromieState()
    if how == "all" then
        print(ns.L"|cFFFFD100[TGF]|r Время Хроми одно на все экспансии — снимай по одной, иначе чужие данжи будут не того уровня.")
    elseif era and EraNeedsChromie(era) then
        if not chromieOn then
            print(string.format(ns.L"|cFFFFD100[TGF]|r Время Хроми выкл. Для «%s» включи историю этой эпохи, иначе лут вроде Террасы магистров не того уровня.", era.ru))
        elseif not ChromieMatchesEra(era, chromieName) then
            print(string.format(ns.L"|cFFFFD100[TGF]|r Снимаю %s, а Время Хроми — %s. Включи историю этой эпохи.", era.ru, chromieName))
        end
    end

    if how == "dungeon" and wantInst then
        if era then
            print(string.format(ns.L"|cFFFFD100[TGF]|r Данж: %s (%s).", wantInst.name, era.ru))
        else
            print(string.format(ns.L"|cFFFFD100[TGF]|r Данж: %s.", wantInst.name))
        end
    elseif era then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Снимаю %s.", era.ru))
    else
        print(ns.L"|cFFFFD100[TGF]|r Снимаю все экспансии.")
    end
    if chromieOn then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Время Хроми: %s.", chromieName))
    else
        print(ns.L"|cFFFFD100[TGF]|r Время Хроми: Настоящее.")
    end

    local savedTier = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local savedDiff = EJ_GetDifficulty and EJ_GetDifficulty()
    local savedClass, savedSpec
    if EJ_GetLootFilter then savedClass, savedSpec = EJ_GetLootFilter() end

    if EJ_SetLootFilter then pcall(EJ_SetLootFilter, 0, 0) end
    if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
        C_EncounterJournal.ResetSlotFilter()
    end

    local dungeonNormal = NormalDifficultyID()
    local rows, seen = {}, {}
    local tails = {}
    local nKnown, nDungeons, nLooted, nNoNormal, nCataSkip = 0, 0, 0, 0, 0

    local function RememberTail(dungeon, tierName, link)
        local tail = LinkTail(link)
        if not tail then return end
        if dungeon and not tails[dungeon] then tails[dungeon] = tail end
        local tk = "tier:" .. (tierName or "")
        if not tails[tk] then tails[tk] = tail end
    end

    local function TakeLoot(dungeon, tierName, tier)
        local cataTrinketsOnly = IsCataclysmTier(tierName)
        local n = (EJ_GetNumLoot and EJ_GetNumLoot()) or 0
        for i = 1, n do
            local info = LootAt(i)
            if info and info.itemID and not seen[info.itemID] then
                seen[info.itemID] = true
                nLooted = nLooted + 1
                if opts.known and opts.known(info.itemID) then
                    nKnown = nKnown + 1
                else
                    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(info.itemID)
                    if equipLoc and equipLoc ~= "" and not SKIP_LOC[equipLoc] then
                        if cataTrinketsOnly and equipLoc ~= "INVTYPE_TRINKET" then
                            nCataSkip = nCataSkip + 1
                        else
                            local boss = ""
                            if info.encounterID and EJ_GetEncounterInfo then
                                boss = StripColor(select(1, EJ_GetEncounterInfo(info.encounterID)) or "") or ""
                            end
                            if info.link then RememberTail(dungeon, tierName, info.link) end
                            rows[#rows + 1] = {
                                tierName = tierName,
                                tier = tier,
                                dungeon = dungeon,
                                boss = boss,
                                itemID = info.itemID,
                                name = StripColor(info.name),
                                link = info.link,
                                equipLoc = equipLoc,
                            }
                        end
                    end
                end
            end
        end
        return n
    end

    local numTiers = EJ_GetNumTiers and EJ_GetNumTiers() or 0
    for tier = 1, numTiers do
        local tierName = (EJ_GetTierInfo and select(1, EJ_GetTierInfo(tier))) or tostring(tier)
        if not era or TierInEra(tierName, era) then
            local list = FillDungeonInstances(tier)
            for d = 1, #list do
                local inst = list[d]
                if not wantInst or inst.instanceID == wantInst.instanceID then
                    EJ_SelectInstance(inst.instanceID)
                    if EJ_SetDifficulty then EJ_SetDifficulty(dungeonNormal) end
                    if SelectedHasNormal(dungeonNormal) then
                        nDungeons = nDungeons + 1
                        if EJ_SelectEncounter then pcall(EJ_SelectEncounter, 0) end
                        local got = TakeLoot(inst.name, tierName, tier)
                        if got == 0 and EJ_GetEncounterInfoByIndex then
                            local e = 1
                            while true do
                                local encName, _, encID = EJ_GetEncounterInfoByIndex(e)
                                if not encName then break end
                                if encID and EJ_SelectEncounter then EJ_SelectEncounter(encID) end
                                TakeLoot(inst.name, tierName, tier)
                                e = e + 1
                            end
                        end
                    else
                        nNoNormal = nNoNormal + 1
                    end
                end
            end
        end
    end

    if savedClass and EJ_SetLootFilter then EJ_SetLootFilter(savedClass, savedSpec or 0) end
    if savedTier and EJ_SelectTier then EJ_SelectTier(savedTier) end
    if savedDiff and EJ_SetDifficulty then pcall(EJ_SetDifficulty, savedDiff) end

    if nNoNormal > 0 then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Без обычной сложности пропущено данжей: %d.", nNoNormal))
    end
    if nCataSkip > 0 then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Катаклизм: броню и оружие не снимал, только аксессуары (%d пропущено).", nCataSkip))
    end

    if nDungeons == 0 then
        if how == "dungeon" and wantInst then
            print(string.format(ns.L"|cFFFFD100[TGF]|r В журнале нет обычной сложности у «%s».", wantInst.name))
        elseif era then
            print(string.format(ns.L"|cFFFFD100[TGF]|r В журнале нет обычных подземелий для «%s».", era.ru))
        else
            print(ns.L"|cFFFFD100[TGF]|r В журнале нет обычных подземелий.")
        end
        return
    end
    if nLooted == 0 then
        print(ns.L"|cFFFFD100[TGF]|r Журнал не отдал добычу. Открой Путеводитель приключений и повтори /tgf dj.")
        return
    end
    if #rows == 0 then
        print(string.format(ns.L"|cFFFFD100[TGF]|r Обычные подземелья: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне.",
            0, nLooted))
        return
    end

    local chromieLine
    if chromieOn then
        chromieLine = "# время хроми: " .. chromieName
    else
        chromieLine = "# время хроми: выкл"
    end

    BeginDumpScan({
        rows = rows,
        tails = tails,
        nDungeons = nDungeons,
        nLooted = nLooted,
        nKnown = nKnown,
        opts = opts,
        headers = {
            "# TrialGearFinder: добыча обычных подземелий из журнала",
            "# сложность обычная, не путешествие во времени",
            "# статы — тултип ссылки журнала на этом персонаже, не армори",
            chromieLine,
            "# Катаклизм — в базу только аксессуары (отображение как у шлема Кузни Душ)",
            "# Кузня Душ — шлем (Шлем удара духа): тултип врёт вверх",
            "# только вещи, которых нет в Data.lua, BiS_Community.lua и Timewalk.lua",
        },
        resultL = "|cFFFFD100[TGF]|r Обычные подземелья: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне.",
    })
end

-- Параметры аддона: тумблеры значка и текущего сезона. Журнал уже открыт —
-- пересобрать список, не ждать /reload.
function ns.RefreshJournal()
    if SeasonOn() then AskCalendar() end
    StampVisible()
    local selectFrame = EncounterJournal and EncounterJournal.instanceSelect
    if selectFrame and selectFrame:IsShown() and EncounterJournal_ListInstances then
        EncounterJournal_ListInstances()
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
loader:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addonName and name ~= "Blizzard_EncounterJournal" then return end
        if _G.EncounterJournal then
            Setup()
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(5, function()
            if SeasonOn() then AskCalendar() end
        end)
    elseif event == "CALENDAR_UPDATE_EVENT_LIST" then
        ScanCalendar()
        if EncounterJournal and EncounterJournal:IsShown() and EncounterJournal.instanceSelect
            and EncounterJournal.instanceSelect:IsShown() then
            if not replacing then
                replacing = true
                ReplaceSeasonList()
                StampVisible()
                replacing = false
            end
        else
            UpdateSeasonMessage(GetActiveTimewalk())
        end
    end
end)
