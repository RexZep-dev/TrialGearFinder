-- Предметы от СООБЩЕСТВА, отдельно от базы главы гильдии.
--
-- База в Data.lua — работа автора гайда «Отвергнутые и Забытые», её формат
-- и содержимое ведёт он. Этот файл — вещи, которые в тот гайд не попали,
-- а игроки считают их BiS: приносят названием или Shift-ссылкой, я завожу
-- строку тем же форматом. Авторство здесь — сообщество, не глава гильдии.
--
-- Окно BiS-сборок (BiS.lua) собирает кандидатов в слот из ОБЕИХ баз.
-- Формат записи — как в Data.lua: см. его шапку.

local addonName, ns = ...

ns.CommunityItems = {
    -- Ткань/кожа/кольчуга/латы — тем же порядком полей, что Data.lua.

    { itemID = 27417, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Старые предгорья Хилсбрада", note = "кожаные плечи с универсальностью для монаха-ткача (от сообщества)", ilvl = 23, armor = 7, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = { key = "int", value = 1 }, stats = { agi = 5, int = 5, stam = 7, haste = 4, vers = 5 } },
    -- +скорость передвижения на этих сапогах — третичка, в статах не учитываем.
    -- id был 133441 (догадка по Wowhead) — по слепку гильдии 13 одетых носят
    -- 34707: тот же «Сапоги оживления», кожа, 2 гнезда. Поправлено 8 сентября.
    { itemID = 34707, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Терраса Магистров", note = "падает с Вексалиуса; Сапоги оживления: кожаные ступни на универсальность, со скоростью бега (от сообщества)", ilvl = 23, armor = 9, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { agi = 5, int = 5, stam = 7, vers = 5 } },
    -- Двойной клинок мастерства: кинжал разбойника, БиС Ликвидации в обе руки.
    -- id найден через Wowhead (127234, добыча с Пандемониус в Гробницах Маны),
    -- статы сняты со скриншота с триала — в игре аддоном не сверялись.
    { itemID = 127234, bonusIDs = { 6710, 6652 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Гробницы маны", note = "Двойной клинок мастерства: кинжал разбойника, обе руки (от сообщества)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 3, stam = 3, crit = 7, haste = 4 } },

    -- ── Шеи и кольца (пред-BiS) ──────────────────────────────────────────
    -- В базе гайда их нет (шеи удалены к 1.0 — часть больше не выбить; колец
    -- не было). Это НЕ идеальный ролл, а пред-BiS: то, что реально выбивает
    -- любой игрок сейчас, независимо от гильдии. Набрано по слепку 195 одетых
    -- твинков 8 сентября — itemID, уровень, гнёзда, статы с армори; источник
    -- у большинства не выяснен ("уточнить").
    -- Мёртвые удалённые шеи (никто из 195 не носит) назад НЕ вернулись:
    -- 17707, 18723, 88275, 88281, 133767, 137311, 144479, 178707, 185820, 185842.
    -- classes = nil: это «Разное», носят все классы; окно ранжирует по статам
    -- спека. Число за именем в комментарии — сколько человек носят.

    -- Шеи: считаем ТОЛЬКО родное гнездо.
    -- Оправы, дававшие шеям +1/+2 гнезда, занерфлены — новый игрок их уже
    -- не вставит, а у старых копий они остались. По слепку это видно по
    -- разбросу: у Амнезии 3г×72 и 0г×2, у Запятнанной 2г×16 и 0г×3 —
    -- гнёзда не родные. У тайм-волковских шей строго 1г у всех: там гнездо
    -- даёт сам бонус 13668, его получит каждый.
    -- Кольца — другое дело: оправа из The War Within работает, второе
    -- гнездо в кольцо вставить можно, поэтому у колец оставляем 2.
    -- Шеи
    { itemID = 200210, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Лазурный Простор", note = "падает с рарника Forgotten Creation; Амнезия: шея на скорость/универсальность (слепок, ×45 — самая ходовая)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 10, vers = 8 } },
    { itemID = 178827, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "Чертоги Покаяния", note = "падает с Халкиаса; Запятнанная грехом подвеска: шея на скорость/искусность (слепок, ×16)", ilvl = 26, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 14, iskus = 6 } },
    { itemID = 200446, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Равнины Он'ары", note = "падает с рарника Liskheszaera; Кристаллизованная печать: шея на универсальность/искусность (слепок, ×12)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 8, iskus = 10 } },
    { itemID = 200207, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Берега Пробуждения", note = "падает с рарника Morchok; Окаменевшие споры грибов: шея на скорость/универсальность (слепок, ×8)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 9, vers = 9 } },
    { itemID = 193809, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Ульдаман: наследие Тира", note = "падает с Бромача; Выкопанный медальон Бромача: шея на скорость/искусность (слепок, ×6)", ilvl = 22, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 5, haste = 13, iskus = 5 } },
    { itemID = 188471, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Кузня Душ", note = "падает с Пожирателя Душ; Ожерелье из пропавших камней: шея на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x8)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 11, haste = 10 } },
    -- Тир «Искажение временем» (ilvl 32): падают с боссов данжей Wrath только
    -- в неделю Путешествий во времени. Связка 13668/13828/7756 сверена с армори
    -- (гнездо от 13668, scale-config 444 = ilvl 32).
    { itemID = 188476, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Кузня Душ", note = "падает с Броньяма; Узник любви: шея на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 8, vers = 13 } },
    { itemID = 188485, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Кузня Душ", note = "падает с Пожирателя Душ; Чародейский кулон злости: шея на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 10, vers = 10 } },
    -- Катаклизм, Путешествие во времени (ближайшая неделя — 16 сентября).
    -- Другой пул, чем три записи выше: те из данжей Нортренда, эти из
    -- катаклизменных, включая переделанные Крепость Темного Клыка и Мертвые
    -- копи. Связка bonusIDs та же, тир тот же (ilvl 32, гнездо от 13668).
    -- Статы сняты с тултипов пользователя 12 сентября, id — из слепка
    -- гильдии по точному имени, английские имена сверены на Wowhead.
    -- В ИГРЕ НЕ ПРОВЕРЕНО: ждут /reload и взгляда на окно.
    { itemID = 133199, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Подвеска из рыбы-иглы (Pipefish Cord): шея на скорость/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 14, iskus = 7 } },
    { itemID = 224735, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Почерневшее костяное ожерелье (Blackened Bone Necklace): шея на крит. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 15, vers = 6 } },
    { itemID = 188495, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Ртутный амулет (Quicksilver Amulet): шея на скорость/универсальность. Тир 32; по Wowhead ловится удочкой в Пещерах Черной Горы — не проверено", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 10, vers = 11 } },
    -- Вторая половина шей: id найдены по русскому названию через локаль 7
    -- тултип-ручки Wowhead (nether.wowhead.com/tooltip/item/ID?locale=7).
    -- Совпадение имён точное, побуквенно.
    { itemID = 133364, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Магнит на кристальной цепи (Crystal-Chained Lodestone): шея на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 13, haste = 8 } },
    { itemID = 133215, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Подвеска погруженного во тьму грота (Pendant of the Lightless Grotto): шея на искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 6, iskus = 15 } },
    { itemID = 133366, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Разорванное ожерелье из земляного камня (Fractured Earthstone Necklace): шея на универсальность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 7, vers = 13 } },
    { itemID = 133359, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Окованная железом подвеска (Ironshell Pendant): шея на скорость. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 6, haste = 15 } },
    { itemID = 133203, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Подвеска из ракушечника (Barnacle Pendant): шея на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 13, haste = 8 } },
    -- У этой вещи русское имя носят ЧЕТЫРЕ разных itemID: 55781 и 56319 -
    -- обычная и героическая копии времён Катаклизма, 188513 - современная.
    -- Взят 188513: живые вещи гильдии из этого пула лежат в диапазонах 133xxx
    -- и 188xxx, старых 55xxx/56xxx нет ни у кого из 324 разобранных твинков.
    -- ЭТО ВЫВОД, А НЕ ЗАМЕР: проверить уровнем предмета в окне (должен быть 32).
    { itemID = 188513, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Подвеска несущего волны (Carrier Wave Pendant): шея на скорость/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 10, iskus = 11 } },

    -- Возвращены: удалялись к 1.0, но слепок показал — их всё ещё носят.
    { itemID = 193647, bonusIDs = { 6710, 6652, 8810 }, classes = nil, sourceType = "Dungeon", source = "Лазурные Врата", note = "Комендантский медальон наваждения: шея на универсальность/искусность (слепок, ×7; была удалена)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 11, iskus = 8 } },
    { itemID = 193676, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Наступление Нохуда", note = "Бусы предков Укхел: шея на скорость/искусность (слепок, ×4; была удалена)", ilvl = 22, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 5, haste = 6, iskus = 13 } },

    -- Кольца
    { itemID = 178824, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "Чертоги Покаяния", note = "падает с Лорда-камергера; Печатка лживого обвинения: кольцо на искусность (слепок, ×36 — самое ходовое)", ilvl = 26, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 6, iskus = 14 } },
    { itemID = 113082, bonusIDs = { 572, 13619 }, classes = nil, sourceType = "World", source = "Долина Призрачной Луны", note = "Драгоценная петля из кровошипа: кольцо со всеми статами и универсальностью, с Горума (слепок, ×17)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 4, agi = 4, int = 4, stam = 4, vers = 6 } },
    { itemID = 178870, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Театр Боли", note = "падает с Кул'тарока; Ритуальное костяное кольцо: на универсальность/искусность (слепок, ×15)", ilvl = 23, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 13, iskus = 6 } },
    { itemID = 178871, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Театр Боли", note = "падает с Оскорбления претендентов; Печатка клятвы на крови: кольцо на крит/скорость (слепок, ×10)", ilvl = 23, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 8, haste = 11 } },
    { itemID = 178869, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Театр Боли", note = "падает с Кроворуба; Усиленный плотью ободок: кольцо на крит/искусность (слепок, ×9)", ilvl = 23, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 6, iskus = 13 } },
    { itemID = 178736, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "Смертельная тризна", note = "падает с Чумокоста; Потерянная печатка Трупошва: кольцо на скорость/универсальность (слепок, ×9)", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 12, vers = 7 } },
    { itemID = 188446, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Крепость Утгард", note = "падает с Ингвара Расхителя; Несокрушимое тяжёлое кольцо: на скорость/универсальность. Путешествие во времени, ilvl 32 (слепок, x7)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 10, vers = 11 } },
    { itemID = 188451, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Крепость Утгард", note = "падает с Ингвара Расхителя; Кольцо Аннгильды: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x6)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 9, haste = 12 } },
    { itemID = 188472, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Кузня Душ", note = "падает с Пожирателя Душ; Перстень злорадства: на крит/универсальность. Путешествие во времени, ilvl 32 (слепок, x3)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 10, vers = 11 } },
    { itemID = 188419, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Азжол-Неруб", note = "падает с Ануб-арака; Кольцо короля-предателя: на крит/скорость. Путешествие во времени, ilvl 32 (слепок, x2)", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 13, haste = 8 } },

    -- Кольца того же катаклизменного тира 32. У всех ровно одно бесцветное
    -- гнездо (сказано пользователем по тултипам) — в отличие от обычных
    -- колец, где оправа даёт второе.
    -- В ИГРЕ НЕ ПРОВЕРЕНО.
    { itemID = 133189, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Кольцо антии (Anthia's Ring): на крит/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 12, iskus = 9 } },
    { itemID = 133194, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Кольцо наутилуса (Nautilus Ring): на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 13, haste = 7 } },
    { itemID = 133204, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Кольцо великого кита: на универсальность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 6, vers = 15 } },
    { itemID = 188494, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Перстень перевоплощения: на скорость/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 10, iskus = 11 } },
    { itemID = 1156, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Щедро изукрашенное кольцо (Lavishly Jeweled Ring): на крит/скорость. Тир 32; в гильдии носят и обычную копию 23-26 уровня", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 14, haste = 7 } },
    { itemID = 133211, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Перстень из розового кварца (Rose Quartz Band): на крит. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 15, haste = 6 } },
    { itemID = 133210, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Фосфоресцирующее кольцо (Phosphorescent Ring): на универсальность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 7, vers = 14 } },
    { itemID = 133183, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Сплетенные нереиды (Entwined Nereis): кольцо на универсальность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 8, vers = 13 } },
    -- Те же четыре одноимённых id, что у Подвески несущего волны: взяты
    -- современные 188xxx, вывод тот же и так же НЕ ПРОВЕРЕН.
    { itemID = 188502, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Бадья: кольцо на универсальность/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 11, iskus = 10 } },
    { itemID = 188505, bonusIDs = { 13668, 13828, 7756 }, classes = nil, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "Кольцо череподробителя (Skullcracker Ring): на крит/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 11, iskus = 10 } },

    -- ── Прочие слоты (пред-BiS) ──────────────────────────────────────────
    -- Не из гайда, но у одетых согильдийцев (котёл из 67 с BiS-шмотом) на них
    -- сходится 5+ человек. Статы/уровень/гнёзда — с армори, источник не выяснен.
    { itemID = 24387, bonusIDs = { 6710, 6652 }, classes = { "DEATHKNIGHT", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "Кузня Крови", note = "падает с Мастера; Рукавицы Железного лезвия: латные кисти на крит (слепок, ×6)", ilvl = 23, armor = 15, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { str = 5, int = 5, stam = 7, crit = 10 } },
    { itemID = 34612, bonusIDs = { 6710, 6652 }, classes = { "DEATHKNIGHT", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "Терраса Магистров", note = "падает с Кель'таса Солнечного Скитальца; Наголенники кающегося рыцаря: латные ступни на универсальность (слепок, ×7)", ilvl = 23, armor = 14, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { str = 5, int = 5, stam = 7, vers = 5 } },
    { itemID = 30538, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Узилище", note = "падает со Зыбуна; Полуночные набедренники: кожаные ноги на крит/скорость, 3 гнезда (слепок, ×5)", ilvl = 23, armor = 9, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = nil, stats = { agi = 7, int = 7, stam = 10, crit = 7, haste = 4 } },
    { itemID = 188465, bonusIDs = { 6710, 6652 }, classes = { "DRUID", "MONK", "HUNTER" }, sourceType = "Dungeon", source = "Кузня Душ", note = "падает с Пожирателя Душ; Хребет разлагающегося трупа: агиловый посох, у друида-кота (слепок, ×4)", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 7, stam = 11, crit = 7, haste = 8 } },
    { itemID = 178826, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Чертоги Покаяния", note = "падает с верховного адъюдикатора Ализы; тринька на чистую скорость, годится любой роли (слепок, ×5)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { haste = 9 } },

    -- Оба падают с одного босса, Эрудакса в Грим Батоле - разобрано по
    -- предложению пользователя 11 сентября: скорлупа для хилеров (щит на
    -- союзника + возврат маны), буря теней для урона периодикой (Тьма).
    -- Жёстко закреплены за спеками в BiS_Data.lua (ns.BiSPick), сюда попадают
    -- только как источник данных - в общем ранжировании их формула недооценит:
    -- эффект по использованию, не голые статы.
    { itemID = 56463, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Грим Батол", note = "[Хил] падает с Эрудакса, Повелителя Глубин; Оскверненная яичная скорлупа: по использованию щит на союзника 2809 + возврат маны", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = {  } },
    { itemID = 56462, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Грим Батол", note = "[ДД] падает с Эрудакса, Повелителя Глубин; Буря теней: интеллект копится от урона периодикой, до 20 стаков", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { haste = 9 } },
}
