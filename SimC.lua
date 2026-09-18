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

-- Лекарские спеки. В таблице ролей SimC их нет — там они «attack», потому что
-- сим считает только урон. Нам список нужен ради уровня цели: см. ниже.
local HEALERS = {
    [105] = true,  -- друид, Исцеление
    [1468] = true, -- пробудитель, Хранитель
    [270] = true,  -- монах, Ткач туманов
    [65] = true,   -- паладин, Свет
    [256] = true, [257] = true, -- жрец, Послушание и Свет
    [264] = true,  -- шаман, Исцеление
}

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
    -- 23. Двадцатки ходят в подземелья, где мобы много выше, а сборка BiS
    -- собирается под самые сложные из них — мифики Легиона, мобы 45 (решение
    -- пользователя, 17 сентября).
    --
    -- Уровень мобов выведен из логов рейтинга по доле промахов (231 бой):
    -- старые героики ~30 (73 % боёв), Пандария ~38, Легион 45, Каз Алгар ~73.
    -- Сверка: у Чащи Тёмного Сердца вышло ровно 45, как и в её названии.
    -- Под другое подземелье меняется одна цифра — строки-подсказки ниже.
    --
    -- На Raidbots урон выйдет занижен: их движок растит уклонение вместе
    -- с уровнем и на цели 45 даёт 33 % вместо 9 % по логам. Сравнение сборок
    -- между собой это не ломает — ошибка одинакова для всех вариантов.
    --
    -- Кастерам и лекарям цель понижена до болванки 23 (решение пользователя,
    -- 18 сентября): лекарь в подземелье лечит, а не бьёт, а маг в сложные
    -- подземелья не ходит. Заодно это единственная цель, на которой их отчёт
    -- не пустой: магия по высокоуровневой цели мажет — это правило игры,
    -- а не ошибка сима. Замер на жреце Тьмы 16 сентября: промах заклинаний
    -- растёт примерно на 11 % за уровень цели — 0 % по 23, 44 % по 27,
    -- 88 % по 31, а с 33 и выше все заклинания мимо и урон ноль.
    if role == "spell" or HEALERS[specID] or gameRole == "HEALER" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "# Цель — болванка 23 уровня: по высокой цели заклинания мажут все до одного."
        lines[#lines + 1] = "target_level=23"
    else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "# Цель — моб 45 уровня: сборка BiS считается по самым сложным подземельям."
        lines[#lines + 1] = "target_level=45"
        lines[#lines + 1] = "# Другое подземелье: старые героики — 30, Пандария — 38, Каз Алгар — 73."
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
        -- Кровопускание ПОСЛЕ Смертельного удара: у Оружия ярость копится
        -- медленно, и если обновлять дот первым, он съедает её всю —
        -- Смертельный удар тогда не жмётся ни разу. Замер 18 сентября
        -- на выгрузке Кавочавоо, цель 45: 290 против 392. У Неистовства
        -- порядок не важен (Кровожадность сама даёт ярость), там дот раньше.
        "actions+=/mortal_strike",
        "actions+=/rend,if=refreshable",
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
        -- Реванш первым спендером: в логах он главный приём Защиты (29 % урона
        -- против 13 % у Мощного удара щитом). Замер 18 сентября на выгрузке
        -- Кавочавоо, цель 45: 344 → 356 на одной цели, 667 → 713 на трёх;
        -- доля Реванша стала 29 %, ровно как в логах.
        "actions+=/revenge",
        "actions+=/shield_slam",
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
        -- Копить ци под Кулаки: за 6 сек. до их отката Журавль и Нокаут ци не
        -- тратят, пока её не хватит и на Кулаки. Без этого Лапа даёт 2 ци,
        -- Журавль (2 ци) их сразу съедает, и до 3 ци на Кулаки запас не
        -- доходит — Кулаков ноль, хотя в логах они треть урона. Замер
        -- 17 сентября: болванка 1541 → 1622, цель 38 на движке без ошибки
        -- возврата ци 711 → 751; порог подобран из 2–30 сек.
        "actions+=/spinning_crane_kick,if=combo_strike&(cooldown.fists_of_fury.remains>6|chi>=5)",
        "actions+=/blackout_kick,if=combo_strike&(cooldown.fists_of_fury.remains>6|chi>=4)",
        -- Запасной выход: без него промах Лапы (ци даётся только с попадания)
        -- вместе с запретом повтора оставлял монаха стоять до Мудрости боя.
        "actions+=/tiger_palm,if=combo_strike|chi<1",
        "actions+=/fists_of_fury",
        "actions+=/spinning_crane_kick,if=cooldown.fists_of_fury.remains>6|chi>=5",
        "actions+=/blackout_kick,if=cooldown.fists_of_fury.remains>6|chi>=4",
        "actions+=/tiger_palm",
    },
    [260] = { -- Головорез: Коварный удар и Выстрел из пистоли, финишеры — Промеж
              -- глаз и Потрошение; Бросок костей до боя, Шквал клинков от двух целей.
              -- Штатная ротация SimC на двадцатке почти не жмёт приёмы: 121 против
              -- 262 у этой (18 сентября, цель 45, сборка BiS разбойника).
              -- Состав сверен с логами: Коварный удар, «Правой, левой», Выстрел
              -- из пистоли — те же приёмы и в том же порядке по доле урона.
              -- У Ликвидации и Скрытности штатная ротация работает лучше любой
              -- нашей, поэтому им строк не пишем.
        "actions.precombat=apply_poison",
        "actions=auto_attack",
        "actions+=/roll_the_bones,if=!buff.roll_the_bones.up",
        "actions+=/between_the_eyes,if=combo_points>=5",
        "actions+=/dispatch,if=combo_points>=5",
        "actions+=/blade_flurry,if=active_enemies>=2",
        "actions+=/pistol_shot,if=buff.opportunity.up",
        "actions+=/sinister_strike",
    },
    [102] = { -- Баланс: доты Лунный и Солнечный огонь, спендер Звёздный поток,
              -- заполнитель Гнев. Штатная ротация SimC на двадцатке не жмёт
              -- заклинания вовсе: 48 урона, из них две трети даёт удар посохом
              -- в ближнем бою. Своя — 710, в пятнадцать раз (19 сентября,
              -- цель 23 как кастеру, сборка Чома с армори). Состав сверен
              -- с логами гильдии: Звёздный поток, Солнечный огонь, Гнев,
              -- Лунный огонь. Облик совы до боя обязателен.
        "actions.precombat=moonkin_form",
        "actions=moonfire,if=refreshable",
        "actions+=/sunfire,if=refreshable",
        "actions+=/starsurge",
        "actions+=/starfall,if=active_enemies>=3",
        "actions+=/starfire,if=active_enemies>=2",
        "actions+=/wrath",
    },
    [104] = { -- Страж: Взбучка, Увечье, Лунный огонь, Размах. Штатная ротация SimC
              -- на двадцатке даёт 187, своя 266 (19 сентября, цель 45, сборка
              -- Филиондры с армори). Состав сверен с логами гильдии: Взбучка,
              -- Лунный огонь, Размах, Увечье — те же приёмы. Порядок проверен:
              -- Увечье выше Взбучки хуже (266 против 266), Лунный огонь первым
              -- хуже (261). Медвежий облик до боя — без него ротация мёртвая.
              -- Кошке своя ротация не нужна: штатная 419 против наших 361.
        "actions.precombat=bear_form",
        "actions=auto_attack",
        "actions+=/thrash",
        "actions+=/mangle",
        "actions+=/moonfire,if=refreshable",
        "actions+=/swipe_bear",
    },
    [254] = { -- Стрельба: Быстрая стрельба, Прицельный, Чародейский, Верный выстрел.
              -- Штатная ротация SimC на двадцатке не жмёт почти ничего: 162 урона,
              -- из них 98 % даёт автовыстрел. Своя — 640 (18 сентября, цель 45,
              -- сборка Снайперюльки с армори, аксессуар заменён на инженерный).
              -- Состав сверен с логами гильдии:
              -- Чародейский выстрел, Прицельный, Быстрая стрельба — те же приёмы
              -- и в том же порядке по доле урона. Прицельный выше Быстрой
              -- стрельбы пробовал — хуже (537). Верный выстрел последний:
              -- он восполняет фокус, а не бьёт.
              -- Питомца Стрельбе призывать незачем: с призывом ровно столько же.
              -- Выживанию и Повелителю зверей штатная ротация работает не хуже
              -- нашей (241 и 330 против 241 и 279), им строк не пишем.
        "actions=auto_shot",
        "actions+=/rapid_fire",
        "actions+=/aimed_shot",
        -- Залп от двух целей, не от трёх: на двух даёт +2 % (653 против 640),
        -- на трёх разницы нет. В рейдовых логах гильдии он даёт стрелкам
        -- 14-22 % урона — на трэше между боссами.
        "actions+=/multishot,if=active_enemies>=2",
        "actions+=/arcane_shot",
        "actions+=/steady_shot",
    },
    [66] = { -- Защита паладина: Щит праведника, Правосудие, Щит мстителя, Освящение.
             -- Штатная ротация SimC Щит праведника не жмёт ни разу: все три её
             -- строки с ним требуют героического дерева (Храмовник или Оружейник),
             -- а оно открывается сильно позже двадцатки. Святая сила копилась
             -- впустую. Своя ротация — 455 против 380 (18 сентября, цель 45).
             -- Трата на трёх зарядах выгоднее, чем на пяти (455 против 453).
             -- Состав сверен с логами гильдии: у танков-паладинов те же приёмы —
             -- Благословенный молот, Правосудие, Щит праведника, Освящение.
        "actions.precombat=consecration",
        "actions=auto_attack",
        "actions+=/shield_of_the_righteous,if=holy_power>=3",
        "actions+=/judgment",
        "actions+=/avengers_shield",
        -- Молот гнева сейчас — усиленное Правосудие под Крыльями, отдельной
        -- кнопки нет («During Avenging Wrath, Judgment is empowered into
        -- Hammer of Wrath» в данных игры). Двадцатки Крылья не берут: в логах
        -- на 68 боёв 0,3 нажатия Крыльев. Строка молчит, пока их нет, и
        -- сработает у того, кто взял. В логах он нажат 36 раз за бой —
        -- это прошлая версия игры, где он был добиванием.
        "actions+=/hammer_of_wrath",
        "actions+=/consecration,if=!consecration.up",
        -- Благословенный молот — талант, у кого не взят, строка просто молчит.
        "actions+=/blessed_hammer",
        "actions+=/hammer_of_the_righteous",
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
