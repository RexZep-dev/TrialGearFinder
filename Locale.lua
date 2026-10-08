-- Locale.lua - язык интерфейса аддона: только логика. Тексты лежат
-- в Locales\<язык>.lua, по файлу на язык (с 1 октября 2026, как у больших
-- аддонов).
--
-- В каждом языковом файле три таблицы:
--   L.КЛЮЧ = "текст"           - интерфейс: подписи, подсказки, сообщения;
--   D["русское название"] = .. - данные: подземелья, чары, заметки талантов;
--   N[номер вещи] = "текст"    - заметки к вещам.
-- Ключи интерфейса короткие и условные (COMPARE, FILTER_SLOT). Русский -
-- такой же язык, как остальные (Locales\ruRU.lua). Данные в базе аддона
-- написаны по-русски, поэтому D и N у русского пустые.
--
-- Загружается не всё: .toc берёт английский (запасной) и язык клиента -
-- Locales\[TextLocale].lua, подстановка игры с 11.2.0. Китаец не грузит
-- русский, русский не грузит китайский.
--
-- Нет строки в языке - берётся английская, нет и её - на экране сам ключ:
-- так пропуск сразу видно. Полнота проверяется l10n\check.js.

local ADDON_NAME, ns = ...
-- Общие данные ядра - модулям. «Сборки» и «Журнал» - отдельные аддоны
-- в списке аддонов (как у GatherMate2), и у каждого аддона свой `...`:
-- свою таблицу ядра модуль иначе не увидит. Одна глобальная ссылка.
TrialGearFinderNS = ns

local LOCALES = {}

-- Языковой файл берёт свои таблицы отсюда.
function ns.NewLocale(code)
    local t = LOCALES[code]
    if not t then
        t = { L = {}, D = {}, N = {} }
        LOCALES[code] = t
    end
    return t.L, t.D, t.N
end

-- Выбранный язык: как у игры или английский. Пока ADDON_LOADED не пришёл,
-- сохранённых настроек нет - выбор не запоминаем, иначе английский потом
-- не перебьёт кэш. Прежние значения настройки (ruRU, zhCN) - это «как в игре».
local resolved, loaded

local function Resolve()
    if loaded and resolved then return resolved end
    local saved = TrialGearFinderDB and TrialGearFinderDB.locale
    local value = (saved == "enUS") and "enUS" or GetLocale()
    if not LOCALES[value] or not next(LOCALES[value].L) then value = "enUS" end
    if loaded then resolved = value end
    return value
end

-- Строка интерфейса по ключу или nil.
local function Lookup(key)
    local cur = LOCALES[Resolve()]
    local v = cur and cur.L[key]
    if v then return v end
    local en = LOCALES.enUS
    return en and en.L[key]
end

-- Перевод строки интерфейса. Вызывается как L("КЛЮЧ"), L"КЛЮЧ" и L.КЛЮЧ.
ns.L = setmetatable({}, {
    __call = function(_, key) return Lookup(key) or key end,
    __index = function(_, key) return Lookup(key) or key end,
})

-- Перевод данных по их русскому названию: подземелья, чары, заметки талантов.
function ns.D(text)
    if not text then return text end
    local loc = Resolve()
    if loc == "ruRU" then return text end
    local cur = LOCALES[loc]
    local v = cur and cur.D[text]
    if v then return v end
    local en = LOCALES.enUS
    return en and en.D[text] or text
end

-- Выбранный язык аддона (не клиента): ruRU, enUS, zhCN, ...
function ns.AddonLang() return Resolve() end

-- Название слота по языку аддона, не клиента: принудительный английский на
-- русском клиенте иначе оставляет «Голова».
function ns.SlotName(invType)
    local v = invType and Lookup("SLOT_" .. invType:gsub("^INVTYPE_", ""))
    return v or _G[invType] or invType
end

-- Название класса по языку аддона. Ключи - те же, что в Data.lua.
function ns.ClassName(token)
    local v = token and Lookup("CLASS_" .. token)
    return v or (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or token
end

-- Название спека по языку аддона. Номера - те же, что у игры и в Talents.lua.
function ns.SpecName(specID)
    local v = specID and Lookup("SPEC_" .. specID)
    if v then return v end
    local name = specID and GetSpecializationInfoByID and select(2, GetSpecializationInfoByID(specID))
    return name or tostring(specID or "?")
end

-- Подпись колонки. Короткая и полная сила - разные ключи (COL_STR и
-- STRENGTH): «Strength» в узкую колонку не влезал (23 сентября).
function ns.ShortLabel(key) return ns.L(key) end

-- Заметка к вещи. Переведённая - по номеру вещи (N). Заметки Путешествия во
-- времени собраны из русского журнала по шаблону «падает с <босс>; <вещь>.
-- Журнал, <эпоха>, тир N»: имён боссов на других языках взять неоткуда, а
-- вещь и так названа в строке, поэтому переводятся эпоха и тир.
local EPOCH_KEY = {
    ["классика"] = "EPOCH_CLASSIC", ["BC"] = "EPOCH_BC", ["гнев"] = "EPOCH_WRATH",
    ["катаклизм"] = "EPOCH_CATA", ["Пандария"] = "EPOCH_MOP", ["Дренор"] = "EPOCH_WOD",
    ["Легион"] = "EPOCH_LEGION", ["BfA"] = "EPOCH_BFA", ["Темные земли"] = "EPOCH_SL",
    ["Драконы"] = "EPOCH_DF",
}

function ns.Note(text, itemID)
    if not text then return text end
    local loc = Resolve()
    if loc == "ruRU" then return text end
    local cur, en = LOCALES[loc], LOCALES.enUS
    local v = itemID and ((cur and cur.N[itemID]) or (en and en.N[itemID]))
    if v then return v end
    local epoch, tier = text:match("^падает с .-; .-%. Журнал, ([^,]+), тир (%d+)$")
    if epoch then
        return string.format(ns.L"TW_NOTE", EPOCH_KEY[epoch] and ns.L(EPOCH_KEY[epoch]) or epoch, tier)
    end
    return ns.D(text)
end

-- Язык КЛИЕНТА, не выбор в Параметрах. Нужно там, где разбирается тултип
-- предмета: карточка рисуется игрой, и на русском клиенте с английским окном
-- строки всё равно «+7 к ловкости». Если смотреть Resolve(), правка статов
-- молча отключается, а сверка копии пишет «отличается от базы».
function ns.IsRussian()
    return GetLocale() == "ruRU"
end

-- Строка приоритета из гайда: «Сила > Искусность >> Скорость». Разделители
-- значимы (>> значит «намного важнее»), поэтому переводятся только названия
-- характеристик. Длинные названия идут первыми, иначе «Сила» съела бы кусок
-- другого слова.
local STAT_WORDS = {
    { "Критический удар", "CRITICAL_STRIKE" }, { "Универсальность", "VERSATILITY" },
    { "Выносливость", "STAMINA" }, { "Интеллект", "INTELLECT" }, { "Искусность", "MASTERY" },
    { "Ловкость", "AGILITY" }, { "Скорость", "HASTE" }, { "Броня", "ARMOR" }, { "Сила", "STRENGTH" },
}

function ns.TranslateStatLine(text)
    if Resolve() == "ruRU" then return text end
    for _, w in ipairs(STAT_WORDS) do
        text = text:gsub(w[1], (ns.L(w[2]):gsub("%%", "%%%%")))
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
    loaded = true
    resolved = nil          -- перечитать выбор: настройки уже загружены
    Resolve()
    for _, fn in ipairs(pending) do fn() end
end

-- ── Страница в игровых Параметрах ────────────────────────────────────────
local CHOICES = { "auto", "enUS" }

local function BuildOptions()
    if not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
    local L = ns.L

    -- Цвет имени во вкладке Параметры → Модификации. Это не Title из .toc:
    -- список там строится из категории настроек. Cap20 красит так же.
    local category = Settings.RegisterVerticalLayoutCategory("|cffc0c0c0Trial Gear Finder|r")

    -- Значение хранится строкой, а выпадающий список отдаёт номер: держим
    -- переходник, иначе в сохранённых настройках окажется «2» без смысла.
    local function GetValue()
        return (TrialGearFinderDB and TrialGearFinderDB.locale == "enUS") and 2 or 1
    end

    local function SetValue(index)
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB.locale = CHOICES[index] or "auto"
        print(L"OPT_LANG_SAVED")
    end

    local setting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_LOCALE",
        Settings.VarType.Number, L"OPT_LANGUAGE", 1, GetValue, SetValue)

    Settings.CreateDropdown(category, setting, function()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, L"OPT_LANG_AUTO")
        container:Add(2, L"OPT_LANG_ENGLISH")
        return container:GetData()
    end, L"OPT_LANGUAGE_DESC")

    local function JournalFlag(key)
        return not TrialGearFinderDB or TrialGearFinderDB[key] ~= false
    end

    local function SetJournalFlag(key, value)
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB[key] = value and true or false
        if ns.RefreshJournal then ns.RefreshJournal() end
    end

    local badgeSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_JOURNAL_TW_BADGE",
        Settings.VarType.Boolean, L"OPT_TW_BADGE", true,
        function() return JournalFlag("journalTWBadge") end,
        function(value) SetJournalFlag("journalTWBadge", value) end)
    Settings.CreateCheckbox(category, badgeSetting, L"OPT_TW_BADGE_DESC")

    local seasonSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_JOURNAL_TW_SEASON",
        Settings.VarType.Boolean, L"OPT_TW_SEASON", true,
        function() return JournalFlag("journalTWSeason") end,
        function(value) SetJournalFlag("journalTWSeason", value) end)
    Settings.CreateCheckbox(category, seasonSetting, L"OPT_TW_SEASON_DESC")

    -- Отладка: команды разработчика (/tgf debug, ui, names, pins) и кнопка
    -- SimC в окне «Сборки». Тот же флаг, что у /tgf dev (пользователь 1 октября:
    -- «пусть работают, когда в параметрах стоит галочка»).
    local devSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_DEV",
        Settings.VarType.Boolean, L"OPT_DEBUG", false,
        function() return TrialGearFinderDB and TrialGearFinderDB.dev and true or false end,
        function(value)
            TrialGearFinderDB = TrialGearFinderDB or {}
            TrialGearFinderDB.dev = value and true or nil
            if ns.ApplyDevButtons then ns.ApplyDevButtons() end
            if ns.ApplyChatCopyButton then ns.ApplyChatCopyButton() end
        end)
    Settings.CreateCheckbox(category, devSetting, L"OPT_DEBUG_DESC")

    -- Модуль Forsaken Dungeons+ (3 октября): весь блок рейтинга в подсказке и
    -- отдельно таблица по ключам. Флаги - в ForsakenIOSettings модуля; модуль
    -- выключен в списке аддонов - галочки есть, но ничего не делают.
    local function FioFlag(key)
        return not ForsakenIOSettings or ForsakenIOSettings[key] ~= false
    end
    local function SetFioFlag(key, value)
        ForsakenIOSettings = ForsakenIOSettings or {}
        ForsakenIOSettings[key] = value and true or false
    end
    local fioSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_FIO_TOOLTIP",
        Settings.VarType.Boolean, L"OPT_FIO_TOOLTIP", true,
        function() return FioFlag("tooltipEnabled") end,
        function(value) SetFioFlag("tooltipEnabled", value) end)
    Settings.CreateCheckbox(category, fioSetting, L"OPT_FIO_TOOLTIP_DESC")
    local tiersSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_FIO_TIERS",
        Settings.VarType.Boolean, L"OPT_FIO_TIERS", true,
        function() return FioFlag("tiersEnabled") end,
        function(value) SetFioFlag("tiersEnabled", value) end)
    Settings.CreateCheckbox(category, tiersSetting, L"OPT_FIO_TIERS_DESC")

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
