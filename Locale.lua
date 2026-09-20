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
