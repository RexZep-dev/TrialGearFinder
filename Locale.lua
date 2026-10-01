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
-- Общие данные ядра - модулям. «Сборки» и «Журнал» - отдельные аддоны
-- в списке аддонов (как у GatherMate2), и у каждого аддона свой `...`:
-- свою таблицу ядра модуль иначе не увидит. Одна глобальная ссылка.
TrialGearFinderNS = ns

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
    ["Ловк."]              = "Agi",
    ["Инт."]               = "Int",
    ["Вын."]               = "Sta",
    ["Крит"]               = "Crit",
    ["Скор."]              = "Haste",
    ["Иск."]               = "Mast",
    ["Унив."]              = "Vers",

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
    ["Сборки"]         = "Builds",
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
    ["Ранг"]               = "Tier",
    ["Ранг аксессуара для спека: S лучший, дальше A, B, C"] = "Trinket tier for the spec: S is best, then A, B, C",
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
    ["|cFF86C7BD[TGF]|r Сначала открой окно сборок и выбери спек: /tgf bis"] =
        "|cFF86C7BD[TGF]|r Open the builds window and pick a spec first: /tgf bis",
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
    ["Разрушенные залы"] = "The Shattered Halls",
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
    ["Путешествие во времени: Нордскол"] = "Timewalking: Northrend",
    ["Подземелья Дренора"] = "Draenor dungeons",
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
        "|cFFFFD100[TGF]|r No entrance for your faction on %s yet. Pin the entrance, then /tgf pin жила horde or /tgf pin жила alliance.",
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


    -- Окно сравнения со сборкой (Compare.lua)
    ["Сборка"] = "Build",
    ["%d-го уровня"] = "level %d",
    ["Нет чар"] = "No enchant",
    ["Диаграмма"] = "Chart",
    ["Цифры"] = "Numbers",
    ["Персонажи"] = "Characters",
    ["Диаграммы"] = "Charts",
    ["Сравнить"] = "Compare",
    ["Сравнить сборку с надетым"] = "Compare the build with your gear",
    ["Слева сборка твоего спека, справа то, что на тебе. То же окно - /tgf compare."] = "Your spec build on the left, what you wear on the right. Same window: /tgf compare.",

    ["Классические земли (мировой дроп)"] = "Classic zones (world drop)",
    ["Цитадель Адского Пламени"] = "Hellfire Citadel",

    -- Подземелья Путешествия во времени (Timewalk.lua): названия сняты
    -- с русского журнала игры, английские - официальные.
    ["Мертвые копи"] = "The Deadmines",
    ["Стратхольм – главные врата"] = "Stratholme - Main Gate",
    ["Чертоги Молний"] = "Halls of Lightning",
    ["Затерянный город Тол'вир"] = "Lost City of the Tol'vir",
    ["Каменные Недра"] = "The Stonecore",
    ["Пещеры Черной горы"] = "Blackrock Caverns",
    ["Трон Приливов"] = "Throne of the Tides",
    ["Аукиндон"] = "Auchindoun",
    ["Вечное Цветение"] = "The Everbloom",
    ["Квартал Звезд"] = "Court of Stars",
    ["Крепость Черной Ладьи"] = "Black Rook Hold",
    ["Чаща Темного Сердца"] = "Darkheart Thicket",
    ["Атал'Дазар"] = "Atal'Dazar",
    ["Гробница королей"] = "Kings' Rest",
    ["Святилище Штормов"] = "Shrine of the Storm",
    ["Кровавые катакомбы"] = "Sanguine Depths",
    ["Та Сторона"] = "De Other Side",
    ["Шпили Перерождения"] = "Spires of Ascension",
    ["Академия Алгет'ар"] = "Algeth'ar Academy",
    ["Лощина Бурошкуров"] = "Brackenhide Hollow",
    ["Чертоги Насыщения"] = "Halls of Infusion",
    ["Нелтарий"] = "Neltharus",
    ["Рубиновые Омуты Жизни"] = "Ruby Life Pools",
    ["Лазурное хранилище"] = "The Azure Vault",
    ["Забытый город – палаты Гордока"] = "Dire Maul - Gordok Commons",
    ["Забытый город – центральный сад"] = "Dire Maul - Capital Gardens",
    ["Забытый город – квартал Криводревов"] = "Dire Maul - Warpwood Quarter",
    ["Зул'Фаррак"] = "Zul'Farrak",
    ["Стратхольм – черный ход"] = "Stratholme - Service Entrance",
    ["Гундрак"] = "Gundrak",
    ["Конец Времен"] = "End Time",
    ["Врата Заходящего Солнца"] = "Gate of the Setting Sun",
    ["Дворец Могу'шан"] = "Mogu'shan Palace",
    ["Монастырь Шадо-Пан"] = "Shado-Pan Monastery",
    ["Хмелеварня Буйных Портеров"] = "Stormstout Brewery",
    ["Храм Нефритовой Змеи"] = "Temple of the Jade Serpent",
    ["Депо Мрачных Путей"] = "Grimrail Depot",
    ["Небесный Путь"] = "Skyreach",
    ["Некрополь Призрачной Луны"] = "Shadowmoon Burial Grounds",
    ["Шлаковые шахты Кровавого Молота"] = "Bloodmaul Slag Mines",
    ["Казематы Стражей"] = "Vault of the Wardens",
    ["Вольная Гавань"] = "Freehold",

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
    ["Открыть сборки"] = "Open builds",
    ["Свернуть сборки"] = "Collapse builds",
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
        "|cFFFFD100[TGF]|r Motherlode has two entrances: /tgf pin жила horde or /tgf pin жила alliance",
    ["|cFFFFD100[TGF]|r Укажи сторону: /tgf pin жила орда  или  /tgf pin жила альянс"] =
        "|cFFFFD100[TGF]|r Say which side: /tgf pin жила horde or /tgf pin жила alliance",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе не найден."] =
        "|cFFFFD100[TGF]|r No source containing %s in the database.",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе и в журнале не найден."] =
        "|cFFFFD100[TGF]|r No source containing %s in the database or the journal.",
    ["|cFFFFD100[TGF]|r Модуль «Сборки» выключен в списке аддонов."] =
        "|cFFFFD100[TGF]|r The Builds module is disabled in the AddOns list.",
    ["|cFFFFD100[TGF]|r Модуль «Журнал» выключен в списке аддонов."] =
        "|cFFFFD100[TGF]|r The Journal module is disabled in the AddOns list.",
    ["|cFFFFD100[TGF]|r Журнал подземелий недоступен."] =
        "|cFFFFD100[TGF]|r Encounter Journal is not available.",
    ["|cFFFFD100[TGF]|r В журнале %d подземелий: с меткой %d, без метки %d."] =
        "|cFFFFD100[TGF]|r Journal has %d dungeons: %d pinned, %d without a pin.",
    ["|cFFFFD100[TGF]|r Без метки из журнала: /tgf pin список"] =
        "|cFFFFD100[TGF]|r Unpinned from the journal: /tgf pin list",
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
    ["|cFF86C7BD[TGF]|r Окно сборок ещё не открывалось: /tgf bis"] =
        "|cFF86C7BD[TGF]|r Open the builds window first: /tgf bis",
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
    ["# TrialGearFinder: сборка, %s %s"] = "# TrialGearFinder: build, %s %s",
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
    ["# Цель — моб 45 уровня: сборка считается по самым сложным подземельям."] =
        "# Target is a level-45 mob: the build is scored against the hardest dungeons.",
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

    -- 1 октября: проверка полноты перевода
    ["Только для своего класса: чужую сборку с твоими вещами не сравнить."] = "Own class only: another class's build can't be compared with your gear.",
    ["[TGF] %s | гн %d/%d | sb %s | камни %s"] = "[TGF] %s | sockets %d/%d | sb %s | gems %s",
    ["[TGF] %d %s | ур%s | %s | гн%d%s"] = "[TGF] %d %s | ilvl%s | %s | sockets%d%s",
    ["|cFFFFD100[TGF]|r Команды разработчика: %s"] = "|cFFFFD100[TGF]|r Developer commands: %s",
    ["включены"] = "on",
    ["выключены"] = "off",
    ["Отладка"] = "Debug",
    ["Команды разработчика (/tgf debug, ui, names, pins) и кнопка SimC в окне «Сборки». Для проверки и отчётов об ошибках."] = "Developer commands (/tgf debug, ui, names, pins) and the SimC button in the Builds window. For testing and bug reports.",
    ["|cFFFFD100[TGF]|r Неизвестная команда. Команды разработчика включаются галочкой «Отладка» в Параметрах."] = "|cFFFFD100[TGF]|r Unknown command. Developer commands are enabled by the Debug checkbox in Options.",
    -- Были только в китайском словаре (проверка 1 октября)
    ["крафт (инженерия Пандарии, надеть может только инженер); Заряженная ретинальная защита: кольчужный шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Energized Retinal Armor: mail helm, a meta socket and two cogwheel sockets",
    ["крафт (инженерия Пандарии, надеть может только инженер); Легкая ретинальная защита: тканевый шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Lightweight Retinal Armor: cloth helm, a meta socket and two cogwheel sockets",
    ["крафт (инженерия Пандарии, надеть может только инженер); Маскировочная ретинальная защита: кожаный шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Camouflage Retinal Armor: leather helm, a meta socket and two cogwheel sockets",
    ["крафт (инженерия Пандарии, надеть может только инженер); Подвижная ретинальная защита: кожаный шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Agile Retinal Armor: leather helm, a meta socket and two cogwheel sockets",
    ["крафт (инженерия Пандарии, надеть может только инженер); Смертоносная ретинальная защита: кольчужный шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Deadly Retinal Armor: mail helm, a meta socket and two cogwheel sockets",
    ["крафт (инженерия Пандарии, надеть может только инженер); Специализированная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Specialized Retinal Armor: plate helm, a meta socket and two cogwheel sockets",
    ["крафт (инженерия Пандарии, надеть может только инженер); Усиленная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса"] = "crafted (Pandaria Engineering, engineers only); Reinforced Retinal Armor: plate helm, a meta socket and two cogwheel sockets",
    ["+10 к силе"] = "+10 Strength",
    ["+11 к силе заклинаний"] = "+11 Spell Power",
    ["+12 к ловкости"] = "+12 Agility",
    ["+2 к искусности и небольшой бонус к скорости"] = "+2 Mastery and minor run speed increase",
    ["+2 к силе атаки и +2 к вероятности критического удара"] = "+2 Attack Power and +2 Critical Strike",
    ["+3 к выносливости и небольшое увеличение скорости"] = "+3 Stamina and minor run speed increase",
    ["+3 к интеллекту и +2 к универсальности"] = "+3 Intellect and +2 Versatility",
    ["+3 к ловкости и +2 к вероятности критического удара"] = "+3 Agility and +2 Critical Strike",
    ["+3 к силе атаки"] = "+3 Attack Power",
    ["+3 к силе заклинаний"] = "+3 Spell Power",
    ["+3 к силе заклинаний и +1 к вероятности критического удара"] = "+3 Spell Power and +1 Critical Strike",
    ["+3 к силе и +2 к вероятности критического удара"] = "+3 Strength and +2 Critical Strike",
    ["+3 к скорости"] = "+3 Haste",
    ["+3 к универсальности"] = "+3 Versatility",
    ["+3 ко всем характеристикам"] = "+3 All Stats",
    ["+4 к вероятности критического удара"] = "+4 Critical Strike",
    ["+4 к выносливости"] = "+4 Stamina",
    ["+4 к интеллекту"] = "+4 Intellect",
    ["+4 к искусности"] = "+4 Mastery",
    ["+4 к ловкости"] = "+4 Agility",
    ["+4 к основной характеристике"] = "+4 Primary Stat",
    ["+4 к силе"] = "+4 Strength",
    ["+4 к силе заклинаний"] = "+4 Spell Power",
    ["+4 к скорости"] = "+4 Haste",
    ["+4 к универсальности"] = "+4 Versatility",
    ["+5 к интеллекту и +3 к выносливости"] = "+5 Intellect and +3 Stamina",
    ["+5 к интеллекту и +5% маны"] = "+5 Intellect and +5% Mana",
    ["Затененная поясная застежка"] = "Shadowed Belt Clasp",
    ["Знак когтя"] = "Mark of the Claw",
    ["Знак незримого сатира"] = "Mark of the Hidden Satyr",
    ["Знак подготовленного солдата"] = "Mark of the Trained Soldier",
    ["Прицел (+2 к урону)"] = "Scope (+2 Damage)",
    ["Пробужденные характеристики"] = "Waking Stats",
    ["Руна каменной горгульи"] = "Rune of the Stoneskin Gargoyle",
    ["Руна павшего рыцаря"] = "Rune of the Fallen Crusader",
    ["Руна режущего льда"] = "Rune of Razorice",
    ["Рыцарь"] = "Crusader",
    ["Танцующая сталь"] = "Dancing Steel",
    ["Китайский"] = "Chinese",
    ["[Танк] падает с Хадронокса; Квинтэссенция паутины: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23"] = "[Tank] drops from Hadronox; Essence of Gossamer: Timewalking version, item level 32. The dungeon copy in the guide is a different item, level 23",
    ["[Хил] падает с Жрицы Делриссы; Флакон воды из Солнечного Колодца: универсальность, по использованию накопленный свет"] = "[Healer] drops from Priestess Delrissa; Vial of the Sunwell: Versatility, on use releases stored light",
    ["Драгоценная петля из кровошипа: берут ради эффекта (шипы и незаметность), BiS - любая копия; с Горума (слепок: 17 копий 23 ур. без гнезда)"] = "Precious Bloodthorn Loop: taken for its effect (thorns and stealth), any copy is BiS; from Gorum (snapshot: 17 copies, level 23, no socket)",
    ["Наручи Кишкодава: латные запястья, без гнезда. Случайная добыча в подземельях Дренора (Крушто, Нхаллиш, Аззакель) и в тайниках, 1-3%"] = "Gutcrusher Bracers: plate wrists, no socket. Random drop in Draenor dungeons (Crushto, Nhallish, Azzakel) and in caches, 1-3%",
    ["Наручи огненной собранности: кожаные запястья, одно гнездо. Случайная добыча в подземельях Дренора (Крушто, Нхаллиш, Аззакель) и в тайниках, 1,5-3%"] = "Bracers of Burning Focus: leather wrists, one socket. Random drop in Draenor dungeons (Crushto, Nhallish, Azzakel) and in caches, 1.5-3%",
    ["падает с Аззакеля; Кровавая печать Аззакеля: аксессуар на ловкость и крит"] = "drops from Azzakel; Blood Seal of Azzakel: Agility and Critical Strike trinket",
    ["падает с Верховной жрицы Азил (Каменные Недра); Элементиевый клык: одноручный меч на силу, крит/искусность. Тир 32"] = "drops from High Priestess Azil (The Stonecore); Elementium Fang: one-hand Strength sword, Critical Strike/Mastery. Tier 32",
    ["падает с Вождя Каргата Острорука; Рука-клинок: одноручное кистевое, версия 26. Не путать с Рукой-клинком из Разрушенных залов (та 23). Прок скорости на 10 сек при ударе, откат 45 сек"] = "drops from Warchief Kargath Bladefist; The Bladefist: one-hand fist weapon, level 26 version. Not the Bladefist from the Shattered Halls (that one is 23). Haste proc for 10 sec on hit, 45 sec cooldown",
    ["падает с Вождя Укорза Песчаного Черепа; Головорез вождя: двуручный посох на ловкость, уровень 23"] = "drops from Chief Ukorz Sandscalp; The Chief's Enforcer: two-hand Agility staff, item level 23",
    ["падает с Дозорного Каатара; Кристаллический волшебный посох Камуи: двуручный, интеллект 30"] = "drops from Vigilant Kaathar; Kamui's Crystalline Staff of Wizardry: two-hand, 30 Intellect",
    ["падает с Дулгу и других в Вечном Цветении; Лист древних защитников: аксессуар на искусность, по использованию щит на союзника"] = "drops from Dulhu and others in The Everbloom; Leaf of the Ancient Protectors: Mastery trinket, on use shields an ally",
    ["падает с Императора Даграна Тауриссана; Сталебой: одноручное дробящее, уровень 26. Атаки могут сработать дважды"] = "drops from Emperor Dagran Thaurissan; Ironfoe: one-hand mace, item level 26. Attacks can strike twice",
    ["падает с Кель'таса; Одеяния летнего великолепия: кожаная грудь, три бесцветных гнезда"] = "drops from Kael'thas Sunstrider; Robes of Summer Flame: leather chest, three prismatic sockets",
    ["падает с Локена (Чертоги Молний); те же Улучшенные поручи, версия Путешествия во времени, уровень 32, без гнезда"] = "drops from Loken (Halls of Lightning); the same Advanced Tooled-Leather Bands, Timewalking version, item level 32, no socket",
    ["падает с Локена; Улучшенные поручи из выделанной кожи: кожа, уровень 23, одно гнездо"] = "drops from Loken; Advanced Tooled-Leather Bands: leather, item level 23, one socket",
    ["падает с Надсмотрщика за рабами Крушто; Обезглавливатель Крушто: двуручное древковое на ловкость"] = "drops from Slave Watcher Crushto; Crushto's Neck Separator: two-hand Agility polearm",
    ["падает с Пожирателя Душ; Воплощение мечты: кожаные кисти, Путешествие во времени, уровень 32"] = "drops from Devourer of Souls; Essence of Desire: leather hands, Timewalking, item level 32",
    ["падает с Хадронокса; Перчатки Туманного грота: кожа, Путешествие во времени, уровень 32"] = "drops from Hadronox; Grotto Mist Gloves: leather, Timewalking, item level 32",
    ["падает с Черепона; Окровавленная рука горести: одноручное кистевое на ловкость"] = "drops from Skulloc; Bloodied Hand of Woe: one-hand Agility fist weapon",
    ["падает со Скарвальда Строителя (Крепость Утгард); Наручники проходчика: кожа, Путешествие во времени, уровень 32. Шанс мал, 0,2%"] = "drops from Skarvald the Constructor (Utgarde Keep); Bindings of the Tunneler: leather, Timewalking, item level 32. Low chance, 0.2%",
    ["Баланс: лучшая из 14 сборок двадцаток гильдии"] = "Balance: best of 14 guild level-20 builds",
    ["Воздаяние: сборка Эбеко, лучшая из 43 сборок двадцаток гильдии"] = "Retribution: Эбеко's build, best of 43 guild level-20 builds",
    ["Выживание: Обрез, Остриё копья, Дикий огонь, Команда «Взять!», Удар ящера"] = "Survival: Boomstick, Spearhead, Wildfire, Kill Command, Raptor Strike",
    ["Защита: сборка Кавочавоо"] = "Protection: Кавочавоо's build",
    ["Защита: сборка Пурдюшечки, лучшая из 37 сборок двадцаток гильдии"] = "Protection: Пурдюшечка's build, best of 37 guild level-20 builds",
    ["Исцеление: сборка двадцатки гильдии. Лекаря симулятор не считает — не замерена"] = "Restoration: a guild level-20 build. The simulator doesn't model healers — not measured",
    ["Кровь: лучшая из сборок двадцаток гильдии"] = "Blood: best of the guild level-20 builds",
    ["Лёд: лучшая из сборок двадцаток гильдии"] = "Frost: best of the guild level-20 builds",
    ["Неистовство: сборка Кавочавоо, 247 заходов в логах рейтинга"] = "Fury: Кавочавоо's build, 247 runs in the ranking logs",
    ["Нечестивость: лучшая из сборок двадцаток гильдии"] = "Unholy: best of the guild level-20 builds",
    ["Оружие: сборка Кавочавоо"] = "Arms: Кавочавоо's build",
    ["Повелитель зверей: Команда «Взять!», Звериный гнев, Дикий трепет, Ужасный зверь, Спутник животного. Без Разрывающего и Кобры"] = "Beast Mastery: Kill Command, Bestial Wrath, Wild Thrash, Dire Beast, Animal Companion. No Barbed Shot or Cobra Shot",
    ["Свет: сборка Keotore с армори 21 сентября. Лекаря симулятор не считает — код не замерен уроном"] = "Holy: Keotore's build from the armory, September 21. The simulator doesn't model healers — not measured by damage",
    ["Сила зверя: лучшая из 16 сборок двадцаток гильдии"] = "Feral: best of 16 guild level-20 builds",
    ["Страж: лучшая из 14 сборок двадцаток гильдии"] = "Guardian: best of 14 guild level-20 builds",
    ["Стрельба: лучшая из тех, где есть Быстрая стрельба — её жмут 98 % игроков"] = "Marksmanship: best of those with Rapid Fire — 98% of players press it",
}

-- 中文翻译：[俄语字符串] = "中文"
local zhCN = {
    -- 窗口与控件
    ["ПОИСК ШМОТА ДЛЯ ТРИАЛА"] = "试玩装备查找器",
    ["Поиск"]              = "搜索",
    ["Все"]                = "全部",
    [": Все"]              = "：全部",
    ["Слот"]               = "部位",
    ["Класс"]              = "职业",
    ["Броня"]              = "护甲",
    ["Источник"]           = "来源",
    ["Предмет"]            = "物品",
    ["Крафт"]              = "制造",
    ["Фамильные вещи"]     = "传家宝",

    -- 属性
    ["Сила"]               = "力量",
    ["Броня"]              = "护甲",
    ["Ловкость"]           = "敏捷",
    ["Интеллект"]          = "智力",
    ["Выносливость"]       = "耐力",
    ["Критический удар"]   = "暴击",
    ["Скорость"]           = "急速",
    ["Искусность"]         = "精通",
    ["Универсальность"]    = "全能",
    ["Ловк."]              = "敏",
    ["Инт."]               = "智",
    ["Вын."]               = "耐",
    ["Крит"]               = "暴",
    ["Скор."]              = "急",
    ["Иск."]               = "精",
    ["Унив."]              = "全",

    -- 插槽
    ["особое"]             = "多彩",
    ["бесцветное"]         = "棱彩",
    ["красное"]            = "红色",
    ["жёлтое"]             = "黄色",
    ["синее"]              = "蓝色",
    ["шестерёнка"]         = "齿轮",
    ["владычества"]        = "统御",
    ["гнездо"]             = "插槽",
    ["гнёзда"]             = "插槽",

    ["Голова"]             = "头部",
    ["Шея"]                = "颈部",
    ["Плечи"]              = "肩部",
    ["Спина"]              = "背部",
    ["Грудь"]              = "胸部",
    ["Запястья"]           = "手腕",
    ["Кисти рук"]          = "手",
    ["Пояс"]               = "腰部",
    ["Ноги"]               = "腿部",
    ["Ступни"]             = "脚",
    ["Палец"]              = "手指",
    ["Аксессуар"]          = "饰品",
    ["Щит"]                = "盾牌",
    ["Одноручное"]         = "单手",
    ["Двуручное"]          = "双手",
    ["Правая рука"]        = "主手",
    ["Левая рука"]         = "副手",
    ["Дальнобойное"]       = "远程",

    -- BiS 配装窗口
    ["Сборки"]         = "配装",
    ["ИТОГ СБОРКИ"]        = "配装总计",
    ["Таланты"]            = "天赋",
    ["Кисти"]              = "手",
    ["Кольцо 1"]           = "戒指 1",
    ["Кольцо 2"]           = "戒指 2",
    ["Аксессуар 1"]        = "饰品 1",
    ["Аксессуар 2"]        = "饰品 2",
    ["— двуручное"]        = "— 双手",
    ["[Танк]"]             = "[坦克]",
    ["[ДД]"]               = "[输出]",
    ["[Хил]"]              = "[治疗]",
    ["Чара: "]             = "附魔：",
    ["Источник: "]         = "来源：",
    ["Статы: "]            = "属性：",
    ["Статы (наш замер): "] = "属性（我们的模拟）：",
    ["Прок; в счёт идёт средний вклад за бой."] = "触发；按战斗中平均贡献计算。",
    ["Пред-BiS от сообщества — не из гайда гильдии, но выбить может любой."] =
        "社区准BiS——不是公会攻略，但任何人都能刷。",
    ["Путешествие во времени из журнала — не гайд главы гильдии."] =
        "时空漫游数据来自冒险指南，非公会攻略",
    ["|cffE06C5EПеребор: после 30% каждая единица рейтинга даёт на 10% меньше|r"] =
        "|cffE06C5E溢出：超过30%后每点等级收益降低10%|r",
    ["  |cff5fd35fвыше гайда|r"]  = "  |cff5fd35f高于攻略|r",
    ["  |cff9a9a9aнет в гайде|r"] = "  |cff9a9a9a攻略中没有|r",
    ["  |cff9a9a9aпред-BiS|r"]    = "  |cff9a9a9a准BiS|r",
    ["  |cff3fc7ebТайм Волк|r"]   = "  |cff3fc7eb时空漫游|r",
    [" - чара: "]                 = " - 附魔：",
    [" (номера нет, в симе не учтена)"] = "（没有编号，模拟中未计入）",

    -- 主窗口
    ["Поиск"]              = "搜索",
    ["Предмет"]            = "物品",
    ["Комьюнити"]          = "社区",
    ["Мин-Макс"]           = "缩放",

    -- 护甲材质与来源类型
    ["Ткань"]              = "布甲",
    ["Кожа"]               = "皮甲",
    ["Кольчуга"]           = "锁甲",
    ["Латы"]               = "板甲",
    ["Подземелье"]         = "地下城",
    ["Квест"]              = "任务",
    ["Рарники"]            = "稀有怪",
    ["Фамильные вещи"]     = "传家宝",
    ["%d ур."]             = "装等 %d",

    -- 聊天消息
    ["|cFF86C7BD[TGF]|r Сначала открой окно сборок и выбери спек: /tgf bis"] =
        "|cFF86C7BD[TGF]|r 请先打开配装窗口并选择专精：/tgf bis",
    ["|cFF86C7BD[TGF]|r Профиль SimC — в окне копирования: Ctrl+C и вставить в Advanced Sim на Raidbots."] =
        "|cFF86C7BD[TGF]|r SimC配置在复制窗口中：Ctrl+C，然后粘贴到Raidbots的Advanced Sim。",

    -- 地下城与掉落地点
    ["Азжол-Неруб"] = "艾卓-尼鲁布",
    ["Аукенайские гробницы"] = "奥金尼地穴",
    ["Ботаника"] = "生态船",
    ["Вершина Смерча"] = "漩涡尖塔",
    ["Глубины Черной горы"] = "黑石深渊",
    ["Гробницы маны"] = "法力陵墓",
    ["Долина Призрачной Луны"] = "影月谷",
    ["Дренор (рарники, раз в день)"] = "德拉诺（稀有怪，每日一次）",
    ["Железные доки"] = "钢铁码头",
    ["Зандалар (рарники, раз на персонажа)"] = "赞达拉（稀有怪，每角色一次）",
    ["Инженерия"] = "工程学",
    ["Крепость Темного Клыка"] = "影牙城堡",
    ["Кузня Душ"] = "灵魂熔炉",
    ["Кузня Крови"] = "鲜血熔炉",
    ["Кул-Тирас (рарники, раз на персонажа)"] = "库尔提拉斯（稀有怪，每角色一次）",
    ["Логово Нелтариона"] = "奈萨里奥的巢穴",
    ["Мародон"] = "玛拉顿",
    ["Механар"] = "能源舰",
    ["Награнд"] = "纳格兰",
    ["Некроситет"] = "通灵学院",
    ["Нексус"] = "魔枢",
    ["Нижетопь"] = "幽暗沼泽",
    ["Низина Шолазар"] = "索拉查盆地",
    ["Око Азшары"] = "艾萨拉之眼",
    ["Окулус"] = "魔环",
    ["Очищение Стратхольма"] = "净化斯坦索姆",
    ["Паровое подземелье"] = "蒸汽地窟",
    ["Разрушенные залы"] = "破碎大厅",
    ["Сетеккские залы"] = "塞泰克大厅",
    ["Старые предгорья Хилсбрада"] = "旧希尔斯布莱德丘陵",
    ["Стратхольм"] = "斯坦索姆",
    ["Темный лабиринт"] = "暗影迷宫",
    ["Терраса Магистров"] = "魔导师平台",
    ["Узилище"] = "奴隶围栏",
    ["Ульдаман"] = "奥达曼",
    ["Усадьба Уэйкрестов"] = "维克雷斯庄园",
    ["Чумные каскады"] = "凋魂之殇",
    ["Штурм Аметистовой крепости"] = "紫罗兰监狱突袭",
    ["Яма Сарона"] = "萨隆矿坑",
    ["Залы Алого ордена"] = "血色大厅",
    ["Стратхольм - Чёрный ход"] = "斯坦索姆 - 后门",
    ["Берега Пробуждения"] = "觉醒海岸",
    ["Грим Батол"] = "格瑞姆巴托",
    ["Крепость Утгард"] = "乌特加德城堡",
    ["Лазурные Врата"] = "碧蓝魔馆",
    ["Лазурный Простор"] = "碧蓝林海",
    ["Наступление Нохуда"] = "诺库德阻击战",
    ["Путешествие во времени: Катаклизм"] = "时空漫游：大灾变",
    ["Путешествие во времени: Пандария"] = "时空漫游：潘达利亚",
    ["Путешествие во времени: Нордскол"] = "时空漫游：诺森德",
    ["Подземелья Дренора"] = "德拉诺地下城",
    ["Равнины Он'ары"] = "欧恩哈拉平原",
    ["Смертельная тризна"] = "凋骨之殇",
    ["Танаанские джунгли"] = "塔纳安丛林",
    ["Театр Боли"] = "苦痛剧场",
    ["Ульдаман: наследие Тира"] = "奥达曼：提尔的遗产",
    ["Чертоги Покаяния"] = "赎罪大厅",
    ["ЗОЛОТАЯ ЖИЛА!!!"] = "暴富矿区！！",
    ["Храм Сетралисс"] = "塞塔里斯神庙",
    ["Зул'Драк — задание «Чемпион Амфитеатра Страданий»"] = "祖达克 - 任务“痛苦斗兽场冠军”",
    ["Задание «Битва за Расколотый берег» — только Альянс"] = "任务“破碎海滩之战” - 仅限联盟",
    ["Крафт (аукцион)"] = "制造（拍卖行）",
    ["уточнить"] = "待确认",

    ["Щелчок - открыть окно"]     = "点击打开窗口",
    ["Перетаскивание - двигать по краю карты"] = "拖动可沿小地图边缘移动",
    ["Щелчок - поставить метку на карте"] = "点击在地图上放置标记",
    ["Ctrl+щелчок - запомнить текущую метку для этого источника"] =
        "Ctrl+点击记住此来源的当前标记",
    ["|cFFFFD100[TGF]|r Координаты для «%s» ещё не заданы."] =
        "|cFFFFD100[TGF]|r “%s”尚未设置坐标。",
    ["|cFFFFD100[TGF]|r Для «%s» вход вашей фракции ещё не снят. Метка на входе, потом /tgf pin жила орда  или  /tgf pin жила альянс."] =
        "|cFFFFD100[TGF]|r “%s”尚未记录你阵营的入口。先标记入口，然后 /tgf pin жила horde 或 /tgf pin жила alliance。",
    ["Альянс"] = "联盟",
    ["Орда"] = "部落",
    ["|cFFFFD100[TGF]|r Сначала поставь метку на карте (Ctrl+щелчок по карте), потом Ctrl+щелчок по источнику."] =
        "|cFFFFD100[TGF]|r 先在地图上放标记（Ctrl+点击地图），然后Ctrl+点击来源。",

    ["|cFFFFD100[TGF]|r Путешествие во времени: вход только через поиск подземелий, в неделю события."] =
        "|cFFFFD100[TGF]|r 时空漫游：仅在活动周通过地下城查找器进入。",
    ["Сейчас: %s (до %s)"] = "当前：%s（至 %s）",
    ["Сейчас: %s"] = "当前：%s",
    ["Сейчас нет Путешествия во времени"] = "当前没有时空漫游活动",
    ["Следующее: %s"] = "下一个：%s",
    ["В календаре пока нет ближайшего Путешествия во времени"] =
        "日历上还没有即将到来的时空漫游",
    ["января"] = "1月",
    ["февраля"] = "2月",
    ["марта"] = "3月",
    ["апреля"] = "4月",
    ["мая"] = "5月",
    ["июня"] = "6月",
    ["июля"] = "7月",
    ["августа"] = "8月",
    ["сентября"] = "9月",
    ["октября"] = "10月",
    ["ноября"] = "11月",
    ["декабря"] = "12月",
    ["Классика"] = "经典旧世",
    ["Гнев Короля-лича"] = "巫妖王之怒",
    ["Катаклизм"] = "大灾变",
    ["Пандария"] = "潘达利亚",
    ["Дренор"] = "德拉诺",
    ["Легион"] = "军团再临",
    ["Битва за Азерот"] = "争霸艾泽拉斯",
    ["Темные земли"] = "暗影国度",
    ["Драконы"] = "巨龙时代",
    ["Значок Путешествия во времени на плитках"] =
        "地下城格子上的时空漫游标记",
    ["Показывать знак валюты в углу плитки, если у данжа есть сложность Путешествия во времени."] =
        "当地下城有时空漫游难度时，在格子角落显示货币图标。",
    ["Данжи Путешествия во времени на текущем сезоне"] =
        "当前赛季标签页上的时空漫游地下城",
    ["На вкладке текущего сезона показывать данжи текущей недели Путешествия во времени вместо ключей Midnight."] =
        "在当前赛季标签页上显示本周时空漫游地下城，而不是至暗之夜钥石地下城。",
    ["|cFFFFD100[TGF]|r На этой карте игра не разрешает ставить метку."] =
        "|cFFFFD100[TGF]|r 游戏不允许在此地图上放置标记。",

    -- 对比窗口
    ["Сборка"] = "配装",
    ["%d-го уровня"] = "%d级",
    ["Нет чар"] = "无附魔",
    ["Диаграмма"] = "图表",
    ["Цифры"] = "数字",
    ["Персонажи"] = "角色",
    ["Диаграммы"] = "图表",
    ["Сравнить"] = "对比",
    ["Сравнить сборку с надетым"] = "将配装与当前装备对比",
    ["Слева сборка твоего спека, справа то, что на тебе. То же окно - /tgf compare."] = "左边是你专精的配装，右边是你当前装备。同一窗口：/tgf compare。",

    ["Классические земли (мировой дроп)"] = "经典旧世区域（世界掉落）",
    ["Цитадель Адского Пламени"] = "地狱火堡垒",

    -- 时空漫游地下城
    ["Мертвые копи"] = "死亡矿井",
    ["Стратхольм – главные врата"] = "斯坦索姆 - 正门",
    ["Чертоги Молний"] = "闪电大厅",
    ["Затерянный город Тол'вир"] = "托维尔失落之城",
    ["Каменные Недра"] = "巨石之核",
    ["Пещеры Черной горы"] = "黑石岩窟",
    ["Трон Приливов"] = "潮汐王座",
    ["Аукиндон"] = "奥金顿",
    ["Вечное Цветение"] = "永茂林地",
    ["Квартал Звезд"] = "群星庭院",
    ["Крепость Черной Ладьи"] = "黑鸦堡垒",
    ["Чаща Темного Сердца"] = "黑心林地",
    ["Атал'Дазар"] = "阿塔达萨",
    ["Гробница королей"] = "诸王之眠",
    ["Святилище Штормов"] = "风暴神殿",
    ["Кровавые катакомбы"] = "赤红深渊",
    ["Та Сторона"] = "彼界",
    ["Шпили Перерождения"] = "晋升高塔",
    ["Академия Алгет'ар"] = "艾杰斯亚学院",
    ["Лощина Бурошкуров"] = "蕨皮山谷",
    ["Чертоги Насыщения"] = "注能大厅",
    ["Нелтарий"] = "奈萨鲁斯",
    ["Рубиновые Омуты Жизни"] = "红玉新生法池",
    ["Лазурное хранилище"] = "碧蓝魔馆",
    ["Забытый город – палаты Гордока"] = "厄运之槌 - 戈多克议会",
    ["Забытый город – центральный сад"] = "厄运之槌 - 中心花园",
    ["Забытый город – квартал Криводревов"] = "厄运之槌 - 扭木区",
    ["Зул'Фаррак"] = "祖尔法拉克",
    ["Стратхольм – черный ход"] = "斯坦索姆 - 后门",
    ["Гундрак"] = "古达克",
    ["Конец Времен"] = "时光之末",
    ["Врата Заходящего Солнца"] = "残阳关",
    ["Дворец Могу'шан"] = "魔古山宫殿",
    ["Монастырь Шадо-Пан"] = "影踪禅院",
    ["Хмелеварня Буйных Портеров"] = "风暴烈酒酿造厂",
    ["Храм Нефритовой Змеи"] = "青龙寺",
    ["Депо Мрачных Путей"] = "恐轨车站",
    ["Небесный Путь"] = "通天峰",
    ["Некрополь Призрачной Луны"] = "影月墓地",
    ["Шлаковые шахты Кровавого Молота"] = "血槌炉渣矿井",
    ["Казематы Стражей"] = "守望者地窟",
    ["Вольная Гавань"] = "自由镇",

    -- 设置
    ["Язык"]               = "语言",
    ["Как в игре"]         = "跟随游戏",
    ["Русский"]            = "俄语",
    ["Английский"]         = "英语",
    ["Язык окна и сообщений аддона. Смена языка применится после /reload."] =
        "插件窗口和消息的语言。切换后需 /reload 生效。",
    ["|cFFFFD100[TGF]|r Язык сохранён. Чтобы окно переключилось, сделай /reload."] =
        "|cFFFFD100[TGF]|r 语言已保存。窗口切换请执行 /reload。",

    -- 提示与核对
    ["к уровню предмета"] = "装等",
    ["к силе"] = "力量",
    ["к ловкости"] = "敏捷",
    ["к интеллекту"] = "智力",
    ["к выносливости"] = "耐力",
    ["к критическому удару"] = "暴击",
    ["к скорости"] = "急速",
    ["к искусности"] = "精通",
    ["к универсальности"] = "全能",
    ["особое гнездо"] = "多彩插槽",
    ["особое гнёзда"] = "多彩插槽",
    ["бесцветное гнездо"] = "棱彩插槽",
    ["бесцветное гнёзда"] = "棱彩插槽",
    ["красное гнездо"] = "红色插槽",
    ["красное гнёзда"] = "红色插槽",
    ["жёлтое гнездо"] = "黄色插槽",
    ["жёлтое гнёзда"] = "黄色插槽",
    ["синее гнездо"] = "蓝色插槽",
    ["синее гнёзда"] = "蓝色插槽",
    ["шестерёнка гнездо"] = "齿轮插槽",
    ["шестерёнка гнёзда"] = "齿轮插槽",
    ["владычества гнездо"] = "统御插槽",
    ["владычества гнёзда"] = "统御插槽",
    ["Статы поправлены по базе — клиент масштабирует эту ссылку неточно."] =
        "属性已按数据库修正——客户端对此链接的缩放不准确。",
    ["Твоя копия отличается от базы:"] = "你的同款装备与数据库不同：",
    ["BiS-версия на руках"] = "BiS版本已在背包中",
    ["Отметка залипла навсегда: к этому рарнику можно больше не ходить."] =
        "标记将永久保留：不必再刷此稀有怪。",
    ["Выпала не BiS-версия"] = "掉落了非BiS版本",
    ["Копия где-то есть, но прочитать её не удалось - похоже, в закрытом банке или у другого персонажа."] =
        "某处有同款装备，但无法读取——可能在未打开的银行或其他角色上。",
    ["Рарник ежедневный: на дневном сбросе кружок опустеет, можно прийти снова за BiS-версией."] =
        "每日稀有怪：每日重置后标记清除，可以再来刷BiS版本。",
    ["Рарник даётся раз на персонажа - BiS-версии уже не будет. Отметил по ошибке: Ctrl+щелчок."] =
        "每角色一次——BiS版本不会再掉落。误标记：Ctrl+点击。",
    ["Рарник убит, нужная вещь не выпала"] = "稀有怪已击杀，所需物品未掉落",
    ["На дневном сбросе кружок опустеет - можно прийти снова."] =
        "每日重置后标记清除——可以再来。",
    ["Рарник даётся раз на персонажа, вещь не выпала - слот придётся закрывать другой. Отметил по ошибке: Ctrl+щелчок."] =
        "每角色一次，物品未掉落——该部位需用其他装备补上。误标记：Ctrl+点击。",
    ["Отметить: рарник убит, нужная вещь не выпала"] = "标记：稀有怪已击杀，所需物品未掉落",
    ["Ставится сама при убийстве. Старые вещи в сумке на цвет не влияют - пока не сходишь к рарнику, кружок пуст."] =
        "击杀时自动设置。背包中已有的同款装备不影响颜色——未访问稀有怪前圆圈为空。",
    ["|cFF888888Загрузка данных...|r"] = "|cFF888888加载中...|r",
    ["|cFF888888Нет предметов под эти фильтры.|r"] = "|cFF888888没有符合筛选条件的物品。|r",

    -- 复制窗口
    ["Копировать из чата — Ctrl+A, Ctrl+C"] = "从聊天复制 — Ctrl+A、Ctrl+C",
    ["Выделить всё"] = "全选",
    ["Сверить (/tgf scan)"] = "核对（/tgf scan）",
    ["Слепок надетого (/tgf ref)"] = "当前装备记录（/tgf ref）",
    ["Показать: весь чат"] = "显示：全部聊天",
    ["Показать: только TGF"] = "显示：仅TGF",
    ["Показать: только код"] = "显示：仅代码",
    ["Копировать из чата (TGF)"] = "从聊天复制（TGF）",
    ["После /tgf scan или /tgf gems — здесь их вывод"] = "/tgf scan 或 /tgf gems 后，其输出显示在此处",
    ["прогон"] = "运行",
    ["Чат пуст."] = "聊天为空。",
    ["Строк [TGF] пока нет.\n\nНажми кнопку сверху — «Сверить» или «Слепок надетого» — вывод появится здесь.\nЛибо переключи на «весь чат»."] =
        "还没有[TGF]行。\n\n点击上方的“核对”或“当前装备记录”——输出将显示在此处。\n或切换到“全部聊天”。",

    -- BiS 窗口按钮
    ["Выгрузить сборку для SimulationCraft"] = "导出配装到SimulationCraft",
    ["Готовый профиль для Advanced Sim на Raidbots: персонаж, вещи, чары и ротация двадцатки."] =
        "Raidbots Advanced Sim 的现成配置：角色、装备、附魔和20级循环。",
    ["Код талантов"] = "天赋代码",
    ["Для этого спека кода пока нет."] = "此专精暂无代码。",
    ["Вставляется в игре: окно талантов — Загрузить сборку."] =
        "在游戏中粘贴：天赋窗口——加载配装。",
    ["Открыть сборки"] = "打开配装",
    ["Свернуть сборки"] = "收起配装",
    ["|cFF86C7BD[TGF]|r Кода талантов для этого спека пока нет. Пришлите свой: окно талантов, кнопка «Экспорт»."] =
        "|cFF86C7BD[TGF]|r 此专精暂无天赋代码。请发送你的：天赋窗口，导出按钮。",

    -- 聊天：核对、标记、样本
    ["метка на карте"] = "地图标记",
    ["|cFFFFD100[TGF]|r Запомнено: %s = %s"] = "|cFFFFD100[TGF]|r 已保存：%s = %s",
    ["карта %d: %.1f, %.1f"] = "地图 %d：%.1f，%.1f",
    ["|cFFFFD100[TGF]|r Отмечен как убитый: %s"] = "|cFFFFD100[TGF]|r 已标记为击杀：%s",
    ["|cFFFFD100[TGF]|r Настройки перенесены со старого имени аддона."] =
        "|cFFFFD100[TGF]|r 设置已从旧插件名迁移。",
    ["|cFFFFD100[TGF]|r Дневной сброс: снято отметок с ежедневных рарников - %d"] =
        "|cFFFFD100[TGF]|r 每日重置：已清除每日稀有怪标记 - %d",
    ["|cFFFFD100[TGF]|r Проверено %d предметов из базы (надето, сумки, банк если открыт), расхождений: %d"] =
        "|cFFFFD100[TGF]|r 已检查 %d 件数据库物品（已装备、背包、银行若打开），差异：%d",
    ["|cFF86C7BD[TGF]|r Скопировать: /tgf copy"] = "|cFF86C7BD[TGF]|r 复制：/tgf copy",
    ["|cFF86C7BD[TGF]|r Скопировать отчёт: /tgf copy"] = "|cFF86C7BD[TGF]|r 复制报告：/tgf copy",
    ["[TGF] ВНИМАНИЕ: не 20 уровня. Число гнёзд верно, статы и уровень — нет."] =
        "[TGF] 警告：不是20级。插槽数正确，属性和装等不正确。",
    ["[TGF] ВНИМАНИЕ: персонаж не 20 уровня — статы и уровни предметов неточны. Слепок годен только с двадцатки."] =
        "[TGF] 警告：角色不是20级——属性和装等不准确。只有20级角色的样本才有效。",
    ["[TGF] ВНИМАНИЕ: персонаж не 20 уровня — статы масштабируются по уровню, сверка неточна. Прогонять только двадцаткой."] =
        "[TGF] 警告：角色不是20级——属性随等级缩放，核对不准确。请仅用20级角色运行。",
    ["|cFFFFD100[TGF]|r Меток пока не запомнено."] = "|cFFFFD100[TGF]|r 尚未保存标记。",
    ["|cFFFFD100[TGF]|r Метки на карте нет. Поставь её Ctrl+щелчком по карте и повтори."] =
        "|cFFFFD100[TGF]|r 地图上没有标记。先Ctrl+点击地图放置标记再试。",
    ["|cFFFFD100[TGF]|r Текущая метка: карта %d, %.1f, %.1f"] =
        "|cFFFFD100[TGF]|r 当前标记：地图 %d，%.1f，%.1f",
    ["|cFFFFD100[TGF]|r Привязать: /tgf pin <часть названия подземелья>"] =
        "|cFFFFD100[TGF]|r 绑定：/tgf pin <地下城名称的一部分>",
    ["|cFFFFD100[TGF]|r Два входа Жилы: /tgf pin жила орда  или  /tgf pin жила альянс"] =
        "|cFFFFD100[TGF]|r 暴富矿区有两个入口：/tgf pin жила horde 或 /tgf pin жила alliance",
    ["|cFFFFD100[TGF]|r Укажи сторону: /tgf pin жила орда  или  /tgf pin жила альянс"] =
        "|cFFFFD100[TGF]|r 请指定阵营：/tgf pin жила horde 或 /tgf pin жила alliance",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе не найден."] =
        "|cFFFFD100[TGF]|r 数据库中未找到包含“%s”的来源。",
    ["|cFFFFD100[TGF]|r Источник со словом «%s» в базе и в журнале не найден."] =
        "|cFFFFD100[TGF]|r 数据库和冒险指南中均未找到包含“%s”的来源。",
    ["|cFFFFD100[TGF]|r Модуль «Сборки» выключен в списке аддонов."] =
        "|cFFFFD100[TGF]|r “配装”模块在插件列表中已禁用。",
    ["|cFFFFD100[TGF]|r Модуль «Журнал» выключен в списке аддонов."] =
        "|cFFFFD100[TGF]|r “冒险指南”模块在插件列表中已禁用。",
    ["|cFFFFD100[TGF]|r Журнал подземелий недоступен."] =
        "|cFFFFD100[TGF]|r 地下城冒险指南不可用。",
    ["|cFFFFD100[TGF]|r В журнале %d подземелий: с меткой %d, без метки %d."] =
        "|cFFFFD100[TGF]|r 冒险指南中有 %d 个地下城：已标记 %d，未标记 %d。",
    ["|cFFFFD100[TGF]|r Без метки из журнала: /tgf pin список"] =
        "|cFFFFD100[TGF]|r 冒险指南中未标记的：/tgf pin list",
    ["|cFFFFD100[TGF]|r Подходит несколько, уточни (%d):"] =
        "|cFFFFD100[TGF]|r 匹配多个，请更精确（%d）：",
    ["|cFFFFD100[TGF]|r Запомнено: %s = карта %d, %.1f, %.1f"] =
        "|cFFFFD100[TGF]|r 已保存：%s = 地图 %d，%.1f，%.1f",
    ["|cFFFFD100[TGF]|r Журнал не отдал добычу. Открой Путеводитель приключений и повтори /tgf tw."] =
        "|cFFFFD100[TGF]|r 冒险指南未返回掉落。打开冒险指南并重新运行 /tgf tw。",
    ["|cFF86C7BD[TGF]|r Какую экспансию снять — одна команда, не все сразу:"] =
        "|cFF86C7BD[TGF]|r 选择要导出的资料片——一次一个，不要全部：",
    ["|cFFFFD100[TGF]|r Не знаю экспансию «%s». Так:"] =
        "|cFFFFD100[TGF]|r 未知资料片“%s”。试试：",
    ["|cFFFFD100[TGF]|r /tgf tw все  — все экспансии сразу"] =
        "|cFFFFD100[TGF]|r /tgf tw all  — 所有资料片",
    ["|cFF86C7BD[TGF]|r Обычные подземелья — одна экспансия, не все сразу:"] =
        "|cFF86C7BD[TGF]|r 普通地下城——一次一个资料片，不要全部：",
    ["|cFF86C7BD[TGF]|r Обычные подземелья — одно дополнение или один данж:"] =
        "|cFF86C7BD[TGF]|r 普通地下城——一个资料片或一个地下城：",
    ["|cFFFFD100[TGF]|r Не знаю экспансию или данж «%s». Так:"] =
        "|cFFFFD100[TGF]|r 未知资料片或地下城“%s”。试试：",
    ["|cFFFFD100[TGF]|r /tgf dj кузня душ  — один данж"] =
        "|cFFFFD100[TGF]|r /tgf dj 灵魂洪炉  — 一个地下城",
    ["|cFFFFD100[TGF]|r /tgf dj список  — чеклист по данжам"] =
        "|cFFFFD100[TGF]|r /tgf dj list  — 地下城清单",
    ["|cFFFFD100[TGF]|r /tgf dj все  — все экспансии сразу"] =
        "|cFFFFD100[TGF]|r /tgf dj all  — 所有资料片",
    ["|cFFFFD100[TGF]|r Чеклист: %d данжей. Скопировать: Ctrl+C в открывшемся окне."] =
        "|cFFFFD100[TGF]|r 清单：%d 个地下城。复制：在打开的窗口中按Ctrl+C。",
    ["|cFFFFD100[TGF]|r Данж: %s."] =
        "|cFFFFD100[TGF]|r 地下城：%s。",
    ["|cFFFFD100[TGF]|r Данж: %s (%s)."] =
        "|cFFFFD100[TGF]|r 地下城：%s（%s）。",
    ["|cFFFFD100[TGF]|r В журнале нет обычной сложности у «%s»."] =
        "|cFFFFD100[TGF]|r 冒险指南中“%s”没有普通难度。",
    ["|cFFFFD100[TGF]|r Старые экспансии снимай со включённым Временем Хроми той же эпохи: без него лут вроде Террасы магистров не того уровня."] =
        "|cFFFFD100[TGF]|r 旧资料片请开启对应时代的克罗米时间：否则魔导师平台等掉落装等不对。",
    ["|cFFFFD100[TGF]|r Время Хроми одно на все экспансии — снимай по одной, иначе чужие данжи будут не того уровня."] =
        "|cFFFFD100[TGF]|r 克罗米时间一次只能选一个资料片——请逐个导出，否则其他地下城装等不对。",
    ["|cFFFFD100[TGF]|r Время Хроми выкл. Для «%s» включи историю этой эпохи, иначе лут вроде Террасы магистров не того уровня."] =
        "|cFFFFD100[TGF]|r 克罗米时间已关闭。对于“%s”请开启该时代的战役，否则魔导师平台等掉落装等不对。",
    ["|cFFFFD100[TGF]|r Снимаю %s, а Время Хроми — %s. Включи историю этой эпохи."] =
        "|cFFFFD100[TGF]|r 正在导出 %s，但克罗米时间是 %s。请开启该版本的时间线。",
    ["|cFFFFD100[TGF]|r Время Хроми: %s."] =
        "|cFFFFD100[TGF]|r 克罗米时间：%s。",
    ["|cFFFFD100[TGF]|r Время Хроми: Настоящее."] =
        "|cFFFFD100[TGF]|r 克罗米时间：现在。",
    ["Настоящее"] = "现在",
    ["|cFFFFD100[TGF]|r В журнале нет обычных подземелий для «%s»."] =
        "|cFFFFD100[TGF]|r 冒险指南中没有“%s”的普通地下城。",
    ["|cFFFFD100[TGF]|r В журнале нет обычных подземелий."] =
        "|cFFFFD100[TGF]|r 冒险指南中没有普通地下城。",
    ["|cFFFFD100[TGF]|r Журнал не отдал добычу. Открой Путеводитель приключений и повтори /tgf dj."] =
        "|cFFFFD100[TGF]|r 冒险指南未返回掉落。打开冒险指南并重新运行 /tgf dj。",
    ["|cFFFFD100[TGF]|r Обычные подземелья: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне."] =
        "|cFFFFD100[TGF]|r 普通地下城：%d 个新，共 %d 个。复制：在打开的窗口中按Ctrl+C。",
    ["|cFFFFD100[TGF]|r Без обычной сложности пропущено данжей: %d."] =
        "|cFFFFD100[TGF]|r 跳过无普通难度的地下城：%d。",
    ["|cFFFFD100[TGF]|r Катаклизм: броню и оружие не снимал, только аксессуары (%d пропущено)."] =
        "|cFFFFD100[TGF]|r 大灾变：未导出护甲和武器，仅饰品（跳过 %d）。",
    ["|cFFFFD100[TGF]|r Снимаю %s."] =
        "|cFFFFD100[TGF]|r 正在导出 %s。",
    ["|cFFFFD100[TGF]|r Снимаю все экспансии."] =
        "|cFFFFD100[TGF]|r 正在导出所有资料片。",
    ["|cFFFFD100[TGF]|r В журнале нет подземелий Путешествия во времени для «%s»."] =
        "|cFFFFD100[TGF]|r 冒险指南中没有“%s”的时空漫游地下城。",
    ["|cFFFFD100[TGF]|r В журнале нет подземелий с Путешествием во времени."] =
        "|cFFFFD100[TGF]|r 冒险指南中没有时空漫游地下城。",
    ["|cFFFFD100[TGF]|r Путешествие во времени: %d новых из %d. Скопировать: Ctrl+C в открывшемся окне."] =
        "|cFFFFD100[TGF]|r 时空漫游：%d 个新，共 %d 个。复制：在打开的窗口中按Ctrl+C。",
    ["|cFFFFD100[TGF]|r Гружу %d вещей из журнала, подожди несколько секунд."] =
        "|cFFFFD100[TGF]|r 正在加载 %d 件冒险指南物品，请稍候几秒。",
    ["|cFFFFD100[TGF]|r Дамп уже идёт, подожди."] =
        "|cFFFFD100[TGF]|r 导出已在进行中，请稍候。",
    ["|cFF86C7BD[TGF]|r /tgf new [шея|кольцо|аксессуар] — без слова покажет все вещи, которых нет в базе"] =
        "|cFF86C7BD[TGF]|r /tgf new [颈部|戒指|饰品] — 不带词则列出所有不在数据库中的物品",
    ["|cFFFFD100[TGF]|r Не из базы: %d %s (надето, сумки, банк если открыт). Скопировать: /tgf copy"] =
        "|cFFFFD100[TGF]|r 不在数据库中：%d %s（已装备、背包、银行若打开）。复制：/tgf copy",
    ["|cFF86C7BD[TGF]|r Таланты не читаются: игра не отдала активную сборку."] =
        "|cFF86C7BD[TGF]|r 无法读取天赋：游戏未返回当前配装。",
    ["|cFF86C7BD[TGF]|r Окно сборок ещё не открывалось: /tgf bis"] =
        "|cFF86C7BD[TGF]|r 配装窗口尚未打开：/tgf bis",
    ["# TrialGearFinder: таланты, %s %s (спек %s)"] = "# TrialGearFinder：天赋，%s %s（专精 %s）",
    ["# код сборки игра не отдала — возьми его в окне талантов кнопкой «Экспорт»"] =
        "# 游戏未返回配装代码——请在天赋窗口用“导出”按钮获取",
    ["|cFFFFD100[TGF]|r Зачарованных вещей: %d. Наведи на них в сумке или на себе, чтобы увидеть текст чары. Скопировать: /tgf copy"] =
        "|cFFFFD100[TGF]|r 已附魔物品：%d。将鼠标悬停在背包或已装备物品上查看附魔文本。复制：/tgf copy",
    ["[TGF] ref: %d предметов из базы у персонажа"] = "[TGF] ref：角色身上有 %d 件数据库物品",
    ["|cFFFFD100[TGF]|r %s: %d. Скопировать: /tgf copy"] =
        "|cFFFFD100[TGF]|r %s：%d。复制：/tgf copy",
    ["[TGF] ссылка: "] = "[TGF] 链接：",

    -- SimC 导出
    ["# TrialGearFinder: сборка, %s %s"] = "# TrialGearFinder：配装，%s %s",
    ["# Выгрузка TrialGearFinder, не аддона SimulationCraft: Raidbots пометит «Unverified Input»."] =
        "# TrialGearFinder导出，非SimulationCraft插件：Raidbots会标记“Unverified Input”。",
    ["# Вставлять в Advanced Sim на Raidbots: Quick Sim выбрасывает строки ротации."] =
        "# 粘贴到Raidbots的Advanced Sim：Quick Sim会丢弃循环行。",
    ["# Нужны веса статов — та же вставка в Stat Weights: raidbots.com/simbot/stats."] =
        "# 需要属性权重——同样粘贴到Stat Weights：raidbots.com/simbot/stats。",
    ["# Расходники максимального уровня двадцатке недоступны — выключены."] =
        "# 最高等级消耗品对20级不可用——已禁用。",
    ["# Цель — болванка 23 уровня: по высокой цели заклинания мажут все до одного."] =
        "# 目标为23级假人：对高等级目标法术全部未命中。",
    ["# Цель — моб 45 уровня: сборка считается по самым сложным подземельям."] =
        "# 目标为45级怪物：按最困难的地下城计算配装。",
    ["# Другое подземелье: старые героики — 30, Пандария — 38, Каз Алгар — 73."] =
        "# 其他地下城：旧英雄本30，潘达利亚38，卡兹阿加73。",
    ["# Таланты взяты из аддона, не с этого персонажа: код снят не на двадцатке."] =
        "# 天赋来自插件，非此角色：代码不是在20级获取的。",
    ["# Талантов нет: зайди этим спеком — выгрузка возьмёт их из игры."] =
        "# 没有天赋：用此专精登录——导出将从游戏获取。",
    ["# Острые рефлексы: в данных сима с 23 уровня, на двадцатке талант есть."] =
        "# 敏锐反射：模拟数据从23级开始，但20级可以点出该天赋。",
    ["# Боевые инстинкты и Эффективная тренировка на 20 уровне нет."] =
        "# 战斗本能和高效训练在20级不存在。",
    ["# Пачка из трёх целей: убери решётку в начале следующей строки."] =
        "# 三目标群：删除下一行开头的井号。",
    ["# Ротация двадцатки из TrialGearFinder, сверена с логами рейтинга."] =
        "# 来自TrialGearFinder的20级循环，已对照排行榜核对。",
    ["# Ротации двадцатки для этого спека в аддоне нет: SimC возьмёт свою,"] =
        "# 插件中没有此专精的20级循环：SimC将使用自己的，",
    ["# под максимальный уровень. У одних спеков она на двадцатке почти не жмёт"] =
        "# 为最高等级编写。某些专精在20级几乎不按",
    ["# приёмы, у других работает — цифре верить с оглядкой."] =
        "# 技能，其他专精则可用——数字仅供参考。",

    -- 职业与专精
    ["Воин"] = "战士",
    ["Паладин"] = "圣骑士",
    ["Охотник"] = "猎人",
    ["Разбойник"] = "潜行者",
    ["Жрец"] = "牧师",
    ["Рыцарь смерти"] = "死亡骑士",
    ["Шаман"] = "萨满祭司",
    ["Маг"] = "法师",
    ["Чернокнижник"] = "术士",
    ["Монах"] = "武僧",
    ["Друид"] = "德鲁伊",
    ["Охотник на демонов"] = "恶魔猎手",
    ["Пробудитель"] = "唤魔师",
    ["Оружие"] = "武器",
    ["Неистовство"] = "狂怒",
    ["Защита"] = "防护",
    ["Повелитель зверей"] = "野兽控制",
    ["Стрельба"] = "射击",
    ["Выживание"] = "生存",
    ["Воздаяние"] = "惩戒",
    ["Свет"] = "神圣",
    ["Ликвидация"] = "奇袭",
    ["Головорез"] = "狂徒",
    ["Скрытность"] = "敏锐",
    ["Послушание"] = "戒律",
    ["Тьма"] = "暗影",
    ["Нечестивость"] = "邪恶",
    ["Лёд"] = "冰霜",
    ["Лед"] = "冰霜",
    ["Кровь"] = "鲜血",
    ["Колдовство"] = "痛苦",
    ["Демонология"] = "恶魔学识",
    ["Разрушение"] = "毁灭",
    ["Танцующий с ветром"] = "踏风",
    ["Ткач туманов"] = "织雾",
    ["Хмелевар"] = "酒仙",
    ["Баланс"] = "平衡",
    ["Сила зверя"] = "野性",
    ["Страж"] = "守护",
    ["Исцеление"] = "恢复",
    ["Истребление"] = "浩劫",
    ["Месть"] = "复仇",
    ["Пожиратель"] = "吞噬者",
    ["Опустошитель"] = "湮灭",
    ["Хранитель"] = "恩护",
    ["Насыщатель"] = "增辉",
    ["Огонь"] = "火焰",
    ["Тайная магия"] = "奥术",
    ["Стихии"] = "元素",
    ["Совершенствование"] = "增强",

    -- 指南物品注释
    ["[ДД] падает с Древний зуболом в Назмире; Беспрерывно тикающие часы: аксессуар со всеми основными статами разом (в рейтинге ×8)"] = "[输出] 掉落自纳兹米尔的远古断颌鳄；不停滴答的时钟：同时提供所有主属性的饰品（排行榜 ×8）",
    ["[ДД] Карта Таро Пророчества: три вторички разом - крит, универсальность, искусность. Уникальная использующаяся"] = "[输出] 预言塔罗牌：同时提供三种副属性——暴击、全能、精通。唯一装备，使用效果",
    ["[ДД] Клык Расте: три вторички разом - крит, скорость, искусность. Падает с Расте, раз в день"] = "[输出] 拉瑟之牙：同时提供三种副属性——暴击、急速、精通。掉落自拉斯特，每日稀有",
    ["[ДД] Обузданный огонь: три вторички разом - крит, универсальность, искусность. Падает с Обуглень Дикий Огонь, раз в день"] = "[输出] 被驯服的火焰：同时提供三种副属性——暴击、全能、精通。掉落自野火辛达尔，每日稀有",
    ["[ДД] аналог Рога талбука, с квеста"] = "[输出] 任务版塔布羊角",
    ["[ДД] падает с Сиамата (Затерянный город Тол'вир); Благоволение Тиа (Tia's Grace): атаки дают +1 ловкости на 15 сек., до 10 раз. Тир 32"] = "[输出] 掉落自希亚玛特（托维尔失落之城）；提亚的恩典：攻击提供+1敏捷，持续15秒，最多叠加10次。装等32",
    ["[ДД] падает с Эрудакса, Повелителя Глубин; Буря теней: интеллект копится от урона периодикой, до 20 стаков"] = "[输出] 掉落自埃鲁达克，深渊之主；暗影风暴：智力通过持续伤害积累，最多20层",
    ["[ДД] последовательное накопление основной характеристики"] = "[输出] 随时间叠加主属性",
    ["[ДД] хорошая прожимка на интеллект"] = "[输出] 强力的主动智力",
    ["[ДД] хорошая прожимка на силу заклинаний"] = "[输出] 强力的主动法术强度",
    ["[ДД] хороший прок ловкости; рарник, убивать В РЕЖИМЕ ИСТОРИИ"] = "[输出] 强力的敏捷触发；稀有怪，请在剧情模式中击杀",
    ["[ДД] хороший прок силы, с сокровища"] = "[输出] 强力的力量触发，来自宝藏",
    ["[Танк] нишевая смесь Квинтэссенции и Скаломола"] = "[坦克] 精华与碎山的利基组合",
    ["[Танк] пассивно снижает получаемый урон, очень хороша на аое запулах"] = "[坦克] 被动降低受到的伤害，在群拉时非常出色",
    ["[Танк] прожимка, снижающая получаемый урон"] = "[坦克] 降低受到伤害的主动效果",
    ["[Танк] сильно увеличивает запас здоровья; нужно засумониться в данж 30 уровня"] = "[坦克] 大幅提高生命值；需要被召唤进30级地下城",
    ["[Танк] спасает от критического урона"] = "[坦克] 从爆发伤害中保命",
    ["[Хил] падает с Эрудакса, Повелителя Глубин; Оскверненная яичная скорлупа: по использованию щит на союзника 2809 + возврат маны"] = "[治疗] 掉落自埃鲁达克，深渊之主；腐化的蛋壳：使用后为盟友提供2809护盾并回复法力",
    ["[Хил] реген маны"] = "[治疗] 法力回复",
    ["[Хил] падает с Рухрана; Перо Рухрана: скорость и универсальность, синий, уникальный (Keotore, 30 из 50 заходов; статы и уровень с тултипа 21 сентября)"] = "[治疗] 掉落自鲁克兰；鲁克兰的羽毛：急速和全能，蓝色，唯一装备（Keotore，50次中30次；属性和装等来自9月21日提示）",
    ["падает с Жрицы Делриссы; Боевая палица верховной жрицы: одноручная, интеллект 19, одно родное гнездо"] = "掉落自女祭司德莉希亚；高阶女祭司的战锤：单手，19智力，一个原生插槽",
    ["падает со Стражницы душ Ниами; Губительный клинок мудреца: одноручный меч на интеллект 19"] = "掉落自缚魂者尼娅米；灭魂法师之刃：单手剑，19智力",
    ["Кристаллический волшебный посох Камуи: двуручный, интеллект 30. Откуда падает — не выяснено"] = "卡缪的水晶魔法法杖：双手，30智力。掉落来源未确认",
    ["редкий: Рука Эдварда Странного, уникальная одноручка, мировой дроп. В сборку не ставим (Keotore, армори ilvl 27)"] = "稀有：爱德华古怪之手，唯一单手，世界掉落。未放入配装（Keotore，英雄榜装等27）",
    ["Бадья: кольцо на универсальность/искусность. Тир 32"] = "水桶：戒指，全能/精通。装等32",
    ["крафт (инженерия); Специализированная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса. Статы двадцатки в игре не сняты"] = "制造（工程学）；特制视网膜护甲：板甲头盔，多彩插槽和两个齿轮插槽。20级属性未在游戏中核实",
    ["падает с Ром'огга Костекрушителя; Щит железной леди: Путешествие во времени, уровень 32. Статы двадцатки в игре не сняты"] = "掉落自罗姆欧格·碎骨者；铁娘子之盾：时空漫游，装等32。20级属性未在游戏中核实",
    ["[Танк] падает с Асаада; Сердце грома: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23"] = "[坦克] 掉落自阿萨德；雷霆之心：时空漫游版本，装等32。攻略中的地下城同款装备是另一件物品，装等23",
    ["Бусы предков Укхел: шея на скорость/искусность (слепок, ×4; была удалена)"] = "乌克赫尔先祖之珠：颈部，急速/精通（样本 ×4；已被移除）",
    ["Двойной клинок мастерства: кинжал разбойника, обе руки (от сообщества)"] = "精通双刃：潜行者匕首，双手（社区）",
    ["Драгоценная петля из кровошипа: кольцо со всеми статами и универсальностью, с Горума (слепок, ×17)"] = "血棘指环：全属性加全能的戒指，来自戈鲁姆（样本 ×17）",
    ["Кинжал штормградского бойца авангарда: награда за задание, только Альянс, с 10 ур. (от сообщества)"] = "暴风城先锋战士匕首：任务奖励，仅联盟，10级起（社区）",
    ["Кольцо антии (Anthia's Ring): на крит/искусность. Тир 32"] = "安西亚之戒：暴击/精通。装等32",
    ["Кольцо великого кита: на универсальность. Тир 32"] = "巨鲸之戒：全能。装等32",
    ["Кольцо наутилуса (Nautilus Ring): на крит/скорость. Тир 32"] = "鹦鹉螺之戒：暴击/急速。装等32",
    ["падает с Платного разгонятеля толпы; Кольцо чемпиона по футбомбометанию: на скорость/искусность (в рейтинге ×19)"] = "掉落自投币式群体打击者；足球炸弹冠军戒指：急速/精通（排行榜 ×19）",
    ["Кольцо череподробителя (Skullcracker Ring): на крит/искусность. Тир 32"] = "碎颅者之戒：暴击/精通。装等32",
    ["Комендантский медальон наваждения: шея на универсальность/искусность (слепок, ×7; была удалена)"] = "萦绕指挥官勋章：颈部，全能/精通（样本 ×7；已被移除）",
    ["Магнит на кристальной цепи (Crystal-Chained Lodestone): шея на крит/скорость. Тир 32"] = "水晶链磁石：颈部，暴击/急速。装等32",
    ["падает с Полководца Калитреша; Наплечники Лунной поляны: кожаные плечи на версу, два гнезда (в рейтинге ×8)"] = "掉落自督军卡利瑟里斯；月光林地护肩：皮甲肩部，全能，两个插槽（排行榜 ×8）",
    ["падает с Гюрзиса и Аспидиса; Обоюдоострое копье: двуручное на ловкость, Путешествие во времени, ilvl 26 (логи, x98)"] = "掉落自阿德里斯和阿斯匹克斯；双刃长矛：敏捷双手，时空漫游，装等26（日志，x98）",
    ["Окованная железом подвеска (Ironshell Pendant): шея на скорость. Тир 32"] = "铁壳吊坠：颈部，急速。装等32",
    ["Перстень из розового кварца (Rose Quartz Band): на крит. Тир 32"] = "玫瑰石英指环：暴击。装等32",
    ["Перстень перевоплощения: на скорость/искусность. Тир 32"] = "转生指环：急速/精通。装等32",
    ["Подвеска из ракушечника (Barnacle Pendant): шея на крит/скорость. Тир 32"] = "藤壶吊坠：颈部，暴击/急速。装等32",
    ["Подвеска из рыбы-иглы (Pipefish Cord): шея на скорость/искусность. Тир 32"] = "尖嘴鱼束带：颈部，急速/精通。装等32",
    ["Подвеска несущего волны (Carrier Wave Pendant): шея на скорость/искусность. Тир 32"] = "载波吊坠：颈部，急速/精通。装等32",
    ["Подвеска погруженного во тьму грота (Pendant of the Lightless Grotto): шея на искусность. Тир 32"] = "无光洞穴吊坠：颈部，精通。装等32",
    ["Почерневшее костяное ожерелье (Blackened Bone Necklace): шея на крит. Тир 32"] = "黑骨项链：颈部，暴击。装等32",
    ["Почти лучшая заточка Водина: кинжал, награда за задание, обе фракции, с 20 ур. (от сообщества)"] = "近乎最佳的沃丁匕首：任务奖励，双方阵营，20级起（社区）",
    ["Разорванное ожерелье из земляного камня (Fractured Earthstone Necklace): шея на универсальность. Тир 32"] = "破碎的土石项链：颈部，全能。装等32",
    ["падает с Налтора Криоманта; Ритуальный перстень командира: кольцо на крит/универсальность (в рейтинге ×16)"] = "掉落自纳尔索尔·冰缚者；仪式指挥官之戒：暴击/全能（排行榜 ×16）",
    ["Ртутный амулет (Quicksilver Amulet): шея на скорость/универсальность. Тир 32; по Wowhead ловится удочкой в Пещерах Черной Горы — не проверено"] = " 颈部，急速/全能。装等32；Wowhead说在黑石岩窟钓鱼获得——未验证",
    ["Сплетенные нереиды (Entwined Nereis): кольцо на универсальность. Тир 32"] = " 戒指，全能。装等32",
    ["Фамильная печать Сильверлейнов: кольцо на скорость/универсальность, без гнезда"] = " 戒指，急速/全能，无插槽",
    ["Фосфоресцирующее кольцо (Phosphorescent Ring): на универсальность. Тир 32"] = " 全能。装等32",
    ["падает с Ингвара Расхителя; Шлем расхитителя: кольчужная голова на крит/скорость, два гнезда (в рейтинге ×8)"] = "掉落自掠夺者因格瓦尔；掠夺者头盔：锁甲头部，暴击/急速，两个插槽（排行榜 ×8）",
    ["Щедро изукрашенное кольцо (Lavishly Jeweled Ring): на крит/скорость. Тир 32; в гильдии носят и обычную копию 23-26 уровня"] = "华丽珠宝戒指：暴击/急速。装等32；公会也有人佩戴23-26级普通版本",
    ["аналог бивня на прожим искусности"] = "獠牙的类似物，主动精通",
    ["бисовая кожаная голова для критовиков (1/2 сета Странника пустошей)"] = "暴击流BiS皮甲头盔（荒废者套装 1/2）",
    ["бисовая тканевая грудь с выносливостью"] = "BiS布甲胸甲，带耐力",
    ["бисовая тканевая грудь с интеллектом"] = "BiS布甲胸甲，带智力",
    ["бисовые кожаные наручи"] = "BiS皮甲护腕",
    ["бисовые кожаные плечи"] = "BiS皮甲护肩",
    ["бисовые кожаные поножи"] = "BiS皮甲护腿",
    ["бисовые кольчужные наручи"] = "BiS锁甲护腕",
    ["бисовые кольчужные плечи"] = "BiS锁甲护肩",
    ["бисовые кольчужные поножи"] = "BiS锁甲护腿",
    ["бисовые кольчужные руки"] = "BiS锁甲手套",
    ["бисовые латные наручи"] = "BiS板甲护腕",
    ["бисовые латные плечи"] = "BiS板甲护肩",
    ["бисовые латные поножи"] = "BiS板甲护腿",
    ["бисовые латные руки"] = "BiS板甲手套",
    ["бисовые латные сапоги"] = "BiS板甲靴子",
    ["бисовые тканевые наручи на скорость"] = "BiS布甲护腕，急速",
    ["бисовые тканевые наручи на универсальность"] = "BiS布甲护腕，全能",
    ["бисовые тканевые ноги с силой заклинаний"] = "BiS布甲护腿，带法术强度",
    ["бисовые тканевые плечи"] = "BiS布甲护肩",
    ["бисовые тканевые поножи с выносливостью"] = "BiS布甲护腿，带耐力",
    ["бисовые тканевые ступни"] = "BiS布甲靴子",
    ["бисовый кожаный нагрудник"] = "BiS皮甲胸甲",
    ["бисовый кожаный пояс"] = "BiS皮甲腰带",
    ["бисовый кольчужный нагрудник"] = "BiS锁甲胸甲",
    ["бисовый кольчужный пояс"] = "BiS锁甲腰带",
    ["бисовый кольчужный шлем"] = "BiS锁甲头盔",
    ["бисовый латный нагрудник"] = "BiS板甲胸甲",
    ["бисовый латный ремень"] = "BiS板甲腰带",
    ["бисовый латный шлем с особым гнездом"] = "BiS板甲头盔，带多彩插槽",
    ["бисовый лук за цепочку Хеминга Эрнестуэя, вторичек вдвое больше, чем у других пушек"] = "BiS弓，来自赫米特·奈辛瓦里任务线，副属性是其他武器的两倍",
    ["бисовый тканевый шлем"] = "BiS布甲头盔",
    ["вторая часть \"манасета\", нужен хилам для регена маны"] = "“法力套装”第二件，治疗需要它回复法力",
    ["за квест здесь дают начальный грудак для латников Защитник наместника"] = "此处任务给板甲起始胸甲：执政官的守护者",
    ["забавный латный шлем для контроля противника в PvP"] = "有趣的板甲头盔，用于PvP控制对手",
    ["здесь за квест дают бисовые сапоги на кольчугу Аукенайские сапоги и временные латы Скованные Ша'тар наголенники"] = "此处任务给BiS锁甲靴子：奥金尼靴子，以及临时板甲：沙塔尔束缚护胫",
    ["из ящика Тажаня Чжу (Монастырь Шадо-Пан); Ка'эн, дыхание тьмы (Ka'eng, Breath of the Shadow): кистевое оружие на крит/скорость. Тир 32"] = "来自塔兰·祝的箱子（影踪禅院）；卡恩，暗影之息：拳套，暴击/急速。装等32",
    ["кистевое, статов нет - только прок: +61 к скорости на 10 сек. при ударе (КД 45с)"] = "拳套，无属性——仅触发：命中时+61急速，持续10秒（冷却45秒）",
    ["кожаные плечи с универсальностью для монаха-ткача (от сообщества)"] = "织雾武僧用的全能皮甲护肩（社区）",
    ["кольчужный ремень за сопровождение Тралла (парная награда к Касанию бури)"] = "护送萨尔的锁甲腰带（与风暴之触配对奖励）",
    ["крафт (инженерия), статы зависят от изготовления - самая популярная триальная тринька"] = "制造（工程学），属性取决于制作——最受欢迎的试玩饰品",
    ["лучшая прожимка на скорость"] = "最佳主动急速",
    ["лучшая прожимка на универсальность"] = "最佳主动全能",
    ["лучшая тринька для фарма подземелий"] = "刷地下城的最佳饰品",
    ["лучшие латные плечи на скорость"] = "最佳板甲急速护肩",
    ["лучшие тканевые руки на версу"] = "最佳布甲全能手套",
    ["лучший посох на кастеров"] = "最佳法系法杖",
    ["лучший тканевый ремень на версу"] = "最佳布甲全能腰带",
    ["очень сильная двуручка для силовиков и сурв-хантов"] = "非常强的双手武器，适合力量职业和生存猎",
    ["очень сильная одноручка для ловкачей и силовиков"] = "非常强的单手武器，适合敏捷和力量职业",
    ["падает в Каменных Недрах; Тяжелая жеодовая палица (Heavy Geode Mace): булава на ловкость, крит/скорость. Тир 32"] = "掉落自巨石之核；重型晶簇锤：敏捷锤，暴击/急速。装等32",
    ["падает в Конце Времен; Зазубренное лезвие времени (Jagged Edge of Time): кинжал на крит/скорость. Тир 32"] = "掉落自时光之末；锯齿时光之刃：匕首，暴击/急速。装等32",
    ["падает интовикам с Хранитель рощи Йал в Горгронде"] = "智力职业掉落自戈尔隆德的林地守护者亚尔",
    ["падает ловкачам с Гиблет Трусливый на Хребте Ледяного Огня"] = "敏捷职业掉落自霜火岭的胆小鬼吉布利特",
    ["падает с Ануб-арака; Кольцо короля-предателя: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x2)"] = "掉落自阿努巴拉克；背叛者之王之戒：暴击/急速。时空漫游，装等32（样本，x2）",
    ["падает с Бармагрыз на Хребте Ледяного Огня"] = "掉落自霜火岭的巴玛加什",
    ["падает с Бармен Билл на Тирагардском поморье"] = "掉落自提拉加德海峡的酒保比尔",
    ["падает с Бромача; Выкопанный медальон Бромача: шея на скорость/искусность (слепок, ×6)"] = "掉落自布罗马赫；布罗马赫的出土勋章：颈部，急速/精通（样本 ×6）",
    ["падает с Броньяма; Узник любви: шея на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "掉落自布朗吉姆；爱的囚徒：颈部，急速/全能。时空漫游，装等32（样本，x3）",
    ["падает с Вексалиуса; Сапоги оживления: кожаные ступни на универсальность, со скоростью бега (от сообщества)"] = "掉落自维萨鲁斯；复苏之靴：皮甲靴子，全能，带移动速度（社区）",
    ["падает с Геккана (Дворец Могу'шан); Когти Геккана: кистевое оружие на крит/скорость. Тир 32"] = "掉落自格坎（魔古山宫殿）；格坎之爪：拳套，暴击/急速。装等32",
    ["падает с Глубтока (Мертвые копи); Шип-клинок (Buzzer Blade): кинжал на крит. Тир 32"] = "掉落自格鲁布托克（死亡矿井）；蜂鸣之刃：匕首，暴击。装等32",
    ["падает с Дикобраз-матриарх в Друстваре"] = "掉落自德鲁斯瓦的箭鼠母兽",
    ["падает с Длинноклык и Генри Брейкуотер в Долине Штормов"] = "掉落自斯托颂谷地的长牙和亨利·断水",
    ["падает с Зубохлопа (Затерянный город Тол'вир); Кинжал Барима (Barim's Main Gauche): на крит/искусность. Тир 32"] = "掉落自锁喉（托维尔失落之城）；巴里姆的左手匕首：暴击/精通。装等32",
    ["падает с Ингвара Расхителя; Кольцо Аннгильды: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x6)"] = "掉落自掠夺者因格瓦尔；安海尔德之戒：暴击/急速。时空漫游，装等32（样本，x6）",
    ["падает с Ингвара Расхителя; Несокрушимое тяжёлое кольцо: на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x7)"] = "掉落自掠夺者因格瓦尔；坚不可摧的重型戒指：急速/全能。时空漫游，装等32（样本，x7）",
    ["падает с Камнешкура (Каменные Недра); Ртутный клинок (Quicksilver Blade): кинжал на скорость/искусность. Тир 32"] = "掉落自岩皮（巨石之核）；水银之刃：匕首，急速/精通。装等32",
    ["падает с Кандак в Зулдазаре"] = "掉落自祖达萨的坎达克",
    ["падает с Карша Гнущего Сталь (Пещеры Черной горы); Шедевр Гнущего Сталь (Steelbender's Masterpiece): кинжал на крит/искусность. Тир 32"] = "掉落自卡尔什·弯钢（黑石岩窟）；弯钢杰作：匕首，暴击/精通。装等32",
    ["падает с Кель'таса Солнечного Скитальца; Наголенники кающегося рыцаря: латные ступни на универсальность (слепок, ×7)"] = "掉落自凯尔萨斯·逐日者；忏悔骑士护胫：板甲靴子，全能（样本 ×7）",
    ["падает с Кинжалозуб в Зулдазаре"] = "掉落自祖达萨的匕首牙",
    ["падает с Командира Ри'мока (Врата Заходящего Солнца); Вертлуг богомола: кинжал на крит/скорость. Тир 32"] = "掉落自指挥官瑞莫克（残阳关）；螳螂妖关节：匕首，暴击/急速。装等32",
    ["падает с Королева шипожалов в Друстваре"] = "掉落自德鲁斯瓦的箭猪女王",
    ["падает с Кроворуба; Усиленный плотью ободок: кольцо на крит/искусность (слепок, ×9)"] = "掉落自血斧；血肉强化指环：戒指，暴击/精通（样本 ×9）",
    ["падает с Кул'тарока; Ритуальное костяное кольцо: на универсальность/искусность (слепок, ×15)"] = "掉落自库尔塔罗克；仪式骨戒：全能/精通（样本 ×15）",
    ["падает с Кулетт Вспыльчивый на Тирагардском поморье"] = "掉落自提拉加德海峡的暴躁的库莱特",
    ["падает с Лорда-камергера; Печатка лживого обвинения: кольцо на искусность (слепок, ×36 — самое ходовое)"] = "掉落自宫务大臣；虚假指控之印：戒指，精通（样本 ×36——最常用）",
    ["падает с Мак в Друстваре"] = "掉落自德鲁斯瓦的麦克",
    ["падает с Мастера; Рукавицы Железного лезвия: латные кисти на крит (слепок, ×6)"] = "掉落自大师；铁刃护手：板甲手套，暴击（样本 ×6）",
    ["падает с Могамаго в Горгронде"] = "掉落自戈尔隆德的莫加马戈",
    ["падает с Мрачноморд Безмозглый в Долине Штормов (В РЕЖИМЕ ИСТОРИИ)"] = "掉落自斯托颂谷地的无脑暗喉（剧情模式）",
    ["падает с Оскорбления претендентов; Печатка клятвы на крови: кольцо на крит/скорость (слепок, ×10)"] = "掉落自挑战者的侮辱；血誓之印：戒指，暴击/急速（样本 ×10）",
    ["падает с Пилозуб в Боралусе"] = "掉落自伯拉勒斯的锯齿",
    ["падает с Пожирателя Душ; Ожерелье из пропавших камней: шея на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x8)"] = "掉落自噬魂者；失落之石项链：颈部，暴击/急速。时空漫游，装等32（样本，x8）",
    ["падает с Пожирателя Душ; Перстень злорадства: на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "掉落自噬魂者；怨恨指环：暴击/全能。时空漫游，装等32（样本，x3）",
    ["падает с Пожирателя Душ; Хребет разлагающегося трупа: агиловый посох, у друида-кота (слепок, ×4)"] = "掉落自噬魂者；腐烂尸骸之脊：敏捷法杖，野性德用（样本 ×4）",
    ["падает с Пожирателя Душ; Чародейский кулон злости: шея на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "掉落自噬魂者；奥术怨恨吊坠：颈部，暴击/全能。时空漫游，装等32（样本，x3）",
    ["падает с Сестра Абсинтия в Долине Штормов (В РЕЖИМЕ ИСТОРИИ)"] = "掉落自斯托颂谷地的艾比森修女（剧情模式）",
    ["падает с Сестра Марта в Друстваре"] = "掉落自德鲁斯瓦的玛尔塔修女",
    ["падает с Сиамата (Затерянный город Тол'вир); Молот Искр (Hammer of Sparks): булава на ловкость, крит/скорость. Тир 32"] = "掉落自希亚玛特（托维尔失落之城）；火花之锤：敏捷锤，暴击/急速。装等32",
    ["падает с Сквиргл-из-Глубин на Тирагардском поморье"] = "掉落自提拉加德海峡的深渊尖叫者",
    ["падает с Сын Горамала на Хребте Ледяного Огня"] = "掉落自霜火岭的戈拉玛尔之子",
    ["падает с Темноуст Джо'ла в Зулдазаре"] = "掉落自祖达萨的暗语者乔拉",
    ["падает с Хакби Восставший в Зулдазаре"] = "掉落自祖达萨的复生者哈克比",
    ["падает с Халкиаса; Запятнанная грехом подвеска: шея на скорость/искусность (слепок, ×16)"] = "掉落自哈尔基亚斯；罪恶玷污的吊坠：颈部，急速/精通（样本 ×16）",
    ["падает с Чешуетряс Ядовитый на Тирагардском поморье"] = "掉落自提拉加德海峡的毒鳞",
    ["падает с Чумокоста; Потерянная печатка Трупошва: кольцо на скорость/универсальность (слепок, ×9)"] = "掉落自疫骨；失落的缝肉之印：戒指，急速/全能（样本 ×9）",
    ["падает с Ша Жестокости (Монастырь Шадо-Пан); Гнойный полумесяц: одноручный топор на скорость/искусность. Тир 32"] = "掉落自暴力之煞（影踪禅院）；化脓新月：单手斧，急速/精通。装等32",
    ["падает с Эмили Мэйвилл в Друстваре"] = "掉落自德鲁斯瓦的艾米丽·梅维尔",
    ["падает с верховного адъюдикатора Ализы; тринька на чистую скорость, годится любой роли (слепок, ×5)"] = "掉落自高阶审判官阿丽兹；纯急速饰品，任何角色适用（样本 ×5）",
    ["падает с рарника Forgotten Creation; Амнезия: шея на скорость/универсальность (слепок, ×45 — самая ходовая)"] = "掉落自稀有怪被遗忘的造物；失忆：颈部，急速/全能（样本 ×45——最常用）",
    ["падает с рарника Liskheszaera; Кристаллизованная печать: шея на универсальность/искусность (слепок, ×12)"] = "掉落自稀有怪利斯克塞拉；结晶之印：颈部，全能/精通（样本 ×12）",
    ["падает с рарника Morchok; Окаменевшие споры грибов: шея на скорость/универсальность (слепок, ×8)"] = "掉落自稀有怪莫卓克；石化蘑菇孢子：颈部，急速/全能（样本 ×8）",
    ["падает с сундука за доставку рарника Страж источника к нпс Чалый Бертольд на Тирагардском поморье"] = "掉落自将稀有怪源泉守卫交给提拉加德海峡NPC灰白贝特霍尔德后的箱子",
    ["падает силовикам и ловкачам с Монстр арены в Награнде (В РЕЖИМЕ ИСТОРИИ)"] = "力量和敏捷职业掉落自纳格兰的竞技场怪物（剧情模式）",
    ["падает силовикам с Слякоч-повелитель в Горгронде"] = "力量职业掉落自戈尔隆德的软泥怪大王",
    ["падает со Зыбуна; Полуночные набедренники: кожаные ноги на крит/скорость, 3 гнезда (слепок, ×5)"] = "掉落自流沙；午夜护腿：皮甲腿部，暴击/急速，3个插槽（样本 ×5）",
    ["прожимка на искусность (сама вещь на универсальность), с сокровища"] = "主动精通（物品本身为全能），来自宝藏",
    ["сильная двуручка для силовиков"] = "强力双手武器，适合力量职业",
    ["тканевые руки за сопровождение Тралла (парная награда к Кушаку поборника)"] = "护送萨尔的布甲手套（与拥护者腰带配对奖励）",
    ["фамильная тринька для PvP"] = "PvP传家宝饰品",
    ["хорошая кожаная голова"] = "不错的皮甲头盔",
    ["хорошая кожаная голова с особым гнездом"] = "不错的皮甲头盔，带多彩插槽",
    ["хорошая латная голова на крит"] = "不错的板甲头盔，暴击",
    ["хорошая латная голова на универсальность"] = "不错的板甲头盔，全能",
    ["хорошие кожаные ноги для критовиков (1/2 сета Странника пустошей)"] = "暴击流不错的皮甲护腿（荒废者套装 1/2）",
    ["хорошие кожаные руки для критовиков (1/2 сета Странника пустошей)"] = "暴击流不错的皮甲手套（荒废者套装 1/2）",
    ["хорошие кожаные руки на кастеров"] = "法系不错的皮甲手套",
    ["хорошие кожаные руки на ловкачей"] = "敏捷职业不错的皮甲手套",
    ["хорошие кожаные сапоги"] = "不错的皮甲靴子",
    ["хорошие кольчужные сапоги"] = "不错的锁甲靴子",
    ["хорошие тканевые руки для DPS"] = "DPS不错的布甲手套",
    ["хороший кинжал для интовиков"] = "智力职业不错的匕首",
    ["хороший кольчужный шлем, но даёт меньше стат"] = "不错的锁甲头盔，但属性较低",
    ["хороший офф-хенд на интовиков"] = "智力职业不错的副手",
    ["хороший тканевый пояс"] = "不错的布甲腰带",
    ["хороший тканевый шлем для хиллеров, первая часть \"манасета\""] = "治疗不错的布甲头盔，“法力套装”第一件",
    -- ===== BiS_Community.lua note 翻译 =====
    ["кожаные плечи с универсальностью для монаха-ткача (от сообщества)"] = "织雾武僧用的全能皮甲护肩（社区）",
    ["падает с Вексалиуса; Сапоги оживления: кожаные ступни на универсальность, со скоростью бега (от сообщества)"] = "掉落自维萨鲁斯，全能，带移动速度（社区）",
    ["Двойной клинок мастерства: кинжал разбойника, обе руки (от сообщества)"] = "精通双刃：潜行者匕首，双手（社区）",
    ["Почти лучшая заточка Водина: кинжал, награда за задание, обе фракции, с 20 ур. (от сообщества)"] = "近乎最佳的沃丁匕首：任务奖励，双方阵营，20级起（社区）",
    ["Кинжал штормградского бойца авангарда: награда за задание, только Альянс, с 10 ур. (от сообщества)"] = "暴风城先锋战士匕首：任务奖励，仅联盟，10级起（社区）",
    ["падает с рарника Forgotten Creation; Амнезия: шея на скорость/универсальность (слепок, ×45 — самая ходовая)"] = "掉落自稀有怪被遗忘的造物；失忆：颈部，急速/全能（样本 ×45——最常用）",
    ["падает с Халкиаса; Запятнанная грехом подвеска: шея на скорость/искусность (слепок, ×16)"] = "掉落自哈尔基亚斯；罪恶玷污的吊坠：颈部，急速/精通（样本 ×16）",
    ["падает с Пожирателя Душ; Ожерелье из пропавших камней: шея на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x8)"] = "掉落自噬魂者；失落之石项链：颈部，暴击/急速。时空漫游，装等32（样本，x8）",
    ["падает с Броньяма; Узник любви: шея на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "掉落自布朗吉姆；爱的囚徒：颈部，急速/全能。时空漫游，装等32（样本，x3）",
    ["падает с Пожирателя Душ; Чародейский кулон злости: шея на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "掉落自噬魂者；奥术怨恨吊坠：颈部，暴击/全能。时空漫游，装等32（样本，x3）",
    ["Подвеска из рыбы-иглы (Pipefish Cord): шея на скорость/искусность. Тир 32"] = "尖嘴鱼束带：颈部，急速/精通。装等32",
    ["Почерневшее костяное ожерелье (Blackened Bone Necklace): шея на крит. Тир 32"] = "黑骨项链：颈部，暴击。装等32",
    ["Ртутный амулет (Quicksilver Amulet): шея на скорость/универсальность. Тир 32; по Wowhead ловится удочкой в Пещерах Черной Горы — не проверено"] = "水银护符：颈部，急速/全能。装等32；Wowhead说在黑石岩窟钓鱼获得——未验证",
    ["Магнит на кристальной цепи (Crystal-Chained Lodestone): шея на крит/скорость. Тир 32"] = "水晶链磁石：颈部，暴击/急速。装等32",
    ["Подвеска погруженного во тьму грота (Pendant of the Lightless Grotto): шея на искусность. Тир 32"] = "无光洞穴吊坠：颈部，精通。装等32",
    ["Разорванное ожерелье из земляного камня (Fractured Earthstone Necklace): шея на универсальность. Тир 32"] = "破碎的土石项链：颈部，全能。装等32",
    ["Окованная железом подвеска (Ironshell Pendant): шея на скорость. Тир 32"] = "铁壳吊坠：颈部，急速。装等32",
    ["Подвеска из ракушечника (Barnacle Pendant): шея на крит/скорость. Тир 32"] = "藤壶吊坠：颈部，暴击/急速。装等32",
    ["Подвеска несущего волны (Carrier Wave Pendant): шея на скорость/искусность. Тир 32"] = "载波吊坠：颈部，急速/精通。装等32",
    ["падает с Лорда-камергера; Печатка лживого обвинения: кольцо на искусность (слепок, ×36 — самое ходовое)"] = "掉落自宫务大臣；虚假指控之印：戒指，精通（样本 ×36——最常用）",
    ["Драгоценная петля из кровошипа: берут ради эффекта (шипы и незаметность), BiS - любая копия; с Горума (слепок: 17 копий 23 ур. без гнезда)"] = "血棘指环：为了特效（荆棘和潜行）而带，BiS——任意同款装备；来自戈鲁姆（样本：17个23级无插槽同款装备）",
    ["падает с Ингвара Расхителя; Несокрушимое тяжёлое кольцо: на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x7)"] = "掉落自掠夺者因格瓦尔；坚不可摧的重型戒指：急速/全能。时空漫游，装等32（样本，x7）",
    ["падает с Ингвара Расхителя; Кольцо Аннгильды: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x6)"] = "掉落自掠夺者因格瓦尔；安海尔德之戒：暴击/急速。时空漫游，装等32（样本，x6）",
    ["падает с Пожирателя Душ; Перстень злорадства: на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)"] = "掉落自噬魂者；怨恨指环：暴击/全能。时空漫游，装等32（样本，x3）",
    ["падает с Ануб-арака; Кольцо короля-предателя: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x2)"] = "掉落自阿努巴拉克；背叛者之王之戒：暴击/急速。时空漫游，装等32（样本，x2）",
    ["Кольцо антии (Anthia's Ring): на крит/искусность. Тир 32"] = "安西亚之戒：暴击/精通。装等32",
    ["Кольцо наутилуса (Nautilus Ring): на крит/скорость. Тир 32"] = "鹦鹉螺之戒：暴击/急速。装等32",
    ["Кольцо великого кита: на универсальность. Тир 32"] = "巨鲸之戒：全能。装等32",
    ["Перстень перевоплощения: на скорость/искусность. Тир 32"] = "转生指环：急速/精通。装等32",
    ["Щедро изукрашенное кольцо (Lavishly Jeweled Ring): на крит/скорость. Тир 32; в гильдии носят и обычную копию 23-26 уровня"] = "华丽珠宝戒指：暴击/急速。装等32；公会也有人佩戴23-26级普通版本",
    ["Перстень из розового кварца (Rose Quartz Band): на крит. Тир 32"] = "玫瑰石英指环：暴击。装等32",
    ["Фосфоресцирующее кольцо (Phosphorescent Ring): на универсальность. Тир 32"] = "磷光之戒：全能。装等32",
    ["Сплетенные нереиды (Entwined Nereis): кольцо на универсальность. Тир 32"] = "缠绕海仙女：戒指，全能。装等32",
    ["Бадья: кольцо на универсальность/искусность. Тир 32"] = "水桶：戒指，全能/精通。装等32",
    ["Кольцо череподробителя (Skullcracker Ring): на крит/искусность. Тир 32"] = "碎颅者之戒：暴击/精通。装等32",
    ["падает с Зубохлопа (Затерянный город Тол'вир); Кинжал Барима (Barim's Main Gauche): на крит/искусность. Тир 32"] = "掉落自锁喉（托维尔失落之城）；巴里姆的左手匕首：暴击/精通。装等32",
    ["падает с Камнешкура (Каменные Недра); Ртутный клинок (Quicksilver Blade): кинжал на скорость/искусность. Тир 32"] = "掉落自岩皮（巨石之核）；水银之刃：匕首，急速/精通。装等32",
    ["падает с Верховной жрицы Азил (Каменные Недра); Элементиевый клык: одноручный меч на силу, крит/искусность. Тир 32"] = "掉落自高阶女祭司阿兹尔（巨石之核）；元素之牙：单手剑，力量，暴击/精通。装等32",
    ["падает в Конце Времен; Зазубренное лезвие времени (Jagged Edge of Time): кинжал на крит/скорость. Тир 32"] = "掉落自时光之末；锯齿时光之刃：匕首，暴击/急速。装等32",
    ["падает с Глубтока (Мертвые копи); Шип-клинок (Buzzer Blade): кинжал на крит. Тир 32"] = "掉落自格鲁布托克（死亡矿井）；蜂鸣之刃：匕首，暴击。装等32",
    ["падает с Карша Гнущего Сталь (Пещеры Черной горы); Шедевр Гнущего Сталь (Steelbender's Masterpiece): кинжал на крит/искусность. Тир 32"] = "掉落自卡尔什·弯钢（黑石岩窟）；弯钢杰作：匕首，暴击/精通。装等32",
    ["падает с Сиамата (Затерянный город Тол'вир); Молот Искр (Hammer of Sparks): булава на ловкость, крит/скорость. Тир 32"] = "掉落自希亚玛特（托维尔失落之城）；火花之锤：敏捷锤，暴击/急速。装等32",
    ["падает в Каменных Недрах; Тяжелая жеодовая палица (Heavy Geode Mace): булава на ловкость, крит/скорость. Тир 32"] = "掉落自巨石之核；重型晶簇锤：敏捷锤，暴击/急速。装等32",
    ["[ДД] падает с Сиамата (Затерянный город Тол'вир); Благоволение Тиа (Tia's Grace): атаки дают +1 ловкости на 15 сек., до 10 раз. Тир 32"] = "[输出] 掉落自希亚玛特（托维尔失落之城）；提亚的恩典：攻击提供+1敏捷，持续15秒，最多叠加10次。装等32",
    ["падает с Командира Ри'мока (Врата Заходящего Солнца); Вертлуг богомола: кинжал на крит/скорость. Тир 32"] = "掉落自指挥官瑞莫克（残阳关）；螳螂妖关节：匕首，暴击/急速。装等32",
    ["падает с Геккана (Дворец Могу'шан); Когти Геккана: кистевое оружие на крит/скорость. Тир 32"] = "掉落自格坎（魔古山宫殿）；格坎之爪：拳套，暴击/急速。装等32",
    ["из ящика Тажаня Чжу (Монастырь Шадо-Пан); Ка'эн, дыхание тьмы (Ka'eng, Breath of the Shadow): кистевое оружие на крит/скорость. Тир 32"] = "来自塔兰·祝的箱子（影踪禅院）；卡恩，暗影之息：拳套，暴击/急速。装等32",
    ["падает с Ша Жестокости (Монастырь Шадо-Пан); Гнойный полумесяц: одноручный топор на скорость/искусность. Тир 32"] = "掉落自暴力之煞（影踪禅院）；化脓新月：单手斧，急速/精通。装等32",
    ["[ДД] Клык Расте: три вторички разом - крит, скорость, искусность. Падает с Расте, раз в день"] = "[输出] 同时提供三种副属性——暴击、急速、精通。掉落自拉斯特，每日稀有",
    ["[ДД] Обузданный огонь: три вторички разом - крит, универсальность, искусность. Падает с Обуглень Дикий Огонь, раз в день"] = "[输出] 同时提供三种副属性——暴击、全能、精通。掉落自野火辛德拉尔，每日稀有",
    ["[ДД] Карта Таро Пророчества: три вторички разом - крит, универсальность, искусность. Уникальная использующаяся"] = "[输出] 预言塔罗牌：同时提供三种副属性——暴击、全能、精通。唯一装备，使用效果",
    ["падает с Полководца Калитреша; Наплечники Лунной поляны: кожаные плечи на версу, два гнезда (в рейтинге ×8)"] = "掉落自督军卡利瑟里斯；月光林地护肩：皮甲肩部，全能，两个插槽（排行榜 ×8）",
    ["падает с Ингвара Расхителя; Шлем расхитителя: кольчужная голова на крит/скорость, два гнезда (в рейтинге ×8)"] = "掉落自掠夺者因格瓦尔；掠夺者头盔：锁甲头部，暴击/急速，两个插槽（排行榜 ×8）",
    ["[ДД] падает с Древний зуболом в Назмире; Беспрерывно тикающие часы: аксессуар со всеми основными статами разом (в рейтинге ×8)"] = "[输出] 掉落自纳兹米尔的远古碎牙者；不停滴答的时钟：同时提供所有主属性的饰品（排行榜 ×8）",
    ["падает с Мастера; Рукавицы Железного лезвия: латные кисти на крит (слепок, ×6)"] = "掉落自大师；铁刃护手：板甲手套，暴击（样本 ×6）",
    ["падает с Кель'таса Солнечного Скитальца; Наголенники кающегося рыцаря: латные ступни на универсальность (слепок, ×7)"] = "掉落自凯尔萨斯·逐日者；忏悔骑士护胫：板甲靴子，全能（样本 ×7）",
    ["падает со Зыбуна; Полуночные набедренники: кожаные ноги на крит/скорость, 3 гнезда (слепок, ×5)"] = "掉落自流沙；午夜护腿：皮甲腿部，暴击/急速，3个插槽（样本 ×5）",
    ["падает с Пожирателя Душ; Хребет разлагающегося трупа: агиловый посох, у друида-кота (слепок, ×4)"] = "掉落自噬魂者；腐烂尸骸之脊：敏捷法杖，野性德用（样本 ×4）",
    ["падает с верховного адъюдикатора Ализы; тринька на чистую скорость, годится любой роли (слепок, ×5)"] = "掉落自高阶审判官阿丽兹；纯急速饰品，任何角色适用（样本 ×5）",
    ["[Хил] падает с Эрудакса, Повелителя Глубин; Оскверненная яичная скорлупа: по использованию щит на союзника 2809 + возврат маны"] = "[治疗] 掉落自埃鲁达克，深渊之主；腐化的蛋壳：使用后为盟友提供2809护盾并回复法力",
    ["[ДД] падает с Эрудакса, Повелителя Глубин; Буря теней: интеллект копится от урона периодикой, до 20 стаков"] = "[输出] 掉落自埃鲁达克，深渊之主；暗影风暴：智力通过持续伤害积累，最多20层",
    ["падает с Гюрзиса и Аспидиса; Обоюдоострое копье: двуручное на ловкость, Путешествие во времени, ilvl 26 (логи, x98)"] = "掉落自阿德里斯和阿斯匹克斯；双刃长矛：敏捷双手，时空漫游，装等26（日志，x98）",
    ["редкий: Рука Эдварда Странного, уникальная одноручка, мировой дроп. В сборку не ставим (Keotore, армори ilvl 27)"] = "唯一单手，世界掉落。未放入配装（Keotore，英雄榜装等27）",
    ["[Хил] падает с Рухрана; Перо Рухрана: скорость и универсальность, синий, уникальный (Keotore, 30 из 50 заходов; статы и уровень с тултипа 21 сентября)"] = "[治疗] 掉落自鲁克兰；鲁克兰的羽毛：急速和全能，蓝色，唯一装备（Keotore，50次中30次；属性和装等来自9月21日提示）",
    ["падает с Вождя Каргата Острорука; Рука-клинок: одноручное кистевое, версия 26. Не путать с Рукой-клинком из Разрушенных залов (та 23). Прок скорости на 10 сек при ударе, откат 45 сек"] = "掉落自酋长卡加斯·刃拳；刃拳：单手拳套，26版。不要与破碎大厅的刃拳混淆（那个是23）。命中时触发急速，持续10秒，冷却45秒",
    ["падает с Императора Даграна Тауриссана; Сталебой: одноручное дробящее, уровень 26. Атаки могут сработать дважды"] = "掉落自皇帝达格兰·索瑞森；钢击：单手锤，等级26。攻击可能触发两次",
    ["падает с Вождя Укорза Песчаного Черепа; Головорез вождя: двуручный посох на ловкость, уровень 23"] = "掉落自酋长乌克兹·沙顶；酋长的杀手：敏捷双手法杖，等级23",
    ["падает с Надсмотрщика за рабами Крушто; Обезглавливатель Крушто: двуручное древковое на ловкость"] = "掉落自奴隶监工克鲁什托；克鲁什托的斩首者：敏捷双手长柄武器",
    ["падает с Черепона; Окровавленная рука горести: одноручное кистевое на ловкость"] = "掉落自碎颅者；染血的悲伤之手：敏捷单手拳套",
    ["падает с Кель'таса; Одеяния летнего великолепия: кожаная грудь, три бесцветных гнезда"] = "掉落自凯尔萨斯；夏日辉煌长袍：皮甲胸甲，三个棱彩插槽",
    ["Наручи огненной собранности: кожаные запястья, одно гнездо. Случайная добыча в подземельях Дренора (Крушто, Нхаллиш, Аззакель) и в тайниках, 1,5-3%"] = "火焰集中护腕：皮甲护腕，一个插槽。德拉诺地下城（克鲁什托、尼萨利什、阿扎凯尔）和宝箱随机掉落，1.5-3%",
    ["падает с Локена; Улучшенные поручи из выделанной кожи: кожа, уровень 23, одно гнездо"] = "掉落自洛肯；改良的制皮护腕：皮甲，等级23，一个插槽",
    ["падает с Локена (Чертоги Молний); те же Улучшенные поручи, версия Путешествия во времени, уровень 32, без гнезда"] = "掉落自洛肯（闪电大厅）；同样的改良护腕，时空漫游版本，等级32，无插槽",
    ["Наручи Кишкодава: латные запястья, без гнезда. Случайная добыча в подземельях Дренора (Крушто, Нхаллиш, Аззакель) и в тайниках, 1-3%"] = "肠击者护腕：板甲护腕，无插槽。德拉诺地下城（克鲁什托、尼萨利什、阿扎凯尔）和宝箱随机掉落，1-3%",
    ["падает с Хадронокса; Перчатки Туманного грота: кожа, Путешествие во времени, уровень 32"] = "掉落自哈德隆诺克斯；迷雾洞穴手套：皮甲，时空漫游，等级32",
    ["падает со Скарвальда Строителя (Крепость Утгард); Наручники проходчика: кожа, Путешествие во времени, уровень 32. Шанс мал, 0,2%"] = "掉落自建筑师斯卡瓦尔德（乌特加德城堡）；矿工护腕：皮甲，时空漫游，等级32。几率很低，0.2%",
    ["падает с Пожирателя Душ; Воплощение мечты: кожаные кисти, Путешествие во времени, уровень 32"] = "掉落自噬魂者；梦想化身：皮甲手套，时空漫游，等级32",
    ["падает с Аззакеля; Кровавая печать Аззакеля: аксессуар на ловкость и крит"] = "掉落自阿扎凯尔；阿扎凯尔的血印：敏捷和暴击饰品",
    ["падает с Дулгу и других в Вечном Цветении; Лист древних защитников: аксессуар на искусность, по использованию щит на союзника"] = "掉落自杜尔古和永茂林地的其他怪；古代守护者之叶：精通饰品，使用后为盟友提供护盾",
    ["[Хил] падает с Жрицы Делриссы; Флакон воды из Солнечного Колодца: универсальность, по использованию накопленный свет"] = "[治疗] 掉落自女祭司德莉希亚；太阳井水瓶：全能，使用后释放积累的光芒",
    ["[Танк] падает с Хадронокса; Квинтэссенция паутины: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23"] = "[坦克] 掉落自哈德隆诺克斯；蛛网精华：时空漫游版本，等级32。攻略中的地下城同款装备是另一件物品，等级23",
    ["падает с Жрицы Делриссы; Боевая палица верховной жрицы: одноручная, интеллект 19, одно родное гнездо"] = "掉落自女祭司德莉希亚；高阶女祭司的战锤：单手，19智力，一个原生插槽",
    ["падает со Стражницы душ Ниами; Губительный клинок мудреца: одноручный меч на интеллект 19"] = "掉落自缚魂者尼娅米；灭魂法师之刃：单手剑，19智力",
    ["падает с Дозорного Каатара; Кристаллический волшебный посох Камуи: двуручный, интеллект 30"] = "掉落自哨兵卡塔；卡缪的水晶魔法法杖：双手，30智力",
    ["крафт (инженерия Пандарии, надеть может только инженер); Легкая ретинальная защита: тканевый шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；轻型视网膜护甲：布甲头盔，多彩插槽和两个齿轮插槽",
    ["крафт (инженерия Пандарии, надеть может только инженер); Маскировочная ретинальная защита: кожаный шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；伪装视网膜护甲：皮甲头盔，多彩插槽和两个齿轮插槽",
    ["крафт (инженерия Пандарии, надеть может только инженер); Подвижная ретинальная защита: кожаный шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；机动视网膜护甲：皮甲头盔，多彩插槽和两个齿轮插槽",
    ["крафт (инженерия Пандарии, надеть может только инженер); Заряженная ретинальная защита: кольчужный шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；充能视网膜护甲：锁甲头盔，多彩插槽和两个齿轮插槽",
    ["крафт (инженерия Пандарии, надеть может только инженер); Смертоносная ретинальная защита: кольчужный шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；致命视网膜护甲：锁甲头盔，多彩插槽和两个齿轮插槽",
    ["крафт (инженерия Пандарии, надеть может только инженер); Специализированная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；特制视网膜护甲：板甲头盔，多彩插槽和两个齿轮插槽",
    ["крафт (инженерия Пандарии, надеть может только инженер); Усиленная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса"] = "制造（潘达利亚工程学，仅工程师可穿）；强化视网膜护甲：板甲头盔，多彩插槽和两个齿轮插槽",
    ["падает с Ром'огга Костекрушителя; Щит железной леди: Путешествие во времени, уровень 32. Статы двадцатки в игре не сняты"] = "掉落自罗姆欧格·碎骨者；铁娘子之盾：时空漫游，装等32。20级属性未在游戏中核实",
    ["[Танк] падает с Асаада; Сердце грома: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23"] = "[坦克] 掉落自阿萨德；雷霆之心：时空漫游版本，装等32。攻略中的地下城同款装备是另一件物品，装等23",
 

    -- Enchants.lua 附魔翻译
    ["Знак когтя"] = "爪之印记",
    ["Знак подготовленного солдата"] = "备战士兵印记",
    ["Знак незримого сатира"] = "隐形萨特印记",
    ["+2 к силе атаки и +2 к вероятности критического удара"] = "+2 攻击强度，+2 爆击",
    ["+3 к интеллекту и +2 к универсальности"] = "+3 智力，+2 全能",
    ["+3 к силе заклинаний и +1 к вероятности критического удара"] = "+3 法术强度，+1 爆击",
    ["+4 к основной характеристике"] = "+4 主属性",
    ["+3 к скорости"] = "+3 急速",
    ["+3 ко всем характеристикам"] = "+3 所有属性",
    ["+4 к универсальности"] = "+4 全能",
    ["+4 к силе"] = "+4 力量",
    ["+4 к ловкости"] = "+4 敏捷",
    ["+4 к интеллекту"] = "+4 智力",
    ["+4 к выносливости"] = "+4 耐力",
    ["+4 к силе заклинаний"] = "+4 法术强度",
    ["Затененная поясная застежка"] = "暗影腰带扣",
    ["+3 к силе и +2 к вероятности критического удара"] = "+3 力量，+2 爆击",
    ["+3 к ловкости и +2 к вероятности критического удара"] = "+3 敏捷，+2 爆击",
    ["+5 к интеллекту и +5% маны"] = "+5 智力，+5% 法力",
    ["+5 к интеллекту и +3 к выносливости"] = "+5 智力，+3 耐力",
    ["+3 к выносливости и небольшое увеличение скорости"] = "+3 耐力，略微提高移动速度",
    ["+3 к универсальности"] = "+3 全能",
    ["+3 к силе атаки"] = "+3 攻击强度",
    ["+4 к скорости"] = "+4 急速",
    ["+4 к искусности"] = "+4 精通",
    ["+4 к вероятности критического удара"] = "+4 爆击",
    ["Руна каменной горгульи"] = "石像鬼符文",
    ["Руна режущего льда"] = "冰刃符文",
    ["Руна павшего рыцаря"] = "堕落骑士符文",
    ["Рыцарь"] = "十字军",
    ["Танцующая сталь"] = "舞钢",
    ["+11 к силе заклинаний"] = "+11 法术强度",
    ["+12 к ловкости"] = "+12 敏捷",
    ["+10 к силе"] = "+10 力量",
    ["Прицел (+2 к урону)"] = "瞄准镜 (+2 伤害)",
    ["Пробужденные характеристики"] = "觉醒属性",
    ["+2 к искусности и небольшой бонус к скорости"] = "+2 精通，略微提高移动速度",
    ["+3 к силе заклинаний"] = "+3 法术强度",

    -- /tgf ref 和 /tgf gems 调试输出
    ["[TGF] %d %s | ур%s | %s | гн%d%s"] = "[TGF] %d %s | 装等%s | %s | 插槽%d%s",
    ["[TGF] %s | гн %d/%d | sb %s | камни %s"] = "[TGF] %s | 插槽 %d/%d | 奖励 %s | 宝石 %s",

    -- /tgf ref 属性缩写
    ["int"]   = "智",
    ["agi"]   = "敏",
    ["str"]   = "力",
    ["stam"]  = "耐",
    ["crit"]  = "暴",
    ["haste"] = "急",
    ["iskus"] = "精",
    ["vers"]  = "全",

    -- 设置页
    ["Язык"] = "语言",
    ["Как в игре"] = "跟随游戏",
    ["Русский"] = "俄语",
    ["Английский"] = "英语",
    ["Китайский"] = "中文",
    ["Язык окна и сообщений аддона. Смена языка применится после /reload."] =
        "插件窗口和消息的语言。切换后需 /reload 生效。",
    ["|cFFFFD100[TGF]|r Язык сохранён. Чтобы окно переключилось, сделай /reload."] =
        "|cFFFFD100[TGF]|r 语言已保存。窗口切换请执行 /reload。",
    ["Значок Путешествия во времени на плитках"] = "地下城格子上的时空漫游标记",
    ["Показывать знак валюты в углу плитки, если у данжа есть сложность Путешествия во времени."] =
        "当地下城有时空漫游难度时，在格子角落显示货币图标。",
    ["Данжи Путешествия во времени на текущем сезоне"] = "当前赛季标签页上的时空漫游地下城",
    ["На вкладке текущего сезона показывать данжи текущей недели Путешествия во времени вместо ключей Midnight."] =
        "在当前赛季标签页上显示本周时空漫游地下城，而不是至暗之夜钥石地下城。",

    -- ===== Talents.lua note 翻译 =====
    ["Оружие: сборка Кавочавоо"] = "武器：Кавочавоо 的配装",
    ["Неистовство: сборка Кавочавоо, 247 заходов в логах рейтинга"] = "狂怒：Кавочавоо 的配装，排行榜中 247 次通关",
    ["Защита: сборка Кавочавоо"] = "防护：Кавочавоо 的配装",
    ["Повелитель зверей: Команда «Взять!», Звериный гнев, Дикий трепет, Ужасный зверь, Спутник животного. Без Разрывающего и Кобры"] = "野兽控制：杀戮命令、狂野怒火、野性之怒、凶暴野兽、动物伙伴。不带夺命射击和眼镜蛇射击",
    ["Стрельба: лучшая из тех, где есть Быстрая стрельба — её жмут 98 % игроков"] = "射击：带急速射击的最佳配装——98% 玩家使用它",
    ["Выживание: Обрез, Остриё копья, Дикий огонь, Команда «Взять!», Удар ящера"] = "生存：猛禽一击、鱼叉尖刺、野火炸弹、杀戮命令、猛禽打击",
    ["Воздаяние: сборка Эбеко, лучшая из 43 сборок двадцаток гильдии"] = "惩戒：Эбеко 的配装，公会 43 套 20 级配装中最佳",
    ["Защита: сборка Пурдюшечки, лучшая из 37 сборок двадцаток гильдии"] = "防护：Пурдюшечка 的配装，公会 37 套 20 级配装中最佳",
    ["Свет: сборка Keotore с армори 21 сентября. Лекаря симулятор не считает — код не замерен уроном"] = "神圣：Keotore 的配装，来自 9 月 21 日英雄榜。治疗专精模拟器不计算——代码未按伤害测量",
    ["Нечестивость: лучшая из сборок двадцаток гильдии"] = "邪恶：公会 20 级配装中最佳",
    ["Лёд: лучшая из сборок двадцаток гильдии"] = "冰霜：公会 20 级配装中最佳",
    ["Кровь: лучшая из сборок двадцаток гильдии"] = "鲜血：公会 20 级配装中最佳",
    ["Баланс: лучшая из 14 сборок двадцаток гильдии"] = "平衡：公会 14 套 20 级配装中最佳",
    ["Сила зверя: лучшая из 16 сборок двадцаток гильдии"] = "野性：公会 16 套 20 级配装中最佳",
    ["Страж: лучшая из 14 сборок двадцаток гильдии"] = "守护：公会 14 套 20 级配装中最佳",
    ["Исцеление: сборка двадцатки гильдии. Лекаря симулятор не считает — не замерена"] = "恢复：公会 20 级配装。治疗专精模拟器不计算——未测量",

    -- 1 октября: проверка полноты перевода
    ["Ранг"] = "评级",
    ["The War Within"] = "地心之战",
    ["Midnight"] = "至暗之夜",
    ["Ранг аксессуара для спека: S лучший, дальше A, B, C"] = "该专精的饰品评级：S 最佳，其次为 A、B、C",
    ["Только для своего класса: чужую сборку с твоими вещами не сравнить."] = "仅限本职业：其他职业的配装无法与你的装备对比。",
    ["[TGF] %s | гн %d/%d | sb %s | камни %s"] = "[TGF] %s | 插槽 %d/%d | sb %s | 宝石 %s",
    ["[TGF] %d %s | ур%s | %s | гн%d%s"] = "[TGF] %d %s | 装等%s | %s | 插槽%d%s",
    ["|cFFFFD100[TGF]|r Команды разработчика: %s"] = "|cFFFFD100[TGF]|r 开发者命令：%s",
    ["включены"] = "已开启",
    ["выключены"] = "已关闭",
    ["Отладка"] = "调试",
    ["Команды разработчика (/tgf debug, ui, names, pins) и кнопка SimC в окне «Сборки». Для проверки и отчётов об ошибках."] = "开发者命令（/tgf debug、ui、names、pins）以及“配装”窗口中的 SimC 按钮。用于测试和错误报告。",
    ["|cFFFFD100[TGF]|r Неизвестная команда. Команды разработчика включаются галочкой «Отладка» в Параметрах."] = "|cFFFFD100[TGF]|r 未知命令。开发者命令可在设置中勾选“调试”开启。",
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

-- Выбранный язык аддона (не клиента): ruRU, enUS или zhCN.
function ns.AddonLang() return Resolve() end

-- Перевод строки. Вызывается и как L("текст"), и как L"текст".
function ns.L(text)
    local loc = Resolve()
    if loc == "ruRU" then return text end
    if loc == "zhCN" then return zhCN[text] or enUS[text] or text end
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

-- Короткие подписи колонок. Ключ словаря один на слово, а «Сила» - и полное
-- название, и подпись узкой колонки: «Strength» в неё не влезало, переносилось
-- на вторую строку и уезжало вниз (23 сентября).
local SHORT_EN = { ["Сила"] = "Str" }
local SHORT_ZH = { ["Сила"] = "力" }

function ns.ShortLabel(ru)
    local loc = Resolve()
    if loc == "zhCN" and SHORT_ZH[ru] then return SHORT_ZH[ru] end
    if loc ~= "ruRU" and SHORT_EN[ru] then return SHORT_EN[ru] end
    return ns.L(ru)
end

-- Заметка под источником. Гайдовые переведены словарём. Заметки Путешествия
-- во времени собраны из русского журнала по шаблону «падает с <босс>; <вещь>.
-- Журнал, <эпоха>, тир N»: имена боссов в них русские, английских взять
-- неоткуда, а вещь и так названа в строке. Поэтому не на русском остаются
-- эпоха и тир.
local EPOCH_EN = {
    ["классика"] = "Classic", ["BC"] = "Burning Crusade", ["гнев"] = "Wrath of the Lich King",
    ["катаклизм"] = "Cataclysm", ["Пандария"] = "Mists of Pandaria", ["Дренор"] = "Warlords of Draenor",
    ["Легион"] = "Legion", ["BfA"] = "Battle for Azeroth", ["Темные земли"] = "Shadowlands",
    ["Драконы"] = "Dragonflight",
}
local EPOCH_ZH = {
    ["классика"] = "经典旧世", ["BC"] = "燃烧的远征", ["гнев"] = "巫妖王之怒",
    ["катаклизм"] = "大灾变", ["Пандария"] = "潘达利亚之谜", ["Дренор"] = "德拉诺之王",
    ["Легион"] = "军团再临", ["BfA"] = "争霸艾泽拉斯", ["Темные земли"] = "暗影国度",
    ["Драконы"] = "巨龙时代",
}

function ns.Note(text)
    if not text then return text end
    local loc = Resolve()
    if loc == "ruRU" then return text end
    if loc == "zhCN" and zhCN[text] then return zhCN[text] end
    if enUS[text] then return enUS[text] end
    local epoch, tier = text:match("^падает с .-; .-%. Журнал, ([^,]+), тир (%d+)$")
    if epoch then
        if loc == "zhCN" then
            return string.format("时空漫游：%s，装等%s", EPOCH_ZH[epoch] or epoch, tier)
        end
        return string.format("Timewalking journal: %s, tier %s", EPOCH_EN[epoch] or epoch, tier)
    end
    return text
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
    local loc = Resolve()
    if loc == "ruRU" then return text end
    for _, word in ipairs(STAT_WORDS) do
        local translated = (loc == "zhCN") and zhCN[word] or enUS[word]
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
local CHOICES = { "auto", "ruRU", "enUS", "zhCN" }

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
        container:Add(4, L"Китайский")
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

    -- Отладка: команды разработчика (/tgf debug, ui, names, pins) и кнопка
    -- SimC в окне «Сборки». Тот же флаг, что у /tgf dev (пользователь 1 октября:
    -- «пусть работают, когда в параметрах стоит галочка»).
    local devSetting = Settings.RegisterProxySetting(category, "TRIALGEARFINDER_DEV",
        Settings.VarType.Boolean, L"Отладка", false,
        function() return TrialGearFinderDB and TrialGearFinderDB.dev and true or false end,
        function(value)
            TrialGearFinderDB = TrialGearFinderDB or {}
            TrialGearFinderDB.dev = value and true or nil
            if ns.ApplyDevButtons then ns.ApplyDevButtons() end
        end)
    Settings.CreateCheckbox(category, devSetting,
        L"Команды разработчика (/tgf debug, ui, names, pins) и кнопка SimC в окне «Сборки». Для проверки и отчётов об ошибках.")

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
