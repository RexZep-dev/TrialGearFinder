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
    ["Броня"]              = "Armor",
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

    ["Голова"]             = "Head",
    ["Шея"]                = "Neck",
    ["Плечи"]              = "Shoulder",
    ["Спина"]              = "Back",
    ["Грудь"]              = "Chest",
    ["Запястья"]           = "Wrist",
    ["Кисти рук"]          = "Hands",
    ["Пояс"]               = "Waist",
    ["Ноги"]               = "Legs",
    ["Ступни"]             = "Feet",
    ["Палец"]              = "Finger",
    ["Аксессуар"]          = "Trinket",
    ["Щит"]                = "Shield",
    ["Одноручное"]         = "One-Hand",
    ["Двуручное"]          = "Two-Hand",
    ["Правая рука"]        = "Main Hand",
    ["Левая рука"]         = "Off Hand",
    ["Дальнобойное"]       = "Ranged",

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

    -- Подземелья и места, откуда падают вещи. Названия официальные,
    -- сверены по английскому клиенту.
    ["Азжол-Неруб"] = "Azjol-Nerub",
    ["Аукенайские гробницы"] = "Auchenai Crypts",
    ["Ботаника"] = "The Botanica",
    ["Вершина Смерча"] = "The Vortex Pinnacle",
    ["Глубины Черной горы"] = "Blackrock Depths",
    ["Гробницы маны"] = "Mana-Tombs",
    ["Долина Призрачной Луны"] = "Shadowmoon Valley",
    ["Дренор (рарники, раз в день)"] = "Draenor (rares, once a day)",
    ["Железные доки"] = "Iron Docks",
    ["Зандалар (рарники, раз на персонажа)"] = "Zandalar (rares, once per character)",
    ["Инженерия"] = "Engineering",
    ["Крепость Темного Клыка"] = "Shadowfang Keep",
    ["Кузня Душ"] = "The Forge of Souls",
    ["Кузня Крови"] = "The Blood Furnace",
    ["Кул-Тирас (рарники, раз на персонажа)"] = "Kul Tiras (rares, once per character)",
    ["Логово Нелтариона"] = "Neltharion's Lair",
    ["Мародон"] = "Maraudon",
    ["Механар"] = "The Mechanar",
    ["Награнд"] = "Nagrand",
    ["Некроситет"] = "Scholomance",
    ["Нексус"] = "The Nexus",
    ["Нижетопь"] = "The Underbog",
    ["Низина Шолазар"] = "Sholazar Basin",
    ["Око Азшары"] = "Eye of Azshara",
    ["Окулус"] = "The Oculus",
    ["Очищение Стратхольма"] = "The Culling of Stratholme",
    ["Паровое подземелье"] = "The Steamvault",
    ["Разрушенные залы"] = "Hellfire Ramparts",
    ["Сетеккские залы"] = "Sethekk Halls",
    ["Старые предгорья Хилсбрада"] = "Old Hillsbrad Foothills",
    ["Стратхольм"] = "Stratholme",
    ["Темный лабиринт"] = "Shadow Labyrinth",
    ["Терраса Магистров"] = "Magisters' Terrace",
    ["Узилище"] = "The Slave Pens",
    ["Ульдаман"] = "Uldaman",
    ["Усадьба Уэйкрестов"] = "Waycrest Manor",
    ["Чумные каскады"] = "Plaguefall",
    ["Штурм Аметистовой крепости"] = "Assault on Violet Hold",
    ["Яма Сарона"] = "Pit of Saron",
    ["Залы Алого ордена"] = "Scarlet Halls",
    ["Стратхольм - Чёрный ход"] = "Stratholme - Service Entrance",
    ["Берега Пробуждения"] = "The Waking Shores",
    ["Грим Батол"] = "Grim Batol",
    ["Крепость Утгард"] = "Utgarde Keep",
    ["Лазурные Врата"] = "The Azure Vault",
    ["Лазурный Простор"] = "The Azure Span",
    ["Наступление Нохуда"] = "The Nokhud Offensive",
    ["Путешествие во времени: Катаклизм"] = "Timewalking: Cataclysm",
    ["Путешествие во времени: Пандария"] = "Timewalking: Pandaria",
    ["Равнины Он'ары"] = "Ohn'ahran Plains",
    ["Смертельная тризна"] = "De Other Side",
    ["Танаанские джунгли"] = "Tanaan Jungle",
    ["Театр Боли"] = "Theater of Pain",
    ["Ульдаман: наследие Тира"] = "Uldaman: Legacy of Tyr",
    ["Чертоги Покаяния"] = "Halls of Atonement",
    ["Зул'Драк — задание «Чемпион Амфитеатра Страданий»"] = "Zul'Drak - quest 'Champion of the Amphitheater'",
    ["Задание «Битва за Расколотый берег» — только Альянс"] = "Quest 'Battle for the Broken Shore' - Alliance only",
    ["Крафт (аукцион)"] = "Crafted (auction house)",
    ["уточнить"] = "to be confirmed",

    ["Щелчок - открыть окно"]     = "Click to open the window",
    ["Перетаскивание - двигать по краю карты"] = "Drag to move around the minimap",
    ["Щелчок - поставить метку на карте"] = "Click to put a marker on the map",
    ["Ctrl+щелчок - запомнить текущую метку для этого источника"] =
        "Ctrl-click to remember the current marker for this source",
    ["|cFFFFD100[TGF]|r Координаты для «%s» ещё не заданы."] =
        "|cFFFFD100[TGF]|r No coordinates set for %s yet.",
    ["|cFFFFD100[TGF]|r Сначала поставь метку на карте (Ctrl+щелчок по карте), потом Ctrl+щелчок по источнику."] =
        "|cFFFFD100[TGF]|r Put a marker on the map first (Ctrl-click the map), then Ctrl-click the source.",

    ["|cFFFFD100[TGF]|r Путешествие во времени: вход только через поиск подземелий, в неделю события."] =
        "|cFFFFD100[TGF]|r Timewalking: entered through the dungeon finder only, during the event week.",
    ["|cFFFFD100[TGF]|r На этой карте игра не разрешает ставить метку."] =
        "|cFFFFD100[TGF]|r The game does not allow markers on this map.",

    -- Параметры
    ["Язык"]               = "Language",
    ["Как в игре"]         = "Same as game client",
    ["Русский"]            = "Russian",
    ["Английский"]         = "English",
    ["Язык окна и сообщений аддона. Смена языка применится после /reload."] =
        "Language of the addon window and messages. Takes effect after /reload.",
    ["|cFFFFD100[TGF]|r Язык сохранён. Чтобы окно переключилось, сделай /reload."] =
        "|cFFFFD100[TGF]|r Language saved. /reload to switch the window.",
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

-- Строка приоритета из гайда: «Сила > Искусность >> Скорость». Разделители
-- значимы (>> значит «намного важнее»), поэтому переводим только названия
-- характеристик, а саму строку не разбираем. Длинные названия идут первыми,
-- иначе «Сила» съела бы кусок другого слова.
local STAT_WORDS = {
    "Критический удар", "Универсальность", "Выносливость", "Интеллект",
    "Искусность", "Ловкость", "Скорость", "Броня", "Сила",
}

function ns.TranslateStatLine(text)
    if Resolve() == "ruRU" then return text end
    for _, word in ipairs(STAT_WORDS) do
        local translated = enUS[word]
        if translated then text = text:gsub(word, translated) end
    end
    return text
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

    -- Цвет имени во вкладке Параметры → Модификации. Это не Title из .toc:
    -- список там строится из категории настроек. Cap20 красит так же.
    local category = Settings.RegisterVerticalLayoutCategory("|cffc0c0c0Trial Gear Finder|r")

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
        print(L"|cFFFFD100[TGF]|r Язык сохранён. Чтобы окно переключилось, сделай /reload.")
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
