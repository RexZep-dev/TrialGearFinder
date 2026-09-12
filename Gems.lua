-- Камни: что даёт каждый на ДВАДЦАТКЕ и во что ставится.
--
-- Источник — таблица «all* gems and permanent/temporary enchants that are
-- potentially useful for level 20 characters» за авторством Golden Cucumber
-- (EU, Pharisee) и Харфа (русское сообщество «Отвергнутые и Забытые»).
-- Разрешение на использование получено пользователем лично, как и на гайд.
-- Числа там сняты с SimulationCraft и Wago.tools под масштабирование
-- 20(29): без скобок — двадцатка, в скобках — 29 уровень. Берём первое.
--
-- Сверено с нашими замерами по армори в трёх точках, разошлось 0:
-- зубчатые колёса 10, шестерёнки 8, Плотный неуравновешенный алмаз 12 крита.
--
-- Номера предметов найдены по английскому имени в дампе item_data.inc из
-- simc, русские названия — через тултип-ручку Wowhead (locale=7).
-- У крафтовых камней TWW три номера подряд — три качества; берём третье,
-- как и указано в таблице.
--
-- socket: prismatic — обычное гнездо; cogwheel — только Дракончик;
--         meta — только шлемы. В шестерёнку и мету основную характеристику
--         не положить, туда идут вторички (см. вики «Камни»).
-- unique: «Уникальный использующийся» — двух таких на персонаже не будет.

local addonName, ns = ...

ns.Gems = {
    { itemID = 59489, socket = "cogwheel", stats = { haste = 10 }, unique = true, expansion = "Cataclysm" }, -- Аккуратное зубчатое колесо
    { itemID = 59479, socket = "cogwheel", stats = { haste = 10 }, unique = true, expansion = "Cataclysm" }, -- Быстрое зубчатое колесо
    { itemID = 59496, socket = "cogwheel", stats = { vers = 10 }, unique = true, expansion = "Cataclysm" }, -- Искрящееся зубчатое колесо
    { itemID = 59480, socket = "cogwheel", stats = { iskus = 10 }, unique = true, expansion = "Cataclysm" }, -- Растрескавшееся зубчатое колесо
    { itemID = 59493, socket = "cogwheel", stats = { crit = 10 }, unique = true, expansion = "Cataclysm" }, -- Прочное зубчатое колесо
    { itemID = 59478, socket = "cogwheel", stats = { crit = 10 }, unique = true, expansion = "Cataclysm" }, -- Гладкое зубчатое колесо
    { itemID = 59477, socket = "cogwheel", stats = { dodge = 10 }, unique = true, expansion = "Cataclysm" }, -- Изящное зубчатое колесо
    { itemID = 59491, socket = "cogwheel", stats = { parry = 10 }, unique = true, expansion = "Cataclysm" }, -- Блистательное зубчатое колесо
    { itemID = 77543, socket = "cogwheel", stats = { haste = 8 }, unique = true, expansion = "MoP" }, -- Точная шестеренка
    { itemID = 77542, socket = "cogwheel", stats = { haste = 8 }, unique = true, expansion = "MoP" }, -- Подвижная шестеренка
    { itemID = 77546, socket = "cogwheel", stats = { vers = 8 }, unique = true, expansion = "MoP" }, -- Блестящая шестеренка
    { itemID = 77547, socket = "cogwheel", stats = { iskus = 8 }, unique = true, expansion = "MoP" }, -- Сломанная шестеренка
    { itemID = 77545, socket = "cogwheel", stats = { crit = 8 }, unique = true, expansion = "MoP" }, -- Прочная шестеренка
    { itemID = 77541, socket = "cogwheel", stats = { crit = 8 }, unique = true, expansion = "MoP" }, -- Плавная шестеренка
    { itemID = 77540, socket = "cogwheel", stats = { dodge = 8 }, unique = true, expansion = "MoP" }, -- Изящная шестеренка
    { itemID = 77544, socket = "cogwheel", stats = { parry = 8 }, unique = true, expansion = "MoP" }, -- Сверкающая шестеренка
    { itemID = 68660, socket = "cogwheel", stats = { armor = 3 }, unique = true, expansion = "Cataclysm" }, -- Мистическое зубчатое колесо
    { itemID = 32640, socket = "meta", stats = { crit = 12 }, unique = false, expansion = "TBC", effect = "5% Stun Resistance" }, -- Плотный неуравновешенный алмаз
    { itemID = 44088, socket = "meta", stats = { stam = 3 }, unique = false, expansion = "WotLK", effect = "-10% Stun Duration" }, -- Могучий алмаз Землекрушителя
    { itemID = 32641, socket = "meta", stats = { int = 3 }, unique = false, expansion = "TBC", effect = "5% Stun Resistance" }, -- Глубокий неуравновешенный алмаз
    { itemID = 76886, socket = "meta", stats = { str = 2 }, unique = false, expansion = "MoP", effect = "3% Increased Critical Effect" }, -- Рокочущий изначальный алмаз
    { itemID = 76885, socket = "meta", stats = { int = 2 }, unique = false, expansion = "MoP", effect = "3% Increased Critical Effect" }, -- Горящий изначальный алмаз
    { itemID = 76879, socket = "meta", stats = { int = 2 }, unique = false, expansion = "MoP", effect = "+2.0% Maximum Mana" }, -- Угасающий изначальный алмаз
    { itemID = 76894, socket = "meta", stats = { int = 2 }, unique = false, expansion = "MoP", effect = "-10% Silence Duration" }, -- Жалкий изначальный алмаз
    { itemID = 76888, socket = "meta", stats = { vers = 2 }, unique = false, expansion = "MoP", effect = "3% Increased Critical Effect" }, -- Оживляющий изначальный алмаз
    { itemID = 76890, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "MoP", effect = "1% Spell Reflect" }, -- Разрушительный изначальный алмаз
    { itemID = 76892, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "MoP", effect = "-10% Snare/Root Duration" }, -- Загадочный изначальный алмаз
    { itemID = 76893, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "MoP", effect = "-10% Fear Duration" }, -- Бездушный изначальный алмаз
    { itemID = 76896, socket = "meta", stats = { dodge = 2 }, unique = false, expansion = "MoP", effect = "1% Shield Block Value" }, -- Вечный изначальный алмаз
    { itemID = 76895, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "MoP", effect = "2% Increased Armor Value from Items" }, -- Неограненный изначальный алмаз
    { itemID = 76897, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "MoP", effect = "-2% Spell Damage Taken" }, -- Лучезарный изначальный алмаз
    { itemID = 76891, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "MoP", effect = "-10% Stun Duration" }, -- Могучий изначальный алмаз
    { itemID = 68778, socket = "meta", stats = { agi = 2 }, unique = false, expansion = "Cataclysm", effect = "3% Increased Critical Effect" }, -- Звонкий мглистый алмаз
    { itemID = 68779, socket = "meta", stats = { str = 2 }, unique = false, expansion = "Cataclysm", effect = "3% Increased Critical Effect" }, -- Рокочущий мглистый алмаз
    { itemID = 52292, socket = "meta", stats = { int = 2 }, unique = false, expansion = "Cataclysm", effect = "-2% Threat" }, -- Нерушимый мглистый алмаз
    { itemID = 68780, socket = "meta", stats = { int = 2 }, unique = false, expansion = "Cataclysm", effect = "3% Increased Critical Effect" }, -- Горящий мглистый алмаз
    { itemID = 52296, socket = "meta", stats = { int = 2 }, unique = false, expansion = "Cataclysm", effect = "+2.0% Maximum Mana" }, -- Угасающий мглистый алмаз
    { itemID = 52302, socket = "meta", stats = { int = 2 }, unique = false, expansion = "Cataclysm", effect = "-10% Silence Duration" }, -- Жалкий мглистый алмаз
    { itemID = 52297, socket = "meta", stats = { vers = 2 }, unique = false, expansion = "Cataclysm", effect = "3% Increased Critical Effect" }, -- Оживляющий мглистый алмаз
    { itemID = 52289, socket = "meta", stats = { iskus = 2 }, unique = false, expansion = "Cataclysm", effect = "+10% Speed Increase" }, -- Тающий мглистый алмаз
    { itemID = 52291, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "Cataclysm", effect = "3% Increased Critical Effect" }, -- Хаотический мглистый алмаз
    { itemID = 52298, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "Cataclysm", effect = "1% Spell Reflect" }, -- Разрушительный мглистый алмаз
    { itemID = 52300, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "Cataclysm", effect = "-10% Snare/Root Duration" }, -- Загадочный мглистый алмаз
    { itemID = 52301, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "Cataclysm", effect = "-10% Fear Duration" }, -- Бездушный мглистый алмаз
    { itemID = 52294, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "Cataclysm", effect = "2% Increased Armor Value from Items" }, -- Неограненный мглистый алмаз
    { itemID = 52295, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "Cataclysm", effect = "-2% Spell Damage Taken" }, -- Лучезарный мглистый алмаз
    { itemID = 52293, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "Cataclysm", effect = "1% Shield Block Value" }, -- Вечный мглистый алмаз
    { itemID = 52299, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "Cataclysm", effect = "-10% Stun Duration" }, -- Могучий мглистый алмаз
    { itemID = 41398, socket = "meta", stats = { agi = 2 }, unique = false, expansion = "WotLK", effect = "3% Increased Critical Effect" }, -- Алмаз жестокого землеправителя
    { itemID = 41395, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "-2% Threat" }, -- Нерушимый алмаз землеправителя
    { itemID = 41333, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "+2.0% Maximum Mana" }, -- Угасающий алмаз небесного сияния
    { itemID = 41378, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "-10% Silence Duration" }, -- Жалкий алмаз небесного сияния
    { itemID = 44084, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "-10% Silence Duration" }, -- Жалкий алмаз звездного сияния
    { itemID = 41401, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "Chance to restore mana on spellcast by 75(78)" }, -- Провидческий алмаз землеправителя
    { itemID = 44089, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "-10% Stun Duration" }, -- Заостренный алмаз Землекрушителя
    { itemID = 41382, socket = "meta", stats = { int = 2 }, unique = false, expansion = "WotLK", effect = "-10% Stun Duration" }, -- Заостренный алмаз землеправителя
    { itemID = 41385, socket = "meta", stats = { haste = 2 }, unique = false, expansion = "WotLK", effect = "Sometimes Heal on Your Crits by 2% of Health" }, -- Живительный алмаз землеправителя
    { itemID = 41376, socket = "meta", stats = { vers = 2 }, unique = false, expansion = "WotLK", effect = "3% Increased Critical Effect" }, -- Оживляющий алмаз небесного сияния
    { itemID = 41389, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "+2.0% Maximum Mana" }, -- Лучащийся алмаз землеправителя
    { itemID = 41285, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "3% Increased Critical Effect" }, -- Хаотический алмаз небесного сияния
    { itemID = 41307, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "1% Spell Reflect" }, -- Разрушительный алмаз небесного сияния
    { itemID = 41335, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "-10% Snare/Root Duration" }, -- Загадочный алмаз небесного сияния
    { itemID = 44081, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "-10% Snare/Root Duration" }, -- Загадочный алмаз звездного сияния
    { itemID = 41379, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "-10% Fear Duration" }, -- Бездушный алмаз небесного сияния
    { itemID = 44082, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "-10% Fear Duration" }, -- Бездушный алмаз звездного сияния
    { itemID = 44087, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "-10% Snare/Root Duration" }, -- Незыблемый алмаз Землекрушителя
    { itemID = 41381, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "WotLK", effect = "-10% Stun Duration" }, -- Незыблемый алмаз землеправителя
    { itemID = 41396, socket = "meta", stats = { dodge = 2 }, unique = false, expansion = "WotLK", effect = "1% Shield Block Value" }, -- Вечный алмаз землеправителя
    { itemID = 41380, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "WotLK", effect = "2% Increased Armor Value from Items" }, -- Алмаз строгого землеправителя
    { itemID = 41397, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "WotLK", effect = "-10% Stun Duration" }, -- Могущественный алмаз землеправителя
    { itemID = 41377, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "WotLK", effect = "-2% Spell Damage Taken" }, -- Защищенный алмаз небесного сияния
    { itemID = 32409, socket = "meta", stats = { agi = 2 }, unique = false, expansion = "TBC", effect = "3% Increased Critical Effect" }, -- Алмаз жестокой земной бури
    { itemID = 25897, socket = "meta", stats = { int = 2 }, unique = false, expansion = "TBC", effect = "-2% Threat" }, -- Нерушимый алмаз земной бури
    { itemID = 35503, socket = "meta", stats = { int = 2 }, unique = false, expansion = "TBC", effect = "+2.0% Maximum Mana" }, -- Угасающий алмаз небесного огня
    { itemID = 25901, socket = "meta", stats = { int = 2 }, unique = false, expansion = "TBC", effect = "Chance to restore mana on spellcast by 75(78)" }, -- Провидческий алмаз земной бури
    { itemID = 28557, socket = "meta", stats = { int = 2 }, unique = false, expansion = "TBC", effect = "+10% Speed Increase" }, -- Оживленный алмаз Звездного огня
    { itemID = 34220, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "TBC", effect = "3% Increased Critical Effect" }, -- Хаотический алмаз небесного огня
    { itemID = 25890, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "TBC", effect = "1% Spell Reflect" }, -- Разрушительный алмаз небесного огня
    { itemID = 25895, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "TBC", effect = "-10% Snare/Root Duration" }, -- Загадочный алмаз небесного огня
    { itemID = 25894, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "TBC", effect = "+10% Speed Increase" }, -- Стремительный алмаз небесного огня
    { itemID = 28556, socket = "meta", stats = { crit = 2 }, unique = false, expansion = "TBC", effect = "+10% Speed Increase" }, -- Стремительный алмаз огненного ветра
    { itemID = 35501, socket = "meta", stats = { dodge = 2 }, unique = false, expansion = "TBC", effect = "1% Shield Block Value" }, -- Вечный алмаз земной бури
    { itemID = 25898, socket = "meta", stats = { dodge = 2 }, unique = false, expansion = "TBC", effect = "Chance to Restore Health on Hit (?)" }, -- Крепкий алмаз земной бури
    { itemID = 25896, socket = "meta", stats = { stam = 2 }, unique = false, expansion = "TBC", effect = "-10% Stun Duration" }, -- Могущественный алмаз земной бури
    { itemID = 41400, socket = "meta", stats = {  }, unique = false, expansion = "WotLK", effect = "Increases melee and ranged haste by 120(125) for 6s" }, -- Громовой алмаз небесного сияния
    { itemID = 25899, socket = "meta", stats = {  }, unique = false, expansion = "TBC", effect = " +0 Melee Damage and Chance to Stun Target for 1s" }, -- Грубый алмаз земной бури
    { itemID = 25893, socket = "meta", stats = {  }, unique = false, expansion = "TBC", effect = "Increases Haste by 167 for 4s (23 ilvl)" }, -- Мистический алмаз небесного огня
    { itemID = 32410, socket = "meta", stats = {  }, unique = false, expansion = "TBC", effect = "Increases melee and ranged haste by 50(52) for 6s (23 ilvl)" }, -- Громовой алмаз небесного огня
    { itemID = 213516, socket = "prismatic", stats = { stam = 7 }, unique = false, expansion = "TWW" }, -- Янтарь твердости
    { itemID = 213517, socket = "prismatic", stats = { stam = 7 }, unique = false, expansion = "TWW" }, -- Янтарь твердости
    { itemID = 213505, socket = "prismatic", stats = { stam = 5, haste = 1 }, unique = false, expansion = "TWW" }, -- Янтарь скорости
    { itemID = 213506, socket = "prismatic", stats = { stam = 5, haste = 1 }, unique = false, expansion = "TWW" }, -- Янтарь скорости
    { itemID = 213511, socket = "prismatic", stats = { stam = 5, vers = 1 }, unique = false, expansion = "TWW" }, -- Янтарь универсальности
    { itemID = 213512, socket = "prismatic", stats = { stam = 5, vers = 1 }, unique = false, expansion = "TWW" }, -- Янтарь универсальности
    { itemID = 213508, socket = "prismatic", stats = { stam = 5, iskus = 1 }, unique = false, expansion = "TWW" }, -- Янтарь искусности
    { itemID = 213509, socket = "prismatic", stats = { stam = 5, iskus = 1 }, unique = false, expansion = "TWW" }, -- Янтарь искусности
    { itemID = 213502, socket = "prismatic", stats = { stam = 5, crit = 1 }, unique = false, expansion = "TWW" }, -- Янтарь смерти
    { itemID = 213503, socket = "prismatic", stats = { stam = 5, crit = 1 }, unique = false, expansion = "TWW" }, -- Янтарь смерти
    { itemID = 213748, socket = "prismatic", stats = { main = 5 }, unique = true, expansion = "TWW", effect = "opponent's failed interrupt attempts grant Precognition" }, -- Кровавый камень разума
    { itemID = 213743, socket = "prismatic", stats = { main = 5 }, unique = true, expansion = "TWW", effect = "0.15% Critical Effect per unique Algari gem color" }, -- Профанит апогея
    { itemID = 213749, socket = "prismatic", stats = { main = 5 }, unique = true, expansion = "TWW", effect = "Getting snared increases damage of your next attack by 23(38) per stack(max 20)" }, -- Кровавый камень решительности
    { itemID = 213746, socket = "prismatic", stats = { main = 5 }, unique = true, expansion = "TWW", effect = "2% Movement Speed per unique Algari gem color" }, -- Профанит неуловимости
    { itemID = 213747, socket = "prismatic", stats = { main = 5 }, unique = true, expansion = "TWW", effect = "5% Damage Reduction when affected by Crowd Control" }, -- Кровавый камень выносливости
    { itemID = 213740, socket = "prismatic", stats = { main = 5 }, unique = true, expansion = "TWW", effect = "1% Maximum Mana per unique Algari gem color" }, -- Профанит проницательности
    { itemID = 213488, socket = "prismatic", stats = { haste = 5 }, unique = false, expansion = "TWW" }, -- Изумруд скорости
    { itemID = 213485, socket = "prismatic", stats = { haste = 4, vers = 1 }, unique = false, expansion = "TWW" }, -- Изумруд универсальности
    { itemID = 213482, socket = "prismatic", stats = { haste = 4, iskus = 1 }, unique = false, expansion = "TWW" }, -- Изумруд искусности
    { itemID = 213479, socket = "prismatic", stats = { crit = 1, haste = 4 }, unique = false, expansion = "TWW" }, -- Изумруд смерти
    { itemID = 213470, socket = "prismatic", stats = { haste = 1, vers = 4 }, unique = false, expansion = "TWW" }, -- Сапфир скорости
    { itemID = 213494, socket = "prismatic", stats = { haste = 1, iskus = 4 }, unique = false, expansion = "TWW" }, -- Оникс скорости
    { itemID = 213455, socket = "prismatic", stats = { crit = 4, haste = 1 }, unique = false, expansion = "TWW" }, -- Рубин скорости
    { itemID = 213476, socket = "prismatic", stats = { vers = 5 }, unique = false, expansion = "TWW" }, -- Сапфир универсальности
    { itemID = 213473, socket = "prismatic", stats = { iskus = 1, vers = 4 }, unique = false, expansion = "TWW" }, -- Сапфир искусности
    { itemID = 213467, socket = "prismatic", stats = { crit = 1, vers = 4 }, unique = false, expansion = "TWW" }, -- Сапфир смерти
    { itemID = 213497, socket = "prismatic", stats = { iskus = 4, vers = 1 }, unique = false, expansion = "TWW" }, -- Оникс универсальности
    { itemID = 213461, socket = "prismatic", stats = { crit = 4, vers = 1 }, unique = false, expansion = "TWW" }, -- Рубин универсальности
    { itemID = 213500, socket = "prismatic", stats = { iskus = 5 }, unique = false, expansion = "TWW" }, -- Оникс искусности
    { itemID = 213491, socket = "prismatic", stats = { crit = 1, iskus = 4 }, unique = false, expansion = "TWW" }, -- Оникс смерти
    { itemID = 213458, socket = "prismatic", stats = { crit = 4, iskus = 1 }, unique = false, expansion = "TWW" }, -- Рубин искусности
    { itemID = 213464, socket = "prismatic", stats = { crit = 5 }, unique = false, expansion = "TWW" }, -- Рубин смерти
    { itemID = 77143, socket = "prismatic", stats = { main = 2, armor = 2 }, unique = false, expansion = "Cataclysm" }, -- Насыщенный эльфийский хризолит
    { itemID = 71848, socket = "prismatic", stats = { agi = 2, haste = 2 }, unique = false, expansion = "Cataclysm" }, -- Лавовый коралл проворства
    { itemID = 71852, socket = "prismatic", stats = { agi = 2, iskus = 2 }, unique = false, expansion = "Cataclysm" }, -- Лавовый коралл адепта
    { itemID = 71840, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "Cataclysm" }, -- Смертоносный лавовый коралл
    { itemID = 71862, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "Cataclysm" }, -- Блистающая сумрачная шпинель
    { itemID = 77132, socket = "prismatic", stats = { agi = 2, armor = 2 }, unique = false, expansion = "Cataclysm" }, -- Прозрачный лавовый коралл
    { itemID = 71844, socket = "prismatic", stats = { agi = 2, dodge = 2 }, unique = false, expansion = "Cataclysm" }, -- Полированный лавовый коралл
    { itemID = 71869, socket = "prismatic", stats = { agi = 2, stam = 2 }, unique = false, expansion = "Cataclysm" }, -- Изменчивая сумрачная шпинель
    { itemID = 71851, socket = "prismatic", stats = { str = 2, haste = 2 }, unique = false, expansion = "Cataclysm" }, -- Броский лавовый коралл
    { itemID = 71856, socket = "prismatic", stats = { str = 2, iskus = 2 }, unique = false, expansion = "Cataclysm" }, -- Мастерский лавовый коралл
    { itemID = 71866, socket = "prismatic", stats = { str = 2, crit = 2 }, unique = false, expansion = "Cataclysm" }, -- Гравированная сумрачная шпинель
    { itemID = 71843, socket = "prismatic", stats = { str = 2, crit = 2 }, unique = false, expansion = "Cataclysm" }, -- Покрытый письменами лавовый коралл
    { itemID = 77136, socket = "prismatic", stats = { str = 2, armor = 2 }, unique = false, expansion = "Cataclysm" }, -- Глянцевый лавовый коралл
    { itemID = 71847, socket = "prismatic", stats = { str = 2, dodge = 2 }, unique = false, expansion = "Cataclysm" }, -- Лавовый коралл воителя
    { itemID = 71873, socket = "prismatic", stats = { str = 2, stam = 2 }, unique = false, expansion = "Cataclysm" }, -- Царственная сумрачная шпинель
    { itemID = 71850, socket = "prismatic", stats = { int = 2, haste = 2 }, unique = false, expansion = "Cataclysm" }, -- Тревожный лавовый коралл
    { itemID = 77133, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "Cataclysm" }, -- Таинственная сумрачная шпинель
    { itemID = 71868, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "Cataclysm" }, -- Очищенная сумрачная шпинель
    { itemID = 71854, socket = "prismatic", stats = { int = 2, iskus = 2 }, unique = false, expansion = "Cataclysm" }, -- Искусный лавовый коралл
    { itemID = 71842, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "Cataclysm" }, -- Могущественный лавовый коралл
    { itemID = 71864, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "Cataclysm" }, -- Сокрытая сумрачная шпинель
    { itemID = 77144, socket = "prismatic", stats = { int = 2, armor = 2 }, unique = false, expansion = "Cataclysm" }, -- Неподатливый лавовый коралл
    { itemID = 71871, socket = "prismatic", stats = { int = 2, stam = 2 }, unique = false, expansion = "Cataclysm" }, -- Вневременная сумрачная шпинель
    { itemID = 77138, socket = "prismatic", stats = { armor = 2, parry = 2 }, unique = false, expansion = "Cataclysm" }, -- Великолепный лавовый коралл
    { itemID = 77139, socket = "prismatic", stats = { stam = 2, armor = 2 }, unique = false, expansion = "Cataclysm" }, -- Неизменный эльфийский хризолит
    { itemID = 71846, socket = "prismatic", stats = { dodge = 2, parry = 2 }, unique = false, expansion = "Cataclysm" }, -- Стойкий лавовый коралл
    { itemID = 71835, socket = "prismatic", stats = { stam = 2, dodge = 2 }, unique = false, expansion = "Cataclysm" }, -- Монарший эльфийский хризолит
    { itemID = 71872, socket = "prismatic", stats = { stam = 2, parry = 2 }, unique = false, expansion = "Cataclysm" }, -- Сумрачная шпинель защитника
    { itemID = 40159, socket = "prismatic", stats = { agi = 2, haste = 2 }, unique = false, expansion = "WotLK" }, -- Аметрин проворства
    { itemID = 40156, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "WotLK" }, -- Смертоносный аметрин
    { itemID = 40157, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "WotLK" }, -- Блистающий страхолит
    { itemID = 40158, socket = "prismatic", stats = { agi = 2, armor = 2 }, unique = false, expansion = "WotLK" }, -- Прозрачный аметрин
    { itemID = 40136, socket = "prismatic", stats = { agi = 2, stam = 2 }, unique = false, expansion = "WotLK" }, -- Изменчивый страхолит
    { itemID = 40146, socket = "prismatic", stats = { str = 2, haste = 2 }, unique = false, expansion = "WotLK" }, -- Броский аметрин
    { itemID = 40143, socket = "prismatic", stats = { str = 2, crit = 2 }, unique = false, expansion = "WotLK" }, -- Гравированный страхолит
    { itemID = 40142, socket = "prismatic", stats = { str = 2, crit = 2 }, unique = false, expansion = "WotLK" }, -- Покрытый письменами аметрин
    { itemID = 40145, socket = "prismatic", stats = { str = 2, armor = 2 }, unique = false, expansion = "WotLK" }, -- Глянцевый аметрин
    { itemID = 40144, socket = "prismatic", stats = { str = 2, dodge = 2 }, unique = false, expansion = "WotLK" }, -- Аметрин воителя
    { itemID = 40129, socket = "prismatic", stats = { str = 2, stam = 2 }, unique = false, expansion = "WotLK" }, -- Царственный страхолит
    { itemID = 40155, socket = "prismatic", stats = { int = 2, haste = 2 }, unique = false, expansion = "WotLK" }, -- Тревожный аметрин
    { itemID = 40135, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "WotLK" }, -- Таинственный страхолит
    { itemID = 40175, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "WotLK" }, -- Очищенный страхолит
    { itemID = 40152, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "WotLK" }, -- Могущественный аметрин
    { itemID = 40153, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "WotLK" }, -- Сокрытый страхолит
    { itemID = 40154, socket = "prismatic", stats = { int = 2, armor = 2 }, unique = false, expansion = "WotLK" }, -- Неподатливый аметрин
    { itemID = 40164, socket = "prismatic", stats = { int = 2, stam = 2 }, unique = false, expansion = "WotLK" }, -- Вневременной страхолит
    { itemID = 40168, socket = "prismatic", stats = { stam = 2, armor = 2 }, unique = false, expansion = "WotLK" }, -- Неизменное око Зула
    { itemID = 40161, socket = "prismatic", stats = { dodge = 2, parry = 2 }, unique = false, expansion = "WotLK" }, -- Стойкий аметрин
    { itemID = 40167, socket = "prismatic", stats = { stam = 2, dodge = 2 }, unique = false, expansion = "WotLK" }, -- Монаршее око Зула
    { itemID = 40139, socket = "prismatic", stats = { stam = 2, parry = 2 }, unique = false, expansion = "WotLK" }, -- Страхолит защитника
    { itemID = 38547, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Смертоносный изысканный топаз
    { itemID = 32222, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Смертоносный огнекамень
    { itemID = 32220, socket = "prismatic", stats = { agi = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Блистающий аметист Песни Теней
    { itemID = 30585, socket = "prismatic", stats = { agi = 2, dodge = 2 }, unique = false, expansion = "TBC" }, -- Полированный огненный опал
    { itemID = 32213, socket = "prismatic", stats = { agi = 2, stam = 2 }, unique = false, expansion = "TBC" }, -- Изменчивый аметист Песни Теней
    { itemID = 30584, socket = "prismatic", stats = { str = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Покрытый письменами огненный опал
    { itemID = 32217, socket = "prismatic", stats = { str = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Покрытый письменами огнекамень
    { itemID = 32211, socket = "prismatic", stats = { str = 2, stam = 2 }, unique = false, expansion = "TBC" }, -- Царственный аметист Песни Теней
    { itemID = 30551, socket = "prismatic", stats = { int = 2, haste = 2 }, unique = false, expansion = "TBC" }, -- Тревожный огненный опал
    { itemID = 35760, socket = "prismatic", stats = { int = 2, haste = 2 }, unique = false, expansion = "TBC" }, -- Тревожный огнекамень
    { itemID = 30573, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "TBC" }, -- Таинственный танзанит
    { itemID = 37503, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "TBC" }, -- Очищенный аметист Песни Теней
    { itemID = 30603, socket = "prismatic", stats = { int = 2, vers = 2 }, unique = false, expansion = "TBC" }, -- Очищенный танзанит
    { itemID = 38548, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Могущественный изысканный топаз
    { itemID = 32218, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Могущественный огнекамень
    { itemID = 32221, socket = "prismatic", stats = { int = 2, crit = 2 }, unique = false, expansion = "TBC" }, -- Сокрытый аметист Песни Теней
    { itemID = 32215, socket = "prismatic", stats = { int = 2, stam = 2 }, unique = false, expansion = "TBC" }, -- Вневременной аметист Песни Теней
    { itemID = 30583, socket = "prismatic", stats = { int = 2, stam = 2 }, unique = false, expansion = "TBC" }, -- Вневременной танзанит
    { itemID = 30607, socket = "prismatic", stats = { armor = 2, parry = 2 }, unique = false, expansion = "TBC" }, -- Великолепный огненный опал
    { itemID = 30601, socket = "prismatic", stats = { stam = 2, armor = 2 }, unique = false, expansion = "TBC" }, -- Неизменный хризопраз
    { itemID = 35758, socket = "prismatic", stats = { stam = 2, armor = 2 }, unique = false, expansion = "TBC" }, -- Неизменный морской изумруд
    { itemID = 32223, socket = "prismatic", stats = { stam = 2, dodge = 2 }, unique = false, expansion = "TBC" }, -- Монарший морской изумруд
    { itemID = 168637, socket = "prismatic", stats = { agi = 3 }, unique = true, expansion = "BfA" }, -- Левиафанов глаз ловкости
    { itemID = 168636, socket = "prismatic", stats = { str = 3 }, unique = true, expansion = "BfA" }, -- Левиафанов глаз силы
    { itemID = 168638, socket = "prismatic", stats = { int = 3 }, unique = true, expansion = "BfA" }, -- Левиафанов глаз интеллекта
    { itemID = 71879, socket = "prismatic", stats = { agi = 3 }, unique = false, expansion = "Cataclysm" }, -- Хрупкий королевский гранат
    { itemID = 71883, socket = "prismatic", stats = { str = 3 }, unique = false, expansion = "Cataclysm" }, -- Рельефный королевский гранат
    { itemID = 71881, socket = "prismatic", stats = { int = 3 }, unique = false, expansion = "Cataclysm" }, -- Сверкающий королевский гранат
    { itemID = 77134, socket = "prismatic", stats = { armor = 3 }, unique = false, expansion = "Cataclysm" }, -- Мистический светолит
    { itemID = 71875, socket = "prismatic", stats = { dodge = 3 }, unique = false, expansion = "Cataclysm" }, -- Изящный светолит
    { itemID = 71882, socket = "prismatic", stats = { parry = 3 }, unique = false, expansion = "Cataclysm" }, -- Блистательный королевский гранат
    { itemID = 40114, socket = "prismatic", stats = { agi = 3 }, unique = false, expansion = "WotLK" }, -- Хрупкий багровый рубин
    { itemID = 42143, socket = "prismatic", stats = { agi = 3 }, unique = false, expansion = "WotLK" }, -- Хрупкое око дракона
    { itemID = 40111, socket = "prismatic", stats = { str = 3 }, unique = false, expansion = "WotLK" }, -- Рельефный багровый рубин
    { itemID = 42142, socket = "prismatic", stats = { str = 3 }, unique = false, expansion = "WotLK" }, -- Рельефное око дракона
    { itemID = 40123, socket = "prismatic", stats = { int = 3 }, unique = false, expansion = "WotLK" }, -- Сверкающий багровый рубин
    { itemID = 42148, socket = "prismatic", stats = { int = 3 }, unique = false, expansion = "WotLK" }, -- Сверкающее око дракона
    { itemID = 44066, socket = "prismatic", stats = { armor = 3 }, unique = true, expansion = "WotLK" }, -- Милость Хармы
    { itemID = 42158, socket = "prismatic", stats = { armor = 3 }, unique = false, expansion = "WotLK" }, -- Мистическое око дракона
    { itemID = 40127, socket = "prismatic", stats = { armor = 3 }, unique = false, expansion = "WotLK" }, -- Мистический царский янтарь
    { itemID = 42157, socket = "prismatic", stats = { dodge = 3 }, unique = false, expansion = "WotLK" }, -- Изящное око дракона
    { itemID = 40126, socket = "prismatic", stats = { dodge = 3 }, unique = false, expansion = "WotLK" }, -- Изящный царский янтарь
    { itemID = 40116, socket = "prismatic", stats = { parry = 3 }, unique = false, expansion = "WotLK" }, -- Блистательный багровый рубин
    { itemID = 42152, socket = "prismatic", stats = { parry = 3 }, unique = false, expansion = "WotLK" }, -- Блистательное око дракона
    { itemID = 33131, socket = "prismatic", stats = { agi = 3 }, unique = true, expansion = "TBC" }, -- Пунцовое солнце
    { itemID = 35487, socket = "prismatic", stats = { agi = 3 }, unique = false, expansion = "TBC" }, -- Хрупкая пунцовая шпинель
    { itemID = 32193, socket = "prismatic", stats = { str = 3 }, unique = false, expansion = "TBC" }, -- Рельефная пунцовая шпинель
    { itemID = 35489, socket = "prismatic", stats = { int = 3 }, unique = false, expansion = "TBC" }, -- Сверкающая пунцовая шпинель
    { itemID = 33133, socket = "prismatic", stats = { int = 3 }, unique = true, expansion = "TBC" }, -- Сердце дона Хулио
    { itemID = 33134, socket = "prismatic", stats = { int = 3 }, unique = true, expansion = "TBC" }, -- Роза Кайли
    { itemID = 27679, socket = "prismatic", stats = { armor = 3 }, unique = true, expansion = "TBC" }, -- Мистический зоревик
    { itemID = 32209, socket = "prismatic", stats = { armor = 3 }, unique = false, expansion = "TBC" }, -- Мистический львиный глаз
    { itemID = 33144, socket = "prismatic", stats = { dodge = 3 }, unique = true, expansion = "TBC" }, -- Грань вечности
    { itemID = 32208, socket = "prismatic", stats = { dodge = 3 }, unique = false, expansion = "TBC" }, -- Изящный львиный глаз
    { itemID = 32199, socket = "prismatic", stats = { parry = 3 }, unique = false, expansion = "TBC" }, -- Блистательная пунцовая шпинель
    { itemID = 173128, socket = "prismatic", stats = { haste = 2 }, unique = false, expansion = "Shadowlands" }, -- Композиция самоцветов стремительности
    { itemID = 173129, socket = "prismatic", stats = { vers = 2 }, unique = false, expansion = "Shadowlands" }, -- Композиция самоцветов универсальности
    { itemID = 173130, socket = "prismatic", stats = { iskus = 2 }, unique = false, expansion = "Shadowlands" }, -- Композиция самоцветов искусности
    { itemID = 173127, socket = "prismatic", stats = { crit = 2 }, unique = false, expansion = "Shadowlands" }, -- Композиция самоцветов смертоносности
    { itemID = 49110, socket = "prismatic", stats = { all = 2 }, unique = true, expansion = "WotLK" }, -- Слеза кошмаров
    { itemID = 30546, socket = "prismatic", stats = { str = 2 }, unique = false, expansion = "TBC" }, -- Царственный танзанит
    { itemID = 173125, socket = "prismatic", stats = {  }, unique = true, expansion = "Shadowlands", effect = "133 health every 10 sec for each Unique Equipped Shadowlands gem you have socketed" }, -- Ободряющий дублет
    { itemID = 173126, socket = "prismatic", stats = {  }, unique = true, expansion = "Shadowlands", effect = "Speed increased by 3 for each Unique Equipped Shadowlands gem you have socketed" }, -- Широкий дублет
    { itemID = 153715, socket = "prismatic", stats = {  }, unique = true, expansion = "BfA" }, -- Охватывающий виридий
    { itemID = 169220, socket = "prismatic", stats = {  }, unique = true, expansion = "BfA" }, -- Резвый провидческий агат
    { itemID = 153714, socket = "prismatic", stats = {  }, unique = true, expansion = "BfA", effect = "+5% Swim Speed" }, -- Рубеллит плавучести
    { itemID = 38545, socket = "prismatic", stats = {  }, unique = false, expansion = "TBC" }, -- Хрупкий изысканный рубин
    { itemID = 38549, socket = "prismatic", stats = {  }, unique = false, expansion = "TBC" }, -- Сверкающий изысканный рубин
}
