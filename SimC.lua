-- Шапка профиля SimulationCraft для выгрузки сборки BiS (/tgf simc).
--
-- ЗАЧЕМ. Без шапки Raidbots не узнаёт персонажа: на каждой строке вещи
-- «Gear slot "head" appears before any class declaration», и симулировать
-- некого. Формат повторяет аддон SimulationCraft (его core.lua и extras.lua).
-- Проверено вставкой на Raidbots 15 сентября: персонаж, таланты и все
-- 16 вещей узнались; сервер кириллицей тоже принимается.
--
-- ЧЕГО НЕТ И НЕ БУДЕТ. Строки «# Checksum»: ею SimulationCraft подтверждает,
-- что текст снят его аддоном и не правлен. Наш текст — не его, поэтому
-- Raidbots пишет «Unverified Input»; сим это не останавливает. Пометка
-- «Low Level» тоже останется — так Raidbots помечает любого ниже максимума.

local addonName, ns = ...

-- Номер спека → имя спека в SimC. Копия Simulationcraft.SpecNames.
local SPEC_NAMES = {
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    [577] = "Havoc", [581] = "Vengeance", [1480] = "Devourer",
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Restoration",
    [1473] = "Augmentation", [1467] = "Devastation", [1468] = "Preservation",
    [253] = "Beast Mastery", [254] = "Marksmanship", [255] = "Survival",
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    [268] = "Brewmaster", [269] = "Windwalker", [270] = "Mistweaver",
    [65] = "Holy", [66] = "Protection", [70] = "Retribution",
    [256] = "Discipline", [257] = "Holy", [258] = "Shadow",
    [259] = "Assassination", [260] = "Outlaw", [261] = "Subtlety",
    [262] = "Elemental", [263] = "Enhancement", [264] = "Restoration",
    [265] = "Affliction", [266] = "Demonology", [267] = "Destruction",
    [71] = "Arms", [72] = "Fury", [73] = "Protection",
}

-- Номер спека → role=. Копия Simulationcraft.RoleTable. Кого в ней нет,
-- тому роль по игре — так же, как делает SimulationCraft (лекарь → attack).
local ROLES = {
    [250] = "tank", [251] = "attack", [252] = "attack",
    [577] = "attack", [581] = "tank",
    [102] = "spell", [103] = "attack", [104] = "tank", [1480] = "spell",
    [1467] = "spell", [1468] = "attack",
    [253] = "attack", [254] = "attack", [255] = "attack",
    [62] = "spell", [63] = "spell", [64] = "spell",
    [268] = "tank", [269] = "attack", [270] = "attack",
    [65] = "attack", [66] = "tank", [70] = "attack",
    [256] = "spell", [257] = "attack", [258] = "spell",
    [259] = "attack", [260] = "attack", [261] = "attack",
    [262] = "spell", [263] = "attack", [264] = "attack",
    [265] = "spell", [266] = "spell", [267] = "spell",
    [71] = "attack", [72] = "attack", [73] = "tank",
}
local ROLE_BY_GAME = { TANK = "tank", DAMAGER = "attack", HEALER = "attack" }

-- Нижний регистр вместе с кириллицей. string.lower её ломает: идёт побайтно
-- и на байтах выше 127 смотрит на локаль. Приём тот же, что у NormalizeName
-- в Core.lua: А-П (D0 90..9F) → D0 B0..BF, Р-Я (D0 A0..AF) → D1 80..8F, Ё → ё.
local function Lower(s)
    s = s:gsub("[A-Z]", function(c) return string.char(c:byte() + 32) end)
    s = s:gsub("\208([\144-\175])", function(c)
        local b = c:byte()
        if b <= 0x9F then return "\208" .. string.char(b + 0x20) end
        return "\209" .. string.char(b - 0x20)
    end)
    return (s:gsub("\208\129", "\209\145"))
end

-- Токен SimC, как Tokenize у SimulationCraft: нижний регистр, пробел → «_»,
-- из ASCII остаются буквы, цифры и % + . _, многобайтные буквы — целиком.
local function Tokenize(s)
    s = Lower(s or ""):gsub(" ", "_")
    s = s:gsub("[%z\1-\127]", function(c)
        if c:match("[%w%%%+%._]") then return c end
        return ""
    end)
    return (s:gsub("_$", ""))
end

-- Раса из английского имени в игре: «NightElf» → night_elf, «Scourge» → undead.
-- SimC расу с классом не сверяет (ворген-монах считается без ошибок) —
-- поэтому для сборки чужого класса годится своя раса.
local function RaceToken()
    local _, race = UnitRace("player")
    if race == "Scourge" then return "undead" end
    return Tokenize((tostring(race or "Human"):gsub("(%l)(%u)", "%1 %2")))
end

-- Код талантов. Свой спек — прямо из игры, как у SimulationCraft: это
-- настоящая сборка двадцатки. Чужой — из Talents.lua, и тогда с пометкой:
-- коды там сняты не на двадцатке (50–55 очков против 10–11 у армори).
local function TalentCode(specID)
    local current = GetSpecialization and GetSpecialization()
    local mySpec = current and GetSpecializationInfo(current)
    if mySpec == specID and C_ClassTalents and C_ClassTalents.GetActiveConfigID then
        local configID = C_ClassTalents.GetActiveConfigID()
        local ok, code = pcall(function() return C_Traits.GenerateImportString(configID) end)
        if ok and type(code) == "string" and code ~= "" then return code, true end
    end
    local t = ns.TalentCodes and ns.TalentCodes[specID]
    if t then return t.code, false end
end

-- Строки шапки для спека из окна BiS. nil — если номер спека игре неизвестен.
function ns.SimCHeader(specID)
    local _, specName, _, _, gameRole, classFile, className = GetSpecializationInfoByID(specID or 0)
    if not classFile then return nil end

    local _, myClass = UnitClass("player")
    local spec = SPEC_NAMES[specID] or specName or "unknown"
    -- Имя — своё, если класс сборки свой; иначе условное. Имя в секрете
    -- (Midnight, правило 16 в HANDOFF) не трогаем вовсе.
    local name = UnitName("player")
    if myClass ~= classFile or type(name) ~= "string"
        or (issecretvalue and issecretvalue(name)) then
        name = "TGF_" .. Tokenize(spec)
    end
    local realm = GetRealmName() or ""
    local region = (GetCurrentRegionName and GetCurrentRegionName()) or ""
    -- Роль нужна дважды: строкой role= и ниже, чтобы выбрать уровень цели.
    local role = ROLES[specID] or ROLE_BY_GAME[gameRole] or "attack"

    local lines = {
        string.format("# %s - %s - %s - %s/%s", name, spec, date("%Y-%m-%d %H:%M"), Lower(region), realm),
        string.format("# TrialGearFinder: сборка BiS, %s %s", className or "?", specName or ""),
        "# Выгрузка TrialGearFinder, не аддона SimulationCraft: Raidbots пометит «Unverified Input».",
        -- Только Advanced Sim (решение пользователя, 16 сентября): Quick Sim
        -- комментирует строки ротации, и SimC бьёт одними автоатаками (200 вместо 1485).
        "# Вставлять в Advanced Sim на Raidbots: Quick Sim выбрасывает строки ротации.",
        -- Advanced Sim печатает только урон сборки. Веса статов — отдельный
        -- инструмент, та же вставка; он же выдаёт строку для аддона Pawn.
        -- Проверено на жреце 16 сентября: веса сошлись с локальными до сотых.
        "# Нужны веса статов — та же вставка в Stat Weights: raidbots.com/simbot/stats.",
        "",
        string.format('%s="%s"', Lower(classFile), name),
        "level=20",
        "race=" .. RaceToken(),
        "region=" .. Tokenize(region),
        "server=" .. Tokenize(realm),
        "role=" .. role,
        "spec=" .. Tokenize(spec),
        "",
        -- SimC по умолчанию выдаёт флягу, еду, зелье и руну максимального уровня:
        -- у жреца Тьмы это 1892 против 1578 (+20 %), а двадцатке они недоступны
        -- (у Фляги алхимического хаоса требование 71 уровень). 16 сентября.
        "# Расходники максимального уровня двадцатке недоступны — выключены.",
        "potion=disabled",
        "flask=disabled",
        "food=disabled",
        "augmentation=disabled",
        "temporary_enchant=disabled",
    }

    -- Уровень цели. По умолчанию SimC ставит врага на три уровня выше — болванку
    -- 23, а двадцатки ходят в высокоуровневые подземелья, где мобы 38 (решение
    -- пользователя, 16 сентября). Урон падает вдвое: Неистовство 1499 по
    -- болванке против 665 по цели 38, Ликвидация 1153 против 612 (17 сентября).
    --
    -- Кастерам цель не трогаем: магия по высокоуровневой цели мажет — это
    -- правило игры, а не ошибка сима. Замер на жреце Тьмы 16 сентября: промах
    -- заклинаний растёт примерно на 11 % за уровень цели — 0 % по 23, 44 %
    -- по 27, 88 % по 31, а с 33 и выше все заклинания мимо и урон ноль.
    if role ~= "spell" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "# Цель — моб подземелья 38 уровня: двадцатки ходят в высокоуровневые данжи."
        lines[#lines + 1] = "target_level=38"
    end
    local code, fromGame = TalentCode(specID)
    if code then
        if not fromGame then
            lines[#lines + 1] = "# Таланты взяты из аддона, не с этого персонажа: код снят не на двадцатке."
        end
        lines[#lines + 1] = "talents=" .. code
    else
        lines[#lines + 1] = "# Талантов нет: зайди этим спеком — выгрузка возьмёт их из игры."
    end
    lines[#lines + 1] = ""
    return lines
end

-- ---------------------------------------------------------------------------
-- Проки, которых SimC не знает. Без них сим на сайте занижает урон.
-- Проверено локальным SimC 15 сентября: у Рыцаря и Руки-клинка баффа
-- в отчёте нет вовсе, пока прок не описан строкой equip=.
-- ---------------------------------------------------------------------------

-- Прок самой вещи — по номеру предмета.
local ITEM_PROCS = {
    -- Рука-клинок: +61 к скорости на 10 сек., раз в 45 сек. Шанс неизвестен,
    -- 100 % — верхняя граница.
    [29348] = "procby/wmelee_procon/hit_61haste_100%_10dur_45cd",
}

local CRUSADER = 1900 -- Рыцарь: 33 силы на 15 сек., раз в минуту на оружие

-- Возвращает { [ключ слота] = "строка для equip=" }.
function ns.SimCProcs(slots)
    local out, crusader = {}, {}
    for _, s in ipairs(slots or {}) do
        local id = s.item and s.item.itemID
        if id and ITEM_PROCS[id] then out[s.key] = ITEM_PROCS[id] end
        if (s.key == "MAINHAND" or s.key == "OFFHAND")
            and s.ench and s.ench.enchantID == CRUSADER then
            crusader[#crusader + 1] = s.key
        end
    end
    -- Рыцарь на двух оружиях — одним эффектом на правой руке: два прока
    -- в минуту, до двух стопок. Два отдельных эффекта у одинакового оружия
    -- SimC сливает в один прок раз в минуту (уптайм 24 % вместо 43 %).
    local key = crusader[1]
    if key and not out[key] then
        out[key] = (#crusader == 2) and "procby/melee_procon/hit_33str_2rppm_15dur_2stacks"
            or "procby/melee_procon/hit_33str_1rppm_15dur"
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Ротации двадцатки. Штатная у SimC — под максимальный уровень: на двадцатке
-- персонаж почти не жмёт приёмы (выгрузка Неистовства: 253 урона в секунду
-- вместо 2597, на Raidbots — 257). Здесь только спеки, чья ротация сверена
-- с разбивкой нажатий лучших игроков в логах рейтинга (вики «Симулятор»).
-- ---------------------------------------------------------------------------
local ACTIONS = {
    [71] = { -- Оружие: логи — Кровопускание, Смертельный удар, Превосходство, Казнь, Вихрь.
             -- Добивка на одной цели — Мощный удар (+7 % против Вихря), Вихрь — от двух целей.
             -- Кровопускание — талант; у кого не взят, SimC строку просто пропустит.
             -- Боевая стойка до боя: +2,4 % (1233 → 1263). Без toggle=on SimC строку не выполняет.
        "actions.precombat=battle_stance,toggle=on",
        "actions=auto_attack",
        "actions+=/sweeping_strikes,if=active_enemies>=2",
        "actions+=/rend,if=refreshable",
        "actions+=/mortal_strike",
        "actions+=/overpower",
        "actions+=/execute",
        "actions+=/whirlwind,if=active_enemies>=2",
        "actions+=/slam",
    },
    [73] = { -- Защита: логи — Реванш, Мощный удар щитом, Удар грома; Реванш раньше Удара грома (+1,7 %).
             -- Сокрушение при таланте «Сокрушитель» пассивное — строка тогда молчит.
             -- Стойка — Оборонительная: Защита так и играет, ей надо и бить, и выживать
             -- (решение пользователя, 16 сентября). Урон 1044 против 1070 в Боевой,
             -- зато получаемый урон −16 %.
        "actions.precombat=defensive_stance,toggle=on",
        "actions=auto_attack",
        "actions+=/shield_block",
        "actions+=/ignore_pain",
        "actions+=/demoralizing_shout",
        "actions+=/shield_slam",
        "actions+=/revenge",
        "actions+=/thunder_clap",
        "actions+=/execute",
        "actions+=/devastate",
    },
    [72] = { -- Неистовство: на пачке Вихрь, на одной цели Кровожадность и Яростный выпад
             -- Стойка берсерка до боя: +1,5 % (1463 → 1485), так же ставит её ротация Blizzard.
        "actions.precombat=berserker_stance,toggle=on",
        "actions=auto_attack",
        "actions+=/execute",
        "actions+=/rend,if=refreshable",
        "actions+=/bloodthirst,if=active_enemies<3",
        "actions+=/raging_blow,if=active_enemies<3",
        "actions+=/whirlwind",
        "actions+=/slam",
    },
    [269] = { -- Танцующий с ветром: после спендера — Лапа, спендеры Кулаки > Журавль > Нокаут.
              -- «combo_strike» — не повторять предыдущий приём: за это монах получает урон,
              -- поэтому цепочка Лапа → спендер → Лапа. Удар восходящего солнца не жмём:
              -- по мобам подземелья он мажет. Ротация от К., снята на его монахе.
              -- Замер 16 сентября против штатной ротации SimC: +12,5 % на болванке
              -- (1382 → 1555) и +21,3 % на цели 38 уровня (990 → 1200).
              -- Расовую (у дворфа Чёрного Железа это fireblood, +0,8 %) не пишем:
              -- она у каждой расы своя, а чужая строка сим не ломает, но и не работает.
        "actions.precombat=snapshot_stats",
        "actions=auto_attack",
        "actions+=/touch_of_death",
        "actions+=/tiger_palm,if=combo_strike&(prev_gcd.1.fists_of_fury|prev_gcd.1.spinning_crane_kick|prev_gcd.1.blackout_kick)",
        "actions+=/fists_of_fury,if=combo_strike",
        "actions+=/spinning_crane_kick,if=combo_strike",
        "actions+=/blackout_kick,if=combo_strike",
        -- Запасной выход: без него промах Лапы (ци даётся только с попадания)
        -- вместе с запретом повтора оставлял монаха стоять до Мудрости боя.
        "actions+=/tiger_palm,if=combo_strike|chi<1",
        "actions+=/fists_of_fury",
        "actions+=/spinning_crane_kick",
        "actions+=/blackout_kick",
        "actions+=/tiger_palm",
    },
    [268] = { -- Хмелевар: бочка, журавль, нокаутирующий; энергию копить под бочку
        "actions.precombat=snapshot_stats",
        "actions=auto_attack",
        "actions+=/touch_of_death",
        "actions+=/keg_smash",
        "actions+=/spinning_crane_kick,if=energy>=65|cooldown.keg_smash.remains>2",
        "actions+=/blackout_kick",
        "actions+=/tiger_palm,if=energy>=65|cooldown.keg_smash.remains>3",
    },
}

-- ---------------------------------------------------------------------------
-- Статы вещи строкой stats= — значения базы, то есть армори. Свои SimC
-- на двадцатке пересчитывает и ошибается (кинжалы разбойника, 13 сентября);
-- с 9 сентября он и сам при загрузке с армори кладёт статы так же.
-- Проверено 15 сентября: stats= меняет только статы самой вещи — броня
-- и бонус за гнёзда остаются, сумма у воина та же.
-- ---------------------------------------------------------------------------
local STAT_TOKEN = {
    str = "str", agi = "agi", int = "int", stam = "sta",
    crit = "crit", haste = "haste", iskus = "mastery", vers = "vers",
}
local STAT_ORDER = { "str", "agi", "int", "stam", "crit", "haste", "iskus", "vers" }
local MAIN_STAT = { str = true, agi = true, int = true }

-- Из основных характеристик — только своя: у вещей «на силу и ловкость» база
-- хранит обе, а SimC с армори так же пропускает неактивную (is_negated).
-- nil — оставить статы на SimC: основная не известна (иначе вещь осталась бы
-- без неё) или у записи статов нет (Дракончик).
function ns.SimCStats(item, primary)
    local st = item and item.stats
    if not (st and primary and STAT_TOKEN[primary]) then return nil end
    local tokens = {}
    for _, k in ipairs(STAT_ORDER) do
        local v = st[k]
        if type(v) == "number" and v > 0 and (not MAIN_STAT[k] or k == primary) then
            tokens[#tokens + 1] = v .. STAT_TOKEN[k]
        end
    end
    if #tokens == 0 then return nil end
    return table.concat(tokens, "_")
end

-- Хвост профиля: число целей и ротация (или предупреждение, что её нет).
function ns.SimCActions(specID)
    local lines = {
        "",
        "# Пачка из трёх целей: убери решётку в начале следующей строки.",
        "# desired_targets=3",
        "",
    }
    local list = ACTIONS[specID]
    if list then
        lines[#lines + 1] = "# Ротация двадцатки из TrialGearFinder, сверена с логами рейтинга."
        for _, l in ipairs(list) do lines[#lines + 1] = l end
    else
        -- Не «занижен в разы» у всех: у воинов и Хмелевара штатная ротация на двадцатке
        -- почти не жмёт приёмы, у жреца Тьмы работает как надо, а у Танцующего с ветром
        -- жала, но слабо — своя дала +12,5 % (16 сентября), теперь она здесь же.
        lines[#lines + 1] = "# Ротации двадцатки для этого спека в аддоне нет: SimC возьмёт свою,"
        lines[#lines + 1] = "# под максимальный уровень. У одних спеков она на двадцатке почти не жмёт"
        lines[#lines + 1] = "# приёмы, у других работает — цифре верить с оглядкой."
    end
    return lines
end
