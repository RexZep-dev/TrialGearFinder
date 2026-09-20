-- Locale.lua - язык интерфейса аддона.
--
-- Строки в коде написаны по-русски, и русский текст сам служит ключом: нет
-- перевода - вернётся русская строка, и окно всё равно соберётся. Поэтому
-- новый текст можно писать в коде как раньше, а перевод дописывать сюда.
--
-- Язык выбирается в игровых Параметрах (раздел Trial Gear Finder): "Как в игре"
-- берёт язык клиента, остальные два переключают принудительно. Смена требует
-- /reload - строки разложены по таблицам на загрузке, перерисовать их на лету
-- дешевле не выходит.

local ADDON_NAME, ns = ...

-- Перевод: [русская строка] = "English string".
local enUS = {
    -- Окно и его управление
    ["ПОИСК ШМОТА ДЛЯ ТРИАЛА"] = "TRIAL GEAR FINDER",
    ["Поиск"]              = "Search",
    ["Все"]                = "All",
    [": Все"]              = ": All",
    ["Слот"]               = "Slot",
    ["Класс"]              = "Class",
    ["Броня"]              = "Armor",
    ["Источник"]           = "Source",
    ["Предмет"]            = "Item",
    ["Крафт"]              = "Crafted",
    ["Фамильные вещи"]     = "Heirlooms",

    -- Характеристики: длинные и краткие подписи
    ["Сила"]               = "Strength",
    ["Ловкость"]           = "Agility",
    ["Интеллект"]          = "Intellect",
    ["Выносливость"]       = "Stamina",
    ["Критический удар"]   = "Critical Strike",
    ["Скорость"]           = "Haste",
    ["Искусность"]         = "Mastery",
    ["Универсальность"]    = "Versatility",
    ["Лов"]                = "Agi",
    ["Инт"]                = "Int",
    ["Вын"]                = "Sta",
    ["Крит"]               = "Crit",
    ["Скор"]               = "Haste",
    ["Иск"]                = "Mast",
    ["Уни"]                = "Vers",

    -- Гнёзда
    ["особое"]             = "meta",
    ["бесцветное"]         = "prismatic",
    ["красное"]            = "red",
    ["жёлтое"]             = "yellow",
    ["синее"]              = "blue",
    ["шестерёнка"]         = "cogwheel",
    ["владычества"]        = "domination",
    ["гнездо"]             = "socket",
    ["гнёзда"]             = "sockets",

    -- Окно BiS-сборок
    ["BiS-сборки"]         = "BiS Builds",
    ["ИТОГ СБОРКИ"]        = "BUILD TOTALS",
    ["Таланты"]            = "Talents",
    ["Кисти"]              = "Hands",
    ["Кольцо 1"]           = "Ring 1",
    ["Кольцо 2"]           = "Ring 2",
    ["Аксессуар 1"]        = "Trinket 1",
    ["Аксессуар 2"]        = "Trinket 2",
    ["— двуручное"]        = "— two-handed",
    ["[Танк]"]             = "[Tank]",
    ["[ДД]"]               = "[DPS]",
    ["[Хил]"]              = "[Healer]",
    ["Чара: "]             = "Enchant: ",
    ["Источник: "]         = "Source: ",
    ["Статы: "]            = "Stats: ",
    ["Статы (наш замер): "] = "Stats (our sim): ",
    ["Прок; в счёт идёт средний вклад за бой."] = "Proc; counted as its average contribution over the fight.",
    ["Пред-BiS от сообщества — не из гайда гильдии, но выбить может любой."] =
        "Community pre-BiS: not from the guild guide, but anyone can farm it.",
    ["|cffE06C5EПеребор: после 30% каждая единица рейтинга даёт на 10% меньше|r"] =
        "|cffE06C5EOvercap: past 30% each point of rating gives 10% less|r",
    ["  |cff5fd35fвыше гайда|r"]  = "  |cff5fd35fabove guide|r",
    ["  |cff9a9a9aнет в гайде|r"] = "  |cff9a9a9anot in guide|r",
    ["  |cff9a9a9aпред-BiS|r"]    = "  |cff9a9a9apre-BiS|r",
    ["  |cff3fc7ebТайм Волк|r"]   = "  |cff3fc7ebTimewalking|r",
    [" - чара: "]                 = " - enchant: ",
    [" (номера нет, в симе не учтена)"] = " (no id, not counted in the sim)",

    -- Главное окно: строка поиска, тумблеры, заголовки колонок
    ["Поиск"]              = "Search",
    ["Предмет"]            = "Item",
    ["Комьюнити"]          = "Community",
    ["Мин-Макс"]           = "Min-Max",

    -- Материал брони и типы источников
    ["Ткань"]              = "Cloth",
    ["Кожа"]               = "Leather",
    ["Кольчуга"]           = "Mail",
    ["Латы"]               = "Plate",
    ["Подземелье"]         = "Dungeon",
    ["Квест"]              = "Quest",
    ["Рарники"]            = "Rare mobs",
    ["Фамильные вещи"]     = "Heirlooms",
    ["%d ур."]             = "ilvl %d",

    -- Сообщения в чат
    ["|cFF86C7BD[TGF]|r Сначала открой окно BiS и выбери спек: /tgf bis"] =
        "|cFF86C7BD[TGF]|r Open the BiS window and pick a spec first: /tgf bis",
    ["|cFF86C7BD[TGF]|r Профиль SimC — в окне копирования: Ctrl+C и вставить в Advanced Sim на Raidbots."] =
        "|cFF86C7BD[TGF]|r The SimC profile is in the copy window: Ctrl+C, then paste into Advanced Sim on Raidbots.",

    -- Параметры
    ["Язык"]               = "Language",
    ["Как в игре"]         = "Same as game client",
    ["Русский"]            = "Russian",
    ["Английский"]         = "English",
    ["Язык окна и сообщений аддона. Смена языка применится после /reload."] =
        "Language of the addon window and messages. Takes effect after /reload.",
}

-- Названия слотов на русском. На других языках берём их у самой игры
-- (_G.INVTYPE_*), поэтому здесь только русская таблица: до появления этого
-- файла она была зашита в Core.lua и перебивала английский клиент.
local INVTYPE_RU = {
    INVTYPE_HEAD = "Голова",           INVTYPE_NECK = "Шея",
    INVTYPE_SHOULDER = "Плечи",        INVTYPE_CLOAK = "Спина",
    INVTYPE_CHEST = "Грудь",           INVTYPE_ROBE = "Грудь",
    INVTYPE_WRIST = "Запястья",        INVTYPE_HAND = "Кисти рук",
    INVTYPE_WAIST = "Пояс",            INVTYPE_LEGS = "Ноги",
    INVTYPE_FEET = "Ступни",           INVTYPE_FINGER = "Палец",
    INVTYPE_TRINKET = "Аксессуар",     INVTYPE_SHIELD = "Щит",
    INVTYPE_WEAPON = "Одноручное",     INVTYPE_2HWEAPON = "Двуручное",
    INVTYPE_WEAPONMAINHAND = "Правая рука",
    INVTYPE_WEAPONOFFHAND = "Левая рука",
    INVTYPE_HOLDABLE = "Левая рука",
    INVTYPE_RANGED = "Дальнобойное",   INVTYPE_RANGEDRIGHT = "Дальнобойное",
}

-- Названия классов на русском. На других языках берём у игры
-- (LOCALIZED_CLASS_NAMES_MALE). Ключи - те же, что в Data.lua.
local CLASS_RU = {
    WARRIOR = "Воин",             PALADIN = "Паладин",
    HUNTER = "Охотник",           ROGUE = "Разбойник",
    PRIEST = "Жрец",              DEATHKNIGHT = "Рыцарь смерти",
    SHAMAN = "Шаман",             MAGE = "Маг",
    WARLOCK = "Чернокнижник",     MONK = "Монах",
    DRUID = "Друид",              DEMONHUNTER = "Охотник на демонов",
    EVOKER = "Пробудитель",
}

-- Выбранный язык. Считается лениво: в момент выполнения этого файла
-- сохранённые настройки ещё не подгружены.
local resolved

local function Resolve()
    if resolved then return resolved end
    local saved = TrialGearFinderDB and TrialGearFinderDB.locale or "auto"
    resolved = (saved == "auto") and GetLocale() or saved
    return resolved
end

-- Перевод строки. Вызывается и как L("текст"), и как L"текст".
function ns.L(text)
    if Resolve() == "ruRU" then return text end
    return enUS[text] or text
end

-- Название слота: на русском - наше, на остальных языках - клиентское.
function ns.SlotName(invType)
    if Resolve() == "ruRU" then
        return INVTYPE_RU[invType] or _G[invType] or invType
    end
    return _G[invType] or INVTYPE_RU[invType] or invType
end

-- Название класса: на русском - наше, на остальных языках - клиентское.
function ns.ClassName(token)
    if Resolve() == "ruRU" then
        return CLASS_RU[token] or (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or token
    end
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or CLASS_RU[token] or token
end

-- Русский ли сейчас интерфейс. Нужно там, где текст разбирается, а не пишется.
function ns.IsRussian()
    return Resolve() == "ruRU"
end

-- Подписи, созданные при загрузке файлов, приходится переставлять заново:
-- сохранённый выбор языка становится виден только на ADDON_LOADED, а окно
-- собирается раньше. Сюда складываются функции, ставящие текст на место.
local pending = {}

function ns.OnLocaleReady(fn)
    pending[#pending + 1] = fn
    if resolved then fn() end
end

local function LocaleReady()
    resolved = nil          -- перечитать выбор: настройки уже загружены
    Resolve()
    for _, fn in ipairs(pending) do fn() end
end

-- ── Страница в игровых Параметрах ────────────────────────────────────────
local CHOICES = { "auto", "ruRU", "enUS" }

local function BuildOptions()
    if not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
    local L = ns.L

    local category = Settings.RegisterVerticalLayoutCategory("Trial Gear Finder")

    -- Значение хранится строкой, а выпадающий список отдаёт номер: держим
    -- переходник, иначе в сохранённых настройках окажется «2» без смысла.
    local function GetValue()
        local saved = TrialGearFinderDB and TrialGearFinderDB.locale or "auto"
        for i, v in ipairs(CHOICES) do if v == saved then return i end end
        return 1
    end

    local function SetValue(index)
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB.locale = CHOICES[index] or "auto"
    end

    local setting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_LOCALE",
        Settings.VarType.Number, L"Язык", 1, GetValue, SetValue)

    Settings.CreateDropdown(category, setting, function()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, L"Как в игре")
        container:Add(2, L"Русский")
        container:Add(3, L"Английский")
        return container:GetData()
    end, L"Язык окна и сообщений аддона. Смена языка применится после /reload.")

    Settings.RegisterAddOnCategory(category)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
    if name ~= ADDON_NAME then return end
    self:UnregisterEvent("ADDON_LOADED")
    LocaleReady()
    BuildOptions()
end)
