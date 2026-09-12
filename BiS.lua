-- Окно BiS-сборок по классам и спекам. Приклеено слева к основному окну TGF,
-- той же высоты; сворачивается/разворачивается стрелкой на стыке окон
-- (или командой /tgf bis).
--
-- Предметы берутся из базы аддона (Data.lua) — той же, что и основное окно.
-- Это принципиально: надетое у триала ужато сквошем до низкого уровня, а база
-- хранит BiS-версию. Приоритет статов на каждый спек — из гайда гильдии
-- (BiS_Data.lua). По приоритету и ранжируются кандидаты в слот.
--
-- Раскладка окна и перечисление классов/спеков адаптированы из аддона Cap20
-- (BiS/Menu.lua, BiS/Engine.lua) — лицензия MIT, Copyright (c) Josh
-- "Kkthnx" Russell. Данные предметов из Cap20 НЕ взяты.
--
-- Пока временно чёрное, чтобы визуально отличать от основного окна TGF.

local addonName, ns = ...

local MAIN = "TrialGearFinderFrame" -- создаётся в Core.lua раньше этого файла

-- ---------------------------------------------------------------------------
-- Слоты в порядке показа.
-- ---------------------------------------------------------------------------
local SLOTS = {
    { key = "HEAD",     name = "Голова" },
    { key = "NECK",     name = "Шея" },
    { key = "SHOULDER", name = "Плечи" },
    { key = "BACK",     name = "Спина" },
    { key = "CHEST",    name = "Грудь" },
    { key = "WRIST",    name = "Запястья" },
    { key = "HANDS",    name = "Кисти" },
    { key = "WAIST",    name = "Пояс" },
    { key = "LEGS",     name = "Ноги" },
    { key = "FEET",     name = "Ступни" },
    { key = "FINGER1",  name = "Кольцо 1" },
    { key = "FINGER2",  name = "Кольцо 2" },
    { key = "TRINKET1", name = "Аксессуар 1" },
    { key = "TRINKET2", name = "Аксессуар 2" },
    { key = "MAINHAND", name = "Правая рука" },
    { key = "OFFHAND",  name = "Левая рука" },
}

-- equipLoc предмета -> ключ слота. Парные слоты (кольца, аксессуары) собираются
-- в один котёл FINGER / TRINKET, а раскладываются в две строки при показе.
local EQUIPLOC_SLOT = {
    INVTYPE_HEAD = "HEAD", INVTYPE_NECK = "NECK", INVTYPE_SHOULDER = "SHOULDER",
    INVTYPE_CLOAK = "BACK", INVTYPE_CHEST = "CHEST", INVTYPE_ROBE = "CHEST",
    INVTYPE_WRIST = "WRIST", INVTYPE_HAND = "HANDS", INVTYPE_WAIST = "WAIST",
    INVTYPE_LEGS = "LEGS", INVTYPE_FEET = "FEET",
    INVTYPE_FINGER = "FINGER", INVTYPE_TRINKET = "TRINKET",
    INVTYPE_WEAPONMAINHAND = "MAINHAND", INVTYPE_WEAPON = "MAINHAND",
    INVTYPE_2HWEAPON = "MAINHAND", INVTYPE_RANGED = "MAINHAND",
    INVTYPE_RANGEDRIGHT = "MAINHAND",
    INVTYPE_WEAPONOFFHAND = "OFFHAND", INVTYPE_HOLDABLE = "OFFHAND",
    INVTYPE_SHIELD = "OFFHAND",
}

local PAIR_BUCKET = { FINGER1 = "FINGER", FINGER2 = "FINGER", TRINKET1 = "TRINKET", TRINKET2 = "TRINKET" }

-- Двуручное занимает обе руки: при таком выборе в «Левую руку» ничего не ставим.
local TWO_HAND_LOC = {
    INVTYPE_2HWEAPON = true, INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true,
}
local twoHandID = {} -- itemID -> true, заполняется в BuildBuckets

-- Спеки, что носят два двуручных сразу (Titan's Grip). В левую руку кладём
-- вторую двуручку из того же котла, а не запрещаем слот.
local DUAL_2H_SPEC = { [72] = true } -- Воин, Неистовство

-- Слот экипировки для отметки «этот предмет сейчас надет».
local SLOT_INV = {
    HEAD = "HeadSlot", NECK = "NeckSlot", SHOULDER = "ShoulderSlot",
    BACK = "BackSlot", CHEST = "ChestSlot", WRIST = "WristSlot",
    HANDS = "HandsSlot", WAIST = "WaistSlot", LEGS = "LegsSlot",
    FEET = "FeetSlot", FINGER1 = "Finger0Slot", FINGER2 = "Finger1Slot",
    TRINKET1 = "Trinket0Slot", TRINKET2 = "Trinket1Slot",
    MAINHAND = "MainHandSlot", OFFHAND = "SecondaryHandSlot",
}

-- Имя стата в приоритете гайда -> ключ в Data.lua stats.
local PRIO_NAMES = {
    ["Интеллект"] = "int", ["Ловкость"] = "agi", ["Сила"] = "str",
    ["Выносливость"] = "stam", ["Критический удар"] = "crit",
    ["Скорость"] = "haste", ["Искусность"] = "iskus",
    ["Универсальность"] = "vers",
}

-- ---------------------------------------------------------------------------
-- Перечисление классов и спеков берётся у игры, а не пишется таблицей:
-- список и порядок Blizzard меняет, а specID стабилен.
-- ---------------------------------------------------------------------------
local classNameCache = {}
local function ClassName(classID)
    if not classNameCache[classID] then
        local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo
            and C_CreatureInfo.GetClassInfo(classID)
        classNameCache[classID] = info and info.className or ("class " .. classID)
    end
    return classNameCache[classID]
end

local function AllClasses()
    local out = {}
    local n = (GetNumClasses and GetNumClasses()) or 13
    for classID = 1, n do
        local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo
            and C_CreatureInfo.GetClassInfo(classID)
        if info and info.classFile then
            out[#out + 1] = { classID = classID, classFile = info.classFile }
        end
    end
    return out
end

local function SpecsForClass(classID)
    local out = {}
    if not (GetNumSpecializationsForClassID and GetSpecializationInfoForClassID) then
        return out
    end
    for i = 1, (GetNumSpecializationsForClassID(classID) or 0) do
        local id, name, _, icon = GetSpecializationInfoForClassID(classID, i)
        if id then out[#out + 1] = { specID = id, name = name, icon = icon } end
    end
    return out
end

local function PlayerClassSpec()
    local _, classFile, classID = UnitClass("player")
    local specID
    if GetSpecialization and GetSpecializationInfo then
        local idx = GetSpecialization()
        if idx then specID = GetSpecializationInfo(idx) end
    end
    return classFile, classID, specID
end

local function ClassColor(classFile)
    local c = C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(classFile)
    if c then return c.r, c.g, c.b end
    return 1, 1, 1
end

-- ---------------------------------------------------------------------------
-- Кандидаты в слоты из базы аддона
-- ---------------------------------------------------------------------------
local function ClassAllowed(item, classFile)
    -- item.classes == nil у трынек и проков — их пускаем всем.
    if not item.classes then return true end
    for _, c in ipairs(item.classes) do
        if c == classFile then return true end
    end
    return false
end

-- classFile -> { [slotKey] = { item, item, ... } }. Считается один раз: база
-- статична, а equipLoc через GetItemInfoInstant синхронный.
-- Кандидаты берутся из двух баз: гайд главы гильдии (ns.Items) и предметы
-- от сообщества (ns.CommunityItems). Формат записи одинаковый.
local allItemsCache
local communityId = {} -- itemID -> true: пришёл из ns.CommunityItems, не из гайда

-- Тот же тумблер «Комьюнити», что и в основном окне: один флаг на оба окна.
local function CommunityOn()
    return (TrialGearFinderDB and TrialGearFinderDB.showCommunity) and true or false
end

-- Полный список обеих баз. Метка communityId заполняется ВСЕГДА, независимо
-- от тумблера: по ней и рисуется пометка, и отсекаются предметы сообщества
-- при выключенном тумблере. Отбор делает BuildBuckets, а не эта функция -
-- ItemByID должен находить предмет в любом случае.
local function AllItems()
    if not allItemsCache then
        allItemsCache = {}
        for _, it in ipairs(ns.Items or {}) do allItemsCache[#allItemsCache + 1] = it end
        for _, it in ipairs(ns.CommunityItems or {}) do
            allItemsCache[#allItemsCache + 1] = it
            communityId[it.itemID] = true
        end
    end
    return allItemsCache
end

-- itemID -> запись, для ручных поправок ns.BiSPick.
local itemByID
local function ItemByID(id)
    if not itemByID then
        itemByID = {}
        for _, it in ipairs(AllItems()) do itemByID[it.itemID] = it end
    end
    return itemByID[id]
end

local CLASS_ARMOR = {
    WARRIOR = "PLATE", PALADIN = "PLATE", DEATHKNIGHT = "PLATE",
    HUNTER = "MAIL", SHAMAN = "MAIL", EVOKER = "MAIL",
    ROGUE = "LEATHER", MONK = "LEATHER", DRUID = "LEATHER", DEMONHUNTER = "LEATHER",
    MAGE = "CLOTH", PRIEST = "CLOTH", WARLOCK = "CLOTH",
}

-- Ручная поправка для слота: спека бьёт класс, класс бьёт тип брони.
-- Возвращает itemID, false (слот пуст) или nil (поправки нет).
local function SlotOverride(classFile, specID, slotKey)
    local t = ns.BiSPick and specID and ns.BiSPick[specID]
    if t and t[slotKey] ~= nil then return t[slotKey] end
    t = ns.BiSPickClass and classFile and ns.BiSPickClass[classFile]
    if t and t[slotKey] ~= nil then return t[slotKey] end
    t = ns.BiSPickArmor and CLASS_ARMOR[classFile or ""]
    t = t and ns.BiSPickArmor[t]
    if t and t[slotKey] ~= nil then return t[slotKey] end
    if ns.BiSPickAll and ns.BiSPickAll[slotKey] ~= nil then return ns.BiSPickAll[slotKey] end
    return nil
end

-- Ключ кэша включает состояние тумблера: при выключенном комьюнити котлы
-- другие, и старые брать нельзя.
local bucketCache = {}
local function BuildBuckets(classFile)
    local withComm = CommunityOn()
    local ckey = classFile .. (withComm and "+c" or "")
    if bucketCache[ckey] then return bucketCache[ckey] end
    local buckets = {}
    for _, item in ipairs(AllItems()) do
        if (withComm or not communityId[item.itemID]) and ClassAllowed(item, classFile) then
            local _, _, _, equipLoc = C_Item.GetItemInfoInstant(item.itemID)
            local slotKey = equipLoc and EQUIPLOC_SLOT[equipLoc]
            if slotKey then
                if TWO_HAND_LOC[equipLoc] then twoHandID[item.itemID] = true end
                buckets[slotKey] = buckets[slotKey] or {}
                table.insert(buckets[slotKey], item)
            end
        end
    end
    bucketCache[ckey] = buckets
    return buckets
end

-- Приоритет гайда -> веса статов: первый стат самый тяжёлый.
local function ParsePriority(s)
    if not s then return nil end
    local order = {}
    for name, key in pairs(PRIO_NAMES) do
        local pos = s:find(name, 1, true)
        if pos then order[#order + 1] = { pos = pos, key = key } end
    end
    table.sort(order, function(a, b) return a.pos < b.pos end)
    local w = {}
    for i, e in ipairs(order) do w[e.key] = #order - i + 1 end
    return w
end

-- Сколько стата даёт камень на двадцатке — ПО ТИПУ ГНЕЗДА. Раньше здесь
-- стояло одно число на все гнёзда (3), и это сильно занижало два случая.
--
-- Числа сняты со страниц армори 26 одетых твинков: у каждого закрытого
-- гнезда там лежит `display_string` с уже отмасштабированным значением.
-- Таблица целиком — guild-survey/gem_table.txt, 56 камней.
--
--   prismatic — алгарийский самоцвет TWW: Изумруд скорости, Сапфир
--               универсальности, Оникс искусности дают ровно +5. Старые
--               ювелирные +3, камни 2/2 дают 2+2, композиции SL +2 —
--               берём лучший общедоступный, база и так описывает BiS.
--   cogwheel  — шестерёнки Дракончика: все пять типов дают +10.
--   meta      — Плотный неуравновешенный алмаз: +12 к криту. Остальные
--               мета-камни — проки без прямых статов.
--
-- То есть Дракончик с тремя шестерёнками — это +30 вторички, а не +9,
-- как считалось. Отсюда и его 63 носящих: он честно лучший.
local SOCKET_VALUE = { prismatic = 5, cogwheel = 10, meta = 12 }
local GEM_VALUE = SOCKET_VALUE.prismatic -- запасное, если тип гнезда не записан

-- Какая шестерёнка даёт какую вторичку - itemID для вставки в ссылку
-- Дракончика, верхний тир (+10 реально, см. «Камни» § Шестерёнки — два тира).
--
-- ВСЕ шестерёнки «Уникальный использующийся» (проверено скриншотами
-- пользователя) - два экземпляра ОДНОГО предмета в гнёзда не встанут разом.
-- У крита и скорости есть по ДВЕ РАЗНЫХ шестерёнки верхнего тира на одно
-- и то же число (гномья/гоблинская инженерия: Гладкое/Прочное,
-- Быстрое/Аккуратное) - их можно вставить парой. У версы и искусности такой
-- пары нет, вставится только одна.
local COGWHEEL_IDS = {
    crit  = { 59478, 59493 }, -- Гладкое, Прочное
    haste = { 59479, 59489 }, -- Быстрое, Аккуратное
    vers  = { 59496 },        -- Искрящееся - второй такой не откован
    iskus = { 59480 },        -- Растрескавшееся - второй такой не откован
}

-- Какие шестерёнки поставить под спек. Первая проверенная версия давала по
-- одной на три разных стата - оказалось, не лучший выбор по умолчанию.
--
-- Перепроверили по слепку гильдии (guild-survey/dracling_double.js), сверяя
-- с приоритетом КОНКРЕТНОГО спека каждого персонажа (не класса вообще, как
-- в первый раз): 39 персонажей с тремя гнёздами, 19 удвоили какой-то стат,
-- 20 поставили три разных - практически поровну. Но из удвоивших 13 из 19
-- (68%) удвоили именно САМЫЙ приоритетный стат, не второй и не третий.
--
-- И это ещё и математически правильный дефолт: до софткапа (30%, см.
-- «Софткапы Вторичек») больше очков лучшего стата ВСЕГДА выгоднее, чем
-- меньше очков худшего - штрафа ещё нет. А со шмота и камней софткап
-- не собрать (максимум видели 23%), так что для всех, кому нет собственного
-- замера текущего рейтинга, безопасно занять гнёзда топ-статом.
--
-- Поэтому: первая половина гнёзд (округляя вверх) - под САМЫЙ приоритетный
-- стат, остаток - по одному под следующие по приоритету. При трёх гнёздах
-- (Дракончик - единственный такой предмет) выходит 2 + 1, как у реальных
-- игроков гильдии.
--
-- НО «2» под один стат получится, только если под него есть вторая РАЗНАЯ
-- шестерёнка (см. COGWHEEL_IDS выше) - иначе второй экземпляр не встанет
-- (Уникальный использующийся). Если у топ-стата такой пары нет (верса,
-- искусность), недостающее гнездо уходит следующему по приоритету стату -
-- он и заберёт освободившееся место, если у него сама пара есть.
--
-- Возвращает список { key = "haste", id = 59479 }, а не просто ключи стата:
-- вызывающему нужен именно itemID для вставки в ссылку.
local function CogwheelPicks(item, w)
    local n = 0
    for _, t in ipairs(item.socketTypes or {}) do
        if t == "cogwheel" then n = n + 1 end
    end
    if n == 0 or not w then return nil end
    local order = {}
    for _, k in ipairs({ "crit", "haste", "vers", "iskus" }) do
        if (w[k] or 0) > 0 then order[#order + 1] = k end
    end
    table.sort(order, function(a, b) return w[a] > w[b] end)
    if #order == 0 then return nil end

    local topShare = math.ceil(n / 2)
    local picks = {}
    for i = 1, #order do
        if #picks >= n then break end
        local stat = order[i]
        local ids = COGWHEEL_IDS[stat] or {}
        local want = (i == 1) and topShare or (n - #picks)
        want = math.min(want, #ids, n - #picks)
        for j = 1, want do picks[#picks + 1] = { key = stat, id = ids[j] } end
    end
    -- Край: приоритетов меньше, чем гнёзд, и все уже без дублей - добить
    -- нечем кроме повтора топа. Уникальность тут не спасти: лучше показать
    -- хоть что-то, чем ничего.
    local i = 1
    while #picks < n do
        local ids = COGWHEEL_IDS[order[1]] or {}
        picks[#picks + 1] = { key = order[1], id = ids[((i - 1) % math.max(1, #ids)) + 1] }
        i = i + 1
    end
    return picks
end

-- Лучший камень по типу гнезда и стату - из ns.Gems (файл Gems.lua, данные
-- Golden Cucumber и Харфа, разрешение получено). Считаем один раз и кешируем:
-- таблица на 238 записей, перебирать её на каждую отрисовку строки незачем.
--
-- Уникальные камни («Уникальный использующийся», по одному на персонажа)
-- в рекомендацию НЕ берём: в вещи с двумя гнёздами второй такой не встанет,
-- а окно рисует сборку целиком. Уникальные - Профанит, Кровавый камень,
-- Слеза кошмаров - показываются отдельным списком, это разные задачи.
local bestGemCache
local gemByID
local function BuildGemIndex()
    if bestGemCache then return end
    bestGemCache = {}
    gemByID = {}
    do
        for _, g in ipairs(ns.Gems or {}) do
            gemByID[g.itemID] = g
        end
        for _, g in ipairs(ns.Gems or {}) do
            if not g.unique and g.socket and g.stats then
                local t = bestGemCache[g.socket]
                if not t then t = {}; bestGemCache[g.socket] = t end
                for key, val in pairs(g.stats) do
                    local cur = t[key]
                    if not cur or val > cur.val then t[key] = { id = g.itemID, val = val } end
                end
            end
        end
    end
end

local function BestGem(socket, stat)
    BuildGemIndex()
    local t = bestGemCache[socket]
    local e = t and t[stat]
    return e and e.id or nil, e and e.val or nil
end

-- Тумблер «Дорогие камни»: выключен - советуем то, что люди носят.
local function ExpensiveGems()
    return (TrialGearFinderDB and TrialGearFinderDB.bestGems) and true or false
end

-- Доступный камень: 2 к основной характеристике + 2 к нужной вторичке
-- (аметрины, огнекамни, лавовые кораллы). Даёт четыре единицы против пяти
-- у алгарийского самоцвета TWW, но стоит на аукционе 100-200 золота против
-- 2-5 тысяч - цифры пользователя. По слепку двух гильдий (4108 камней)
-- алгарийские стоят у 5% твинков, камни «2 и 2» - у 30%.
--
-- Что выгоднее ПО СИЛЕ - 2 основной + 2 вторички или 5 вторички - **не
-- измерено**: статья гильдии говорит, что основные статы на триале дают
-- наибольшую прибавку, но числа не приводит. Поэтому выбор оставлен
-- тумблером, а не решён за пользователя.
local function AffordableGem(primary, stat)
    BuildGemIndex()
    local best, bestVal
    for _, g in ipairs(ns.Gems or {}) do
        if g.socket == "prismatic" and not g.unique and g.stats
            and g.stats[primary] and g.stats[stat] then
            local v = g.stats[primary] + g.stats[stat]
            if not bestVal or v > bestVal then best, bestVal = g.itemID, v end
        end
    end
    return best
end

local function GemByID(id)
    BuildGemIndex()
    return gemByID[id]
end

-- Что вставить в КАЖДОЕ гнездо предмета, по порядку socketTypes.
-- Шестерёнки считает CogwheelPicks (там своя арифметика из-за уникальности),
-- обычное гнездо и мета - берут лучший камень под топовый стат спека.
--
-- В обычное гнездо можно положить и +5 к ОСНОВНОЙ характеристике, но только
-- уникальный Профанит или Кровавый камень, по одному на персонажа. Что из
-- двух выгоднее на двадцатке - 5 основной или 5 вторички - НЕ ИЗМЕРЕНО,
-- поэтому окно советует вторичку, а уникальные идут отдельным списком.
local function GemPicks(item, w)
    local types = item.socketTypes or {}
    if #types == 0 or not w then return nil end
    local cog = CogwheelPicks(item, w)
    local cogAt = 1

    local order = {}
    for _, k in ipairs({ "crit", "haste", "vers", "iskus" }) do
        if (w[k] or 0) > 0 then order[#order + 1] = k end
    end
    table.sort(order, function(a, b) return w[a] > w[b] end)
    local top = order[1]
    if not top then return cog end

    -- Основная характеристика спека: в приоритете гайда она стоит первой,
    -- поэтому вес у неё самый большой.
    local primary
    for _, k in ipairs({ "str", "agi", "int" }) do
        if (w[k] or 0) > 0 and (not primary or w[k] > w[primary]) then primary = k end
    end

    local picks = {}
    for i, t in ipairs(types) do
        if t == "cogwheel" then
            picks[i] = cog and cog[cogAt] or nil
            cogAt = cogAt + 1
        else
            -- У шестерёнок и меты дешёвой замены нет, там всегда лучшее.
            local id
            if t == "prismatic" and not ExpensiveGems() and primary then
                id = AffordableGem(primary, top)
            end
            id = id or BestGem(t, top)
            picks[i] = id and { key = top, id = id } or nil
        end
    end
    return picks
end

-- Счёт предмета под веса статов спека. Гнёзда идут двумя отдельными частями,
-- и вторая тяжелее первой:
--   * сам камень на двадцатке даёт мелочь (GEM_VALUE);
--   * бонус за совпадение цвета - настоящий приз, он записан в базе числом
--     (socketBonus), и у шлемов это, например, +8 к скорости.
-- Раньше стояло плоское sockets * 2 без учёта весов и бонуса: предмет с тремя
-- гнёздами и бонусом +8 проигрывал тому, у кого просто статы чуть выше.
-- Роль вещи глава гильдии размечает прямо в заметке. Три категории из гайда,
-- плюс четвёртая — без пометки — это «Универсальные» (годятся всем):
--   [ДД]  → DAMAGER   [Танк] → TANK   [Хил] → HEALER
-- Строки роли — как у GetSpecializationRoleByID, чтобы сравнивать напрямую.
-- Пометка есть только у аксессуаров, у остальных вещей её нет и не нужно.
local NOTE_ROLE = { ["[Танк]"] = "TANK", ["[ДД]"] = "DAMAGER", ["[Хил]"] = "HEALER" }
local function NoteRole(item)
    local n = item.note or ""
    for tag, role in pairs(NOTE_ROLE) do
        if n:find(tag, 1, true) then return role end
    end
    return nil -- без пометки: «Универсальные», годится любой роли
end

-- Аксессуар чужой роли в сборку не пускаем. Хил — отдельная роль: ему не
-- годится ни [ДД], ни [Танк], только [Хил] и вещи без пометки. Так Талисман
-- Хаоса ([ДД]) больше не попадает жрецу-хилу в «Аксессуар 2», хотя по статам
-- проходил (искусность 9).
local function RoleAllowed(item, role)
    local want = NoteRole(item)
    if not want or not role then return true end -- нет пометки или роль неизвестна
    return want == role
end

local function ScoreItem(item, w)
    if not w then return 0 end
    local s = 0
    for key, val in pairs(item.stats or {}) do
        s = s + val * (w[key] or 0)
    end
    -- Гнездо стоит столько, сколько даёт лучший камень, который туда влезет.
    -- А камни разного типа умеют РАЗНОЕ, и это решает:
    --   * шестерёнки и мета дают только вторички — основную в них не положить,
    --     поэтому считаем по лучшей ВТОРИЧКЕ, а не по максимальному весу;
    --   * в бесцветное влезет либо алгарийский +5 по вторичке, либо старый
    --     +3 по основной — берём то, что для спека дороже;
    --   * у мета настоящие статы есть только у Плотного неуравновешенного
    --     алмаза, и это +12 КРИТА, поэтому вес берём именно критовый.
    local bestMain, bestSec = 0, 0
    for _, k in ipairs({ "str", "agi", "int" }) do
        if (w[k] or 0) > bestMain then bestMain = w[k] end
    end
    for _, k in ipairs({ "crit", "haste", "vers", "iskus" }) do
        if (w[k] or 0) > bestSec then bestSec = w[k] end
    end
    local perType = {
        prismatic = math.max(SOCKET_VALUE.prismatic * bestSec, 3 * bestMain),
        cogwheel  = SOCKET_VALUE.cogwheel * bestSec,
        meta      = SOCKET_VALUE.meta * (w.crit or 0),
    }
    local types = item.socketTypes
    if types and #types > 0 then
        for _, t in ipairs(types) do
            s = s + (perType[t] or perType.prismatic)
        end
    else
        s = s + (item.sockets or 0) * perType.prismatic
    end
    local sb = item.socketBonus
    if sb and sb.value then s = s + sb.value * (w[sb.key] or 0) end
    return s
end

-- ---------------------------------------------------------------------------
-- Окно
-- ---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local S = ns.Style or {} -- палитра и скруглённые текстуры из Core.lua
local C = S.C or {}
local GOLD = C.gold or { 1.0, 0.82, 0.0 } -- как цвет подземелий в основном окне
-- 366 не хватало: длинные названия с пометкой («Рукавицы Железного лезвия
-- выше гайда») обрезались многоточием, и вкладки спеков тоже жались.
-- 470 - примерно половина основного окна (880), масштаб текста один и тот же.
local PANEL_W = 500
-- Насколько панель заезжает ПОД основное окно. Больше радиуса скругления
-- картинки (10), поэтому правые углы панели и левая рамка окна оказываются
-- накрыты - на стыке ни щели, ни вмятин, два окна читаются как одно.
-- Содержимое панели отступает на столько же, чтобы не залезть за стык.
local SEAM = 12
local HEADER_H = 30
local CLASS_COL_W = 44 -- 8:>=:0 36 ?;NA 7>;>B>5 :>;LF> +4 ?> :@0O<
-- 16 AB@>: 4>;6=K C<5AB8BLAO <564C AB@>:>9 ?@8>@8B5B0 8 ?>4?8ALN 2=87C:
-- ?@8 2KA>B5 >:=0 632 =0 A?8A>: >AB0QBAO >:>;> 462 B>G5:, 462/16 = 28.
local ROW_H = 28
local CLASS_ICON = 36

local panel, arrow
local state = { classID = nil, classFile = nil, specID = nil }
local SelectClass -- forward

local function IsCollapsed()
    return TrialGearFinderDB and TrialGearFinderDB.bisCollapsed
end

local function MakeSlotRow(parent, index, y)
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    -- Чередование строк блоком палитры, как в основном окне.
    local zebra = row:CreateTexture(nil, "BACKGROUND")
    zebra:SetAllPoints()
    if index % 2 == 0 and C.block2 then
        zebra:SetColorTexture(C.block2[1], C.block2[2], C.block2[3], 0.5)
    else
        zebra:SetColorTexture(0, 0, 0, 0)
    end
    row.hl = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.hl:SetAllPoints()
    local w = C.warm or { 0.85, 0.72, 0.42 }
    row.hl:SetColorTexture(w[1], w[2], w[3], 0.10)
    row.hl:Hide()

    -- Шрифт и иконка как в основном окне (там GameFontNormal и значок 32):
    -- при мелком шрифте панель выглядела вдвое «легче» соседа. Иконка меньше
    -- тридцати двух, потому что строк шестнадцать и они должны уместиться
    -- в высоту окна.
    row.slotFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.slotFS:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.slotFS:SetWidth(84) -- «Аксессуар 1» крупным шрифтом в 72 не влезало
    row.slotFS:SetJustifyH("LEFT")
    local t3 = C.text3 or { 0.49, 0.52, 0.56 }
    row.slotFS:SetTextColor(t3[1], t3[2], t3[3])

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(22, 22)
    row.icon:SetPoint("LEFT", row.slotFS, "RIGHT", 4, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon:Hide()

    -- Зелёная галочка: этот предмет сейчас надет.
    row.check = row:CreateTexture(nil, "OVERLAY")
    row.check:SetSize(14, 14)
    row.check:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.check:SetAtlas("common-icon-checkmark")
    row.check:Hide()

    row.valueFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.valueFS:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    row.valueFS:SetPoint("RIGHT", row, "RIGHT", -22, 0)
    row.valueFS:SetJustifyH("LEFT")
    row.valueFS:SetWordWrap(false)

    row:SetScript("OnEnter", function(self)
        if not self.itemID then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.hyperlink or ("item:" .. self.itemID))
        -- Те же завышенные статы, что и в основном окне: клиент масштабирует
        -- старые вещи неточно, эталон - армори, он же в базе. Общая правка
        -- живёт в Core.lua (ns.FixTooltipStats) - до 12 сентября её звало
        -- только основное окно, и Шлем удара духа показывал 6/8/5 там
        -- и 7/10/6 здесь.
        if ns.FixTooltipStats then ns.FixTooltipStats(self.entry and self.entry.stats) end
        if self.entry then
            GameTooltip:AddLine(" ")
            if communityId[self.itemID] then
                GameTooltip:AddLine("Пред-BiS от сообщества — не из гайда гильдии, но выбить может любой.", 0.85, 0.72, 0.42, true)
            end
            if self.entry.source then
                GameTooltip:AddLine("Источник: " .. self.entry.source, 0.55, 0.78, 1, true)
            end
            if self.entry.note then
                GameTooltip:AddLine(self.entry.note, 0.7, 0.7, 0.7, true)
            end
            -- Рекомендованные шестерёнки для Дракончика показывать отдельной
            -- строкой больше не нужно: они теперь вставлены в саму ссылку
            -- (see RenderRow), и клиент уже нарисовал их гнёздами выше -
            -- дублировать текстом означало бы повторяться.
        end
        GameTooltip:Show()
    end)
    row:HookScript("OnEnter", function(self) if self.itemID then self.hl:Show() end end)
    row:SetScript("OnLeave", function(self)
        self.hl:Hide()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if self.itemLink and IsShiftKeyDown() and ChatEdit_InsertLink then
            ChatEdit_InsertLink(self.itemLink)
        end
    end)
    return row
end

-- mark - откуда взялся предмет сообщества в этом слоте:
--   "gap"  - гайд этот слот вообще не закрывает (шея, кольца);
--   "beat" - гайд закрывает, но вещь сообщества обошла его по статам;
--   nil    - предмет из гайда, помечать нечего.
local function RenderRow(row, slot, item, mark)
    row.slotFS:SetText(slot.name)
    row.entry = item
    row.itemID = item and item.itemID or nil
    row.hyperlink = nil
    row.itemLink = nil
    if not item then
        row.icon:Hide()
        row.check:Hide()
        row.valueFS:SetText("—")
        row.valueFS:SetTextColor(0.4, 0.4, 0.42)
        return
    end
    local id = item.itemID
    -- Ссылка с bonusIDs и триальным уровнем — иначе тултип покажет вещь
    -- базового уровня (13-17) с требованием «22-й уровень». Тот же приём,
    -- что в основном окне (Core.lua BuildItemLink).
    --
    -- У шестерёночных гнёзд (Дракончик) вставляем рекомендованные камни
    -- по-настоящему, не текстом поверх: тогда клиент сам рисует строку
    -- статов и цвет гнезда, вместо пустых «гнездо для зубчатого колеса».
    local gems
    local picks = GemPicks(item, ParsePriority(ns.BiSPriority and ns.BiSPriority[state.specID]))
    if picks then
        gems = {}
        -- Дырки в середине быть не должно: ссылка читает камни по позициям,
        -- пропуск сдвинул бы остальные в чужие гнёзда.
        for i = 1, #(item.socketTypes or {}) do
            gems[i] = picks[i] and picks[i].id or 0
        end
    end
    local link = ns.BuildItemLink and ns.BuildItemLink(id, item.bonusIDs or {}, gems) or ("item:" .. id)
    row.hyperlink, row.itemLink = link, link

    local _, _, _, _, icon = C_Item.GetItemInfoInstant(id)
    row.icon:SetTexture(icon or 134400)
    row.icon:Show()

    local invName = SLOT_INV[slot.key]
    local sid = invName and GetInventorySlotInfo(invName)
    row.check:SetShown(sid ~= nil and GetInventoryItemID("player", sid) == id)

    row.valueFS:SetText("…")
    row.valueFS:SetTextColor(0.7, 0.7, 0.7)
    local mixin = Item:CreateFromItemLink(link)
    mixin:ContinueOnItemLoad(function()
        if row.itemID ~= id then return end
        local label = mixin:GetItemName() or ("item:" .. id)
        -- Предмет от сообщества, не из гайда главы гильдии. Разделяем два
        -- случая: гайд слот не закрывает вовсе - или закрывает, но эта вещь
        -- посчиталась лучше. Второе и есть ответ «что даёт комьюнити».
        if communityId[id] then
            if mark == "beat" then
                label = label .. "  |cff5fd35fвыше гайда|r"
            elseif mark == "gap" then
                label = label .. "  |cff9a9a9aнет в гайде|r"
            else
                label = label .. "  |cff9a9a9aпред-BiS|r"
            end
        end
        -- Тайм Волк: вещь только из недели Путешествий во времени. Отдельной
        -- меткой, потому что это про доступность, а не про источник данных.
        if ns.IsTimewalk(item) then
            label = label .. "  |cff3fc7ebТайм Волк|r"
        end
        row.valueFS:SetText(label)
        local q = mixin:GetItemQualityColor()
        if q then row.valueFS:SetTextColor(q.r, q.g, q.b) end
        local ic = mixin:GetItemIcon()
        if ic then row.icon:SetTexture(ic) end
    end)
end

-- Сколько рейтинга = 30% стата на двадцатке. Это СОФТКАП: до него штрафа нет,
-- после каждая следующая единица рейтинга даёт на 10% меньше, и дальше по
-- лестнице (39% -20%, 47% -30% и так далее, 126% - хардкап).
--
-- Числа из статьи гильдии «Характеристики»
-- (forsaken.ucoz.net/publ/guides/kharakteristiki/1-1-0-33), разбор -
-- вики «Софткапы Вторичек». Проценты у спеков разные, пороги общие.
local SOFTCAP = { crit = 132.96, haste = 127.18, vers = 156.08, iskus = 132.96 }

-- Что вещь даёт в сумму сборки: свои статы, камни в её гнёздах и бонус
-- за совпадение цвета. Бонус берём как данность: гнёзда мы заполняем сами,
-- а обычный камень подходит к любому цвету.
local function AddContribution(total, item, w)
    if not item then return end
    for k, v in pairs(item.stats or {}) do total[k] = (total[k] or 0) + v end
    local picks = GemPicks(item, w)
    for _, p in ipairs(picks or {}) do
        local gem = p and p.id and GemByID(p.id)
        for k, v in pairs(gem and gem.stats or {}) do total[k] = (total[k] or 0) + v end
    end
    local sb = item.socketBonus
    if sb and sb.key and (item.sockets or 0) > 0 then
        total[sb.key] = (total[sb.key] or 0) + sb.value
    end
end

local function RenderSlots()
    local buckets = state.classFile and BuildBuckets(state.classFile) or {}
    local w = ParsePriority(ns.BiSPriority and ns.BiSPriority[state.specID])
    local total = {}

    local role = state.specID and GetSpecializationRoleByID
        and GetSpecializationRoleByID(state.specID) or nil

    local ranked = {}
    for slotKey, items in pairs(buckets) do
        local copy = {}
        for _, it in ipairs(items) do
            if RoleAllowed(it, role) then copy[#copy + 1] = it end
        end
        table.sort(copy, function(a, b) return ScoreItem(a, w) > ScoreItem(b, w) end)
        ranked[slotKey] = copy
    end

    -- Лучший счёт среди вещей ГАЙДА в этом котле. nil - гайд слот не закрывает.
    -- Список уже отсортирован, поэтому достаточно первой не-комьюнити записи.
    local function BestGuideScore(list)
        for _, it in ipairs(list or {}) do
            if not communityId[it.itemID] then return ScoreItem(it, w) end
        end
        return nil
    end

    -- Чем помечать выбранную вещь сообщества: дырой в гайде или превосходством.
    local function MarkFor(list, pick)
        if not (pick and communityId[pick.itemID]) then return nil end
        local best = BestGuideScore(list)
        if best == nil then return "gap" end
        return ScoreItem(pick, w) > best and "beat" or nil
    end

    local mhIs2H = false
    for i, slot in ipairs(SLOTS) do
        local row = panel.slotRows[i]
        local bkey = PAIR_BUCKET[slot.key] or slot.key
        local list = ranked[bkey]
        local idx = (slot.key == "FINGER2" or slot.key == "TRINKET2") and 2 or 1
        local pick = list and (list[idx] or list[1]) or nil

        -- Ручная поправка поверх авторанжирования.
        local ov = SlotOverride(state.classFile, state.specID, slot.key)
        if ov == false then
            pick = nil
        elseif ov then
            local forced = ItemByID(ov)
            -- Поправка указывает на вещь сообщества, а тумблер выключен:
            -- поправку игнорируем и оставляем лучшее из гайда по весам спека.
            if forced and communityId[ov] and not CommunityOn() then forced = nil end
            pick = forced or pick
        end

        if slot.key == "OFFHAND" and ov == nil then
            if DUAL_2H_SPEC[state.specID] then
                -- Тот же лучший двуручник во вторую руку: на двадцатке BiS —
                -- две копии одного оружия, а не первое+второе.
                local mh = ranked["MAINHAND"]
                pick = mh and mh[1] or nil
                RenderRow(row, slot, pick, MarkFor(ranked["MAINHAND"], pick))
                AddContribution(total, pick, w) -- Titan's Grip: вторая копия считается
            elseif mhIs2H then
                RenderRow(row, slot, nil)
                row.valueFS:SetText("— двуручное")
                -- Двуручник уже посчитан в правой руке, второй раз не берём.
            else
                RenderRow(row, slot, pick, MarkFor(list, pick))
                AddContribution(total, pick, w)
            end
        else
            RenderRow(row, slot, pick, MarkFor(list, pick))
            AddContribution(total, pick, w)
        end
        -- MAINHAND идёт раньше OFFHAND в SLOTS, флаг успеет проставиться.
        if slot.key == "MAINHAND" then
            mhIs2H = pick ~= nil and twoHandID[pick.itemID] == true
        end
    end

    -- Итог сборки: шмот плюс камни, которые окно само и советует. Считаем
    -- здесь, а не в ScoreItem: счёт ранжирует ОДНУ вещь, а перебор вторички
    -- бывает только у сборки целиком.
    if panel.totalsFS then
        local PRIMARY = { { "str", "сила" }, { "agi", "ловкость" }, { "int", "интеллект" }, { "stam", "вын" } }
        local SECOND  = { { "crit", "крит" }, { "haste", "скор" }, { "vers", "верса" }, { "iskus", "иск" } }
        local left, right, over = {}, {}, false
        for _, p in ipairs(PRIMARY) do
            local v = total[p[1]]
            if v and v > 0 then left[#left + 1] = p[2] .. " " .. v end
        end
        for _, p in ipairs(SECOND) do
            local v = total[p[1]] or 0
            if v > 0 then
                local pct = v * 30 / SOFTCAP[p[1]]
                local s = string.format("%s %d (%.1f%%)", p[2], v, pct)
                if pct >= 30 then
                    over = true
                    s = "|cffE06C5E" .. s .. "|r" -- перебор: дальше рейтинг слабеет
                end
                right[#right + 1] = s
            end
        end
        local line = table.concat(left, " · ")
        if #right > 0 then line = line .. "   |   " .. table.concat(right, " · ") end
        if over then
            line = line .. "\n|cffE06C5EПеребор: после 30% каждая единица рейтинга даёт на 10% меньше|r"
        end
        panel.totalsFS:SetText(line ~= "" and ("Итог сборки: " .. line) or "")
    end
end

local function ClearSpecTabs()
    for _, t in ipairs(panel.specTabs or {}) do t:Hide() end
end

local function SelectSpec(specID)
    state.specID = specID
    -- Выбранная вкладка — золотой обводкой и текстом, как подземелья
    -- в основном окне. Тонкая заливка 0.14 была почти не видна.
    local border = C.border or { 0.25, 0.25, 0.28 }
    local t2 = C.text2 or { 0.85, 0.85, 0.88 }
    for _, t in ipairs(panel.specTabs or {}) do
        local on = t.specID == specID
        t.sel:SetShown(on)
        if t.edge then
            if on then
                t.edge:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 1)
            else
                t.edge:SetVertexColor(border[1], border[2], border[3], 1)
            end
        end
        if on then
            t.label:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
        else
            t.label:SetTextColor(t2[1], t2[2], t2[3])
        end
    end
    -- Приоритет статов — из гайда гильдии (BiS_Data.lua), дословно.
    local prio = ns.BiSPriority and ns.BiSPriority[specID]
    panel.priorityFS:SetText(prio and ("Статы: " .. prio) or "")
    RenderSlots()
end

local function BuildSpecTabs(classID)
    ClearSpecTabs()
    panel.specTabs = panel.specTabs or {}
    local specs = SpecsForClass(classID)
    local n = #specs
    -- Ширина вкладки — чтобы все спеки поместились в один ряд. Друид с 4
    -- спеками ужимается сильнее прочих; длинное имя обрезается.
    local usable = panel.tabAnchor:GetWidth()
    if not usable or usable < 10 then usable = PANEL_W - (CLASS_COL_W + 16) - 8 end
    local gap = 3
    local tabW = math.max(52, math.floor((usable - (n - 1) * gap) / math.max(1, n)))
    local x = 0
    for i, spec in ipairs(specs) do
        local tab = panel.specTabs[i]
        if not tab then
            tab = CreateFrame("Button", nil, panel)
            tab.body, tab.edge = nil, nil
            if S.RoundedPanel then
                tab.body, tab.edge = S.RoundedPanel(tab, C.block2, C.border)
            end
            tab.sel = tab:CreateTexture(nil, "BACKGROUND", nil, 2)
            tab.sel:SetPoint("TOPLEFT", 1, -1)
            tab.sel:SetPoint("BOTTOMRIGHT", -1, 1)
            tab.sel:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.16)
            tab.sel:Hide()
            tab.icon = tab:CreateTexture(nil, "ARTWORK")
            tab.icon:SetSize(16, 16)
            tab.icon:SetPoint("LEFT", tab, "LEFT", 4, 0)
            tab.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            tab.label:SetPoint("LEFT", tab.icon, "RIGHT", 3, 0)
            tab.label:SetPoint("RIGHT", tab, "RIGHT", -2, 0)
            tab.label:SetJustifyH("LEFT")
            tab.label:SetWordWrap(false)
            panel.specTabs[i] = tab
        end
        tab.specID = spec.specID
        tab:SetSize(tabW, 26)
        tab.icon:SetTexture(spec.icon or 134400)
        tab.label:SetText(spec.name)
        tab.label:SetShown(tabW >= 64) -- совсем узкие вкладки — только иконка
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", panel.tabAnchor, "TOPLEFT", x, 0)
        tab:SetScript("OnClick", function() SelectSpec(spec.specID) end)
        tab:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(spec.name)
            GameTooltip:Show()
        end)
        tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
        tab:Show()
        x = x + tabW + gap
    end
    return specs
end

SelectClass = function(classID, classFile, preferSpecID)
    if not panel then return end
    state.classID, state.classFile = classID, classFile
    for _, b in ipairs(panel.classButtons or {}) do
        b.ring:SetShown(b.classID == classID)
    end
    local r, g, b = ClassColor(classFile)
    panel.classTitle:SetText(ClassName(classID))
    panel.classTitle:SetTextColor(r, g, b)

    local specs = BuildSpecTabs(classID)
    local chosen = preferSpecID
    local ok = false
    for _, s in ipairs(specs) do if s.specID == chosen then ok = true break end end
    if not ok then chosen = specs[1] and specs[1].specID end
    if chosen then SelectSpec(chosen) end
end

local function Populate()
    if not panel then return end
    local classFile, classID, specID = PlayerClassSpec()
    if classID then
        SelectClass(classID, classFile, specID)
    elseif not state.classID and panel.classButtons[1] then
        local b = panel.classButtons[1]
        SelectClass(b.classID, b.classFile)
    end
end

-- Скруглённая заливка с рамкой — из хелпера Core.lua, а если его нет (старый
-- Core), просто сплошной цвет с бордюром.
local function Bevel(frame, fill, border)
    if S.RoundedPanel then
        return S.RoundedPanel(frame, fill, border)
    end
    frame:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    frame:SetBackdropColor(fill[1], fill[2], fill[3], 1)
    frame:SetBackdropBorderColor(border[1], border[2], border[3], 1)
end

local function BuildPanel()
    if panel then return panel end
    local main = _G[MAIN]
    if not main then return end

    -- Дочерний основного окна: скрывается вместе с ним, ничего не остаётся
    -- на экране. Той же высоты, уровнем выше окна, чтобы чат за ним
    -- не просвечивал.
    --
    -- Заезжает на SEAM вправо, ПОД основное окно: так накрываются и свои
    -- правые скруглённые углы, и чужая левая рамка. Иначе на стыке видно
    -- то две линии подряд, то вмятины от скругления.
    panel = CreateFrame("Frame", "TrialGearFinderBiSFrame", main, "BackdropTemplate")
    panel:SetWidth(PANEL_W + SEAM)
    panel:SetPoint("TOPRIGHT", main, "TOPLEFT", SEAM, 0)
    panel:SetPoint("BOTTOMRIGHT", main, "BOTTOMLEFT", SEAM, 0)
    panel:SetFrameLevel(main:GetFrameLevel() + 2)
    panel:EnableMouse(true) -- иначе клики проваливаются на мир за окном

    -- Панель — визуально часть окна, поэтому таскать её должно двигать всю
    -- связку. Своего SetMovable у панели нет: двигаем основное окно, панель
    -- за ним следует как дочерняя. Строки списка ловят мышь сами и сюда
    -- перетаскивание не доходит - это и нужно, тянут за пустое поле и рамку.
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function() main:StartMoving() end)
    panel:SetScript("OnDragStop", function() main:StopMovingOrSizing() end)

    -- Скругление слева, прямой край справа.
    --
    -- Правым маргином среза это НЕ делается: середина 9-среза тогда тянется
    -- из области, куда попадают правые скруглённые углы картинки, и на стыке
    -- сверху и снизу вылезали вмятины (проверено в игре 10 сентября).
    -- Маргины остаются честные 10/10/10/10, а правые углы просто закрываются
    -- сверху прямой заплаткой; линии рамки над и под ней дорисовываются.
    local bgcol = C.bg or { 0.02, 0.03, 0.03 }
    local brd = C.border or { 0.18, 0.20, 0.22 }
    if S.RoundedTexture then
        local edge = S.RoundedTexture(panel, "BACKGROUND", brd, 0)
        edge:SetAllPoints()
        local body = S.RoundedTexture(panel, "BACKGROUND", bgcol, 1)
        body:SetPoint("TOPLEFT", panel, "TOPLEFT", 1, -1)
        body:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -1, 1)

        -- Заплатка ровно в ширину захода под окно: она и выпрямляет правый
        -- край, и лежит поверх левой рамки основного окна.
        local patch = panel:CreateTexture(nil, "BACKGROUND", nil, 2)
        patch:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
        patch:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
        patch:SetWidth(SEAM)
        patch:SetColorTexture(bgcol[1], bgcol[2], bgcol[3], 1)
        -- Рамку продолжаем сверху и снизу до самого края - тогда верх и низ
        -- идут одной прямой через оба окна. Справа рамки нет: там середина.
        for _, side in ipairs({ "TOP", "BOTTOM" }) do
            local line = panel:CreateTexture(nil, "BACKGROUND", nil, 3)
            line:SetHeight(1)
            line:SetWidth(SEAM)
            line:SetPoint(side .. "RIGHT", panel, side .. "RIGHT", 0, 0)
            line:SetColorTexture(brd[1], brd[2], brd[3], 1)
        end
    else
        local pbg = panel:CreateTexture(nil, "BACKGROUND")
        pbg:SetAllPoints()
        pbg:SetColorTexture(bgcol[1], bgcol[2], bgcol[3], 1)
        if S.AddBorder then
            local sides = S.AddBorder(panel, brd)
            if sides and sides.RIGHT then sides.RIGHT:Hide() end
        end
    end

    -- Шапка — скруглённый блок, как заголовок основного окна.
    -- Отступ сверху ровно 8, как у titleBg в Core.lua: верх у обоих окон
    -- на одной высоте, и при шестёрке этот блок торчал на два пикселя выше
    -- соседнего — на стыке это читалось бугорком.
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -8)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(6 + SEAM), -8)
    header:SetHeight(HEADER_H)
    Bevel(header, C.block or { 0.06, 0.07, 0.08 }, C.border or { 0.18, 0.20, 0.22 })
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", header, "CENTER", 0, 0)
    title:SetText("BiS-сборки")
    if C.text then title:SetTextColor(C.text[1], C.text[2], C.text[3]) end

    -- Колонка классов — во всю высоту панели, иконки круглые.
    local classCol = CreateFrame("Frame", nil, panel)
    classCol:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
    classCol:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 6, 8)
    classCol:SetWidth(CLASS_COL_W)

    panel.classButtons = {}
    local classes = AllClasses()
    local colH = main:GetHeight() - HEADER_H - 30
    local step = (colH - CLASS_ICON) / math.max(1, #classes - 1)
    local cy = 0
    for _, cls in ipairs(classes) do
        local btn = CreateFrame("Button", nil, classCol)
        btn:SetSize(CLASS_ICON, CLASS_ICON)
        btn:SetPoint("TOP", classCol, "TOP", 0, cy)
        btn.classID, btn.classFile = cls.classID, cls.classFile

        local ic = btn:CreateTexture(nil, "ARTWORK")
        ic:SetPoint("CENTER")
        ic:SetSize(CLASS_ICON - 4, CLASS_ICON - 4)
        if GetClassAtlas then ic:SetAtlas(GetClassAtlas(cls.classFile)) end
        if S.CIRCLE and btn.CreateMaskTexture then
            local mask = btn:CreateMaskTexture()
            mask:SetTexture(S.CIRCLE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(ic)
            ic:AddMaskTexture(mask)
        end

        -- Кольцо выбранного класса: круг чуть больше иконки, золотом.
        local ring = btn:CreateTexture(nil, "BACKGROUND")
        ring:SetPoint("CENTER")
        ring:SetSize(CLASS_ICON + 4, CLASS_ICON + 4)
        if S.CIRCLE then ring:SetTexture(S.CIRCLE) else ring:SetColorTexture(1, 1, 1, 1) end
        ring:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 1)
        ring:Hide()
        btn.ring = ring

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local r, g, b = ClassColor(self.classFile)
            GameTooltip:AddLine(ClassName(self.classID), r, g, b)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        btn:SetScript("OnClick", function(self) SelectClass(self.classID, self.classFile) end)

        panel.classButtons[#panel.classButtons + 1] = btn
        cy = cy - step
    end

    local contentX = CLASS_COL_W + 16

    -- Заголовок класса + якорь для вкладок спеков
    panel.classTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.classTitle:SetPoint("TOPLEFT", header, "BOTTOMLEFT", CLASS_COL_W + 10, -6)

    panel.tabAnchor = CreateFrame("Frame", nil, panel)
    panel.tabAnchor:SetPoint("TOPLEFT", panel, "TOPLEFT", contentX, -(HEADER_H + 34))
    panel.tabAnchor:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(8 + SEAM), -(HEADER_H + 34))
    panel.tabAnchor:SetHeight(22)

    -- Строка приоритета статов
    panel.priorityFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.priorityFS:SetPoint("TOPLEFT", panel.tabAnchor, "BOTTOMLEFT", 0, -8)
    panel.priorityFS:SetPoint("TOPRIGHT", panel.tabAnchor, "BOTTOMRIGHT", 0, -8)
    panel.priorityFS:SetJustifyH("LEFT")
    panel.priorityFS:SetWordWrap(true)
    local warm = C.warm or { 0.85, 0.72, 0.42 }
    panel.priorityFS:SetTextColor(warm[1], warm[2], warm[3])

    -- Список слотов
    local list = CreateFrame("Frame", nil, panel)
    list:SetPoint("TOPLEFT", panel.priorityFS, "BOTTOMLEFT", 0, -10)
    list:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -(8 + SEAM), 40)
    panel.slotRows = {}
    local ry = 0
    for i = 1, #SLOTS do
        panel.slotRows[i] = MakeSlotRow(list, i, ry)
        ry = ry - ROW_H
    end

    -- Тумблер «Дорогие камни». Выключен (по умолчанию) - в гнёзда идут
    -- аметрины и их родня: слабее на единицу, но стоят в 20 раз дешевле,
    -- и именно их носит гильдия. Включён - алгарийские +5.
    local gemToggle = CreateFrame("CheckButton", "TrialGearFinderGemToggle", panel, "UICheckButtonTemplate")
    gemToggle:SetSize(22, 22)
    if S.CheckBox then S.CheckBox(gemToggle, 10) end
    gemToggle.label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gemToggle.label:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 32, 38)
    gemToggle.label:SetText("Дорогие камни")
    gemToggle.label:SetTextColor(C.text2[1], C.text2[2], C.text2[3])
    gemToggle:SetPoint("RIGHT", gemToggle.label, "LEFT", -4, 0)
    gemToggle:SetChecked(ExpensiveGems())
    gemToggle:SetScript("OnClick", function(self)
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB.bestGems = not TrialGearFinderDB.bestGems
        self:SetChecked(ExpensiveGems())
        RenderSlots()
    end)
    gemToggle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Дорогие камни")
        GameTooltip:AddLine("Выключено: камни на 2 к основной и 2 к вторичке — аметрины и их родня, 100-200 золота. Их носят 30% гильдии.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("Включено: алгарийские самоцветы +5 к вторичке, 2-5 тысяч золота. Носят 5%.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    gemToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
    panel.gemToggle = gemToggle

    -- Итог сборки: сумма статов со шмота и советуемых камней, с пометкой
    -- перебора вторички. Живёт в том же зазоре внизу, что и подпись.
    panel.totalsFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.totalsFS:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 20)
    panel.totalsFS:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -(8 + SEAM), 20)
    panel.totalsFS:SetJustifyH("LEFT")
    panel.totalsFS:SetSpacing(2)
    do
        local t2 = C.text2 or { 0.85, 0.85, 0.88 }
        panel.totalsFS:SetTextColor(t2[1], t2[2], t2[3])
    end

    local footer = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOM", panel, "BOTTOM", 0, 6)
    footer:SetText("раскладка адаптирована из Cap20 (MIT), автор Kkthnx")
    local t3 = C.text3 or { 0.4, 0.4, 0.42 }
    footer:SetTextColor(t3[1] * 0.8, t3[2] * 0.8, t3[3] * 0.8)

    return panel
end

-- Язычок на стыке окон: сворачивает и разворачивает панель.
local function UpdateArrow()
    if not arrow then return end
    -- свёрнуто → «<» (открыть, панель слева); развёрнуто → «>» (свернуть)
    arrow.glyph:SetText(IsCollapsed() and "<" or ">")
end

-- Два окна вместе шире одного, и на узком экране панель уезжала бы за край.
-- Ужимаем ОБА одним масштабом: панель - дитя основного окна, поэтому хватает
-- масштабировать его. Свёрнута - масштаб возвращаем, окно снова во всю величину.
--
-- Ниже 0.6 не опускаемся: мельче текст уже не прочитать, пусть лучше вылезет
-- за край - окно можно подвинуть мышью.
local MIN_SCALE = 0.6
local function FitToScreen()
    local main = _G[MAIN]
    if not main then return end
    if IsCollapsed() then main:SetScale(1) return end
    local have = UIParent:GetWidth()
    local need = main:GetWidth() + PANEL_W
    if not (have and need and need > 0) then return end
    local s = have / need
    main:SetScale(s < 1 and math.max(MIN_SCALE, s) or 1)
end

local function ApplyCollapsed()
    if panel then panel:SetShown(not IsCollapsed()) end
    FitToScreen()
    UpdateArrow()
end

local function SetCollapsed(collapsed)
    TrialGearFinderDB = TrialGearFinderDB or {}
    TrialGearFinderDB.bisCollapsed = collapsed and true or nil
    if not collapsed then
        local main = _G[MAIN]
        if main and not main:IsShown() then main:Show() end
        if not panel then BuildPanel() end
        Populate()
    end
    ApplyCollapsed()
end

local function Toggle()
    SetCollapsed(not IsCollapsed())
end

local function MakeArrow()
    local main = _G[MAIN]
    if not main or arrow then return end
    -- Язычок на левой кромке основного окна. Дочерний UIParent (не main и не
    -- панель), самой верхней стратой — иначе панель, которая тоже наверху,
    -- его перекрывала. Показ/скрытие — вместе с основным окном.
    -- Дочерний основного окна: сам скрывается/показывается вместе с ним,
    -- ничего не остаётся на экране после закрытия. Страта выше панели
    -- (та на DIALOG) — тогда язычок поверх неё и без хуков show/hide.
    -- Прижат к левой кромке изнутри: смещение равно своей ширине, поэтому
    -- левый край язычка совпадает с левым краем окна и наружу ничего
    -- не торчит. Было 8 - вылезал на шесть пикселей и висел в пустоте.
    arrow = CreateFrame("Button", nil, main)
    arrow:SetSize(14, 36)
    arrow:SetPoint("RIGHT", main, "LEFT", 14, 0)
    arrow:SetFrameStrata("FULLSCREEN_DIALOG")
    Bevel(arrow, C.block or { 0.06, 0.07, 0.08 }, C.border or { 0.18, 0.20, 0.22 })

    arrow.glyph = arrow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    arrow.glyph:SetPoint("CENTER", 0, 0)
    arrow.glyph:SetTextColor(GOLD[1], GOLD[2], GOLD[3]) -- золотом, как прежняя стрелка

    arrow:SetScript("OnClick", Toggle)
    arrow:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(IsCollapsed() and "Открыть BiS-сборки" or "Свернуть BiS-сборки")
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Основное окно уже создано (Core.lua грузится раньше). Панель — дочерний
-- UIParent, поэтому за окном не следует сама: показ/скрытие вешаем хуками.
local main = _G[MAIN]
if main then
    MakeArrow() -- дочерний main, скрывается вместе с ним
    main:HookScript("OnShow", function()
        if not IsCollapsed() then
            if not panel then BuildPanel() end
            Populate()
        end
        ApplyCollapsed()
    end)
    if main:IsShown() then
        if not IsCollapsed() then BuildPanel(); Populate() end
        ApplyCollapsed()
    end
end

ns.ToggleBiS = Toggle

-- Зовёт основное окно, когда переключили тумблер «Комьюнити»: он один на оба
-- окна, а состав котлов от него зависит - готовые кэши надо выбросить.
ns.RefreshBiS = function()
    bucketCache = {}
    if not (panel and panel:IsShown()) then return end
    -- Пересобираем ТУ ЖЕ вкладку, а не прыгаем на свой класс: Populate зовёт
    -- PlayerClassSpec и всегда возвращает на спек игрока, а при переключении
    -- тумблера человек как раз сравнивает шмот в чужой вкладке.
    if state.classFile and state.specID then
        RenderSlots()
    else
        Populate()
    end
end
