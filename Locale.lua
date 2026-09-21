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

    -- Расхождения в тултипе и сверке
    ["к уровню предмета"] = "item level",
    ["к силе"] = "Strength",
    ["к ловкости"] = "Agility",
    ["к интеллекту"] = "Intellect",
    ["к выносливости"] = "Stamina",
    ["к критическому удару"] = "Critical Strike",
    ["к скорости"] = "Haste",
    ["к искусности"] = "Mastery",
    ["к универсальности"] = "Versatility",
    ["особое гнездо"] = "meta socket",
    ["особое гнёзда"] = "meta sockets",
    ["бесцветное гнездо"] = "prismatic socket",
    ["бесцветное гнёзда"] = "prismatic sockets",
    ["красное гнездо"] = "red socket",
    ["красное гнёзда"] = "red sockets",
    ["жёлтое гнездо"] = "yellow socket",
    ["жёлтое гнёзда"] = "yellow sockets",
    ["синее гнездо"] = "blue socket",
    ["синее гнёзда"] = "blue sockets",
    ["шестерёнка гнездо"] = "cogwheel socket",
    ["шестерёнка гнёзда"] = "cogwheel sockets",
    ["владычества гнездо"] = "domination socket",
    ["владычества гнёзда"] = "domination sockets",
    ["Верса"] = "Vers",
    ["Статы поправлены по базе — клиент масштабирует эту ссылку неточно."] =
        "Stats corrected from the database — the client scales this link inaccurately.",
    ["Твоя копия отличается от базы:"] = "Your copy differs from the database:",
    ["BiS-версия на руках"] = "BiS version in bags",
    ["Отметка залипла навсегда: к этому рарнику можно больше не ходить."] =
        "This mark stays forever: no need to farm this rare again.",
    ["Выпала не BiS-версия"] = "A non-BiS version dropped",
    ["Копия где-то есть, но прочитать её не удалось - похоже, в закрытом банке или у другого персонажа."] =
        "A copy exists somewhere, but it could not be read — likely a closed bank or another character.",
    ["Рарник ежедневный: на дневном сбросе кружок опустеет, можно прийти снова за BiS-версией."] =
        "Daily rare: the mark clears at daily reset, you can come back for the BiS version.",
    ["Рарник даётся раз на персонажа - BiS-версии уже не будет. Отметил по ошибке: Ctrl+щелчок."] =
        "Once per character — the BiS version will not drop again. Marked by mistake: Ctrl-click.",
    ["Рарник убит, нужная вещь не выпала"] = "Rare killed, the item did not drop",
    ["На дневном сбросе кружок опустеет - можно прийти снова."] =
        "The mark clears at daily reset — you can come back.",
    ["Рарник даётся раз на персонажа, вещь не выпала - слот придётся закрывать другой. Отметил по ошибке: Ctrl+щелчок."] =
        "Once per character, the item did not drop — cover the slot with something else. Marked by mistake: Ctrl-click.",
    ["Отметить: рарник убит, нужная вещь не выпала"] = "Mark: rare killed, the item did not drop",
    ["Ставится сама при убийстве. Старые вещи в сумке на цвет не влияют - пока не сходишь к рарнику, кружок пуст."] =
        "Set automatically on kill. Old copies in bags do not change the color — the circle stays empty until you visit the rare.",
    ["|cFF888888Загрузка данных...|r"] = "|cFF888888Loading...|r",
    ["|cFF888888Нет предметов под эти фильтры.|r"] = "|cFF888888No items match these filters.|r",

    -- Окно копирования
    ["Копировать из чата — Ctrl+A, Ctrl+C"] = "Copy from chat — Ctrl+A, Ctrl+C",
    ["Выделить всё"] = "Select all",
    ["Сверить (/tgf scan)"] = "Scan (/tgf scan)",
    ["Слепок надетого (/tgf ref)"] = "Equipped snapshot (/tgf ref)",
    ["Показать: весь чат"] = "Show: all chat",
    ["Показать: только TGF"] = "Show: TGF only",
    ["Показать: только код"] = "Show: code only",
    ["Копировать из чата (TGF)"] = "Copy from chat (TGF)",
    ["После /tgf scan или /tgf gems — здесь их вывод"] = "After /tgf scan or /tgf gems, their output is here",
    ["прогон"] = "run",
    ["Чат пуст."] = "Chat is empty.",
    ["Строк [TGF] пока нет.\n\nНажми кнопку сверху — «Сверить» или «Слепок надетого» — вывод появится здесь.\nЛибо переключи на «весь чат»."] =
        "No [TGF] lines yet.\n\nPress Scan or Equipped snapshot above — the output will appear here.\nOr switch to all chat.",

    -- Окно BiS: подсказки кнопок
    ["Выгрузить сборку для SimulationCraft"] = "Export the build for SimulationCraft",
    ["Готовый профиль для Advanced Sim на Raidbots: персонаж, вещи, чары и ротация двадцатки."] =
        "A ready profile for Advanced Sim on Raidbots: character, gear, enchants, and the level-20 rotation.",
    ["Код талантов"] = "Talent loadout",
    ["Для этого спека кода пока нет."] = "No loadout for this spec yet.",
    ["Вставляется в игре: окно талантов — Загрузить сборку."] =
        "Paste in-game: talent window — Load Loadout.",
    ["Открыть BiS-сборки"] = "Open BiS builds",
    ["Свернуть BiS-сборки"] = "Collapse BiS builds",
    ["|cFF86C7BD[TGF]|r Кода талантов для этого спека пока нет. Пришлите свой: окно талантов, кнопка «Экспорт»."] =
        "|cFF86C7BD[TGF]|r No talent code for this spec yet. Send yours: talent window, Export.",

    -- Чат: сверка, метки, слепок
    ["метка на карте"] = "map pin",
    ["|cFFFFD100[TGF]|r Запомнено: %s = %s"] = "|cFFFFD100[TGF]|r Saved: %s = %s",
    ["карта %d: %.1f, %.1f"] = "map %d: %.1f, %.1f",
    ["|cFFFFD100[TGF]|r Отмечен как убитый: %s"] = "|cFFFFD100[TGF]|r Marked as killed: %s",
    ["|cFFFFD100[TGF]|r Настройки перенесены со старого имени аддона."] =
        "|cFFFFD100[TGF]|r Settings moved from the old addon name.",
    ["|cFFFFD100[TGF]|r Дневной сброс: снято отметок с ежедневных рарников - %d"] =
        "|cFFFFD100[TGF]|r Daily reset: cleared marks on daily rares - %d",
    ["|cFFFFD100[TGF]|r Проверено %d предметов из базы (надето, сумки, банк если открыт), расхождений: %d"] =
        "|cFFFFD100[TGF]|r Checked %d database items (equipped, bags, bank if open), mismatches: %d",
    ["|cFF86C7BD[TGF]|r Скопировать: /tgf copy"] = "|cFF86C7BD[TGF]|r Copy: /tgf copy",
    ["|cFF86C7BD[TGF]|r Скопировать отчёт: /tgf copy"] = "|cFF86C7BD[TGF]|r Copy the report: /tgf copy",
    ["[TGF] ВНИМАНИЕ: не 20 уровня. Число гнёзд верно, статы и уровень — нет."] =
        "[TGF] WARNING: not level 20. Socket count is right; stats and item level are not.",
    ["[TGF] ВНИМАНИЕ: персонаж не 20 уровня — статы и уровни предметов неточны. Слепок годен только с двадцатки."] =
        "[TGF] WARNING: character is not level 20 — stats and item levels are wrong. Snapshot only from a level-20.",
    ["[TGF] ВНИМАНИЕ: персонаж не 20 уровня — статы масштабируются по уровню, сверка неточна. Прогонять только двадцаткой."] =
        "[TGF] WARNING: character is not level 20 — stats scale with level, comparison is wrong. Run this on a level-20.",
    ["|cFFFFD100[TGF]|r Меток пока не запомнено."] = "|cFFFFD100[TGF]|r No pins saved yet.",
    ["|cFFFFD100[TGF]|r Метки на карте нет. Поставь её Ctrl+щелчком по карте и повтори."] =
        "|cFFFFD100[TGF]|r No map pin. Ctrl-click the map first, then try again.",
    ["|cFFFFD100[TGF]|r Текущая метка: карта %d, %.1f, %.1f"] =
        "|cFFFFD100[TGF]|r Current pin: map %d, %.1f, %.1f",
    ["|cFFFFD100[TGF]|r Привязать: /tgf pin <часть названия подземелья>"] =
        "|cFFFFD100[TGF]|r Bind it: /tgf pin <part of the dungeon name>",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе не найден."] =
        "|cFFFFD100[TGF]|r No source containing %s in the database.",
    ["|cFFFFD100[TGF]|r Подходит несколько, уточни (%d):"] =
        "|cFFFFD100[TGF]|r Several matches, be more specific (%d):",
    ["|cFFFFD100[TGF]|r Запомнено: %s = карта %d, %.1f, %.1f"] =
        "|cFFFFD100[TGF]|r Saved: %s = map %d, %.1f, %.1f",
    ["|cFF86C7BD[TGF]|r /tgf new [шея|кольцо|аксессуар] — без слова покажет все вещи, которых нет в базе"] =
        "|cFF86C7BD[TGF]|r /tgf new [neck|finger|trinket] — with no word, lists every item not in the database",
    ["|cFFFFD100[TGF]|r Не из базы: %d %s (надето, сумки, банк если открыт). Скопировать: /tgf copy"] =
        "|cFFFFD100[TGF]|r Not in the database: %d %s (equipped, bags, bank if open). Copy: /tgf copy",
    ["|cFF86C7BD[TGF]|r Таланты не читаются: игра не отдала активную сборку."] =
        "|cFF86C7BD[TGF]|r Talents unread: the game did not return the active loadout.",
    ["|cFF86C7BD[TGF]|r Окно BiS ещё не открывалось: /tgf bis"] =
        "|cFF86C7BD[TGF]|r Open the BiS window first: /tgf bis",
    ["# TrialGearFinder: таланты, %s %s (спек %s)"] = "# TrialGearFinder: talents, %s %s (spec %s)",
    ["# код сборки игра не отдала — возьми его в окне талантов кнопкой «Экспорт»"] =
        "# the game did not return a loadout code — copy it from the talent window, Export",
    ["|cFFFFD100[TGF]|r Зачарованных вещей: %d. Наведи на них в сумке или на себе, чтобы увидеть текст чары. Скопировать: /tgf copy"] =
        "|cFFFFD100[TGF]|r Enchanted items: %d. Hover them in bags or on you to see the enchant text. Copy: /tgf copy",
    ["[TGF] ref: %d предметов из базы у персонажа"] = "[TGF] ref: %d database items on this character",
    ["|cFFFFD100[TGF]|r %s: %d. Скопировать: /tgf copy"] =
        "|cFFFFD100[TGF]|r %s: %d. Copy: /tgf copy",
    ["[TGF] ссылка: "] = "[TGF] link: ",

    -- Выгрузка SimC (комментарии в профиле)
    ["# TrialGearFinder: сборка BiS, %s %s"] = "# TrialGearFinder: BiS build, %s %s",
    ["# Выгрузка TrialGearFinder, не аддона SimulationCraft: Raidbots пометит «Unverified Input»."] =
        "# TrialGearFinder export, not the SimulationCraft addon: Raidbots will mark Unverified Input.",
    ["# Вставлять в Advanced Sim на Raidbots: Quick Sim выбрасывает строки ротации."] =
        "# Paste into Advanced Sim on Raidbots: Quick Sim strips rotation lines.",
    ["# Нужны веса статов — та же вставка в Stat Weights: raidbots.com/simbot/stats."] =
        "# For stat weights, paste the same text into Stat Weights: raidbots.com/simbot/stats.",
    ["# Расходники максимального уровня двадцатке недоступны — выключены."] =
        "# Max-level consumables are unavailable to level 20 — disabled.",
    ["# Цель — болванка 23 уровня: по высокой цели заклинания мажут все до одного."] =
        "# Target is a level-23 dummy: spells miss every hit on a high-level mob.",
    ["# Цель — моб 45 уровня: сборка BiS считается по самым сложным подземельям."] =
        "# Target is a level-45 mob: BiS is scored against the hardest dungeons.",
    ["# Другое подземелье: старые героики — 30, Пандария — 38, Каз Алгар — 73."] =
        "# Other dungeons: old heroics 30, Pandaria 38, Khaz Algar 73.",
    ["# Таланты взяты из аддона, не с этого персонажа: код снят не на двадцатке."] =
        "# Talents come from the addon, not this character: the code was not taken at level 20.",
    ["# Талантов нет: зайди этим спеком — выгрузка возьмёт их из игры."] =
        "# No talents: log in on this spec — the export will take them from the game.",
    ["# Пачка из трёх целей: убери решётку в начале следующей строки."] =
        "# Three-target pack: remove the hash at the start of the next line.",
    ["# Ротация двадцатки из TrialGearFinder, сверена с логами рейтинга."] =
        "# Level-20 rotation from TrialGearFinder, checked against ranked logs.",
    ["# Ротации двадцатки для этого спека в аддоне нет: SimC возьмёт свою,"] =
        "# No level-20 rotation for this spec in the addon: SimC will use its own,",
    ["# под максимальный уровень. У одних спеков она на двадцатке почти не жмёт"] =
        "# written for max level. On some specs at 20 it barely presses",
    ["# приёмы, у других работает — цифре верить с оглядкой."] =
        "# abilities, on others it works — treat the number with caution.",
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
