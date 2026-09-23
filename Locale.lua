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
    ["Путешествие во времени из журнала — не гайд главы гильдии."] =
        "Timewalking from the journal — not the guild guide.",
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
    ["Смертельная тризна"] = "The Necrotic Wake",
    ["Танаанские джунгли"] = "Tanaan Jungle",
    ["Театр Боли"] = "Theater of Pain",
    ["Ульдаман: наследие Тира"] = "Uldaman: Legacy of Tyr",
    ["Чертоги Покаяния"] = "Halls of Atonement",
    ["ЗОЛОТАЯ ЖИЛА!!!"] = "The MOTHERLODE!!",
    ["Храм Сетралисс"] = "Temple of Sethraliss",
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
    ["|cFFFFD100[TGF]|r Для «%s» вход вашей фракции ещё не снят. Метка на входе, потом /tgf pin жила орда  или  /tgf pin жила альянс."] =
        "|cFFFFD100[TGF]|r No entrance for your faction on %s yet. Pin the entrance, then /tgf pin жила орда or /tgf pin жила альянс.",
    ["Альянс"] = "Alliance",
    ["Орда"] = "Horde",
    ["|cFFFFD100[TGF]|r Сначала поставь метку на карте (Ctrl+щелчок по карте), потом Ctrl+щелчок по источнику."] =
        "|cFFFFD100[TGF]|r Put a marker on the map first (Ctrl-click the map), then Ctrl-click the source.",

    ["|cFFFFD100[TGF]|r Путешествие во времени: вход только через поиск подземелий, в неделю события."] =
        "|cFFFFD100[TGF]|r Timewalking: entered through the dungeon finder only, during the event week.",
    ["Сейчас: %s (до %s)"] = "Now: %s (until %s)",
    ["Сейчас: %s"] = "Now: %s",
    ["Сейчас нет Путешествия во времени"] = "No Timewalking event is active",
    ["Следующее: %s"] = "Next: %s",
    ["В календаре пока нет ближайшего Путешествия во времени"] =
        "No upcoming Timewalking event on the calendar yet",
    ["января"] = "January",
    ["февраля"] = "February",
    ["марта"] = "March",
    ["апреля"] = "April",
    ["мая"] = "May",
    ["июня"] = "June",
    ["июля"] = "July",
    ["августа"] = "August",
    ["сентября"] = "September",
    ["октября"] = "October",
    ["ноября"] = "November",
    ["декабря"] = "December",
    ["Классика"] = "Classic",
    ["Гнев Короля-лича"] = "Wrath of the Lich King",
    ["Катаклизм"] = "Cataclysm",
    ["Пандария"] = "Pandaria",
    ["Дренор"] = "Draenor",
    ["Легион"] = "Legion",
    ["Битва за Азерот"] = "Battle for Azeroth",
    ["Темные земли"] = "Shadowlands",
    ["Драконы"] = "Dragonflight",
    ["Значок Путешествия во времени на плитках"] =
        "Timewalking badge on dungeon tiles",
    ["Показывать знак валюты в углу плитки, если у данжа есть сложность Путешествия во времени."] =
        "Show the Timewalking currency icon on a tile when that dungeon has a Timewalking difficulty.",
    ["Данжи Путешествия во времени на текущем сезоне"] =
        "Timewalking dungeons on the current season tab",
    ["На вкладке текущего сезона показывать данжи текущей недели Путешествия во времени вместо ключей Midnight."] =
        "On the current season tab, show this week's Timewalking dungeons instead of Midnight key dungeons.",
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
    ["|cFFFFD100[TGF]|r Два входа Жилы: /tgf pin жила орда  или  /tgf pin жила альянс"] =
        "|cFFFFD100[TGF]|r Motherlode has two entrances: /tgf pin жила орда or /tgf pin жила альянс",
    ["|cFFFFD100[TGF]|r Укажи сторону: /tgf pin жила орда  или  /tgf pin жила альянс"] =
        "|cFFFFD100[TGF]|r Say which side: /tgf pin жила орда or /tgf pin жила альянс",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе не найден."] =
        "|cFFFFD100[TGF]|r No source containing %s in the database.",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе и в журнале не найден."] =
        "|cFFFFD100[TGF]|r No source containing %s in the database or the journal.",
    ["|cFFFFD100[TGF]|r Журнал подземелий недоступен."] =
        "|cFFFFD100[TGF]|r Encounter Journal is not available.",
    ["|cFFFFD100[TGF]|r В журнале %d подземелий: с меткой %d, без метки %d."] =
        "|cFFFFD100[TGF]|r Journal has %d dungeons: %d pinned, %d without a pin.",
    ["|cFFFFD100[TGF]|r Без метки из журнала: /tgf pin список"] =
        "|cFFFFD100[TGF]|r Unpinned from the journal: /tgf pin список",
    ["|cFFFFD100[TGF]|r Подходит несколько, уточни (%d):"] =
        "|cFFFFD100[TGF]|r Several matches, be more specific (%d):",
    ["|cFFFFD100[TGF]|r Запомнено: %s = карта %d, %.1f, %.1f"] =
        "|cFFFFD100[TGF]|r Saved: %s = map %d, %.1f, %.1f",
    ["|cFFFFD100[TGF]|r Журнал не отдал добычу. Открой Путеводитель приключений и повтори /tgf tw."] =
        "|cFFFFD100[TGF]|r The journal returned no loot. Open the Adventure Guide and run /tgf tw again.",
    ["|cFF86C7BD[TGF]|r Какую экспансию снять — одна команда, не все сразу:"] =
        "|cFF86C7BD[TGF]|r Pick an expansion — one command, not all at once:",
    ["|cFFFFD100[TGF]|r Не знаю экспансию «%s». Так:"] =
        "|cFFFFD100[TGF]|r Unknown expansion \"%s\". Try:",
    ["|cFFFFD100[TGF]|r /tgf tw все  — все экспансии сразу"] =
        "|cFFFFD100[TGF]|r /tgf tw all  — every expansion at once",
    ["|cFF86C7BD[TGF]|r Обычные подземелья — одна экспансия, не все сразу:"] =
        "|cFF86C7BD[TGF]|r Regular dungeons — one expansion, not all at once:",
    ["|cFF86C7BD[TGF]|r Обычные подземелья — одно дополнение или один данж:"] =
        "|cFF86C7BD[TGF]|r Regular dungeons — one expansion or one dungeon:",
    ["|cFFFFD100[TGF]|r Не знаю экспансию или данж «%s». Так:"] =
        "|cFFFFD100[TGF]|r Unknown expansion or dungeon \"%s\". Try:",
    ["|cFFFFD100[TGF]|r /tgf dj кузня душ  — один данж"] =
        "|cFFFFD100[TGF]|r /tgf dj forge of souls  — one dungeon",
    ["|cFFFFD100[TGF]|r /tgf dj список  — чеклист по данжам"] =
        "|cFFFFD100[TGF]|r /tgf dj list  — dungeon checklist",
    ["|cFFFFD100[TGF]|r /tgf dj все  — все экспансии сразу"] =
        "|cFFFFD100[TGF]|r /tgf dj all  — every expansion at once",
    ["|cFFFFD100[TGF]|r Чеклист: %d данжей. Скопировать: Ctrl+C в открывшемся окне."] =
        "|cFFFFD100[TGF]|r Checklist: %d dungeons. Copy: Ctrl+C in the window that opened.",
    ["|cFFFFD100[TGF]|r Данж: %s."] =
        "|cFFFFD100[TGF]|r Dungeon: %s.",
    ["|cFFFFD100[TGF]|r Данж: %s (%s)."] =
        "|cFFFFD100[TGF]|r Dungeon: %s (%s).",
    ["|cFFFFD100[TGF]|r В журнале нет обычной сложности у «%s»."] =
        "|cFFFFD100[TGF]|r The journal has no Normal difficulty for \"%s\".",
    ["|cFFFFD100[TGF]|r Старые экспансии снимай со включённым Временем Хроми той же эпохи: без него лут вроде Террасы магистров не того уровня."] =
        "|cFFFFD100[TGF]|r For old expansions turn on Chromie Time for that era: without it loot like Magisters' Terrace is the wrong item level.",
    ["|cFFFFD100[TGF]|r Время Хроми одно на все экспансии — снимай по одной, иначе чужие данжи будут не того уровня."] =
        "|cFFFFD100[TGF]|r Chromie Time is one expansion at a time — dump one era, or other dungeons will be the wrong item level.",
    ["|cFFFFD100[TGF]|r Время Хроми выкл. Для «%s» включи историю этой эпохи, иначе лут вроде Террасы магистров не того уровня."] =
        "|cFFFFD100[TGF]|r Chromie Time is off. For \"%s\" turn on that era's campaign, or loot like Magisters' Terrace is the wrong item level.",
    ["|cFFFFD100[TGF]|r Снимаю %s, а Время Хроми — %s. Включи историю этой эпохи."] =
        "|cFFFFD100[TGF]|r Dumping %s, but Chromie Time is %s. Turn on that era's campaign.",
    ["|cFFFFD100[TGF]|r Время Хроми: %s."] =
        "|cFFFFD100[TGF]|r Chromie Time: %s.",
    ["|cFFFFD100[TGF]|r Время Хроми: Настоящее."] =
        "|cFFFFD100[TGF]|r Chromie Time: Present.",
    ["Настоящее"] = "Present",
    ["|cFFFFD100[TGF]|r В журнале нет обычных подземелий для «%s»."] =
        "|cFFFFD100[TGF]|r The journal has no regular dungeons for \"%s\".",
    ["|cFFFFD100[TGF]|r В журнале нет обычных подземелий."] =
        "|cFFFFD100[TGF]|r The journal has no regular dungeons.",
    ["|cFFFFD100[TGF]|r Журнал не отдал добычу. Открой Путеводитель приключений и повтори /tgf dj."] =
        "|cFFFFD100[TGF]|r The journal returned no loot. Open the Adventure Guide and run /tgf dj again.",
    ["|cFFFFD100[TGF]|r Обычные подземелья: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне."] =
        "|cFFFFD100[TGF]|r Regular dungeons: %d new of %d. Copy: Ctrl+C in the window that opened.",
    ["|cFFFFD100[TGF]|r Без обычной сложности пропущено данжей: %d."] =
        "|cFFFFD100[TGF]|r Skipped %d dungeons with no Normal difficulty.",
    ["|cFFFFD100[TGF]|r Катаклизм: броню и оружие не снимал, только аксессуары (%d пропущено)."] =
        "|cFFFFD100[TGF]|r Cataclysm: skipped armor and weapons, trinkets only (%d skipped).",
    ["|cFFFFD100[TGF]|r Снимаю %s."] =
        "|cFFFFD100[TGF]|r Dumping %s.",
    ["|cFFFFD100[TGF]|r Снимаю все экспансии."] =
        "|cFFFFD100[TGF]|r Dumping all expansions.",
    ["|cFFFFD100[TGF]|r В журнале нет подземелий Путешествия во времени для «%s»."] =
        "|cFFFFD100[TGF]|r The journal has no Timewalking dungeons for \"%s\".",
    ["|cFFFFD100[TGF]|r В журнале нет подземелий с Путешествием во времени."] =
        "|cFFFFD100[TGF]|r The journal has no Timewalking dungeons.",
    ["|cFFFFD100[TGF]|r Путешествие во времени: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне."] =
        "|cFFFFD100[TGF]|r Timewalking: %d new of %d. Copy: Ctrl+C in the window that opened.",
    ["|cFFFFD100[TGF]|r Гружу %d вещей из журнала, подожди несколько секунд."] =
        "|cFFFFD100[TGF]|r Loading %d journal items, wait a few seconds.",
    ["|cFFFFD100[TGF]|r Дамп уже идёт, подожди."] =
        "|cFFFFD100[TGF]|r Dump already running, wait.",
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
    ["# Острые рефлексы: в данных сима с 23 уровня, на двадцатке талант есть."] =
        "# Sharp Reflexes: spell data says level 23, but a level-20 can take it.",
    ["# Боевые инстинкты и Эффективная тренировка на 20 уровне нет."] =
        "# Martial Instincts and Efficient Training do not exist at level 20.",
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

    -- Классы и спеки. Игра отдаёт их на языке клиента, а настройка аддона
    -- может быть другой: на русском клиенте с «Английский» клиентские имена
    -- остаются русскими. Свои таблицы — чтобы выбор в Параметрах работал.
    ["Воин"] = "Warrior",
    ["Паладин"] = "Paladin",
    ["Охотник"] = "Hunter",
    ["Разбойник"] = "Rogue",
    ["Жрец"] = "Priest",
    ["Рыцарь смерти"] = "Death Knight",
    ["Шаман"] = "Shaman",
    ["Маг"] = "Mage",
    ["Чернокнижник"] = "Warlock",
    ["Монах"] = "Monk",
    ["Друид"] = "Druid",
    ["Охотник на демонов"] = "Demon Hunter",
    ["Пробудитель"] = "Evoker",
    ["Оружие"] = "Arms",
    ["Неистовство"] = "Fury",
    ["Защита"] = "Protection",
    ["Повелитель зверей"] = "Beast Mastery",
    ["Стрельба"] = "Marksmanship",
    ["Выживание"] = "Survival",
    ["Воздаяние"] = "Retribution",
    ["Свет"] = "Holy",
    ["Ликвидация"] = "Assassination",
    ["Головорез"] = "Outlaw",
    ["Скрытность"] = "Subtlety",
    ["Послушание"] = "Discipline",
    ["Тьма"] = "Shadow",
    ["Нечестивость"] = "Unholy",
    ["Лёд"] = "Frost",
    ["Лед"] = "Frost",
    ["Кровь"] = "Blood",
    ["Колдовство"] = "Affliction",
    ["Демонология"] = "Demonology",
    ["Разрушение"] = "Destruction",
    ["Танцующий с ветром"] = "Windwalker",
    ["Ткач туманов"] = "Mistweaver",
    ["Хмелевар"] = "Brewmaster",
    ["Баланс"] = "Balance",
    ["Сила зверя"] = "Feral",
    ["Страж"] = "Guardian",
    ["Исцеление"] = "Restoration",
    ["Истребление"] = "Havoc",
    ["Месть"] = "Vengeance",
    ["Пожиратель"] = "Devourer",
    ["Опустошитель"] = "Devastation",
    ["Хранитель"] = "Preservation",
    ["Насыщатель"] = "Augmentation",
    ["Огонь"] = "Fire",
    ["Тайная магия"] = "Arcane",
    ["Стихии"] = "Elemental",
    ["Совершенствование"] = "Enhancement",

    -- Заметки предметов из гайда. Ключ — как в базе, русская строка.
    ["[ДД] падает с Древний зуболом в Назмире; Беспрерывно тикающие часы: аксессуар со всеми основными статами разом (в рейтинге ×8)"] = "[DPS] drops from Ancient Jawbreaker in Nazmir; Incessantly Ticking Clock: trinket with all primary stats at once (ranked logs ×8)",
    ["[ДД] Карта Таро Пророчества: три вторички разом - крит, универсальность, искусность. Уникальная использующаяся"] = "[DPS] Prophetic Tarot: three secondaries at once - crit, vers, mastery. Unique-equipped on-use",
    ["[ДД] Клык Расте: три вторички разом - крит, скорость, искусность. Падает с Расте, раз в день"] = "[DPS] Fang of Rasthe: three secondaries at once - crit, haste, mastery. Drops from Rasthe, daily rare",
    ["[ДД] Обузданный огонь: три вторички разом - крит, универсальность, искусность. Падает с Обуглень Дикий Огонь, раз в день"] = "[DPS] Contained Flame: three secondaries at once - crit, vers, mastery. Drops from Cindral the Wildfire, daily rare",
    ["[ДД] аналог Рога талбука, с квеста"] = "[DPS] quest version of Talbuk Horn",
    ["[ДД] падает с Сиамата (Затерянный город Тол'вир); Благоволение Тиа (Tia's Grace): атаки дают +1 ловкости на 15 сек., до 10 раз. Тир 32"] = "[DPS] drops from Siamat (Lost City of the Tol'vir); Tia's Grace: attacks grant +1 Agility for 15 sec, stacks to 10. Tier 32",
    ["[ДД] падает с Эрудакса, Повелителя Глубин; Буря теней: интеллект копится от урона периодикой, до 20 стаков"] = "[DPS] drops from Erudax, the Duke of Below; Storm of Shadows: Intellect stacks from DoT damage, up to 20",
    ["[ДД] последовательное накопление основной характеристики"] = "[DPS] stacks primary stat over time",
    ["[ДД] хорошая прожимка на интеллект"] = "[DPS] strong on-use Intellect",
    ["[ДД] хорошая прожимка на силу заклинаний"] = "[DPS] strong on-use spell power",
    ["[ДД] хороший прок ловкости; рарник, убивать В РЕЖИМЕ ИСТОРИИ"] = "[DPS] strong Agility proc; rare, kill in STORY MODE",
    ["[ДД] хороший прок силы, с сокровища"] = "[DPS] strong Strength proc, from a treasure",
    ["[Танк] нишевая смесь Квинтэссенции и Скаломола"] = "[Tank] niche mix of Quintessence and Rumbling Mountain",
    ["[Танк] пассивно снижает получаемый урон, очень хороша на аое запулах"] = "[Tank] passively reduces damage taken, excellent on AoE pulls",
    ["[Танк] прожимка, снижающая получаемый урон"] = "[Tank] on-use that reduces damage taken",
    ["[Танк] сильно увеличивает запас здоровья; нужно засумониться в данж 30 уровня"] = "[Tank] large health bump; need a summon into a level-30 dungeon",
    ["[Танк] спасает от критического урона"] = "[Tank] saves you from burst damage",
    ["[Хил] падает с Эрудакса, Повелителя Глубин; Оскверненная яичная скорлупа: по использованию щит на союзника 2809 + возврат маны"] = "[Healer] drops from Erudax, the Duke of Below; Corrupted Egg Shell: on-use shield on an ally 2809 + mana return",
    ["[Хил] реген маны"] = "[Healer] mana regen",
    ["[Хил] падает с Рухрана; Перо Рухрана: скорость и универсальность, синий, уникальный (Keotore, 30 из 50 заходов; статы и уровень с тултипа 21 сентября)"] = "[Healer] drops from Rukhran; Rukhran's Quill: haste and vers, rare, unique-equipped (Keotore, 30 of 50 runs; stats and ilvl from tooltip 21 Sep)",
    ["падает с Жрицы Делриссы; Боевая палица верховной жрицы: одноручная, интеллект 19, одно родное гнездо"] = "drops from Priestess Delrissa; Battle-Mace of the High Priestess: one-hand, 19 Int, one native socket",
    ["падает со Стражницы душ Ниами; Губительный клинок мудреца: одноручный меч на интеллект 19"] = "drops from Soulbinder Nyami; Soulcutter Mageblade: one-hand sword, 19 Int",
    ["Кристаллический волшебный посох Камуи: двуручный, интеллект 30. Откуда падает — не выяснено"] = "Kamui's Crystalline Staff of Wizardry: two-hand, 30 Int. Drop source not confirmed",
    ["редкий: Рука Эдварда Странного, уникальная одноручка, мировой дроп. В сборку не ставим (Keotore, армори ilvl 27)"] = "rare: Hand of Edward the Odd, unique one-hander, world drop. Not in the set (Keotore, armory ilvl 27)",
    ["Бадья: кольцо на универсальность/искусность. Тир 32"] = "Bucket: ring, vers/mastery. Tier 32",
    ["крафт (инженерия); Специализированная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса. Статы двадцатки в игре не сняты"] = "crafted (Engineering); Specialized Retinal Armor: plate helm, meta socket and two cogwheels. Level-20 stats not live-checked",
    ["падает с Ром'огга Костекрушителя; Щит железной леди: Путешествие во времени, уровень 32. Статы двадцатки в игре не сняты"] = "drops from Rom'ogg Bonecrusher; Shield of the Iron Maiden: Timewalking, item level 32. Level-20 stats not live-checked",
    ["[Танк] падает с Асаада; Сердце грома: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23"] = "[Tank] drops from Asaad; Heart of Thunder: Timewalking version, item level 32. Dungeon copy in the guide is a different item, item level 23",
    ["Бусы предков Укхел: шея на скорость/искусность (слепок, ×4; была удалена)"] = "Ukhel Ancestry Beads: neck, haste/mastery (snapshot ×4; was removed)",
    ["Двойной клинок мастерства: кинжал разбойника, обе руки (от сообщества)"] = "Twinblade of Mastery: rogue dagger, both hands (community)",
    ["Драгоценная петля из кровошипа: кольцо со всеми статами и универсальностью, с Горума (слепок, ×17)"] = "Bloodthorn Loop: ring with all stats and vers, from Goruk (snapshot ×17)",
    ["Кинжал штормградского бойца авангарда: награда за задание, только Альянс, с 10 ур. (от сообщества)"] = "Stormwind Vanguard Fighter's Dagger: quest reward, Alliance only, from level 10 (community)",
    ["Кольцо антии (Anthia's Ring): на крит/искусность. Тир 32"] = "Anthia's Ring: crit/mastery. Tier 32",
    ["Кольцо великого кита: на универсальность. Тир 32"] = "Great Whale Ring: vers. Tier 32",
    ["Кольцо наутилуса (Nautilus Ring): на крит/скорость. Тир 32"] = "Nautilus Ring: crit/haste. Tier 32",
    ["падает с Платного разгонятеля толпы; Кольцо чемпиона по футбомбометанию: на скорость/искусность (в рейтинге ×19)"] = "drops from Coin-Operated Crowd Pummeler; Footbomb Championship Ring: haste/mastery (ranked logs ×19)",
    ["Кольцо череподробителя (Skullcracker Ring): на крит/искусность. Тир 32"] = "Skullcracker Ring: crit/mastery. Tier 32",
    ["Комендантский медальон наваждения: шея на универсальность/искусность (слепок, ×7; была удалена)"] = "Haunting Commander's Medallion: neck, vers/mastery (snapshot ×7; was removed)",
    ["Магнит на кристальной цепи (Crystal-Chained Lodestone): шея на крит/скорость. Тир 32"] = "Crystal-Chained Lodestone: neck, crit/haste. Tier 32",
    ["падает с Полководца Калитреша; Наплечники Лунной поляны: кожаные плечи на версу, два гнезда (в рейтинге ×8)"] = "drops from Warlord Kalithresh; Moonglade Shoulders: leather shoulders, vers, two sockets (ranked logs ×8)",
    ["падает с Гюрзиса и Аспидиса; Обоюдоострое копье: двуручное на ловкость, Путешествие во времени, ilvl 26 (логи, x98)"] = "drops from Adderis and Aspix; Twin-Strike Polearm: Agility two-hander, Timewalking, ilvl 26 (logs, x98)",
    ["Окованная железом подвеска (Ironshell Pendant): шея на скорость. Тир 32"] = "Ironshell Pendant: neck, haste. Tier 32",
    ["Перстень из розового кварца (Rose Quartz Band): на крит. Тир 32"] = "Rose Quartz Band: crit. Tier 32",
    ["Перстень перевоплощения: на скорость/искусность. Тир 32"] = "Transmogrification Band: haste/mastery. Tier 32",
    ["Подвеска из ракушечника (Barnacle Pendant): шея на крит/скорость. Тир 32"] = "Barnacle Pendant: neck, crit/haste. Tier 32",
    ["Подвеска из рыбы-иглы (Pipefish Cord): шея на скорость/искусность. Тир 32"] = "Pipefish Cord: neck, haste/mastery. Tier 32",
    ["Подвеска несущего волны (Carrier Wave Pendant): шея на скорость/искусность. Тир 32"] = "Carrier Wave Pendant: neck, haste/mastery. Tier 32",
    ["Подвеска погруженного во тьму грота (Pendant of the Lightless Grotto): шея на искусность. Тир 32"] = "Pendant of the Lightless Grotto: neck, mastery. Tier 32",
    ["Почерневшее костяное ожерелье (Blackened Bone Necklace): шея на крит. Тир 32"] = "Blackened Bone Necklace: neck, crit. Tier 32",
    ["Почти лучшая заточка Водина: кинжал, награда за задание, обе фракции, с 20 ур. (от сообщества)"] = "Near-best Wodin's Dagger: quest reward, both factions, from level 20 (community)",
    ["Разорванное ожерелье из земляного камня (Fractured Earthstone Necklace): шея на универсальность. Тир 32"] = "Fractured Earthstone Necklace: neck, vers. Tier 32",
    ["падает с Налтора Криоманта; Ритуальный перстень командира: кольцо на крит/универсальность (в рейтинге ×16)"] = "drops from Nalthor the Rimebinder; Ritual Commander's Ring: crit/vers (ranked logs ×16)",
    ["Ртутный амулет (Quicksilver Amulet): шея на скорость/универсальность. Тир 32; по Wowhead ловится удочкой в Пещерах Черной Горы — не проверено"] = "Quicksilver Amulet: neck, haste/vers. Tier 32; Wowhead says fished in Blackrock Caverns - not verified",
    ["Сплетенные нереиды (Entwined Nereis): кольцо на универсальность. Тир 32"] = "Entwined Nereis: ring, vers. Tier 32",
    ["Фамильная печать Сильверлейнов: кольцо на скорость/универсальность, без гнезда"] = "Silverlaine Family Seal: ring, haste/vers, no socket",
    ["Фосфоресцирующее кольцо (Phosphorescent Ring): на универсальность. Тир 32"] = "Phosphorescent Ring: vers. Tier 32",
    ["падает с Ингвара Расхителя; Шлем расхитителя: кольчужная голова на крит/скорость, два гнезда (в рейтинге ×8)"] = "drops from Ingvar the Plunderer; Plunderer's Helmet: mail head, crit/haste, two sockets (ranked logs ×8)",
    ["Щедро изукрашенное кольцо (Lavishly Jeweled Ring): на крит/скорость. Тир 32; в гильдии носят и обычную копию 23-26 уровня"] = "Lavishly Jeweled Ring: crit/haste. Tier 32; guild also wears the regular 23-26 copy",
    ["аналог бивня на прожим искусности"] = "tusk analog, on-use mastery",
    ["бисовая кожаная голова для критовиков (1/2 сета Странника пустошей)"] = "BiS leather helm for crit builds (1/2 Wastelander set)",
    ["бисовая тканевая грудь с выносливостью"] = "BiS cloth chest with Stamina",
    ["бисовая тканевая грудь с интеллектом"] = "BiS cloth chest with Intellect",
    ["бисовые кожаные наручи"] = "BiS leather bracers",
    ["бисовые кожаные плечи"] = "BiS leather shoulders",
    ["бисовые кожаные поножи"] = "BiS leather legs",
    ["бисовые кольчужные наручи"] = "BiS mail bracers",
    ["бисовые кольчужные плечи"] = "BiS mail shoulders",
    ["бисовые кольчужные поножи"] = "BiS mail legs",
    ["бисовые кольчужные руки"] = "BiS mail gloves",
    ["бисовые латные наручи"] = "BiS plate bracers",
    ["бисовые латные плечи"] = "BiS plate shoulders",
    ["бисовые латные поножи"] = "BiS plate legs",
    ["бисовые латные руки"] = "BiS plate gloves",
    ["бисовые латные сапоги"] = "BiS plate boots",
    ["бисовые тканевые наручи на скорость"] = "BiS cloth bracers, haste",
    ["бисовые тканевые наручи на универсальность"] = "BiS cloth bracers, vers",
    ["бисовые тканевые ноги с силой заклинаний"] = "BiS cloth legs with spell power",
    ["бисовые тканевые плечи"] = "BiS cloth shoulders",
    ["бисовые тканевые поножи с выносливостью"] = "BiS cloth legs with Stamina",
    ["бисовые тканевые ступни"] = "BiS cloth boots",
    ["бисовый кожаный нагрудник"] = "BiS leather chest",
    ["бисовый кожаный пояс"] = "BiS leather belt",
    ["бисовый кольчужный нагрудник"] = "BiS mail chest",
    ["бисовый кольчужный пояс"] = "BiS mail belt",
    ["бисовый кольчужный шлем"] = "BiS mail helm",
    ["бисовый латный нагрудник"] = "BiS plate chest",
    ["бисовый латный ремень"] = "BiS plate belt",
    ["бисовый латный шлем с особым гнездом"] = "BiS plate helm with a meta socket",
    ["бисовый лук за цепочку Хеминга Эрнестуэя, вторичек вдвое больше, чем у других пушек"] = "BiS bow from Hemet Nesingwary's questline, twice the secondaries of other guns",
    ["бисовый тканевый шлем"] = "BiS cloth helm",
    ["вторая часть \"манасета\", нужен хилам для регена маны"] = "second piece of the \"mana set\", healers need it for mana regen",
    ["за квест здесь дают начальный грудак для латников Защитник наместника"] = "quest here gives plate starters the Exarch's Protector chest",
    ["забавный латный шлем для контроля противника в PvP"] = "fun plate helm for PvP crowd control",
    ["здесь за квест дают бисовые сапоги на кольчугу Аукенайские сапоги и временные латы Скованные Ша'тар наголенники"] = "quest here gives BiS mail Auchenai Boots and temporary plate Sha'tari Bound Greaves",
    ["из ящика Тажаня Чжу (Монастырь Шадо-Пан); Ка'эн, дыхание тьмы (Ka'eng, Breath of the Shadow): кистевое оружие на крит/скорость. Тир 32"] = "from Taran Zhu's chest (Shado-Pan Monastery); Ka'eng, Breath of the Shadow: fist weapon, crit/haste. Tier 32",
    ["кистевое, статов нет - только прок: +61 к скорости на 10 сек. при ударе (КД 45с)"] = "fist weapon, no stats - only a proc: +61 Haste for 10 sec on hit (45s CD)",
    ["кожаные плечи с универсальностью для монаха-ткача (от сообщества)"] = "leather shoulders with vers for Mistweaver (community)",
    ["кольчужный ремень за сопровождение Тралла (парная награда к Касанию бури)"] = "mail belt from escorting Thrall (paired with Touch of Storm)",
    ["крафт (инженерия), статы зависят от изготовления - самая популярная триальная тринька"] = "crafted (engineering), stats depend on the craft - the most popular trial trinket",
    ["лучшая прожимка на скорость"] = "best haste on-use",
    ["лучшая прожимка на универсальность"] = "best vers on-use",
    ["лучшая тринька для фарма подземелий"] = "best trinket for dungeon farming",
    ["лучшие латные плечи на скорость"] = "best plate shoulders for haste",
    ["лучшие тканевые руки на версу"] = "best cloth gloves for vers",
    ["лучший посох на кастеров"] = "best staff for casters",
    ["лучший тканевый ремень на версу"] = "best cloth belt for vers",
    ["очень сильная двуручка для силовиков и сурв-хантов"] = "very strong two-hander for Strength specs and Survival hunters",
    ["очень сильная одноручка для ловкачей и силовиков"] = "very strong one-hander for Agility and Strength specs",
    ["падает в Каменных Недрах; Тяжелая жеодовая палица (Heavy Geode Mace): булава на ловкость, крит/скорость. Тир 32"] = "drops in the Stonecore; Heavy Geode Mace: Agility mace, crit/haste. Tier 32",
    ["падает в Конце Времен; Зазубренное лезвие времени (Jagged Edge of Time): кинжал на крит/скорость. Тир 32"] = "drops in End Time; Jagged Edge of Time: dagger, crit/haste. Tier 32",
    ["падает интовикам с Хранитель рощи Йал в Горгронде"] = "drops for Intellect specs from Grove Warden Yal in Gorgrond",
    ["падает ловкачам с Гиблет Трусливый на Хребте Ледяного Огня"] = "drops for Agility specs from Gibblette the Cowardly on Frostfire Ridge",
    ["падает с Ануб-арака; Кольцо короля-предателя: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x2)"] = "drops from Anub'arak; Traitor King's Ring: crit/haste. Timewalking, ilvl 32 (snapshot, x2)",
    ["падает с Бармагрыз на Хребте Ледяного Огня"] = "drops from Barmagash on Frostfire Ridge",
    ["падает с Бармен Билл на Тирагардском поморье"] = "drops from Bartender Bill in Tiragarde Sound",
    ["падает с Бромача; Выкопанный медальон Бромача: шея на скорость/искусность (слепок, ×6)"] = "drops from Bromach; Bromach's Unearthed Medallion: neck, haste/mastery (snapshot ×6)",
    ["падает с Броньяма; Узник любви: шея на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "drops from Bronjahm; Love's Prisoner: neck, haste/vers. Timewalking, ilvl 32 (snapshot, x3)",
    ["падает с Вексалиуса; Сапоги оживления: кожаные ступни на универсальность, со скоростью бега (от сообщества)"] = "drops from Vexallus; Boots of Resuscitation: leather boots, vers, with run speed (community)",
    ["падает с Геккана (Дворец Могу'шан); Когти Геккана: кистевое оружие на крит/скорость. Тир 32"] = "drops from Gekkan (Mogu'shan Palace); Gekkan's Claws: fist weapon, crit/haste. Tier 32",
    ["падает с Глубтока (Мертвые копи); Шип-клинок (Buzzer Blade): кинжал на крит. Тир 32"] = "drops from Glubtok (Deadmines); Buzzer Blade: dagger, crit. Tier 32",
    ["падает с Дикобраз-матриарх в Друстваре"] = "drops from Quillrat Matriarch in Drustvar",
    ["падает с Длинноклык и Генри Брейкуотер в Долине Штормов"] = "drops from Longfang and Henry Breakwater in Stormsong Valley",
    ["падает с Зубохлопа (Затерянный город Тол'вир); Кинжал Барима (Barim's Main Gauche): на крит/искусность. Тир 32"] = "drops from Lockmaw (Lost City of the Tol'vir); Barim's Main Gauche: crit/mastery. Tier 32",
    ["падает с Ингвара Расхителя; Кольцо Аннгильды: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x6)"] = "drops from Ingvar the Plunderer; Annhylde's Ring: crit/haste. Timewalking, ilvl 32 (snapshot, x6)",
    ["падает с Ингвара Расхителя; Несокрушимое тяжёлое кольцо: на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x7)"] = "drops from Ingvar the Plunderer; Unbreakable Band: haste/vers. Timewalking, ilvl 32 (snapshot, x7)",
    ["падает с Камнешкура (Каменные Недра); Ртутный клинок (Quicksilver Blade): кинжал на скорость/искусность. Тир 32"] = "drops from Slabhide (The Stonecore); Quicksilver Blade: dagger, haste/mastery. Tier 32",
    ["падает с Кандак в Зулдазаре"] = "drops from Kandak in Zuldazar",
    ["падает с Карша Гнущего Сталь (Пещеры Черной горы); Шедевр Гнущего Сталь (Steelbender's Masterpiece): кинжал на крит/искусность. Тир 32"] = "drops from Karsh Steelbender (Blackrock Caverns); Steelbender's Masterpiece: dagger, crit/mastery. Tier 32",
    ["падает с Кель'таса Солнечного Скитальца; Наголенники кающегося рыцаря: латные ступни на универсальность (слепок, ×7)"] = "drops from Kael'thas Sunstrider; Penitent Knight's Greaves: plate boots, vers (snapshot ×7)",
    ["падает с Кинжалозуб в Зулдазаре"] = "drops from Daggerjaw in Zuldazar",
    ["падает с Командира Ри'мока (Врата Заходящего Солнца); Вертлуг богомола: кинжал на крит/скорость. Тир 32"] = "drops from Commander Ri'mok (Gate of the Setting Sun); Mantid Joint: dagger, crit/haste. Tier 32",
    ["падает с Королева шипожалов в Друстваре"] = "drops from Quillrat Queen in Drustvar",
    ["падает с Кроворуба; Усиленный плотью ободок: кольцо на крит/искусность (слепок, ×9)"] = "drops from Gorechop; Flesh-Reinforced Loop: ring, crit/mastery (snapshot ×9)",
    ["падает с Кул'тарока; Ритуальное костяное кольцо: на универсальность/искусность (слепок, ×15)"] = "drops from Kul'tharok; Ritual Bone Ring: vers/mastery (snapshot ×15)",
    ["падает с Кулетт Вспыльчивый на Тирагардском поморье"] = "drops from Kul'ett the Irritable in Tiragarde Sound",
    ["падает с Лорда-камергера; Печатка лживого обвинения: кольцо на искусность (слепок, ×36 — самое ходовое)"] = "drops from Lord Chamberlain; Seal of the False Accusation: ring, mastery (snapshot ×36 - most worn)",
    ["падает с Мак в Друстваре"] = "drops from Mack in Drustvar",
    ["падает с Мастера; Рукавицы Железного лезвия: латные кисти на крит (слепок, ×6)"] = "drops from the Master; Ironblade Gauntlets: plate gloves, crit (snapshot ×6)",
    ["падает с Могамаго в Горгронде"] = "drops from Mogamago in Gorgrond",
    ["падает с Мрачноморд Безмозглый в Долине Штормов (В РЕЖИМЕ ИСТОРИИ)"] = "drops from Grimmaw the Brainless in Stormsong Valley (IN STORY MODE)",
    ["падает с Оскорбления претендентов; Печатка клятвы на крови: кольцо на крит/скорость (слепок, ×10)"] = "drops from An Affront of Challengers; Bloodoath Signet: ring, crit/haste (snapshot ×10)",
    ["падает с Пилозуб в Боралусе"] = "drops from Sawtooth in Boralus",
    ["падает с Пожирателя Душ; Ожерелье из пропавших камней: шея на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x8)"] = "drops from Devourer of Souls; Necklace of Lost Stones: neck, crit/haste. Timewalking, ilvl 32 (snapshot, x8)",
    ["падает с Пожирателя Душ; Перстень злорадства: на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "drops from Devourer of Souls; Band of Spite: crit/vers. Timewalking, ilvl 32 (snapshot, x3)",
    ["падает с Пожирателя Душ; Хребет разлагающегося трупа: агиловый посох, у друида-кота (слепок, ×4)"] = "drops from Devourer of Souls; Spine of the Decaying Corpse: Agility staff, for Feral (snapshot ×4)",
    ["падает с Пожирателя Душ; Чародейский кулон злости: шея на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "drops from Devourer of Souls; Arcane Pendant of Spite: neck, crit/vers. Timewalking, ilvl 32 (snapshot, x3)",
    ["падает с Сестра Абсинтия в Долине Штормов (В РЕЖИМЕ ИСТОРИИ)"] = "drops from Sister Absinthe in Stormsong Valley (IN STORY MODE)",
    ["падает с Сестра Марта в Друстваре"] = "drops from Sister Martha in Drustvar",
    ["падает с Сиамата (Затерянный город Тол'вир); Молот Искр (Hammer of Sparks): булава на ловкость, крит/скорость. Тир 32"] = "drops from Siamat (Lost City of the Tol'vir); Hammer of Sparks: Agility mace, crit/haste. Tier 32",
    ["падает с Сквиргл-из-Глубин на Тирагардском поморье"] = "drops from Squacks of the Depths in Tiragarde Sound",
    ["падает с Сын Горамала на Хребте Ледяного Огня"] = "drops from Son of Goramal on Frostfire Ridge",
    ["падает с Темноуст Джо'ла в Зулдазаре"] = "drops from Darkspeaker Jo'la in Zuldazar",
    ["падает с Хакби Восставший в Зулдазаре"] = "drops from Hakbi the Risen in Zuldazar",
    ["падает с Халкиаса; Запятнанная грехом подвеска: шея на скорость/искусность (слепок, ×16)"] = "drops from Halkias; Sin-Stained Pendant: neck, haste/mastery (snapshot ×16)",
    ["падает с Чешуетряс Ядовитый на Тирагардском поморье"] = "drops from Venomscale in Tiragarde Sound",
    ["падает с Чумокоста; Потерянная печатка Трупошва: кольцо на скорость/универсальность (слепок, ×9)"] = "drops from Plaguebone; Lost Stitchflesh Signet: ring, haste/vers (snapshot ×9)",
    ["падает с Ша Жестокости (Монастырь Шадо-Пан); Гнойный полумесяц: одноручный топор на скорость/искусность. Тир 32"] = "drops from Sha of Violence (Shado-Pan Monastery); Festering Crescent: one-hand axe, haste/mastery. Tier 32",
    ["падает с Эмили Мэйвилл в Друстваре"] = "drops from Emily Mayville in Drustvar",
    ["падает с верховного адъюдикатора Ализы; тринька на чистую скорость, годится любой роли (слепок, ×5)"] = "drops from High Adjudicator Aleez; pure haste trinket, any role (snapshot ×5)",
    ["падает с рарника Forgotten Creation; Амнезия: шея на скорость/универсальность (слепок, ×45 — самая ходовая)"] = "drops from rare Forgotten Creation; Amnesia: neck, haste/vers (snapshot ×45 - most worn)",
    ["падает с рарника Liskheszaera; Кристаллизованная печать: шея на универсальность/искусность (слепок, ×12)"] = "drops from rare Liskheszaera; Crystallized Seal: neck, vers/mastery (snapshot ×12)",
    ["падает с рарника Morchok; Окаменевшие споры грибов: шея на скорость/универсальность (слепок, ×8)"] = "drops from rare Morchok; Petrified Mushroom Spores: neck, haste/vers (snapshot ×8)",
    ["падает с сундука за доставку рарника Страж источника к нпс Чалый Бертольд на Тирагардском поморье"] = "drops from the chest for turning in rare Springwarden to Dusky Berthold in Tiragarde Sound",
    ["падает силовикам и ловкачам с Монстр арены в Награнде (В РЕЖИМЕ ИСТОРИИ)"] = "drops for Strength and Agility specs from Arena Beast in Nagrand (IN STORY MODE)",
    ["падает силовикам с Слякоч-повелитель в Горгронде"] = "drops for Strength specs from Sludge-Lord in Gorgrond",
    ["падает со Зыбуна; Полуночные набедренники: кожаные ноги на крит/скорость, 3 гнезда (слепок, ×5)"] = "drops from Quicksand; Midnight Legguards: leather legs, crit/haste, 3 sockets (snapshot ×5)",
    ["прожимка на искусность (сама вещь на универсальность), с сокровища"] = "on-use mastery (the item itself is vers), from a treasure",
    ["сильная двуручка для силовиков"] = "strong two-hander for Strength specs",
    ["тканевые руки за сопровождение Тралла (парная награда к Кушаку поборника)"] = "cloth gloves from escorting Thrall (paired with Champion's Belt)",
    ["фамильная тринька для PvP"] = "heirloom trinket for PvP",
    ["хорошая кожаная голова"] = "good leather helm",
    ["хорошая кожаная голова с особым гнездом"] = "good leather helm with a meta socket",
    ["хорошая латная голова на крит"] = "good plate helm, crit",
    ["хорошая латная голова на универсальность"] = "good plate helm, vers",
    ["хорошие кожаные ноги для критовиков (1/2 сета Странника пустошей)"] = "good leather legs for crit builds (1/2 Wastelander set)",
    ["хорошие кожаные руки для критовиков (1/2 сета Странника пустошей)"] = "good leather gloves for crit builds (1/2 Wastelander set)",
    ["хорошие кожаные руки на кастеров"] = "good leather gloves for casters",
    ["хорошие кожаные руки на ловкачей"] = "good leather gloves for Agility specs",
    ["хорошие кожаные сапоги"] = "good leather boots",
    ["хорошие кольчужные сапоги"] = "good mail boots",
    ["хорошие тканевые руки для DPS"] = "good cloth gloves for DPS",
    ["хороший кинжал для интовиков"] = "good dagger for Intellect specs",
    ["хороший кольчужный шлем, но даёт меньше стат"] = "good mail helm, but lower stats",
    ["хороший офф-хенд на интовиков"] = "good off-hand for Intellect specs",
    ["хороший тканевый пояс"] = "good cloth belt",
    ["хороший тканевый шлем для хиллеров, первая часть \"манасета\""] = "good cloth helm for healers, first piece of the \"mana set\"",
}

-- Названия слотов на русском. Английские — из словаря выше, не из клиента:
-- принудительный английский на русском клиенте иначе оставляет «Голова».
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

-- Названия классов на русском. Английские — из словаря, не из клиента.
-- Ключи - те же, что в Data.lua.
local CLASS_RU = {
    WARRIOR = "Воин",             PALADIN = "Паладин",
    HUNTER = "Охотник",           ROGUE = "Разбойник",
    PRIEST = "Жрец",              DEATHKNIGHT = "Рыцарь смерти",
    SHAMAN = "Шаман",             MAGE = "Маг",
    WARLOCK = "Чернокнижник",     MONK = "Монах",
    DRUID = "Друид",              DEMONHUNTER = "Охотник на демонов",
    EVOKER = "Пробудитель",
}

-- Выбранный язык. Пока ADDON_LOADED не пришёл, сохранённых настроек нет —
-- не запоминаем ruRU с загрузки файлов, иначе английский выбор потом
-- не перебьёт кэш.
local resolved
local loaded

local function Resolve()
    if loaded and resolved then return resolved end
    local saved = TrialGearFinderDB and TrialGearFinderDB.locale or "auto"
    local value = (saved == "auto") and GetLocale() or saved
    if loaded then resolved = value end
    return value
end

-- Перевод строки. Вызывается и как L("текст"), и как L"текст".
function ns.L(text)
    if Resolve() == "ruRU" then return text end
    return enUS[text] or text
end

-- Название слота по настройке аддона, не по языку клиента.
function ns.SlotName(invType)
    local ru = INVTYPE_RU[invType]
    if ru then return ns.L(ru) end
    return _G[invType] or invType
end

-- Название класса по настройке аддона, не по языку клиента.
function ns.ClassName(token)
    local ru = CLASS_RU[token]
    if ru then return ns.L(ru) end
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or token
end

-- Название спека по настройке аддона. Номера — те же, что у игры и в Talents.lua.
local SPEC_RU = {
    [71] = "Оружие", [72] = "Неистовство", [73] = "Защита",
    [65] = "Свет", [66] = "Защита", [70] = "Воздаяние",
    [253] = "Повелитель зверей", [254] = "Стрельба", [255] = "Выживание",
    [259] = "Ликвидация", [260] = "Головорез", [261] = "Скрытность",
    [256] = "Послушание", [257] = "Свет", [258] = "Тьма",
    [250] = "Кровь", [251] = "Лёд", [252] = "Нечестивость",
    [262] = "Стихии", [263] = "Совершенствование", [264] = "Исцеление",
    [62] = "Тайная магия", [63] = "Огонь", [64] = "Лед",
    [265] = "Колдовство", [266] = "Демонология", [267] = "Разрушение",
    [268] = "Хмелевар", [269] = "Танцующий с ветром", [270] = "Ткач туманов",
    [102] = "Баланс", [103] = "Сила зверя", [104] = "Страж", [105] = "Исцеление",
    [577] = "Истребление", [581] = "Месть", [1480] = "Пожиратель",
    [1467] = "Опустошитель", [1468] = "Хранитель", [1473] = "Насыщатель",
}

function ns.SpecName(specID)
    local ru = SPEC_RU[specID]
    if ru then return ns.L(ru) end
    local name = specID and GetSpecializationInfoByID and select(2, GetSpecializationInfoByID(specID))
    return name or tostring(specID or "?")
end

-- Язык КЛИЕНТА, не выбор в Параметрах. Нужно там, где разбирается тултип
-- предмета: карточка рисуется игрой, и на русском клиенте с английским окном
-- строки всё равно «+7 к ловкости». Если смотреть Resolve(), правка статов
-- молча отключается, а сверка копии пишет «отличается от базы».
function ns.IsRussian()
    return GetLocale() == "ruRU"
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
    loaded = true
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

    local function JournalFlag(key)
        return not TrialGearFinderDB or TrialGearFinderDB[key] ~= false
    end

    local function SetJournalFlag(key, value)
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB[key] = value and true or false
        if ns.RefreshJournal then ns.RefreshJournal() end
    end

    local badgeSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_JOURNAL_TW_BADGE",
        Settings.VarType.Boolean, L"Значок Путешествия во времени на плитках", true,
        function() return JournalFlag("journalTWBadge") end,
        function(value) SetJournalFlag("journalTWBadge", value) end)
    Settings.CreateCheckbox(category, badgeSetting,
        L"Показывать знак валюты в углу плитки, если у данжа есть сложность Путешествия во времени.")

    local seasonSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_JOURNAL_TW_SEASON",
        Settings.VarType.Boolean, L"Данжи Путешествия во времени на текущем сезоне", true,
        function() return JournalFlag("journalTWSeason") end,
        function(value) SetJournalFlag("journalTWSeason", value) end)
    Settings.CreateCheckbox(category, seasonSetting,
        L"На вкладке текущего сезона показывать данжи текущей недели Путешествия во времени вместо ключей Midnight.")

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
