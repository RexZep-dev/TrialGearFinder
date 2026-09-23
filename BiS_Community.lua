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

    -- Кинжалы разбойника, которые НЕ надо выбивать — награды за задания
    -- (13 сентября). Двойной клинок мастерства падает с шансом 0,13 %,
    -- Клинок Черного яда — 0,53 % (Wowhead). В SimC пара Водин + штормградский
    -- у Ликвидации сильнее обоих: 1546 против 1537 у Клинка Черного яда ×2.
    -- Статы и bonusIDs сняты с армори согильдийцев, у кого эти кинжалы надеты.
    { itemID = 41825, bonusIDs = { 4811, 4815 }, classes = { "ROGUE" }, sourceType = "Quest", source = "Зул'Драк — задание «Чемпион Амфитеатра Страданий»", note = "Почти лучшая заточка Водина: кинжал, награда за задание, обе фракции, с 20 ур. (от сообщества)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 3, stam = 4, crit = 4, haste = 5 } },
    { itemID = 138770, bonusIDs = { 4811 }, classes = { "ROGUE" }, sourceType = "Quest", source = "Задание «Битва за Расколотый берег» — только Альянс", note = "Кинжал штормградского бойца авангарда: награда за задание, только Альянс, с 10 ур. (от сообщества)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 3, stam = 5, haste = 4, iskus = 3 } },

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
    { itemID = 200210, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Лазурный Простор", note = "падает с рарника Forgotten Creation; Амнезия: шея на скорость/универсальность (слепок, ×45 — самая ходовая)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 10, vers = 8 } },
    { itemID = 178827, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "Чертоги Покаяния", note = "падает с Халкиаса; Запятнанная грехом подвеска: шея на скорость/искусность (слепок, ×16)", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 14, iskus = 6 } },
    { itemID = 200446, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Равнины Он'ары", note = "падает с рарника Liskheszaera; Кристаллизованная печать: шея на универсальность/искусность (слепок, ×12)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, vers = 8, iskus = 10 } },
    { itemID = 200207, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Берега Пробуждения", note = "падает с рарника Morchok; Окаменевшие споры грибов: шея на скорость/универсальность (слепок, ×8)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 9, vers = 9 } },
    { itemID = 193809, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Ульдаман: наследие Тира", note = "падает с Бромача; Выкопанный медальон Бромача: шея на скорость/искусность (слепок, ×6)", ilvl = 22, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 5, haste = 13, iskus = 5 } },
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
    { itemID = 193676, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Наступление Нохуда", note = "Бусы предков Укхел: шея на скорость/искусность (слепок, ×4; была удалена)", ilvl = 22, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 5, haste = 6, iskus = 13 } },

    -- Кольца
    { itemID = 178824, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "Чертоги Покаяния", note = "падает с Лорда-камергера; Печатка лживого обвинения: кольцо на искусность (слепок, ×36 — самое ходовое)", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 6, iskus = 14 } },
    { itemID = 113082, bonusIDs = { 572, 13619 }, classes = nil, sourceType = "World", source = "Долина Призрачной Луны", note = "Драгоценная петля из кровошипа: кольцо со всеми статами и универсальностью, с Горума (слепок, ×17)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { str = 4, agi = 4, int = 4, stam = 4, vers = 6 } },
    { itemID = 178870, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Театр Боли", note = "падает с Кул'тарока; Ритуальное костяное кольцо: на универсальность/искусность (слепок, ×15)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, vers = 13, iskus = 6 } },
    { itemID = 178871, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Театр Боли", note = "падает с Оскорбления претендентов; Печатка клятвы на крови: кольцо на крит/скорость (слепок, ×10)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, crit = 8, haste = 11 } },
    { itemID = 178869, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Театр Боли", note = "падает с Кроворуба; Усиленный плотью ободок: кольцо на крит/искусность (слепок, ×9)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, crit = 6, iskus = 13 } },
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

    -- Оружие и аксессуар того же пула, Катаклизм (13 сентября). Статы — с тултипов
    -- пользователя (смотрел воином, поэтому ловкость там серая). Гнезда нет,
    -- поэтому связка без 13668: у оружия и аксессуаров тира 32 она 13828/7756.
    -- НОМЕРА — ВЫВОД: у каждой вещи 2-3 номера (обычная, героическая,
    -- современная копии), а дамп simc и тултип-ручка Wowhead их не различают.
    -- Взят современный, где есть (133213), иначе героический 56xxx: Путешествия
    -- во времени идут по героическим версиям, и Благоволение Тиа в гильдии
    -- носят именно под 56394. Проверяется в неделю Путешествий во времени.
    -- В ИГРЕ НЕ ПРОВЕРЕНО.
    { itemID = 56390, bonusIDs = { 13828, 7756 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает с Зубохлопа (Затерянный город Тол'вир); Кинжал Барима (Barim's Main Gauche): на крит/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, iskus = 4 } },
    { itemID = 133213, bonusIDs = { 13828, 7756 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает с Камнешкура (Каменные Недра); Ртутный клинок (Quicksilver Blade): кинжал на скорость/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, haste = 4, iskus = 3 } },
    -- Элементиевый клык: современная копия Путешествия во времени, не героический
    -- 56346 (там парирование, уровень 38). Статы и отсутствие гнезда — с живого
    -- тултипа 22 сентября: 8–14, 2,60, сила 4, выносливость 6, крит 3, искусность 4.
    -- Связка без 13668: гнезда нет, как у Ртутного клинка.
    { itemID = 133223, bonusIDs = { 13828, 7756 }, classes = { "DEATHKNIGHT", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает с Верховной жрицы Азил (Каменные Недра); Элементиевый клык: одноручный меч на силу, крит/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 4, stam = 6, crit = 3, iskus = 4 } },
    { itemID = 72822, bonusIDs = { 13828, 7756 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает в Конце Времен; Зазубренное лезвие времени (Jagged Edge of Time): кинжал на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, haste = 4 } },
    { itemID = 65163, bonusIDs = { 13828, 7756 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает с Глубтока (Мертвые копи); Шип-клинок (Buzzer Blade): кинжал на крит. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 7 } },
    { itemID = 56302, bonusIDs = { 13828, 7756 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает с Карша Гнущего Сталь (Пещеры Черной горы); Шедевр Гнущего Сталь (Steelbender's Masterpiece): кинжал на крит/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, iskus = 3 } },
    { itemID = 56396, bonusIDs = { 13828, 7756 }, classes = { "ROGUE", "SHAMAN", "MONK" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает с Сиамата (Затерянный город Тол'вир); Молот Искр (Hammer of Sparks): булава на ловкость, крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, haste = 4 } },
    { itemID = 55822, bonusIDs = { 13828, 7756 }, classes = { "ROGUE", "SHAMAN", "MONK" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "падает в Каменных Недрах; Тяжелая жеодовая палица (Heavy Geode Mace): булава на ловкость, крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, haste = 4 } },
    { itemID = 56394, bonusIDs = { 13828, 7756 }, classes = { "DEMONHUNTER", "DRUID", "HUNTER", "MONK", "ROGUE", "SHAMAN" }, sourceType = "Dungeon", source = "Путешествие во времени: Катаклизм", note = "[ДД] падает с Сиамата (Затерянный город Тол'вир); Благоволение Тиа (Tia's Grace): атаки дают +1 ловкости на 15 сек., до 10 раз. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { iskus = 11 } },

    -- Пандария, Путешествие во времени (13 сентября) — ДРУГОЙ пул и другая неделя,
    -- не катаклизменная: Врата Заходящего Солнца, Монастырь Шадо-Пан, Дворец
    -- Могу'шан. Статы — с тултипов пользователя (смотрел воином, ловкость серая).
    -- Номера — современные копии 144xxx (у каждой вещи есть и старый номер
    -- 8xxxx), по тому же правилу, что шеи и кольца: вывод, не замер. Цвет
    -- названия копию не выдаёт — связка 13828 сама делает вещь редкой.
    -- В ИГРЕ НЕ ПРОВЕРЕНО.
    { itemID = 144098, bonusIDs = { 13828, 7756 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Путешествие во времени: Пандария", note = "падает с Командира Ри'мока (Врата Заходящего Солнца); Вертлуг богомола: кинжал на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, haste = 4 } },
    { itemID = 144148, bonusIDs = { 13828, 7756 }, classes = { "ROGUE", "SHAMAN", "MONK", "DEMONHUNTER" }, sourceType = "Dungeon", source = "Путешествие во времени: Пандария", note = "падает с Геккана (Дворец Могу'шан); Когти Геккана: кистевое оружие на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, haste = 3 } },
    { itemID = 144215, bonusIDs = { 13828, 7756 }, classes = { "ROGUE", "SHAMAN", "MONK", "DEMONHUNTER" }, sourceType = "Dungeon", source = "Путешествие во времени: Пандария", note = "из ящика Тажаня Чжу (Монастырь Шадо-Пан); Ка'эн, дыхание тьмы (Ka'eng, Breath of the Shadow): кистевое оружие на крит/скорость. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, crit = 4, haste = 3 } },
    { itemID = 144099, bonusIDs = { 13828, 7756 }, classes = { "ROGUE", "SHAMAN", "MONK", "DEMONHUNTER" }, sourceType = "Dungeon", source = "Путешествие во времени: Пандария", note = "падает с Ша Жестокости (Монастырь Шадо-Пан); Гнойный полумесяц: одноручный топор на скорость/искусность. Тир 32", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, stam = 6, haste = 4, iskus = 4 } },

    -- Рарники Танаанских джунглей: найдены 12 сентября прогоном по собранной
    -- базе рарников. Три вторички разом — по очкам когда-то считались
    -- вровень с Дракончиком, но без шестерёнок, которых ещё надо достать.
    --
    -- У танаанских аксессуаров сквоша до 23 нет: персональный дроп, уровень 16,
    -- по 7 каждой вторички. Живой Клык Расте 22 сентября; Обузданный огонь —
    -- тот же тултип Wowhead. Раньше в базе стояло 23 / 9 / 9 / 9.
    { itemID = 127661, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Танаанские джунгли", note = "[ДД] Клык Расте: три вторички разом - крит, скорость, искусность. Падает с Расте, раз в день", ilvl = 16, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { crit = 7, haste = 7, iskus = 7 } },
    { itemID = 127660, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Танаанские джунгли", note = "[ДД] Обузданный огонь: три вторички разом - крит, универсальность, искусность. Падает с Обуглень Дикий Огонь, раз в день", ilvl = 16, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { crit = 7, vers = 7, iskus = 7 } },

    -- Крафтовая карта: три вторички разом, как у танаанских рарников, но
    -- покупается на аукционе (около 12 тысяч золота на 12 сентября).
    -- Статы с тултипа пользователя: 18 уровень, по 8 каждой вторички.
    { itemID = 128978, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Craft", source = "Крафт (аукцион)", note = "[ДД] Карта Таро Пророчества: три вторички разом - крит, универсальность, искусность. Уникальная использующаяся", ilvl = 18, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { crit = 8, vers = 8, iskus = 8 } },

    -- Найдено 13 сентября сверкой двух источников: логи с forsaken-dungeons
    -- (295 отчётов, 1409 записей об игроках) показали, ЧТО носят в рейтинге,
    -- а слепок армори дал статы этих вещей на двадцатке. В базе их не было.
    -- Гнёзда — только родные, проверены тултипом со связкой (см. вики
    -- «Бонус За Гнездо» § Сверка гнёзд тултипом).
    -- Источники закрыты 21 сентября: тултип nether.wowhead (locale=7) плюс
    -- loot-таблицы warcraft.wiki.gg. Координаты входов не с сайтов — метки
    -- ставит человек в игре (`/tgf pin`).
    { itemID = 178781, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Смертельная тризна", note = "падает с Налтора Криоманта; Ритуальный перстень командира: кольцо на крит/универсальность (в рейтинге ×16)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, crit = 7, vers = 11 } },
    { itemID = 159462, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "ЗОЛОТАЯ ЖИЛА!!!", note = "падает с Платного разгонятеля толпы; Кольцо чемпиона по футбомбометанию: на скорость/искусность (в рейтинге ×19)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 9, iskus = 10 } },
    { itemID = 27737, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Паровое подземелье", note = "падает с Полководца Калитреша; Наплечники Лунной поляны: кожаные плечи на версу, два гнезда (в рейтинге ×8)", ilvl = 23, armor = 7, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { agi = 5, int = 5, stam = 7, crit = 4, vers = 5 } },
    { itemID = 37188, bonusIDs = { 6710, 6652, 8810 }, classes = { "EVOKER", "HUNTER", "SHAMAN" }, sourceType = "Dungeon", source = "Крепость Утгард", note = "падает с Ингвара Расхителя; Шлем расхитителя: кольчужная голова на крит/скорость, два гнезда (в рейтинге ×8)", ilvl = 23, armor = 11, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { agi = 7, int = 7, stam = 10, crit = 5, haste = 8 } },
    { itemID = 161113, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "World", source = "Зандалар (рарники, раз на персонажа)", note = "[ДД] падает с Древний зуболом в Назмире; Беспрерывно тикающие часы: аксессуар со всеми основными статами разом (в рейтинге ×8)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 6, agi = 6, int = 6 } },

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
    -- Обоюдоострое копье: двуручное древковое на ловкость, ilvl 26, из недели
    -- Путешествий во времени (ярлык "Искажение временем" в тултипе). В гайде
    -- его нет, а в логах рейтинга это самое носимое оружие Кошки: 98 из 230.
    -- Гнёзд НЕТ: в дампе игры у вещи их ноль, ни один бонус связки гнезда
    -- не даёт, и ни у одного из 98 носителей камня в нём нет. Гнездо в тултипе
    -- у отдельных игроков - от оправы, её мы не считаем.
    -- Класс-лист по логам: древковое в гильдии носят только друиды (213 из 213).
    { itemID = 158370, bonusIDs = { 6652, 12379, 7756 }, classes = { "DRUID" }, sourceType = "Dungeon", source = "Храм Сетралисс", note = "падает с Гюрзиса и Аспидиса; Обоюдоострое копье: двуручное на ловкость, Путешествие во времени, ilvl 26 (логи, x98)", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 7, stam = 10, crit = 5, haste = 8 } },

    -- Паладин Света — слепок Keotore (рейтинг forsaken-dungeons, 50 заходов)
    -- и армори 7 сентября. Статы с армори. Руку Эдварда в BiS не ставим:
    -- уникальный мировой дроп, редкий, как Клинок Черного яда.
    { itemID = 2243, bonusIDs = { 6661 }, classes = { "PALADIN", "PRIEST", "SHAMAN", "MONK", "DRUID", "EVOKER" }, sourceType = "World", source = "Классические земли (мировой дроп)", note = "редкий: Рука Эдварда Странного, уникальная одноручка, мировой дроп. В сборку не ставим (Keotore, армори ilvl 27)", ilvl = 27, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { int = 20, stam = 5, vers = 5 } },
    { itemID = 110006, bonusIDs = { 6652, 12379, 7756 }, classes = nil, sourceType = "Dungeon", source = "Небесный Путь", note = "[Хил] падает с Рухрана; Перо Рухрана: скорость и универсальность, синий, уникальный (Keotore, 30 из 50 заходов; статы и уровень с тултипа 21 сентября)", ilvl = 24, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { haste = 10, vers = 10 } },

    -- Сумки тестера, 22 сентября. В гайде этих вещей нет.
    -- Статы сняты шкалой SimC на уровне из выгрузки (ilevel=), не тултипом
    -- в игре: /tgf ref их не печатает, пока вещи нет в базе. Третички
    -- (уклонение, самоисцеление) не пишем. 8810 — одно бесцветное гнездо;
    -- 8812 гнезда не добавляет.
    { itemID = 124030, bonusIDs = { 11069, 7756 }, classes = { "WARRIOR", "HUNTER", "ROGUE", "SHAMAN", "MONK", "DRUID", "DEMONHUNTER" }, sourceType = "Dungeon", source = "Цитадель Адского Пламени", note = "падает с Вождя Каргата Острорука; Рука-клинок: одноручное кистевое, версия 26. Не путать с Рукой-клинком из Разрушенных залов (та 23). Прок скорости на 10 сек при ударе, откат 45 сек", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 3, agi = 3, stam = 5 } },
    { itemID = 11684, bonusIDs = { 6712, 6652 }, classes = { "DEATHKNIGHT", "ROGUE", "PALADIN", "MONK", "SHAMAN", "WARRIOR" }, sourceType = "Dungeon", source = "Глубины Черной горы", note = "падает с Императора Даграна Тауриссана; Сталебой: одноручное дробящее, уровень 26. Атаки могут сработать дважды", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 3, agi = 3, stam = 5, crit = 3, haste = 3 } },
    { itemID = 9477, bonusIDs = { 6710, 6652 }, classes = { "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "Головорез вождя: двуручный посох на ловкость, уровень 23. Откуда падает — не выяснено", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 7, stam = 10, crit = 9, vers = 4 } },
    { itemID = 110040, bonusIDs = { 6710, 4746, 40 }, classes = { "HUNTER", "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "падает с Надсмотрщика за рабами Крушто; Обезглавливатель Крушто: двуручное древковое на ловкость", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 7, stam = 10, crit = 7, iskus = 6 } },
    { itemID = 110058, bonusIDs = { 6710, 4746, 6652 }, classes = { "WARRIOR", "HUNTER", "ROGUE", "SHAMAN", "MONK", "DRUID", "DEMONHUNTER" }, sourceType = "Dungeon", source = "уточнить", note = "падает с Черепона; Окровавленная рука горести: одноручное кистевое на ловкость", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 3, stam = 5, vers = 3, iskus = 3 } },
    { itemID = 34796, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Терраса Магистров", note = "падает с Кель'таса; Одеяния летнего великолепия: кожаная грудь, три бесцветных гнезда", ilvl = 23, armor = 10, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = { key = "vers", value = 1 }, stats = { agi = 7, int = 7, stam = 10, vers = 8 } },
    { itemID = 109868, bonusIDs = { 6710, 4746, 6652, 8810 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "Наручи огненной собранности: кожаные запястья, одно гнездо", ilvl = 23, armor = 5, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { agi = 4, int = 4, stam = 6, crit = 4, iskus = 3 } },
    { itemID = 37853, bonusIDs = { 6710, 6652, 8810 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "падает с Локена; Улучшенные поручи из выделанной кожи: кожа, уровень 23, одно гнездо", ilvl = 23, armor = 5, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { agi = 4, int = 4, stam = 6, haste = 5 } },
    { itemID = 127521, bonusIDs = { 13828, 7756 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "падает с Локена; те же Улучшенные поручи, версия Путешествия во времени, уровень 32, без гнезда", ilvl = 32, armor = 6, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, int = 4, stam = 6, haste = 8 } },
    { itemID = 109879, bonusIDs = { 6710, 6652, 8812 }, classes = { "DEATHKNIGHT", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "уточнить", note = "Наручи Кишкодава: латные запястья, без гнезда", ilvl = 23, armor = 11, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 4, int = 4, stam = 6, vers = 3, iskus = 4 } },
    { itemID = 188418, bonusIDs = { 13828, 7756 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Азжол-Неруб", note = "падает с Хадронокса; Перчатки Туманного грота: кожа, Путешествие во времени, уровень 32", ilvl = 32, armor = 6, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 6, int = 6, stam = 8, haste = 3, vers = 8 } },
    { itemID = 188444, bonusIDs = { 13828, 7756 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "Наручники проходчика: кожа, Путешествие во времени, уровень 32. Откуда падают — не выяснено", ilvl = 32, armor = 6, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 4, int = 4, stam = 6, crit = 4, vers = 5 } },
    { itemID = 188486, bonusIDs = { 13828, 7756 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "Кузня Душ", note = "падает с Пожирателя Душ; Воплощение мечты: кожаные кисти, Путешествие во времени, уровень 32", ilvl = 32, armor = 6, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 6, int = 6, stam = 8, haste = 5, vers = 6 } },
    { itemID = 134487, bonusIDs = { 6710, 8810 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "падает с Верховного друида Глайдалиса; Оскверненная печать верховного друида: кольцо на скорость/искусность, одно гнездо", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 5, iskus = 13 } },
    { itemID = 162544, bonusIDs = { 6710, 6652, 8810 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "падает с Меректы; Нефритовый перстень змея: кольцо на универсальность/искусность, одно гнездо", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 7, iskus = 12 } },
    { itemID = 109995, bonusIDs = { 6710, 4746, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "SHAMAN", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "падает с Аззакеля; Кровавая печать Аззакеля: аксессуар на ловкость и крит", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 6, crit = 9 } },
    { itemID = 110009, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Лист древних защитников: аксессуар на искусность, по использованию щит на союзника. Откуда падает — не выяснено", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { iskus = 9 } },
    { itemID = 34471, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "WARLOCK", "EVOKER", "PALADIN", "MONK", "SHAMAN", "DRUID", "PRIEST", "MAGE" }, sourceType = "Dungeon", source = "Терраса Магистров", note = "[Хил] падает с Жрицы Делриссы; Флакон воды из Солнечного Колодца: универсальность, по использованию накопленный свет", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { vers = 9 } },
    { itemID = 188415, bonusIDs = { 13828, 7756 }, classes = { "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "MONK", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "Азжол-Неруб", note = "[Танк] падает с Хадронокса; Квинтэссенция паутины: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 11 } },
    -- Шкала напечатала интеллект двумя числами (кусок оружия + стат).
    -- Складываем, как у Каменного кулака в гайде: 3+16=19, 7+23=30.
    { itemID = 34790, bonusIDs = { 6710, 6652 }, classes = { "PALADIN", "PRIEST", "SHAMAN", "MONK", "DRUID", "EVOKER" }, sourceType = "Dungeon", source = "Терраса Магистров", note = "падает с Жрицы Делриссы; Боевая палица верховной жрицы: одноручная, интеллект 19, одно родное гнездо", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = { key = "vers", value = 1 }, stats = { int = 19, stam = 5, haste = 5 } },
    { itemID = 110047, bonusIDs = { 6710, 4746, 41 }, classes = { "WARLOCK", "EVOKER", "PALADIN", "MONK", "SHAMAN", "DRUID", "PRIEST", "MAGE" }, sourceType = "Dungeon", source = "Аукиндон", note = "падает со Стражницы душ Ниами; Губительный клинок мудреца: одноручный меч на интеллект 19", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { int = 19, stam = 5, crit = 4, haste = 3 } },
    { itemID = 110045, bonusIDs = { 6710, 4746, 6652 }, classes = { "WARLOCK", "EVOKER", "MONK", "SHAMAN", "DRUID", "PRIEST", "MAGE" }, sourceType = "Dungeon", source = "уточнить", note = "Кристаллический волшебный посох Камуи: двуручный, интеллект 30. Откуда падает — не выяснено", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { int = 30, stam = 10, vers = 7, iskus = 6 } },

    -- Паладин, правки сборки 22 сентября. Очки: имя с тултипа nether,
    -- гнёзда из дампа simc (мета + две шестерёнки). Статы двадцатки в игре
    -- не сняты — ценность в гнёздах, как у Дракончика.
    { itemID = 77538, bonusIDs = { 7175 }, classes = { "DEATHKNIGHT", "PALADIN", "WARRIOR" }, sourceType = "Craft", source = "Инженерия", note = "крафт (инженерия); Специализированная ретинальная защита: латный шлем, особое гнездо и два для зубчатого колеса. Статы двадцатки в игре не сняты", ilvl = 18, armor = 13, sockets = 3, socketTypes = { "meta", "cogwheel", "cogwheel" }, socketBonus = { key = "int", value = 1 }, stats = { int = 2, stam = 6 } },
    { itemID = 188509, bonusIDs = { 13828, 7756 }, classes = { "DEATHKNIGHT", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "Пещеры Черной горы", note = "падает с Ром'огга Костекрушителя; Щит железной леди: Путешествие во времени, уровень 32. Статы двадцатки в игре не сняты", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 4, int = 4, stam = 6, vers = 4, iskus = 3 } },
    { itemID = 133246, bonusIDs = { 13828, 7756 }, classes = { "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "MONK", "PALADIN", "WARRIOR" }, sourceType = "Dungeon", source = "Вершина Смерча", note = "[Танк] падает с Асаада; Сердце грома: версия Путешествия во времени, уровень 32. Данжевая копия в гайде — другая вещь, уровень 23", ilvl = 32, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { vers = 9 } },
}
