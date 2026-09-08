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
    { itemID = 34707, bonusIDs = { 6710, 6652 }, classes = { "DEMONHUNTER", "ROGUE", "MONK", "DRUID" }, sourceType = "Dungeon", source = "уточнить", note = "Сапоги оживления: кожаные ступни на универсальность, со скоростью бега (от сообщества)", ilvl = 23, armor = 9, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { agi = 5, int = 5, stam = 7, vers = 5 } },
    -- Двойной клинок мастерства: кинжал разбойника, БиС Ликвидации в обе руки.
    -- id найден через Wowhead (127234, добыча с Пандемониус в Гробницах Маны),
    -- статы сняты со скриншота с триала — в игре аддоном не сверялись.
    { itemID = 127234, bonusIDs = { 6710, 6652 }, classes = { "ROGUE" }, sourceType = "Dungeon", source = "Гробницы маны", note = "Двойной клинок мастерства: кинжал разбойника, обе руки (от сообщества)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { agi = 3, stam = 3, crit = 7, haste = 4 } },

    -- ── Шеи и кольца ──────────────────────────────────────────────────────
    -- В базе гайда их нет (шеи удалены к 1.0, колец не было). Набрано по
    -- слепку 195 одетых твинков гильдии 8 сентября: itemID, уровень, гнёзда
    -- и статы — с армори; источник у большинства не выяснен ("уточнить").
    -- classes = nil: это «Разное», носят все классы; окно ранжирует по статам
    -- спека. Число за именем в комментарии — сколько человек носят.

    -- Шеи
    { itemID = 200210, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Амнезия: шея на скорость/универсальность, 3 гнезда (слепок, ×45 — самая ходовая)", ilvl = 23, armor = nil, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 10, vers = 8 } },
    { itemID = 178827, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Запятнанная грехом подвеска: шея на скорость/искусность (слепок, ×16)", ilvl = 26, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 14, iskus = 6 } },
    { itemID = 200446, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Кристаллизованная печать: шея на универсальность/искусность, 3 гнезда (слепок, ×12)", ilvl = 23, armor = nil, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 8, iskus = 10 } },
    { itemID = 200207, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Окаменевшие споры грибов: шея на скорость/универсальность, 3 гнезда (слепок, ×8)", ilvl = 23, armor = nil, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 9, vers = 9 } },
    { itemID = 193809, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Выкопанный медальон Бромача: шея на скорость/искусность, 3 гнезда (слепок, ×6)", ilvl = 22, armor = nil, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 5, haste = 13, iskus = 5 } },
    { itemID = 188471, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Ожерелье из пропавших камней: шея на крит/скорость (слепок, ×7)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 11, haste = 10 } },
    -- Возвращены: удалялись к 1.0, но слепок показал — их всё ещё носят.
    { itemID = 193647, bonusIDs = { 6710, 6652, 8810 }, classes = nil, sourceType = "Dungeon", source = "Лазурные Врата", note = "Комендантский медальон наваждения: шея на универсальность/искусность (слепок, ×7; была удалена)", ilvl = 23, armor = nil, sockets = 1, socketTypes = { "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 11, iskus = 8 } },
    { itemID = 193676, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "Наступление Нохуда", note = "Бусы предков Укхел: шея на скорость/искусность, 3 гнезда (слепок, ×4; была удалена)", ilvl = 22, armor = nil, sockets = 3, socketTypes = { "prismatic", "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 5, haste = 6, iskus = 13 } },

    -- Кольца
    { itemID = 178824, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Печатка лживого обвинения: кольцо на искусность (слепок, ×36 — самое ходовое)", ilvl = 26, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, haste = 6, iskus = 14 } },
    { itemID = 113082, bonusIDs = { 572, 13619 }, classes = nil, sourceType = "World", source = "Долина Призрачной Луны", note = "Драгоценная петля из кровошипа: кольцо со всеми статами и универсальностью, с Горума (слепок, ×17)", ilvl = 23, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { str = 4, agi = 4, int = 4, stam = 4, vers = 6 } },
    { itemID = 178870, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Ритуальное костяное кольцо: на универсальность/искусность (слепок, ×15)", ilvl = 23, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, vers = 13, iskus = 6 } },
    { itemID = 178871, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Печатка клятвы на крови: кольцо на крит/скорость (слепок, ×10)", ilvl = 23, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 8, haste = 11 } },
    { itemID = 178869, bonusIDs = { 6710, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Усиленный плотью ободок: кольцо на крит/искусность (слепок, ×9)", ilvl = 23, armor = nil, sockets = 2, socketTypes = { "prismatic", "prismatic" }, socketBonus = nil, stats = { stam = 6, crit = 6, iskus = 13 } },
    { itemID = 178736, bonusIDs = { 6712, 6652 }, classes = nil, sourceType = "Dungeon", source = "уточнить", note = "Потерянная печатка Трупошва: кольцо на скорость/универсальность (слепок, ×9)", ilvl = 26, armor = nil, sockets = 0, socketTypes = {  }, socketBonus = nil, stats = { stam = 6, haste = 12, vers = 7 } },
}
