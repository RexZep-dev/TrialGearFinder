local addonName, ns = ...

local ROW_WIDTH, ROW_HEIGHT, ROW_SPACING = 800, 46, 2
-- Шаг между строками. В расчёт прокрутки идёт именно он, а не ROW_HEIGHT:
-- строки стоят через 48 пикселей, и по 46 счёт медленно уползал.
local ROW_PITCH = ROW_HEIGHT + ROW_SPACING
-- Девятая строка занимает пустую полосу над фильтрами: окно фиксированной
-- высоты, а строк помещалось восемь, и снизу оставалась мёртвая щель ровно
-- в одну строку. Отсюда же берётся высота видимой области списка.
local NUM_VISIBLE_ROWS = 9

-- Признак ежедневного рарника: слово в тексте источника. Отсюда зависят две
-- вещи - сброс отметок на дневном сбросе и смысл самой жёлтой отметки.
-- У ежедневного она значит «приходи завтра», у того, что берётся раз
-- на персонажа, - «второго шанса не будет». Объявлен здесь, а не рядом
-- со сбросом: строки списка нужны раньше.
local DAILY_SOURCE_MARK = "раз в день"
local TWINK_LEVEL = 20

-- Подсказка на ЧУЖИХ тултипах: наводишь на любую вещь в мире, аддон ищет
-- ближайшую запись базы по слоту и показывает расхождения. Механизм написан
-- целиком, но в игре не видели ни разу.
--
-- Решение к релизу 1.0 (4 сентября 2026): оставить ВЫКЛЮЧЕННЫМ. Удалять готовую
-- работу рано, а включать перед первой выкладкой нельзя: хук цепляется к чужим
-- тултипам - самая ломкая часть аддона, и сломает он их у всех сразу.
-- Включаем и обкатываем в 1.1, когда будет кому присылать отчёты.
--
-- Флаг НЕ отключает сверку в списке и /tgf scan - они работают всегда.
local ENABLE_COMPARISON = false

-- Slot names come from the CLIENT (_G.INVTYPE_*), so on an English client the
-- whole addon showed "Cloth (Head)" instead of "Ткань (Голова)". These are ours,
-- so the window reads the same whatever language the game is installed in.
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

local SLOT_DEFS = {
    { key = "HEAD",     label = INVTYPE_RU.INVTYPE_HEAD,     invTypes = { INVTYPE_HEAD = true } },
    { key = "NECK",     label = INVTYPE_RU.INVTYPE_NECK,     invTypes = { INVTYPE_NECK = true }, hidden = true },
    { key = "SHOULDER", label = INVTYPE_RU.INVTYPE_SHOULDER, invTypes = { INVTYPE_SHOULDER = true } },
    { key = "BACK",     label = INVTYPE_RU.INVTYPE_CLOAK,    invTypes = { INVTYPE_CLOAK = true } },
    { key = "CHEST",    label = INVTYPE_RU.INVTYPE_CHEST,    invTypes = { INVTYPE_CHEST = true, INVTYPE_ROBE = true } },
    { key = "WRIST",    label = INVTYPE_RU.INVTYPE_WRIST,    invTypes = { INVTYPE_WRIST = true } },
    { key = "HANDS",    label = INVTYPE_RU.INVTYPE_HAND,     invTypes = { INVTYPE_HAND = true } },
    { key = "WAIST",    label = INVTYPE_RU.INVTYPE_WAIST,    invTypes = { INVTYPE_WAIST = true } },
    { key = "LEGS",     label = INVTYPE_RU.INVTYPE_LEGS,     invTypes = { INVTYPE_LEGS = true } },
    { key = "FEET",     label = INVTYPE_RU.INVTYPE_FEET,     invTypes = { INVTYPE_FEET = true } },
    { key = "FINGER",   label = INVTYPE_RU.INVTYPE_FINGER,   invTypes = { INVTYPE_FINGER = true }, hidden = true },
    { key = "TRINKET",  label = INVTYPE_RU.INVTYPE_TRINKET,  invTypes = { INVTYPE_TRINKET = true } },
    { key = "MAINHAND", label = INVTYPE_RU.INVTYPE_WEAPONMAINHAND, invTypes = { INVTYPE_WEAPONMAINHAND = true, INVTYPE_WEAPON = true } },
    { key = "OFFHAND",  label = INVTYPE_RU.INVTYPE_WEAPONOFFHAND,  invTypes = { INVTYPE_WEAPONOFFHAND = true, INVTYPE_HOLDABLE = true, INVTYPE_SHIELD = true } },
    { key = "TWOHAND",  label = INVTYPE_RU.INVTYPE_2HWEAPON,       invTypes = { INVTYPE_2HWEAPON = true } },
    { key = "RANGED",   label = INVTYPE_RU.INVTYPE_RANGED,         invTypes = { INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true } },
}

-- Slots marked hidden are still ranked and sorted below (SlotRank walks the full
-- list), they just do not appear in the window or in the Слот dropdown - drop the
-- hidden flag to bring a category back once its data is finished.
--
-- К релизу 1.0 скрыты обе: шеи и кольца.
-- Шеи вдобавок удалены из Data.lua целиком - 17 записей. Причина не в аддоне:
-- по гайду часть из них больше не выбить, а гнездо в них вставлялось оправой,
-- которая теперь не работает. Держать в БиС-списке вещи, которых не собрать,
-- хуже, чем не показывать слот вовсе. Записи никуда не делись, они в истории
-- git - вернуть можно, если правила снова поменяются.
-- Кольца просто ждут данных, они не собирались.
local VISIBLE_SLOT_DEFS, HIDDEN_INVTYPES = {}, {}
for _, d in ipairs(SLOT_DEFS) do
    if d.hidden then
        for invType in pairs(d.invTypes) do HIDDEN_INVTYPES[invType] = true end
    else
        table.insert(VISIBLE_SLOT_DEFS, d)
    end
end

-- Standard (no column clicked) row order: head/neck/shoulder/.../trinket first
-- in that fixed sequence, then weapons, matching SLOT_DEFS's own order.
local function SlotRank(equipLoc)
    for i, d in ipairs(SLOT_DEFS) do
        if d.invTypes[equipLoc] then return i end
    end
    return #SLOT_DEFS + 1
end

-- Запасной порядок внутри слота, когда рука не проставила rank. Оценка берётся
-- из заметки: «бисов» у 49 записей, «лучш» у 8, «хорош» и «сильн» у 25.
--
-- Это именно ЗАПАСНОЙ вариант, и он ошибается. Проверено на кожаных шлемах:
-- первым по заметке выходит Шлем странника пустошей («бисовая»), а нужен
-- Клобук Лунной поляны («хорошая»). Пробовали и мета-гнездо как признак -
-- тоже мимо, оно есть у обоих. Какая вещь лучшая в слоте, из данных
-- не выводится: это знание игры, и его проставляют полем rank вручную.
--
-- Сравнение регистрозависимое, и это допустимо: заметки в базе поголовно
-- со строчной буквы (проверено все 122).
local function NoteRank(note)
    if not note or note == "" then return 3 end
    if note:find("бисов", 1, true) or note:find("лучш", 1, true) then return 1 end
    if note:find("хорош", 1, true) or note:find("сильн", 1, true) then return 2 end
    return 3
end

-- GetItemInfo's itemType/itemSubType strings are localized (Russian client returns
-- "Броня"/"Кожа", not "Armor"/"Leather"), so classID/subclassID (numeric, always
-- the same regardless of client language) drive comparisons; these labels are for
-- display/dropdown only.
local ARMOR_CLASS_ID = 4 -- Enum.ItemClass.Armor
local ARMOR_SUBCLASSES = {
    { id = 1, label = "Ткань" },
    { id = 2, label = "Кожа" },
    { id = 3, label = "Кольчуга" },
    { id = 4, label = "Латы" },
}
-- Same reason as INVTYPE_RU: LOCALIZED_CLASS_NAMES_MALE is whatever language the
-- client is installed in. Keys match the class tokens used in Data.lua.
local CLASS_RU = {
    WARRIOR = "Воин",             PALADIN = "Паладин",
    HUNTER = "Охотник",           ROGUE = "Разбойник",
    PRIEST = "Жрец",              DEATHKNIGHT = "Рыцарь смерти",
    SHAMAN = "Шаман",             MAGE = "Маг",
    WARLOCK = "Чернокнижник",     MONK = "Монах",
    DRUID = "Друид",              DEMONHUNTER = "Охотник на демонов",
    EVOKER = "Пробудитель",
}

-- key stays in English - it's compared against item.sourceType from Data.lua.
-- Список должен покрывать ВСЕ значения sourceType из Data.lua. Не покрывал:
-- тип PvP жил в данных с самого начала, а пункта фильтра у него не было -
-- две фамильные вещи нельзя было отобрать никак, они показывались только
-- в «Все». Проверяется хуком pre-commit, чтобы не разошлось снова.
local SOURCE_TYPES = {
    { key = "Dungeon", label = "Подземелье" },
    { key = "Quest", label = "Квест" },
    { key = "World", label = "Рарники" },
    { key = "Craft", label = "Крафт" },
    { key = "PvP", label = "Фамильные вещи" },
}

local filters = { slot = "ALL", class = "ALL", armor = "ALL", sourceType = "ALL", search = "" }

-- Сторона персонажа: "Alliance" или "Horde". Заполняется на PLAYER_LOGIN -
-- до входа UnitFactionGroup возвращает nil. Пока пусто, отсева нет и видны
-- обе версии парных вещей; это безопаснее, чем спрятать обе.
local playerFaction

-- string.lower only folds ASCII a-z; Cyrillic needs its own table since WoW's
-- Lua has no Unicode-aware case conversion built in.
local CYRILLIC_UPPER_TO_LOWER = {}
do
    local upper, lower = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ", "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    local function utf8Chars(s)
        local out = {}
        for c in s:gmatch("[\1-\127\194-\244][\128-\191]*") do table.insert(out, c) end
        return out
    end
    local upperChars, lowerChars = utf8Chars(upper), utf8Chars(lower)
    for i = 1, #upperChars do
        CYRILLIC_UPPER_TO_LOWER[upperChars[i]] = lowerChars[i]
    end
end

local function FoldCase(s)
    if not s or s == "" then return "" end
    s = s:lower()
    return (s:gsub("[\1-\127\194-\244][\128-\191]*", function(c) return CYRILLIC_UPPER_TO_LOWER[c] or c end))
end

-- Item string with bonus IDs baked in, forced to twink level - used only for the
-- hover tooltip's item icon/binding/set info, chat links, and dressup. These old
-- items scale via a level curve the live client applies unpredictably, so this
-- link's OWN reported stats/ilvl are not trusted for the stat columns - those come
-- from Data.lua (scraped from Wowhead for the guide's exact bonus/ilvl combo).
local function BuildItemLink(itemID, bonusIDs)
    local bonusString = table.concat(bonusIDs, ":")
    local specID = GetSpecializationInfo(GetSpecialization() or 0) or 0
    return string.format("item:%d:0:0:0:0:0:0:0:%d:%d:0:0:%d:%s:0",
        itemID, TWINK_LEVEL, specID, #bonusIDs, bonusString)
end
ns.BuildItemLink = BuildItemLink -- окну BiS нужен тот же приём: сырой itemID
                                 -- показывает вещь низкого уровня без bonusIDs.

------------------------------------------------------------
-- Main window
------------------------------------------------------------

------------------------------------------------------------
-- Палитра. Взята с forsaken-dungeons.online, чтобы аддон и сайт выглядели
-- как одно целое. Значения - те же HEX, переведённые в доли единицы.
-- Меняешь тут - меняется во всём окне.
------------------------------------------------------------
local C = {
    bg         = { 0.024, 0.027, 0.031 }, -- #060708 основной фон
    block      = { 0.063, 0.067, 0.075 }, -- #101113 основной блок
    block2     = { 0.090, 0.098, 0.110 }, -- #17191C дополнительный блок
    border     = { 0.184, 0.200, 0.220 }, -- #2F3338 основная рамка
    borderSoft = { 0.125, 0.137, 0.157 }, -- #202328 мягкая рамка
    text       = { 0.957, 0.957, 0.961 }, -- #F4F4F5 основной текст
    text2      = { 0.682, 0.706, 0.737 }, -- #AEB4BC вторичный текст
    text3      = { 0.490, 0.522, 0.561 }, -- #7D858F приглушённый текст
    warm       = { 0.847, 0.722, 0.416 }, -- #D8B86A тёплый акцент
    cool       = { 0.525, 0.780, 0.741 }, -- #86C7BD холодный акцент
    -- Золото самой игры (NORMAL_FONT_COLOR), а не палитры сайта: им подписаны
    -- подземелья в Обзоре приключений, и названия источников должны совпадать
    -- с ними один в один. Тёплый акцент рядом смотрелся выцветшим.
    gold       = { 1.000, 0.820, 0.000 }, -- #FFD100 названия подземелий
    -- Серебро обводки портрета редкого моба. Заметно холоднее нейтрального:
    -- почти нейтральный #C6CBD2 сливался с белой подписью типа брони - оба
    -- светлые и оба без цвета, глаз их не различал. Разводим по цветности,
    -- а не по яркости, иначе серебро пришлось бы гасить до серого.
    silver     = { 0.706, 0.761, 0.831 }, -- #B4C2D4 источники-рарники
}

-- Заливка сплошным цветом из палитры.
local function Fill(texture, color, alpha)
    texture:SetColorTexture(color[1], color[2], color[3], alpha or 1)
end

-- Рамка в один пиксель из четырёх полосок: скруглений в WoW без своих текстур
-- не сделать, поэтому строгие прямые линии - как на сайте.
-- Скруглённая подложка. Движок не умеет скруглять прямоугольники - всё круглое
-- в игре это заранее нарисованные картинки. roundrect.tga (32x32, радиус 10)
-- нарисован для этого аддона; SetTextureSliceMargins растягивает середину,
-- оставляя углы нетронутыми, поэтому одна картинка годится для любого размера.
local debugOverlays = {}

local ROUND_TEXTURE = "Interface/AddOns/TrialGearFinder/roundrect"
-- Капсула для полосы прокрутки: 8x32, радиус 4 - ровно половина ширины.
-- Тянется только по высоте (маргины сверху и снизу по 4), ширина 1 в 1,
-- поэтому торцы остаются полукруглыми, а не превращаются в овал.
local PILL_TEXTURE = "Interface/AddOns/TrialGearFinder/pill"
-- Треугольник вершиной вверх. Для нижней стрелки та же картинка, перевёрнутая
-- через SetTexCoord - вторую рисовать незачем.
local ARROW_TEXTURE = "Interface/AddOns/TrialGearFinder/arrow"
-- Размер стрелок фильтров и прокрутки. Одним именем, чтобы не разъезжались.
local ARROW_SIZE = 12
-- Точка-отметка выбранного пункта в выпадающем списке.
local DOT_TEXTURE = "Interface/AddOns/TrialGearFinder/dot"
-- Кольцо: скруглённый контур в один пиксель, середина прозрачная. Отдельная
-- картинка нужна потому, что RoundedPanel рисует обводку сплошным блоком цвета
-- рамки и прикрывает его блоком цвета фона - под такой «обводкой» всегда есть
-- заливка, и на чередующихся строках она не совпадала бы с фоном.
-- 16x16, радиус 5. Маргины среза 7, а не 5: дуга угла доходит до седьмого
-- пикселя, и при пятёрке её хвост попадал бы в растягиваемую полосу и мазался.
-- Середина остаётся 2 пикселя - ровно прямой участок обводки.
local RING_TEXTURE = "Interface/AddOns/TrialGearFinder/roundring"
-- Сплошной белый круг. Кольцо кнопки на миникарте делается из него тем же
-- приёмом, что и RoundedPanel: круг побольше цветом рамки, поверх меньший
-- цветом заливки. Одна картинка вместо двух, и оба цвета - из палитры.
local CIRCLE_TEXTURE = "Interface/AddOns/TrialGearFinder/circle"

local function RoundedTexture(parent, layer, color, sublevel)
    local t = parent:CreateTexture(nil, layer, nil, sublevel)
    t:SetTexture(ROUND_TEXTURE)
    if t.SetTextureSliceMargins then
        t:SetTextureSliceMargins(10, 10, 10, 10)
        if t.SetTextureSliceMode and Enum and Enum.UITextureSliceMode then
            t:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        end
    end
    t:SetVertexColor(color[1], color[2], color[3], 1)
    return t
end

-- Блок с рамкой: две скруглённые текстуры, нижняя на пиксель больше и цветом
-- рамки - так рамка получается ровной по всему контуру, включая углы.
local function RoundedPanel(parent, fill, border, layer, sublevel)
    layer, sublevel = layer or "BACKGROUND", sublevel or 0
    local edge = RoundedTexture(parent, layer, border, sublevel)
    edge:SetAllPoints()
    local body = RoundedTexture(parent, layer, fill, sublevel + 1)
    body:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
    body:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)
    return body, edge
end

local function AddBorder(parent, color, inset)
    inset = inset or 0
    local sides = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local line = parent:CreateTexture(nil, "BORDER")
        Fill(line, color)
        if side == "TOP" or side == "BOTTOM" then
            line:SetHeight(1)
            line:SetPoint(side .. "LEFT", parent, side .. "LEFT", inset, 0)
            line:SetPoint(side .. "RIGHT", parent, side .. "RIGHT", -inset, 0)
        else
            line:SetWidth(1)
            line:SetPoint("TOP" .. side, parent, "TOP" .. side, 0, -inset)
            line:SetPoint("BOTTOM" .. side, parent, "BOTTOM" .. side, 0, inset)
        end
        sides[side] = line
    end
    return sides
end

-- Штатный квадратик UICheckButtonTemplate - объёмная рамка с «птичкой», чужая
-- в плоской палитре. Гасим его прозрачностью (Hide игра снимает при каждом
-- переключении, альфу не трогает), кладём скруглённый блок и подменяем отметку
-- на кружок из dot.tga.
--
-- Отметку меняем именно текстурой, а не рисуем свою поверх: проверка вещей
-- красит состояние через GetCheckedTexture():SetVertexColor - зелёный, красный,
-- жёлтый. Подменённая текстура принимает тот же цвет, и логику трогать не надо.
local function StyleCheckBox(check, dotSize)
    if not check then return end
    for _, region in ipairs({ check:GetRegions() }) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        end
    end
    -- Только контур, без заливки: под квадратиком должен просвечивать фон
    -- строки, а он чередуется. Белым - мягкая рамка #202328 на блоке почти
    -- не читалась. Наведение тёплым, как везде в окне.
    local edge = check:CreateTexture(nil, "BACKGROUND")
    edge:SetAllPoints()
    edge:SetTexture(RING_TEXTURE)
    if edge.SetTextureSliceMargins then
        edge:SetTextureSliceMargins(7, 7, 7, 7)
        if edge.SetTextureSliceMode and Enum and Enum.UITextureSliceMode then
            edge:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        end
    end
    edge:SetVertexColor(C.text[1], C.text[2], C.text[3], 1)

    check:SetCheckedTexture(DOT_TEXTURE)
    local mark = check:GetCheckedTexture()
    if mark then
        mark:SetAlpha(1) -- цикл выше погасил и её тоже
        mark:ClearAllPoints()
        mark:SetPoint("CENTER")
        mark:SetSize(dotSize or 10, dotSize or 10)
    end

    -- Подсветку шаблона мы погасили вместе с остальным, возвращаем свою: без неё
    -- не видно, что квадратик вообще нажимается.
    check:HookScript("OnEnter", function()
        edge:SetVertexColor(C.warm[1], C.warm[2], C.warm[3], 1)
    end)
    check:HookScript("OnLeave", function()
        edge:SetVertexColor(C.text[1], C.text[2], C.text[3], 1)
    end)
end

-- Кисть оформления для окна BiS (BiS.lua): та же палитра, те же скруглённые
-- текстуры и хелперы, что и у основного окна — чтобы окна выглядели как одно.
ns.Style = {
    C = C,
    RoundedPanel = RoundedPanel,
    RoundedTexture = RoundedTexture,
    AddBorder = AddBorder,
    Fill = Fill,
    ROUND = ROUND_TEXTURE,
    RING = RING_TEXTURE,
    CIRCLE = CIRCLE_TEXTURE,
    PILL = PILL_TEXTURE,
}

local frame = CreateFrame("Frame", "TrialGearFinderFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(880, 632)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG") -- above plain HIGH-strata addon windows, which is
                                -- apparently where some testers were seeing this
                                -- get tucked behind other UI
frame:SetToplevel(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
tinsert(UISpecialFrames, "TrialGearFinderFrame") -- closes on Escape, like Blizzard's own panels
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

-- Стандартную обшивку Blizzard убираем и рисуем своё: сайт строится на плоских
-- тёмных блоках с тонкой рамкой, а шаблонная рамка с камнем и заклёпками этому
-- прямо противоречит. Имена частей шаблона от версии к версии меняются, поэтому
-- не перечисляем их, а просто гасим все текстуры фрейма и его обшивки.
local function StripTextures(f)
    if not f or not f.GetRegions then return end
    for _, region in ipairs({ f:GetRegions() }) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end
end

StripTextures(frame)
StripTextures(frame.NineSlice)
StripTextures(frame.Inset)
StripTextures(frame.Inset and frame.Inset.NineSlice)
StripTextures(frame.TitleContainer)
if frame.PortraitContainer then frame.PortraitContainer:Hide() end

-- Кнопка закрытия: от штатной остаётся только область клика. Круглая рамка
-- с золотым ободком и красным крестом - самая заметная чужая деталь в окне,
-- поэтому вместо картинки рисуем знак умножения шрифтом окна: он белый,
-- со скруглёнными концами и без всякой обшивки.
--
-- Гасим прозрачностью, а не Hide и не пустым путём. Hide игра снимает сама при
-- нажатии и наведении, а Set*Texture("") вообще возвращает регион на место -
-- на этом уже обожглись: штатный крестик проступал под нашим. Альфу игра
-- не трогает (то же правило, что для ползунка прокрутки).
local closeButton = frame.CloseButton
if closeButton then
    for _, region in ipairs({ closeButton:GetRegions() }) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            region:SetAlpha(0)
        end
    end
    -- Отодвигаем от угла: штатная кнопка сидит почти вплотную к краю, а окно
    -- у нас со скруглением - крестик заезжал на закругление.
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
    closeButton:SetSize(28, 28)

    -- Шрифт берём объектом игры, а не путём к файлу: на русском клиенте
    -- подставится тот, в котором знак умножения вообще нарисован.
    closeButton.glyph = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    -- Крупнее шаблонного в полтора раза. Размер берём у самого шрифта, а не
    -- числом: сменится шрифт клиента - соотношение останется.
    local glyphFont, glyphSize, glyphFlags = closeButton.glyph:GetFont()
    if glyphFont and glyphSize then
        closeButton.glyph:SetFont(glyphFont, glyphSize * 1.5, glyphFlags)
    end
    closeButton.glyph:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    closeButton.glyph:SetText("\195\151") -- U+00D7, знак умножения: округлый крестик
    closeButton.glyph:SetTextColor(C.text[1], C.text[2], C.text[3])

    -- Наведение подсвечиваем тёплым - тем же, что строки списка и пункты меню.
    closeButton:HookScript("OnEnter", function(self)
        self.glyph:SetTextColor(C.warm[1], C.warm[2], C.warm[3])
    end)
    closeButton:HookScript("OnLeave", function(self)
        self.glyph:SetTextColor(C.text[1], C.text[2], C.text[3])
    end)
end

frame.backdrop, frame.backdropEdge = RoundedPanel(frame, C.bg, C.border, "BACKGROUND", -8)

-- Шапка. Своя, потому что штатная полоска Blizzard шириной ровно под текст
-- заголовка и поле поиска не накрывает.
--
-- Был плоский прямоугольник с отступом 10 слева и 28 справа (справа оставляли
-- место кнопке закрытия) - блок заметно уезжал влево и упирался прямыми углами
-- в скруглённое окно. Теперь это тот же скруглённый блок с рамкой, что и
-- список: отступы симметричные, углы круглые, контур на месте.
frame.titleBg = CreateFrame("Frame", nil, frame)
frame.titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -8)
frame.titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -8)
frame.titleBg:SetHeight(86) -- заголовок, поле поиска и тумблер Мин-Макс целиком
frame.titleBg:SetFrameLevel(frame:GetFrameLevel()) -- под своим содержимым
RoundedPanel(frame.titleBg, C.block, C.border)

-- Заголовок держим на самой шапке, а не на окне: у равных уровней порядок
-- отрисовки задаётся не слоем, и подложка могла бы закрыть текст.
frame.title = frame.titleBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", frame.titleBg, "TOP", 0, -18)
frame.title:SetText("ПОИСК ШМОТА ДЛЯ ТРИАЛА")
frame.title:SetTextColor(C.text[1], C.text[2], C.text[3])

------------------------------------------------------------
-- Search box: matches item name OR the note text (what the item actually does -
-- "крит", "мана" and so on), not just its name.
------------------------------------------------------------

local RefreshResults -- forward declare, the search box and dropdowns call it

-- SearchBoxTemplate is Blizzard's own (used by the Auction House, Adventure Guide,
-- etc.) - it already draws the magnifying-glass icon and the clear-text "x"
-- button, so no need to build those by hand. Its default OnTextChanged handles
-- showing/hiding that icon and button; HookScript (not SetScript) so ours runs
-- alongside that instead of replacing it.
local searchBox = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
searchBox:SetSize(300, 26) -- одна высота с кнопками фильтров внизу
searchBox:SetPoint("TOP", frame.title, "BOTTOM", 0, -10)
searchBox:SetAutoFocus(false)
searchBox.Instructions:SetText("Поиск")
searchBox:SetScript("OnEscapePressed", searchBox.ClearFocus)

-- Обшивка шаблона - золотистая рамка с объёмными торцами, для плоской тёмной
-- палитры чужая. Гасим её текстуры и кладём тот же блок, что у фильтров внизу.
StripTextures(searchBox)
RoundedPanel(searchBox, C.block2, C.borderSoft)
searchBox:SetTextColor(C.text[1], C.text[2], C.text[3])
searchBox.Instructions:SetTextColor(C.text3[1], C.text3[2], C.text3[3])
-- Лупу и крестик очистки StripTextures погасил вместе с рамкой - возвращаем их
-- и красим в приглушённый, чтобы не спорили с текстом.
--
-- Заодно переставляем: шаблон отсчитывает лупу и подпись от торцевой текстуры
-- рамки, а мы её сняли - поэтому они вылезали левее нашего блока. Задаём
-- отступы сами, те же 8 пикселей, что у кнопок фильтров.
local ICON_INSET, TEXT_INSET = 8, 26 -- 8 отступ + 14 лупа + 4 просвет
if searchBox.searchIcon then
    searchBox.searchIcon:Show()
    searchBox.searchIcon:SetVertexColor(C.text3[1], C.text3[2], C.text3[3])
    searchBox.searchIcon:ClearAllPoints()
    searchBox.searchIcon:SetPoint("LEFT", searchBox, "LEFT", ICON_INSET, 0)
end
searchBox.Instructions:ClearAllPoints()
searchBox.Instructions:SetPoint("LEFT", searchBox, "LEFT", TEXT_INSET, 0)
searchBox:SetTextInsets(TEXT_INSET, 24, 0, 0) -- набранный текст встаёт туда же
if searchBox.clearButton then
    searchBox.clearButton:ClearAllPoints()
    searchBox.clearButton:SetPoint("RIGHT", searchBox, "RIGHT", -6, 0)
    local clearIcon = searchBox.clearButton.GetNormalTexture
        and searchBox.clearButton:GetNormalTexture()
    if clearIcon then clearIcon:SetVertexColor(C.text3[1], C.text3[2], C.text3[3]) end
end
searchBox:HookScript("OnTextChanged", function(self)
    filters.search = FoldCase(self:GetText())
    RefreshResults()
end)

------------------------------------------------------------
-- Footer: filter dropdowns
------------------------------------------------------------

local footer = CreateFrame("Frame", nil, frame)
footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 10)
footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 10)
footer:SetHeight(40)

-- Выпадающий список Blizzard тащит за собой золотую рамку и объёмные торцы -
-- в плоской тёмной палитре сайта это чужое. Гасим его текстуры и рисуем
-- прямоугольник: блок, тонкая рамка, приглушённый текст, своя стрелка.
------------------------------------------------------------
-- Свой выпадающий список.
--
-- Почему не UIDropDownMenu: тот пересоздаёт кнопки при каждом открытии, рисует
-- фон лениво, задаёт отметки атласами и возвращает свои текстуры когда захочет.
-- Шесть заходов правок его так и не приручили, а кода обхода вышло больше, чем
-- занимает этот список целиком. Плюс он общий для всей игры - вмешиваться
-- в него значит менять чужие меню.
--
-- Списки у нас короткие (максимум 16 слотов), поэтому без прокрутки: всё сразу.
------------------------------------------------------------

local MENU_ROW_HEIGHT, MENU_PADDING = 20, 6
local openMenu

local function CloseFilterMenu()
    if openMenu then
        openMenu:Hide()
        openMenu = nil
    end
end

-- Ловушка на весь экран: ловит клик мимо меню и закрывает его. Лежит ниже
-- меню по слою, поэтому клики по самим пунктам до неё не доходят.
local menuCatcher = CreateFrame("Frame", nil, UIParent)
menuCatcher:SetAllPoints(UIParent)
menuCatcher:SetFrameStrata("FULLSCREEN")
menuCatcher:EnableMouse(true)
menuCatcher:Hide()
menuCatcher:SetScript("OnMouseDown", CloseFilterMenu)

local function CreateSelect(name, anchorTo, label, options, getKey, getLabel, onSelect)
    local button = CreateFrame("Button", name, footer)
    button:SetSize(155, 26)
    if anchorTo then
        button:SetPoint("LEFT", anchorTo, "RIGHT", 4, 0)
    else
        button:SetPoint("LEFT", footer, "LEFT", 0, 0)
    end
    RoundedPanel(button, C.block2, C.borderSoft)

    button.label = label
    button.selectedKey = "ALL"

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.text:SetPoint("LEFT", button, "LEFT", 8, 0)
    button.text:SetPoint("RIGHT", button, "RIGHT", -22, 0)
    button.text:SetJustifyH("LEFT")
    button.text:SetTextColor(C.text2[1], C.text2[2], C.text2[3])
    button.text:SetText(label .. ": Все")

    button.arrow = button:CreateTexture(nil, "OVERLAY")
    button.arrow:SetTexture(ARROW_TEXTURE)
    button.arrow:SetSize(ARROW_SIZE, ARROW_SIZE)
    button.arrow:SetPoint("RIGHT", button, "RIGHT", -8, 0)
    button.arrow:SetTexCoord(0, 1, 1, 0)
    button.arrow:SetVertexColor(C.text3[1], C.text3[2], C.text3[3])

    -- Меню держим на UIParent, а не на кнопке: иначе оно обрезалось бы окном
    -- и лежало под соседними фильтрами.
    local menu = CreateFrame("Frame", name .. "Menu", UIParent)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetPoint("TOP", button, "BOTTOM", 0, -2)
    menu:SetWidth(button:GetWidth())
    menu:Hide()
    RoundedPanel(menu, C.block, C.border)
    tinsert(UISpecialFrames, menu:GetName()) -- Escape закроет меню, а не окно

    menu:SetScript("OnHide", function()
        menuCatcher:Hide()
        if openMenu == menu then openMenu = nil end
    end)

    -- Пункты. Строятся один раз: наборы у нас фиксированные, слотов и классов
    -- в игре не прибавится.
    local entries = { { key = "ALL", label = "Все" } }
    for _, option in ipairs(options) do
        table.insert(entries, { key = getKey(option), label = getLabel(option) })
    end

    menu.rows = {}
    for index, entry in ipairs(entries) do
        local row = CreateFrame("Button", nil, menu)
        row:SetHeight(MENU_ROW_HEIGHT)
        row:SetPoint("LEFT", menu, "LEFT", MENU_PADDING, 0)
        row:SetPoint("RIGHT", menu, "RIGHT", -MENU_PADDING, 0)
        row:SetPoint("TOP", menu, "TOP", 0, -(MENU_PADDING + (index - 1) * MENU_ROW_HEIGHT))

        local highlight = row:CreateTexture(nil, "BACKGROUND")
        highlight:SetAllPoints()
        highlight:SetColorTexture(C.text3[1], C.text3[2], C.text3[3], 0.18)
        highlight:Hide()

        row.dot = row:CreateTexture(nil, "OVERLAY")
        row.dot:SetTexture(DOT_TEXTURE)
        row.dot:SetSize(6, 6)
        row.dot:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.dot:SetVertexColor(C.text[1], C.text[2], C.text[3])
        row.dot:Hide()

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row, "LEFT", 16, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetText(entry.label)
        row.text:SetTextColor(C.text2[1], C.text2[2], C.text2[3])

        row:SetScript("OnEnter", function() highlight:Show() end)
        row:SetScript("OnLeave", function() highlight:Hide() end)
        row:SetScript("OnClick", function()
            button.selectedKey = entry.key
            button.text:SetText(label .. ": " .. entry.label)
            CloseFilterMenu()
            onSelect(entry.key)
        end)

        row.entryKey = entry.key
        menu.rows[index] = row
    end
    menu:SetHeight(#entries * MENU_ROW_HEIGHT + MENU_PADDING * 2)

    button:SetScript("OnClick", function()
        if openMenu == menu then
            CloseFilterMenu()
            return
        end
        CloseFilterMenu()
        -- Точку ставим при открытии: так она всегда сходится с текущим выбором,
        -- даже если фильтр сменили из кода.
        for _, row in ipairs(menu.rows) do
            local chosen = row.entryKey == button.selectedKey
            row.dot:SetShown(chosen)
            local color = chosen and C.text or C.text2
            row.text:SetTextColor(color[1], color[2], color[3])
        end
        -- Всегда открываем вниз, но если до низа экрана не хватает - поднимаем
        -- ровно на недостающее, чтобы меню прилипло к краю экрана. Именно так
        -- ведёт себя стандартный список: он не переворачивается, а сползает.
        menu:ClearAllPoints()
        local bottom, overflow = button:GetBottom(), 0
        if bottom then
            overflow = math.max(0, menu:GetHeight() + 2 - bottom)
        end
        menu:SetPoint("TOP", button, "BOTTOM", 0, -2 + overflow)

        menu:Show()
        menuCatcher:Show()
        openMenu = menu
    end)

    -- Смена значения из кода: автовыбор класса при входе и сброс фильтров,
    -- когда прячем колонки статов.
    function button:SetSelected(key)
        self.selectedKey = key or "ALL"
        local caption = "Все"
        for _, row in ipairs(menu.rows) do
            if row.entryKey == self.selectedKey then
                caption = row.text:GetText()
                break
            end
        end
        self.text:SetText(self.label .. ": " .. caption)
    end

    button:SetScript("OnEnter", function()
        button.arrow:SetVertexColor(C.warm[1], C.warm[2], C.warm[3])
    end)
    button:SetScript("OnLeave", function()
        button.arrow:SetVertexColor(C.text3[1], C.text3[2], C.text3[3])
    end)

    return button
end

local slotDrop = CreateSelect("TrialGearFinderSlotDrop", nil, "Слот", VISIBLE_SLOT_DEFS,
    function(o) return o.key end, function(o) return o.label end,
    function(key) filters.slot = key; RefreshResults() end)

local classDrop = CreateSelect("TrialGearFinderClassDrop", slotDrop, "Класс", CLASS_SORT_ORDER,
    function(c) return c end,
    function(c) return CLASS_RU[c] or (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[c]) or c end,
    function(key) filters.class = key; RefreshResults() end)

local armorDrop = CreateSelect("TrialGearFinderArmorDrop", classDrop, "Броня", ARMOR_SUBCLASSES,
    function(a) return a.id end, function(a) return a.label end,
    function(key) filters.armor = key; RefreshResults() end)

local sourceDrop = CreateSelect("TrialGearFinderSourceDrop", armorDrop, "Источник", SOURCE_TYPES,
    function(s) return s.key end, function(s) return s.label end,
    function(key) filters.sourceType = key; RefreshResults() end)

------------------------------------------------------------
-- Column header
------------------------------------------------------------

local header = CreateFrame("Frame", nil, frame)
header:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -106)
header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -106)
header:SetHeight(20)

-- Clicking a stat header both filters and sorts: click Иск, then Скор, and the
-- list keeps only items that have both. Third click on a stat drops it again.
-- Non-stat headers (Источник) stay sort-only.
local sortState = { key = nil, dir = "DESC" }
local statFilter = {} -- statKey -> true; предмет должен иметь ВСЕ отмеченные статы
local headerLabels = {} -- sortKey -> { fs = fontstring, text = base label text }
-- Цвет невыбранной подписи колонки. Держим одним именем: раньше он стоял только
-- внутри UpdateHeaderSortIndicators, а рождались подписи белыми от шрифта - и
-- после первого же клика колонка сереет навсегда, вернуть белый неоткуда.
local HEADER_COLOR = C.text
local STAT_FILTER_KEYS = {
    str = true, agi = true, int = true, stam = true,
    crit = true, haste = true, iskus = true, vers = true,
}

local function UpdateHeaderSortIndicators()
    for key, entry in pairs(headerLabels) do
        entry.fs:SetText(entry.text)

        -- Направление сортировки показываем тем же треугольником, что у прокрутки
        -- и фильтров, а не буквами v и ^ в тексте заголовка.
        local arrow = entry.arrow
        if arrow then
            if sortState.key == key then
                arrow:Show()
                arrow:SetTexCoord(0, 1, 0, 1)
                if sortState.dir == "DESC" then
                    arrow:SetTexCoord(0, 1, 1, 0) -- вершиной вниз
                end
                local color = statFilter[key] and C.warm or C.text2
                arrow:SetVertexColor(color[1], color[2], color[3])

                -- Ставим вплотную к тексту: у колонок разное выравнивание,
                -- поэтому считаем правый край строки сами.
                local justify = entry.justify or "LEFT"
                arrow:ClearAllPoints()
                if justify == "CENTER" then
                    arrow:SetPoint("LEFT", entry.fs, "CENTER", entry.fs:GetStringWidth() / 2 + 3, 0)
                elseif justify == "RIGHT" then
                    arrow:SetPoint("LEFT", entry.fs, "RIGHT", 3, 0)
                else
                    arrow:SetPoint("LEFT", entry.fs, "LEFT", entry.fs:GetStringWidth() + 3, 0)
                end
            else
                arrow:Hide()
            end
        end
        if statFilter[key] then
            entry.fs:SetTextColor(C.warm[1], C.warm[2], C.warm[3]) -- отмечен как фильтр
        else
            entry.fs:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3])
        end
    end
end

local function AddHeaderLabel(x, width, text, justify, sortKey, fullName)
    local fs = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", header, "TOPLEFT", x, 0)
    fs:SetWidth(width)
    fs:SetJustifyH(justify or "LEFT")
    fs:SetText(text)
    fs:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3])

    if sortKey then
        local arrow = header:CreateTexture(nil, "OVERLAY")
        arrow:SetTexture(ARROW_TEXTURE)
        arrow:SetSize(10, 10) -- чуть мельче общей: стоит в строке с мелкой подписью
        arrow:Hide()

        fs:EnableMouse(true)
        fs:SetScript("OnMouseDown", function()
            if STAT_FILTER_KEYS[sortKey] then
                -- Стат: 1-й клик - взять в фильтр и сортировать по убыванию,
                -- 2-й - по возрастанию, 3-й - убрать из фильтра.
                -- Если стат уже в фильтре, но сортировка на другом столбце -
                -- клик просто переносит сортировку сюда, фильтр не трогая.
                if not statFilter[sortKey] then
                    statFilter[sortKey] = true
                    sortState.key, sortState.dir = sortKey, "DESC"
                elseif sortState.key ~= sortKey then
                    sortState.key, sortState.dir = sortKey, "DESC"
                elseif sortState.dir == "DESC" then
                    sortState.dir = "ASC"
                else
                    statFilter[sortKey] = nil
                    sortState.key, sortState.dir = nil, "DESC"
                end
            elseif sortState.key == sortKey then
                -- Обычный столбец: те же три такта, но без фильтра.
                if sortState.dir == "DESC" then
                    sortState.dir = "ASC"
                else
                    sortState.key, sortState.dir = nil, "DESC"
                end
            else
                sortState.key, sortState.dir = sortKey, "DESC"
            end
            UpdateHeaderSortIndicators()
            RefreshResults()
        end)
        headerLabels[sortKey] = { fs = fs, text = text, arrow = arrow, justify = justify or "LEFT" }
    end

    if fullName then
        fs:EnableMouse(true)
        fs:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(fullName)
            GameTooltip:Show()
        end)
        fs:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    return fs
end

local COL_ICON_X = 6
local ICON_SIZE = 32
local COL_NAME_X = COL_ICON_X + ICON_SIZE + 8
local COL_NAME_W = 150
local COL_STAT_W = 36
local COL_STAT_GAP = 5
local COL_STR_X = COL_NAME_X + COL_NAME_W + 8
local COL_AGI_X = COL_STR_X + COL_STAT_W + COL_STAT_GAP
local COL_INT_X = COL_AGI_X + COL_STAT_W + COL_STAT_GAP
local COL_STAM_X = COL_INT_X + COL_STAT_W + COL_STAT_GAP
local COL_CRIT_X = COL_STAM_X + COL_STAT_W + COL_STAT_GAP
local COL_HASTE_X = COL_CRIT_X + COL_STAT_W + COL_STAT_GAP
local COL_ISKUS_X = COL_HASTE_X + COL_STAT_W + COL_STAT_GAP
local COL_VERS_X = COL_ISKUS_X + COL_STAT_W + COL_STAT_GAP
local COL_SOURCE_X = COL_VERS_X + COL_STAT_W + 16
local COL_SOURCE_W = ROW_WIDTH - COL_SOURCE_X - 10

AddHeaderLabel(COL_NAME_X, COL_NAME_W, "Предмет", "LEFT")
AddHeaderLabel(COL_STR_X, COL_STAT_W, "Сила", "CENTER", "str", "Сила")
AddHeaderLabel(COL_AGI_X, COL_STAT_W, "Лов", "CENTER", "agi", "Ловкость")
AddHeaderLabel(COL_INT_X, COL_STAT_W, "Инт", "CENTER", "int", "Интеллект")
AddHeaderLabel(COL_STAM_X, COL_STAT_W, "Вын", "CENTER", "stam", "Выносливость")
AddHeaderLabel(COL_CRIT_X, COL_STAT_W, "Крит", "CENTER", "crit", "Критический удар")
AddHeaderLabel(COL_HASTE_X, COL_STAT_W, "Скор", "CENTER", "haste", "Скорость")
AddHeaderLabel(COL_ISKUS_X, COL_STAT_W, "Иск", "CENTER", "iskus", "Искусность")
AddHeaderLabel(COL_VERS_X, COL_STAT_W, "Уни", "CENTER", "vers", "Универсальность")
AddHeaderLabel(COL_SOURCE_X, COL_SOURCE_W, "Источник", "CENTER", "source")

------------------------------------------------------------
-- Scroll area + rows
------------------------------------------------------------
-- Высота видимой области = ровно стопка строк. Считаем от них, а не от футера:
-- иначе при смене их числа область и список разъезжаются.
local LIST_HEIGHT = NUM_VISIBLE_ROWS * ROW_HEIGHT + (NUM_VISIBLE_ROWS - 1) * ROW_SPACING

------------------------------------------------------------
-- Прокрутка на WowScrollBox - штатной современной системе игры.
--
-- До этого стоял FauxScrollFrameTemplate: девять строк переиспользовались,
-- а полоса двигалась ступенькой в ряд. Плавность на нём не вышла - полоса
-- округляет значение к шагу, и все обходные приёмы упирались в это.
--
-- Здесь всё содержимое лежит в одном длинном блоке content, а scrollBox
-- двигает его целиком и по пикселям. Строки создаются по мере надобности
-- и переиспользуются между обновлениями - список не пересобирается заново.
------------------------------------------------------------

local SCROLLBAR_PAD = 16 -- место справа под полосу

local scrollArea = CreateFrame("Frame", nil, frame)
scrollArea:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
-- Область шире списка ровно на полосу прокрутки: сам scrollBox тогда выходит
-- по ширине в список (он же строка), а полоса встаёт за его правым краем.
scrollArea:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", SCROLLBAR_PAD, -6)
scrollArea:SetHeight(LIST_HEIGHT)

local scrollBox = CreateFrame("Frame", "TrialGearFinderScrollBox", scrollArea, "WowScrollBox")
scrollBox:SetPoint("TOPLEFT", scrollArea, "TOPLEFT", 0, 0)
scrollBox:SetPoint("BOTTOMRIGHT", scrollArea, "BOTTOMRIGHT", -SCROLLBAR_PAD, 0)

local scrollBar = CreateFrame("EventFrame", nil, scrollArea, "MinimalScrollBar")
scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, 0)
if scrollBar.SetHideIfUnscrollable then scrollBar:SetHideIfUnscrollable(true) end

local content = CreateFrame("Frame", nil, scrollBox)
content.scrollable = true -- по этому полю scrollBox узнаёт, что двигать
content:SetWidth(1)

-- Дети уже перепривязываются внутри SetView; без этого флага повторная
-- привязка регистрирует тот же фрейм дважды и содержимое уезжает вниз.
if scrollBox.SetAlignmentOverlapIgnored then scrollBox:SetAlignmentOverlapIgnored(true) end

local scrollView = CreateScrollBoxLinearView(0, 0, 0, 0, 0)
if scrollView.SetElementStretchDisabled then scrollView:SetElementStretchDisabled(true) end
-- Шаг колеса. Без него у вида с одним длинным блоком шага нет вовсе, и колесо
-- либо не работает, либо прокручивает на случайную величину. Строка за щелчок.
if scrollView.SetPanExtent then scrollView:SetPanExtent(ROW_PITCH) end
ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollView)

-- Полосу трудно поймать мышью: она тонкая, и попадать надо ровно в ползунок.
-- Ширину не трогаем - вид должен остаться тонким, - а расширяем область захвата
-- отрицательными отступами хитбокса. Влево ровно на зазор до списка: дальше
-- начинаются строки, и они перехватят мышь у полосы.
local GRAB = 6
if scrollBar.Track then
    scrollBar.Track:SetHitRectInsets(-GRAB, -GRAB, 0, 0)
    if scrollBar.Track.Thumb then
        scrollBar.Track.Thumb:SetHitRectInsets(-GRAB, -GRAB, 0, 0)
    end
end

local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
emptyText:SetPoint("TOPLEFT", scrollArea, "TOPLEFT", 4, -4)
emptyText:SetJustifyH("LEFT")
emptyText:SetJustifyV("TOP")
emptyText:Hide()

-- Числа статов: ярко-зелёный из старого вида в тёмной палитре сайта смотрится
-- чужеродно. Значение - основным текстом, прочерк - приглушённым.
-- math.floor обязателен: %x от дробного числа в Lua роняет форматирование.
local function Hex(color)
    return string.format("%02x%02x%02x",
        math.floor(color[1] * 255 + 0.5),
        math.floor(color[2] * 255 + 0.5),
        math.floor(color[3] * 255 + 0.5))
end
local STAT_HEX, MUTED_HEX = Hex(C.text), Hex(C.text3)

-- Переписана намеренно. Первая версия повторяла одноимённую функцию из чужого
-- аддона вплоть до ярко-зелёного 00ff00, а тот распространяется под
-- All Rights Reserved - копировать из него нельзя, и благодарность этого
-- не исправляет. Пять строк форматирования не жалко переписать своими.
local function ColorStat(value)
    if not value or value <= 0 then
        return "|cff" .. MUTED_HEX .. "-|r"
    end
    return "|cff" .. STAT_HEX .. value .. "|r"
end

local SOCKET_LABELS = {
    meta = "особое", prismatic = "бесцветное", red = "красное",
    yellow = "жёлтое", blue = "синее", cogwheel = "шестерёнка", domination = "владычества",
}


local STAT_LABELS = {
    { key = "str", label = "Сила" },
    { key = "agi", label = "Ловкость" },
    { key = "int", label = "Интеллект" },
    { key = "stam", label = "Выносливость" },
    { key = "crit", label = "к критическому удару" },
    { key = "haste", label = "к скорости" },
    { key = "iskus", label = "к искусности" },
    { key = "vers", label = "к универсальности" },
}

------------------------------------------------------------
-- Ground-truth check: compare Data.lua against an item you actually own.
-- An equipped/bagged item is scaled correctly by the live client - no bonus-ID
-- guessing needed - so this doubles as both a chat-based /tgf scan and (below,
-- in ShowItemTooltip) an inline note on the addon's own item tooltip. Declared
-- here, before CreateRow, so ShowItemTooltip's closure can see these names.
------------------------------------------------------------

local ns_ItemsByID = {}
for _, it in ipairs(ns.Items) do ns_ItemsByID[it.itemID] = it end
-- Пред-BiS от сообщества (BiS_Community.lua): в общий поиск попадают только по
-- тумблеру «Комьюнити», в списке помечаются. В ns_ItemsByID кладём наравне
-- с гайдом, чтобы сверка, тултип и дневной сброс видели и их.
local ns_CommunityID = {}
for _, it in ipairs(ns.CommunityItems or {}) do
    ns_ItemsByID[it.itemID] = it
    ns_CommunityID[it.itemID] = true
end

-- Иконки гнёзд для строки расхождения. Лежат в папке аддона; для остальных
-- типов картинки нет, там останется только текст.
--
-- ВНИМАНИЕ, не удалять как «нерабочее»: они рисуются. Двойной пробел, который
-- виден в скопированном из чата выводе - след копирования, оно вырезает
-- текстуры |T|t. На этом я один раз уже попался и снёс их зря.
local SOCKET_ICON_PATHS = {
    meta = "Interface\\AddOns\\TrialGearFinder\\socket-meta.png",
    prismatic = "Interface\\AddOns\\TrialGearFinder\\socket-prismatic.png",
}

local REVERSE_SOCKET_LABELS = {}
for typeKey, word in pairs(SOCKET_LABELS) do REVERSE_SOCKET_LABELS[word] = typeKey end

local ScanTooltip = CreateFrame("GameTooltip", "TrialGearFinderScanTooltip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

local function StemToStatKey(text)
    if text:find("сил") then return "str" end
    if text:find("ловкост") then return "agi" end
    if text:find("интеллект") then return "int" end
    if text:find("вынослив") then return "stam" end
    if text:find("критическ") then return "crit" end
    if text:find("скорост") then return "haste" end
    if text:find("искусност") then return "iskus" end
    if text:find("универсальност") then return "vers" end
    return nil
end

-- Вставленные камни считаем по самой ссылке, а не по тексту тултипа: строка
-- камня приходит без распознаваемой иконки, а C_Item.GetItemGem эти камни
-- не знает.
-- Разбивка ссылки: [1] префикс с |Hitem, [2] itemID, [3] пусто, [4] чары,
-- [5..8] камни. Проверено диагностикой: в поле 4 у вещей стояли разные числа
-- (чары), а в 5-8 повторялся один и тот же id камня.
local function CountGemsInLink(link)
    local parts = { strsplit(":", link) }
    local n = 0
    for i = 5, 8 do
        local gem = tonumber(parts[i])
        if gem and gem > 0 then n = n + 1 end
    end
    return n
end

local function ScanItemLink(link)
    ScanTooltip:ClearLines()
    ScanTooltip:SetHyperlink(link)

    local result = { ilvl = C_Item.GetDetailedItemLevelInfo(link), stats = {}, socketTypes = {} }
    local inSocketBonusZone = false

    -- "X гнездо" text only shows for EMPTY sockets; a filled one shows the gem's
    -- own effect line instead (icon + "+N к X и +N к Y") - C_Item.GetItemGem
    -- doesn't recognize these particular gems, so they're counted from the
    -- tooltip text itself, the same way the empty-socket lines are.
    local filledGems = CountGemsInLink(link)

    for i = 1, ScanTooltip:NumLines() do
        local fs = _G["TrialGearFinderScanTooltipTextLeft" .. i]
        local text = fs and fs:GetText()
        if text then
            if text:find("соответствии цвета") then inSocketBonusZone = true end

            do
                local value, rest = text:match("^%+(%d+)%s+к%s+(.+)$")
                if value then
                    local key = StemToStatKey(rest)
                    if key then
                        if inSocketBonusZone then
                            result.socketBonus = { key = key, value = tonumber(value) }
                        else
                            result.stats[key] = tonumber(value)
                        end
                    end
                end
            end

            -- Строка пустого гнезда: ищем слово «гнездо» где угодно в строке, а тип
            -- определяем по ключевому слову рядом. Раньше требовалось строгое
            -- «<тип> гнездо», и гнёзда-шестерёнки (инженерные) не находились вовсе -
            -- в игре они подписаны иначе.
            local lowered = text:lower()
            if lowered:find("гнезд", 1, true) then
                local socketType = "prismatic"
                for word, key in pairs(REVERSE_SOCKET_LABELS) do
                    if lowered:find(word:lower(), 1, true) then socketType = key break end
                end
                table.insert(result.socketTypes, socketType)
            end
        end
    end

    -- Гнездо с камнем закрыто, и цвет его по тултипу уже не узнать - считаем
    -- бесцветным. Иначе заполненные гнёзда не попадали в сравнение вовсе:
    -- DiffData сверяет socketTypes, а не общее число.
    for _ = 1, filledGems do table.insert(result.socketTypes, "prismatic") end
    result.sockets = #result.socketTypes
    return result
end

-- Dative case ("к X") for the Blizzard-style "+1 к скорости" comparison lines -
-- different from STAT_LABELS above, which uses nominative for the flat stat list.
local DATIVE_STAT_LABELS = {
    str = "силе", agi = "ловкости", int = "интеллекту", stam = "выносливости",
    crit = "критическому удару", haste = "скорости", iskus = "искусности", vers = "универсальности",
}

-- Compares Data.lua's stored numbers for itemID against what `live` (a ScanItemLink
-- result for a real, owned copy of it) actually shows. Returns a list of
-- { delta = signedNumber, label = "к скорости" | "гнездо" | ... } entries, in the
-- same "+1 к X" / "-1 Y" shape as the game's own gear-comparison tooltip, empty if
-- everything matches.
local function DiffData(dataItem, live)
    if not dataItem then return {} end

    local diffs = {}
    if dataItem.ilvl and live.ilvl and dataItem.ilvl ~= live.ilvl then
        table.insert(diffs, { delta = live.ilvl - dataItem.ilvl, label = "к уровню предмета" })
    end
    -- Per socket type (meta/prismatic/...), not just a total count, so the line
    -- can say which color of socket is actually missing/extra - "-1 бесцветное
    -- гнездо" instead of a bare "-1 гнездо".
    local function CountByType(list)
        local counts = {}
        for _, t in ipairs(list or {}) do counts[t] = (counts[t] or 0) + 1 end
        return counts
    end
    local dataCounts, liveCounts = CountByType(dataItem.socketTypes), CountByType(live.socketTypes)
    local seenTypes = {}
    for t in pairs(dataCounts) do seenTypes[t] = true end
    for t in pairs(liveCounts) do seenTypes[t] = true end
    for t in pairs(seenTypes) do
        local a, b = dataCounts[t] or 0, liveCounts[t] or 0
        if a ~= b then
            local delta = b - a
            local word = SOCKET_LABELS[t] or t
            table.insert(diffs, {
                delta = delta,
                label = word .. " " .. (math.abs(delta) == 1 and "гнездо" or "гнёзда"),
                isSocket = true,
                socketType = t,
            })
        end
    end
    for _, key in ipairs({ "str", "agi", "int", "stam", "crit", "haste", "iskus", "vers" }) do
        local a, b = (dataItem.stats or {})[key] or 0, live.stats[key] or 0
        if a ~= b then
            table.insert(diffs, { delta = b - a, label = "к " .. DATIVE_STAT_LABELS[key] })
        end
    end
    return diffs
end

local function DiffAgainstLive(itemID, live)
    return DiffData(ns_ItemsByID[itemID], live)
end

-- Which primary stat (str/agi/int) is actually rolled on this item, if any -
-- used to pick between several same-slot database entries (e.g. an agi cloak
-- vs an int cloak) when there's no exact itemID match.
local function DominantPrimaryStat(stats)
    local best, bestValue
    for _, key in ipairs({ "str", "agi", "int" }) do
        local value = stats[key] or 0
        if value > 0 and (not bestValue or value > bestValue) then
            best, bestValue = key, value
        end
    end
    return best
end

-- Not every item you hover is one of our 103 tracked BiS entries by itemID -
-- this picks the closest guide recommendation for the SAME slot instead, so you
-- can still gut-check a random drop against what the guide suggests. Scored by
-- slot match (required) + same armor material + same primary stat.
local function FindClosestDatabaseItem(hoveredLink)
    local _, _, _, _, _, _, _, _, equipLoc, _, _, classID, subclassID = C_Item.GetItemInfo(hoveredLink)
    if not equipLoc then return nil end

    local hoveredStats = C_Item.GetItemStats(hoveredLink) or {}
    local hoveredPrimary = DominantPrimaryStat({
        str = hoveredStats["ITEM_MOD_STRENGTH_SHORT"],
        agi = hoveredStats["ITEM_MOD_AGILITY_SHORT"],
        int = hoveredStats["ITEM_MOD_INTELLECT_SHORT"],
    })

    local best, bestScore
    for _, item in ipairs(ns.Items) do
        local link = BuildItemLink(item.itemID, item.bonusIDs or {})
        local _, _, _, _, _, _, _, _, cEquipLoc, _, _, cClassID, cSubclassID = C_Item.GetItemInfo(link)
        if cEquipLoc == equipLoc then
            local score = 0
            if classID == ARMOR_CLASS_ID and cClassID == ARMOR_CLASS_ID and subclassID == cSubclassID then
                score = score + 2
            end
            if hoveredPrimary and DominantPrimaryStat(item.stats or {}) == hoveredPrimary then
                score = score + 1
            end
            if not bestScore or score > bestScore then
                best, bestScore = item, score
            end
        end
    end
    return best
end

-- "+1 к скорости" / "-1 гнездо", the same phrasing the game's own gear-comparison
-- tooltip uses. Returns the text plus r,g,b for AddLine to color it green/red.
-- Colors only the +N/-N number (green/red); the stat name after it stays the
-- tooltip's normal white, matching the game's own comparison block.
-- Цвет гнезда, закрытого камнем, по тултипу не узнать - такие считаются
-- бесцветными. Поэтому «-1 особое, +1 бесцветное» при одинаковом общем числе
-- гнёзд означает только это и расхождением не является. Если же гнёзд реально
-- больше или меньше, разница останется и попадёт в отчёт.
local function DropBalancedSocketDiffs(diffs)
    local total, socketCount = 0, 0
    for _, d in ipairs(diffs) do
        if (d.label or ""):find("гнездо", 1, true) or (d.label or ""):find("гнёзда", 1, true) then
            total = total + (d.delta or 0)
            socketCount = socketCount + 1
        end
    end
    if socketCount == 0 or total ~= 0 then return diffs end

    local kept = {}
    for _, d in ipairs(diffs) do
        local label = d.label or ""
        if not (label:find("гнездо", 1, true) or label:find("гнёзда", 1, true)) then
            table.insert(kept, d)
        end
    end
    return kept
end

local function FormatDiffLine(diff)
    local sign = diff.delta > 0 and "+" or ""
    local colorCode = diff.delta > 0 and "|cFF20FF20" or "|cFFFF4040"
    local number = string.format("%s%s%d|r", colorCode, sign, diff.delta)

    if diff.isSocket then
        local iconPath = SOCKET_ICON_PATHS[diff.socketType]
        if iconPath then
            return string.format("%s |T%s:16:16|t %s", number, iconPath, diff.label)
        end
    end
    return string.format("%s %s", number, diff.label)
end

-- Two side-by-side columns, same layout as the game's own "if you replace this
-- item" comparison block, instead of one line per diff.
local function AddDiffLines(tooltip, diffs)
    for _, diff in ipairs(diffs) do
        tooltip:AddLine(FormatDiffLine(diff), 1, 1, 1)
    end
end

-- Is itemID currently equipped or sitting in a bag? Returns its live link, or nil.
-- Где искать копию вещи. Счётчик C_Item.GetItemCount, по которому ставится
-- «вещь есть», считает и банк - значит и ссылку надо искать там же, иначе вещь
-- числится в наличии, а сверять её не с чем.
--
-- Номера берём из Enum.BagIndex, а НЕ пишем числами. В нынешнем ретейле банк
-- персонажа стал вкладками (CharacterBankTab_1..6), а прежние -1 и 6..11
-- не содержат больше ничего. Мы искали копию именно в них - и вещь из банка
-- вечно висела серой «сверить не удалось»: счётчик её во вкладке видел,
-- а поиск ссылки шёл по мёртвым номерам. Подсказка при этом писала «ни в
-- банке», хотя в банк никто и не заглядывал.
--
-- Номера подсмотрены не по памяти, а в Syndicator (движок Baganator), который
-- живёт под текущий патч: там же видно, что BankBagSlotsCount стал нулём.
-- Закрытый банк отдаёт ноль слотов, лишних обходов это не создаёт.
local OWNED_CONTAINERS = (function()
    local ids = { 0, 1, 2, 3, 4 } -- рюкзак и четыре сумки
    local B = Enum and Enum.BagIndex or {}

    table.insert(ids, B.ReagentBag or 5)

    if B.CharacterBankTab_1 then
        for i = 1, 6 do
            local id = B["CharacterBankTab_" .. i]
            if id then table.insert(ids, id) end
        end
    else
        -- Старый банк: сам банк, шесть его сумок и банк реагентов.
        -- Ветка на случай, если аддон запустят на клиенте до перехода
        -- на вкладки - падать там он не должен.
        for _, id in ipairs({ -1, 6, 7, 8, 9, 10, 11, -3 }) do
            table.insert(ids, id)
        end
    end

    -- Общий банк ратной кампании. Счётчик его копии тоже видит, поэтому
    -- и ссылку надо уметь там найти - иначе возвращается ровно та же серая
    -- отметка, только по другой причине.
    for i = 1, 5 do
        local id = B["AccountBankTab_" .. i]
        if id then table.insert(ids, id) end
    end

    return ids
end)()

local function FindOwnedLink(itemID)
    if not itemID then return nil end
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        if GetInventoryItemID("player", slot) == itemID then
            return GetInventoryItemLink("player", slot)
        end
    end
    for _, bag in ipairs(OWNED_CONTAINERS) do
        for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID == itemID then return info.hyperlink end
        end
    end
    return nil
end

------------------------------------------------------------
-- Map pin on the source. Clicking a row's source drops the same gold diamond
-- waypoint you get from Ctrl-clicking the world map, with the navigation arrow
-- pointing at the dungeon entrance. The game only keeps ONE user waypoint, so
-- each click replaces the previous one.
--
-- Coordinates are entered as they read in game (49.8, not 0.498). Anything not
-- listed here simply says so instead of dropping a pin in the wrong place -
-- a wrong waypoint is worse than none.
------------------------------------------------------------

-- ВАЖНО про связку плащей. Была { 4244, 23, 8810 }, стала { 4244, 8810 }.
-- 23 - это НЕ уровень предмета, а суффикс «с символом огненной вспышки»
-- (+крит, +скорость): без него уровень остаётся 23 (его держит 4244), гнездо
-- остаётся (8810), но крит падает и скорость исчезает.
--
-- Суффикс убран 4 сентября, решение от 2 сентября отменено. Число 23 пришло
-- из параметра &ilvl=23 на Wowhead, а не из игры, и попало в связку при
-- исходном парсинге гайда. Сравнение выбитого плаща с базой бок о бок
-- показало: версии с суффиксом в дропе нет, это артефакт разбора.
-- Гнездо оставлено - его держит 8810, и вот оно как раз редкий ролл.

local SOURCE_PINS = {
    -- ПОДЗЕМЕЛЬЯ. Ключ - поле source из Data.lua.
    -- Восточные королевства
    ["Ульдаман"]               = { 15, 42.2, 11.7 },   -- Бесплодные земли
    ["Залы Алого ордена"]      = { 18, 85.3, 32.5 },   -- Тирисфальские леса
    ["Некроситет"]             = { 22, 69.9, 73.8 },   -- Западные Чумные земли
    ["Стратхольм"]             = { 23, 27.1, 11.5 },   -- Восточные Чумные земли
    ["Стратхольм - Чёрный ход"] = { 23, 43.2, 17.5 },
    ["Глубины Черной горы"]    = { 36, 21.0, 38.6 },   -- Пылающие степи
    -- Калимдор
    ["Мародон"]                = { 66, 29.3, 62.7 },   -- Пустоши
    ["Очищение Стратхольма"]   = { 71, 65.1, 50.0 },   -- Танарис, Пещеры Времени
    ["Старые предгорья Хилсбрада"] = { 71, 64.9, 49.8 },
    ["Вершина Смерча"]         = { 249, 76.7, 84.6 },  -- Ульдум
    -- Запределье
    ["Кузня Крови"]            = { 100, 46.1, 51.6 },  -- Цитадель Адского Пламени
    ["Разрушенные залы"]       = { 100, 48.2, 51.8 },
    ["Аукенайские гробницы"]   = { 101, 44.6, 79.0 },  -- Терокар, Аукиндон
    ["Гробницы маны"]          = { 101, 46.1, 76.6 },
    ["Сетеккские залы"]        = { 101, 47.7, 79.0 },
    ["Темный лабиринт"]        = { 101, 46.1, 81.2 },
    ["Нижетопь"]               = { 102, 54.2, 34.7 },  -- Зангартопь, Дол Заррахем
    ["Паровое подземелье"]     = { 102, 50.4, 33.3 },
    ["Узилище"]                = { 102, 49.0, 35.9 },
    ["Ботаника"]               = { 109, 71.7, 55.1 },  -- Пустоверть, Крепость Бурь
    ["Механар"]                = { 109, 70.6, 69.7 },
    ["Терраса Магистров"]      = { 122, 61.0, 30.8 },  -- Остров Кель'Данас
    -- Нордскол
    ["Нексус"]                 = { 114, 28.7, 27.9 },  -- Борейская тундра, Нексус
    ["Окулус"]                 = { 114, 26.7, 27.5 },
    ["Азжол-Неруб"]            = { 115, 25.9, 50.9 },  -- Драконий Погост
    ["Кузня Душ"]              = { 118, 54.9, 89.8 },  -- Ледяная Корона
    ["Яма Сарона"]             = { 118, 54.6, 91.9 },
    -- Дренор
    ["Железные доки"]          = { 543, 45.4, 13.6 },  -- Горгронд
    ["Долина Призрачной Луны"] = { 539, 26.5, 33.2 },  -- квестовый аксессуар
    -- Расколотые острова
    ["Штурм Аметистовой крепости"] = { 619, 46.7, 65.5 }, -- Даларан
    ["Око Азшары"]             = { 630, 61.0, 41.1 },  -- Азсуна
    ["Чертоги Доблести (бонусбосс Один, мифик)"] = { 634, 72.7, 70.8 }, -- Штормхейм
    ["Крепость Чёрной Ладьи"]  = { 641, 37.3, 50.2 },  -- Вальшара
    ["Чаща Тёмного Сердца"]    = { 641, 59.2, 31.4 },
    ["Собор Вечной Ночи"]      = { 646, 64.9, 16.8 },  -- Расколотый берег
    ["Логово Нелтариона"]      = { 650, 49.7, 68.6 },  -- Крутогорье
    -- Кул-Тирас
    ["Усадьба Уэйкрестов"]     = { 896, 33.9, 12.6 },  -- Друствар
    -- Тёмные земли
    ["Чумные каскады"]         = { 1536, 59.5, 65.0 }, -- Малдраксус
    ["Мгла Тирна Скитта"]      = { 1565, 35.6, 54.2 }, -- Арденвельд
    -- Драконьи острова
    ["Лазурные Врата"]         = { 1978, 47.5, 82.8 },
    ["Наступление Нохуда"]     = { 2023, 60.8, 39.3 }, -- Равнины Охн'арана

    -- РАРНИКИ И СОКРОВИЩА. Ключ по предмету: source у них общий на категорию,
    -- а место у каждого своё. Комментарий - из note в Data.lua.
    -- Дренор
    ["item:108902"] = { 539, 41.6, 28.0 }, -- сокровище, Долина Призрачной Луны
    ["item:113408"] = { 539, 38.9, 43.4 }, -- сокровище, Долина Призрачной Луны
    ["item:119349"] = { 525, 66.6, 25.4 }, -- Гиблет Трусливый, Хребет Ледяного Огня
    ["item:119390"] = { 525, 48.6, 24.9 }, -- Бармагрыз, Хребет Ледяного Огня
    ["item:119399"] = { 525, 38.1, 16.3 }, -- Сын Горамала, Хребет Ледяного Огня
    ["item:119351"] = { 543, 53.2, 55.9 }, -- Слякоч-повелитель, Горгронд
    ["item:119391"] = { 543, 61.7, 39.6 }, -- Могамаго, Горгронд
    ["item:119414"] = { 543, 59.6, 42.9 }, -- Хранитель рощи Йал, Горгронд
    ["item:116824"] = { 550, 66.6, 56.4 }, -- Рог бешеного талбука (рарник), Награнд
    ["item:120317"] = { 550, 58.4, 18.7 }, -- Монстр арены, Награнд
    -- Кул-Тирас
    ["item:155278"] = { 895, 54.9, 32.7 }, -- Чешуетряс Ядовитый, Тирагард
    ["item:155551"] = { 895, 48.7, 36.7 }, -- Сквиргл-из-Глубин, Тирагард
    ["item:155571"] = { 895, 62.1, 51.7 }, -- сундук за Стража источника, Тирагард
    ["item:158597"] = { 895, 48.6, 22.9 }, -- Кулетт Вспыльчивый, Тирагард
    ["item:160451"] = { 895, 76.6, 83.6 }, -- Бармен Билл, Тирагард
    ["item:155273"] = { 895, 76.9, 29.9 }, -- Пилозуб, Боралус
    ["item:154217"] = { 896, 24.6, 22.0 }, -- Мак, Друствар
    ["item:155299"] = { 896, 33.2, 57.6 }, -- Сестра Марта, Друствар
    ["item:155425"] = { 896, 59.0, 17.6 }, -- Королева шипожалов, Друствар
    ["item:158583"] = { 896, 66.5, 42.6 }, -- Дикобраз-матриарх, Друствар
    ["item:160447"] = { 896, 63.6, 40.1 }, -- Эмили Мэйвилл, Друствар
    ["item:155164"] = { 942, 62.0, 56.9 }, -- Сестра Абсинтия, Долина Штормов
    ["item:155572"] = { 942, 62.5, 73.9 }, -- Мрачноморд Безмозглый, Долина Штормов
    ["item:159518"] = { 942, 53.5, 50.8 }, -- Длинноклык и Генри Брейкуотер
    -- Зандалар
    ["item:160952"] = { 862, 74.6, 39.6 }, -- Кинжалозуб, Зулдазар
    ["item:160958"] = { 862, 65.2, 10.2 }, -- Темноуст Джола, Зулдазар
    ["item:160978"] = { 862, 42.2, 36.1 }, -- Хакби Восставший, Зулдазар
    ["item:160984"] = { 862, 68.7, 48.8 }, -- Кандак, Зулдазар
}

-- The same clickable link the game itself posts for a map pin: clicking it sets
-- the waypoint, and the map id and coordinates are readable right in the link.
local function WaypointLink(uiMapID, x, y, label)
    return string.format("|cffffff00|Hworldmap:%d:%d:%d|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a %s]|h|r",
        uiMapID, math.floor(x * 100 + 0.5), math.floor(y * 100 + 0.5), label)
end

-- У рарников источник называет материк ("Кул-Тирас (рарники...)"), а не точку:
-- метка на источник была бы там бесполезна - каждая вещь падает со своего моба
-- в своём месте. Поэтому они ключуются по вещи - "item:158583".
local function PinKey(sourceType, itemID, source)
    if sourceType == "World" and itemID then return "item:" .. itemID end
    return source
end

local function SetSourceWaypoint(sourceName, sourceType, itemID)
    if not sourceName or sourceName == "" then return end
    local key = PinKey(sourceType, itemID, sourceName)

    -- Pins captured in game (Ctrl-click) win over the ones baked into this file.
    local saved = TrialGearFinderDB and TrialGearFinderDB.pins
    local pin = (saved and saved[key]) or SOURCE_PINS[key]
    if not pin then
        print(string.format("|cFFFFD100[TGF]|r Координаты для «%s» ещё не заданы.", sourceName))
        return
    end

    local uiMapID, x, y = pin[1], pin[2], pin[3]
    if not C_Map.CanSetUserWaypointOnMap(uiMapID) then
        print("|cFFFFD100[TGF]|r На этой карте игра не разрешает ставить метку.")
        return
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(uiMapID, x / 100, y / 100))
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)

    -- Open the map on that zone too, so the pin is on screen straight away
    -- instead of only as an arrow somewhere off to the side.
    --
    -- Через C_Map, а не через глобальную OpenWorldMap. Та живёт в Lua
    -- (Blizzard_WorldMap.lua) и, вызванная из аддона, пачкает WorldMapFrame:
    -- дальше встроенный поставщик меток бонусных заданий упирается в защищённую
    -- SetPassThroughButtons, та не срабатывает, и игра винит в этом нас -
    -- ADDON_ACTION_BLOCKED с нашим именем в чужой цепочке вызовов.
    -- C_Map.OpenWorldMap открывает карту из защищённого слоя, и цепочка чистая.
    if C_Map.OpenWorldMap then
        C_Map.OpenWorldMap(uiMapID)
    elseif OpenWorldMap then
        OpenWorldMap(uiMapID)
    end
    print("|cFFFFD100[TGF]|r " .. sourceName .. ": " .. WaypointLink(uiMapID, x, y, "метка на карте"))
end

-- Ctrl-click on a source stores whatever user waypoint is currently on the map
-- for that source. Point being: you place the pin yourself where it actually
-- belongs, so the coordinates are right by construction - no external lists.
local function SaveSourceWaypoint(sourceName, sourceType, itemID)
    if not sourceName or sourceName == "" then return end
    local key = PinKey(sourceType, itemID, sourceName)

    local point = C_Map.GetUserWaypoint()
    if not point then
        print("|cFFFFD100[TGF]|r Сначала поставь метку на карте (Ctrl+щелчок по карте), потом Ctrl+щелчок по источнику.")
        return
    end

    TrialGearFinderDB = TrialGearFinderDB or {}
    TrialGearFinderDB.pins = TrialGearFinderDB.pins or {}
    TrialGearFinderDB.pins[key] = { point.uiMapID, point.position.x * 100, point.position.y * 100 }
    print(string.format("|cFFFFD100[TGF]|r Запомнено: %s = %s", sourceName,
        WaypointLink(point.uiMapID, point.position.x * 100, point.position.y * 100,
            string.format("карта %d: %.1f, %.1f", point.uiMapID,
                point.position.x * 100, point.position.y * 100))))
end

local function CreateRow(index)
    local row = CreateFrame("Frame", "TrialGearFinderRow" .. index, frame)
    row:SetSize(ROW_WIDTH, ROW_HEIGHT)
    row:EnableMouse(true)

    -- Пиксель с боков оставляем рамке подложки: строка лежит поверх неё, и
    -- растянутая на всю ширину заливка закрашивала контур - он проступал только
    -- напротив прозрачных строк, и обводка шла зеброй. Тот же отступ, что у тела
    -- RoundedPanel, поэтому чётные и нечётные строки встают вровень.
    row.bgAlt = row:CreateTexture(nil, "BACKGROUND", nil, 0)
    row.bgAlt:SetPoint("TOPLEFT", row, "TOPLEFT", 1, 0)
    row.bgAlt:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -1, 0)
    -- Чередование строк как на сайте: два соседних оттенка блока. Нечётные
    -- оставляем прозрачными - их оттенок даёт скруглённая подложка списка,
    -- и через неё же видно скругление у первой и последней строки.
    if index % 2 == 0 then
        Fill(row.bgAlt, C.block2)
    else
        row.bgAlt:SetColorTexture(0, 0, 0, 0)
    end

    row.bg = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.bg:SetPoint("TOPLEFT", row, "TOPLEFT", 1, 0) -- тоже мимо рамки подложки
    row.bg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -1, 0)
    row.bg:SetColorTexture(0, 0, 0, 0)

    -- Наведение: подсветка блока плюс полоска слева - так на сайте отмечены
    -- активные карточки. Полоска белая: названия предметов раскрашены по
    -- качеству, и тёплый акцент спорил с оранжевыми и золотыми названиями.
    --
    -- У первой и последней строки угол списка скруглён, и прямая полоска
    -- вылезала за него уголком. Своего скругления полоска нести не может:
    -- маргины среза не бывают шире элемента, а она в 2 пикселя (на том же
    -- спотыкались с ползунком - капсула 16x16 не тянулась). Поэтому там, где
    -- угол круглый, поджимаем её внутрь на радиус и берём капсулу: торцы
    -- получаются скруглёнными.
    local topInset = (index == 1) and 6 or 0

    row.hoverBar = row:CreateTexture(nil, "ARTWORK")
    row.hoverBar:SetWidth(2)
    row.hoverBar:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -topInset)
    row.hoverBar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    row.hoverBar:SetTexture(PILL_TEXTURE)
    if row.hoverBar.SetTextureSliceMargins then
        row.hoverBar:SetTextureSliceMargins(0, 4, 0, 4)
        if row.hoverBar.SetTextureSliceMode and Enum and Enum.UITextureSliceMode then
            row.hoverBar:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        end
    end
    row.hoverBar:SetVertexColor(C.text[1], C.text[2], C.text[3], 1)
    row.hoverBar:Hide()

    -- Какая строка последняя - знает только список: он теперь длиной во все
    -- найденные вещи, а не в девять строк. Метку ставит RefreshResults.
    function row:SetLastInList(isLast)
        self.hoverBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, isLast and 6 or 0)
        -- Заливка строки прямоугольная и срезала бы скруглённый нижний угол
        -- списка. Последняя строка отдаёт угол подложке - как первая, она
        -- прозрачна по чётности.
        self.bgAlt:SetShown(not isLast)
    end

    -- Отдельными методами, а не двумя замыканиями на месте: те же самые
    -- показать-спрятать нужны детям строки, у которых своя мышь (см. ниже).
    function row:HoverOn()
        Fill(self.bg, C.border, 0.35)
        self.hoverBar:Show()
    end
    function row:HoverOff()
        self.bg:SetColorTexture(0, 0, 0, 0)
        self.hoverBar:Hide()
    end
    row:SetScript("OnEnter", row.HoverOn)
    row:SetScript("OnLeave", row.HoverOff)

    row.iconFrame = CreateFrame("Button", nil, row)
    row.iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
    row.iconFrame:SetPoint("TOPLEFT", row, "TOPLEFT", COL_ICON_X, -6)
    row.icon = row.iconFrame:CreateTexture(nil, "ARTWORK")
    row.icon:SetAllPoints()

    -- Обводка значка цветом качества предмета: синий, фиолетовый, оранжевый.
    -- Берём то же кольцо, что у чекбоксов - новой текстуры не нужно. Растянуто
    -- на два пикселя наружу, чтобы не съедать саму иконку.
    row.iconRing = row.iconFrame:CreateTexture(nil, "OVERLAY")
    row.iconRing:SetPoint("TOPLEFT", row.iconFrame, "TOPLEFT", -2, 2)
    row.iconRing:SetPoint("BOTTOMRIGHT", row.iconFrame, "BOTTOMRIGHT", 2, -2)
    row.iconRing:SetTexture(RING_TEXTURE)
    if row.iconRing.SetTextureSliceMargins then
        row.iconRing:SetTextureSliceMargins(7, 7, 7, 7)
        if row.iconRing.SetTextureSliceMode and Enum and Enum.UITextureSliceMode then
            row.iconRing:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        end
    end
    -- Native tooltip via SetHyperlink - real item card, real Shift-compare
    -- against whatever's equipped, real Ctrl-dressup. Accuracy now depends on
    -- each item's bonusIDs in Data.lua actually reconstructing to ilvl 23 -
    -- fix those one at a time as wrong ones turn up in-game (like 24395,
    -- 28229, 17943 already were), there's no manual-tooltip fallback anymore.
    function row:ShowItemTooltip()
        if not frame:IsShown() then return end -- window closed: nothing to describe
        if not self.hyperlink then return end
        GameTooltip:SetOwner(self.iconFrame, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.hyperlink)

        -- Клиент масштабирует старые вещи непредсказуемо, и статы в этой
        -- ссылке расходятся с базой в обе стороны (у 50214 синтетическая
        -- ссылка занижает: 6/6/8 против настоящих 7/7/10 с реального лута).
        -- База правится по реальным копиям с рук - переписываем разошедшиеся
        -- строки статов на месте, только те.
        -- Цвет строки при :SetText сохраняется, поэтому зелёные вторички
        -- остаются зелёными, серая неактивная - серой.
        local base = self.twink and self.twink.stats
        if base then
            local inSB, touched = false, false
            for i = 2, GameTooltip:NumLines() do
                local fs = _G["GameTooltipTextLeft" .. i]
                local text = fs and fs:GetText()
                if issecretvalue and text and issecretvalue(text) then text = nil end -- Midnight
                if text then
                    if text:find("соответствии цвета") then inSB = true end
                    if not inSB then
                        local val, rest = text:match("^%s*%+(%d+)%s+к%s+(.+)$")
                        local key = val and StemToStatKey(rest)
                        local bv = key and base[key]
                        if bv and bv ~= tonumber(val) then
                            fs:SetText("+" .. bv .. " к " .. rest)
                            touched = true
                        end
                    end
                end
            end
            if touched then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Статы поправлены по базе — клиент масштабирует эту ссылку неточно.",
                    0.85, 0.72, 0.42, true)
                GameTooltip:Show() -- пересчитать размер после правки строк
            end
        end

        -- Копия на руках разошлась с базой - показываем чем именно. Ловит
        -- ошибку в самой базе: у предметов с требованием уровня ~25-35 армори
        -- (откуда снята база) занижает статы, а настоящий лут с двадцатки выше.
        -- Расхождение уже посчитано в BuildRowData, тут только выводим.
        if type(self.ownedDiffs) == "table" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Твоя копия отличается от базы:", 0.85, 0.72, 0.42)
            for _, d in ipairs(self.ownedDiffs) do
                GameTooltip:AddLine("  " .. FormatDiffLine(d), 1, 1, 1)
            end
            GameTooltip:Show()
        end

        local sc = self.srcColor or C.gold
        if self.fullSource and self.fullSource ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self.fullSource, sc[1], sc[2], sc[3], true)
        end
        if self.fullNote and self.fullNote ~= "" then
            GameTooltip:AddLine(self.fullNote, 1, 1, 1, true)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Щелчок - поставить метку на карте", 0.6, 0.6, 0.6)
        GameTooltip:AddLine("Ctrl+щелчок - запомнить текущую метку для этого источника", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end

    row.iconFrame:SetScript("OnEnter", function() row:ShowItemTooltip() end)
    row.iconFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.iconFrame:SetScript("OnClick", function()
        if not row.hyperlink then return end
        if IsModifiedClick("CHATLINK") then
            ChatEdit_InsertLink(row.hyperlink)
        elseif IsModifiedClick("DRESSUP") then
            DressUpItemLink(row.hyperlink)
        end
    end)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.name:SetPoint("TOPLEFT", row, "TOPLEFT", COL_NAME_X, -4)
    row.name:SetSize(COL_NAME_W, 16)
    row.name:SetJustifyH("LEFT")

    -- Подпись «Латы (Плечи) | 23 ур.» - белым: приглушённый серый тестеры
    -- читали с трудом. Шрифт остаётся мелким, меняется только цвет.
    row.type = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.type:SetTextColor(C.text[1], C.text[2], C.text[3])
    row.type:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -4)
    row.type:SetSize(COL_NAME_W, 14)
    row.type:SetJustifyH("LEFT")

    local function StatFS(x)
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", row, "TOPLEFT", x, -16)
        fs:SetSize(COL_STAT_W, 16)
        fs:SetJustifyH("CENTER")
        return fs
    end
    row.str = StatFS(COL_STR_X)
    row.agi = StatFS(COL_AGI_X)
    row.int = StatFS(COL_INT_X)
    row.stam = StatFS(COL_STAM_X)
    row.crit = StatFS(COL_CRIT_X)
    row.haste = StatFS(COL_HASTE_X)
    row.iskus = StatFS(COL_ISKUS_X)
    row.vers = StatFS(COL_VERS_X)

    -- Название источника берёт тот же шрифтовой объект, что и название
    -- предмета: две колонки - равные заголовки строки, и размер обязан
    -- совпадать. Через объект, а не через GetFont с подстановкой размера:
    -- сменится шрифт клиента - совпадение сохранится само.
    -- Цвет ставится в SetData, он зависит от типа источника.
    row.source = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.source:SetPoint("TOPLEFT", row, "TOPLEFT", COL_SOURCE_X, -4)
    row.source:SetSize(COL_SOURCE_W, 16)
    row.source:SetJustifyH("LEFT")

    row.sourceboss = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    -- Белым, а не вторичным серым: на тёмной строке #AEB4BC читался с трудом,
    -- та же жалоба, что была на подпись типа брони.
    row.sourceboss:SetTextColor(C.text[1], C.text[2], C.text[3])
    row.sourceboss:SetPoint("TOPLEFT", row.source, "BOTTOMLEFT", 0, -4)
    row.sourceboss:SetSize(COL_SOURCE_W, 14)
    row.sourceboss:SetJustifyH("LEFT")

    -- Source/sourceboss text gets clipped by column width; hover shows the full text.
    row.sourceHitbox = CreateFrame("Frame", nil, row)
    row.sourceHitbox:SetPoint("TOPLEFT", row, "TOPLEFT", COL_SOURCE_X, 0)
    row.sourceHitbox:SetSize(COL_SOURCE_W, ROW_HEIGHT)

    -- "Уже был" - галочка справа в строке. Держится в SavedVariables по itemID,
    -- так что переживает перезаход. Отмеченная строка гаснет, чтобы пройденное
    -- было видно одним взглядом, не вчитываясь.
    row.done = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.done:SetSize(22, 22)
    row.done:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    StyleCheckBox(row.done, 10)
    row.done:SetScript("OnClick", function(self)
        if not row.itemID then return end
        if row.markState == "bis" then
            self:SetChecked(true)
            return
        end
        -- Снятие отметки у рарника «раз на персонажа» - только Ctrl: на дневном
        -- сбросе она не уйдёт, а факт убийства случился. Ctrl - лазейка от промаха.
        if row.markState and not row.daily and not IsControlKeyDown() then
            self:SetChecked(true)
            return
        end
        TrialGearFinderCharDB = TrialGearFinderCharDB or {}
        TrialGearFinderCharDB.done = TrialGearFinderCharDB.done or {}
        if self:GetChecked() then
            -- Ручная отметка «убил, не выпало»: как автоматическая, запоминаем
            -- число копий сейчас - дальше цвет считается от его роста.
            TrialGearFinderCharDB.done[row.itemID] =
                C_Item.GetItemCount(row.itemID, true, false, true) or 0
        else
            TrialGearFinderCharDB.done[row.itemID] = nil
        end
        RefreshResults()
    end)
    row.done:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        -- Текст ровно про тот цвет, что человек видит. Состояние - в row.markState,
        -- считается в BuildRowData от того, что случилось в этот заход к рарнику.
        local st = row.markState
        if st == "bis" then
            GameTooltip:AddLine("BiS-версия на руках", 0.2, 1, 0.2)
            GameTooltip:AddLine("Отметка залипла навсегда: к этому рарнику можно больше не ходить.",
                1, 1, 1, true)
        elseif st == "worse" then
            GameTooltip:AddLine("Выпала не BiS-версия", 1, 0.2, 0.2)
            if type(row.ownedDiffs) == "table" then
                for _, d in ipairs(row.ownedDiffs) do
                    GameTooltip:AddLine("  " .. FormatDiffLine(d), 1, 1, 1)
                end
            elseif (row.ownedCount or 0) > 0 then
                GameTooltip:AddLine("Копия где-то есть, но прочитать её не удалось - похоже, в закрытом банке или у другого персонажа.",
                    0.7, 0.72, 0.75, true)
            end
            if row.daily then
                GameTooltip:AddLine("Рарник ежедневный: на дневном сбросе кружок опустеет, можно прийти снова за BiS-версией.",
                    0.7, 0.72, 0.75, true)
            else
                GameTooltip:AddLine("Рарник даётся раз на персонажа - BiS-версии уже не будет. Отметил по ошибке: Ctrl+щелчок.",
                    0.7, 0.72, 0.75, true)
            end
        elseif st == "nodrop" then
            GameTooltip:AddLine("Рарник убит, нужная вещь не выпала", 1, 0.82, 0)
            if row.daily then
                GameTooltip:AddLine("На дневном сбросе кружок опустеет - можно прийти снова.",
                    1, 1, 1, true)
            else
                GameTooltip:AddLine("Рарник даётся раз на персонажа, вещь не выпала - слот придётся закрывать другой. Отметил по ошибке: Ctrl+щелчок.",
                    0.7, 0.72, 0.75, true)
            end
        else
            GameTooltip:AddLine("Отметить: рарник убит, нужная вещь не выпала", 1, 0.82, 0)
            GameTooltip:AddLine("Ставится сама при убийстве. Старые вещи в сумке на цвет не влияют - пока не сходишь к рарнику, кружок пуст.",
                0.7, 0.72, 0.75, true)
        end
        GameTooltip:Show()
    end)
    row.done:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.sourceHitbox:EnableMouse(true)
    function row:ShowSourceTooltip()
        if not frame:IsShown() then return end -- window closed: nothing to describe
        if not self.fullSource then return end
        GameTooltip:SetOwner(self.sourceHitbox, "ANCHOR_TOPLEFT")
        -- Тот же цвет, что у источника в строке: золото подземельям, серебро
        -- рарникам. Раньше здесь стоял бледно-голубой, и подсказка расходилась
        -- со списком, из которого её открыли.
        local sc = self.srcColor or C.gold
        GameTooltip:AddLine(self.fullSource, sc[1], sc[2], sc[3], true)
        if self.fullNote and self.fullNote ~= "" then
            GameTooltip:AddLine(self.fullNote, 1, 1, 1, true)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Щелчок - поставить метку на карте", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end
    row.sourceHitbox:SetScript("OnMouseUp", function()
        if IsControlKeyDown() then
            SaveSourceWaypoint(row.fullSource, row.sourceType, row.itemID)
        else
            SetSourceWaypoint(row.fullSource, row.sourceType, row.itemID)
        end
    end)
    row.sourceHitbox:SetScript("OnEnter", function() row:ShowSourceTooltip() end)
    row.sourceHitbox:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Ребёнок с включённой мышью забирает её себе, а строка получает OnLeave -
    -- и выделение гасло, стоило навести на источник, значок или галочку.
    -- Вешаем возврат на всех троих сразу: чинить по одному значит оставить
    -- остальных сломанными. HookScript, а не SetScript - у каждого уже есть
    -- свой обработчик с подсказкой.
    for _, child in ipairs({ row.iconFrame, row.sourceHitbox, row.done }) do
        child:HookScript("OnEnter", function() row:HoverOn() end)
        child:HookScript("OnLeave", function() row:HoverOff() end)
    end

    function row:SetData(data)
        if not data then
            self:Hide()
            return
        end
        self:Show()
        self.icon:SetTexture(data.icon)
        local qc = data.qualityColor
        if qc then self.iconRing:SetVertexColor(qc[1], qc[2], qc[3], 1) end
        self.name:SetText(data.name)
        self.type:SetText(data.type)
        self.str:SetText(ColorStat(data.str))
        self.agi:SetText(ColorStat(data.agi))
        self.int:SetText(ColorStat(data.int))
        self.stam:SetText(ColorStat(data.stam))
        self.crit:SetText(ColorStat(data.crit))
        self.haste:SetText(ColorStat(data.haste))
        self.iskus:SetText(ColorStat(data.iskus))
        self.vers:SetText(ColorStat(data.vers))
        self.source:SetText(data.source or "")
        -- Золото - цвет подземелий в Обзоре приключений, и рарникам оно не идёт:
        -- источник там не подземелье, а точка в открытом мире. Делим по тому же
        -- признаку, по которому ставится галочка «уже был», - так две пометки
        -- в строке говорят об одном и том же.
        local srcColor = (data.sourceType == "World") and C.silver or C.gold
        self.source:SetTextColor(srcColor[1], srcColor[2], srcColor[3], 1)
        self.srcColor = srcColor -- тем же цветом источник пишется и в подсказке
        self.sourceboss:SetText(data.sourceboss or "")
        -- Галочка только у рарников и сокровищ (sourceType == "World"): они берутся
        -- раз в день или раз на персонажа, и есть смысл помнить, где уже был.
        -- Подземелья ходятся сколько угодно, там отмечать нечего.
        local trackable = data.sourceType == "World"
        self.done:SetShown(trackable)
        if not trackable then
            self.owned = nil
            self.markState, self.daily = nil, nil
            self:SetAlpha(1)
        else
            -- Цвет кружка = что случилось в этот заход к рарнику, а не что лежит
            -- в сумке. Состояние считает BuildRowData:
            --   bis    - BiS-версия на руках, залипло навсегда (зелёный)
            --   worse  - в этот заход выпала не-BiS копия (красный, с разбором)
            --   nodrop - убил, нужное не выпало (жёлтый); уйдёт на дневном сбросе
            --   nil    - не фармил в этот цикл (пусто); старьё в сумке не в счёт
            local st = data.markState
            self.markState = st
            self.daily = data.source and data.source:find(DAILY_SOURCE_MARK, 1, true) ~= nil
            self.owned = data.owned
            self.ownedDiffs = data.ownedDiffs
            self.ownedCount = data.ownedCount
            self.done:SetChecked(st ~= nil)
            if st then
                local tex = self.done:GetCheckedTexture()
                if tex then
                    if st == "bis" then
                        tex:SetVertexColor(0.2, 1, 0.2)
                    elseif st == "worse" then
                        tex:SetVertexColor(1, 0.2, 0.2)
                    else
                        tex:SetVertexColor(1, 0.82, 0)
                    end
                end
            end
            -- BiS гасим сильнее: туда возвращаться незачем. Жёлтый/красный - ещё
            -- вернёшься (ежедневный) либо строка просто закрыта.
            self:SetAlpha(st == "bis" and 0.45 or (st and 0.7 or 1))
        end

        self.fullSource = data.source
        self.sourceType = data.sourceType
        self.fullNote = data.sourceboss
        self.hyperlink = data.hyperlink
        self.itemID = data.itemID
        self.twink = data.twink

        -- Scrolling the list reuses these same row frames for different items
        -- without the mouse ever leaving them, so OnEnter never refires. If the
        -- mouse happens to already be sitting on one, refresh its tooltip now.
        if self.iconFrame:IsMouseOver() then
            self:ShowItemTooltip()
        elseif self.sourceHitbox:IsMouseOver() then
            self:ShowSourceTooltip()
        end
    end

    return row
end

-- Строки лежат в content одной длинной стопкой и создаются по мере надобности:
-- сколько предметов в списке, столько и строк. Прокрутка двигает весь блок
-- целиком, поэтому ни окна обрезки, ни подмены данных при сдвиге больше нет -
-- scrollBox сам не рисует то, что вышло за его края.
local rows = {}

local function GetRow(index)
    local row = rows[index]
    if row then return row end

    row = CreateRow(index)
    row:SetParent(content)
    if index == 1 then
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    else
        row:SetPoint("TOPLEFT", GetRow(index - 1), "BOTTOMLEFT", 0, -ROW_SPACING)
    end
    row:Hide() -- пустая строка до первого SetData
    rows[index] = row
    return row
end

-- Экран строк вперёд: ApplyStatsLayout раскладывает уже созданные, и при первом
-- проходе ему нужно что-то разложить.
for i = 1, NUM_VISIBLE_ROWS do GetRow(i) end

-- Подложка под всю стопку: скруглить углы у отдельной строки нельзя - текстура
-- скругляет сразу все четыре, и по краям стопки вылезли бы насечки. Поэтому
-- один скруглённый блок под списком, а нечётные строки прозрачные и показывают
-- его - первая как раз нечётная, её верхний угол и скруглён. Нижний отдаёт
-- подложке последняя строка, см. SetLastInList: какая она - зависит от фильтра.
-- Привязана к видимой области, а не к строкам: строки ездят, а подложка
-- со скруглением и рамкой должна стоять на месте.
local listBg = CreateFrame("Frame", nil, frame)
listBg:SetFrameLevel(frame:GetFrameLevel()) -- под строками, они на уровень выше
listBg:SetPoint("TOPLEFT", scrollArea, "TOPLEFT", 0, 0)
listBg:SetPoint("BOTTOMRIGHT", scrollArea, "BOTTOMRIGHT", -SCROLLBAR_PAD, 0)
-- Рамкой, а не осветлением блока: фон окна #060708 и блок #101113 по яркости
-- почти совпадают, и поднимать блок пришлось бы заметно - он перестал бы быть
-- фоном для строк. Контур даёт границу, не трогая заливку.
RoundedPanel(listBg, C.block, C.border)
------------------------------------------------------------
-- "Мин-Макс" toggle: off = plain list (item + source only), on = the full stat
-- table. The stat block is 339px wide, but the four filter dropdowns underneath
-- need ~640, so 660 is as narrow as the window usefully gets.
------------------------------------------------------------

local FRAME_WIDTH_FULL, FRAME_WIDTH_NARROW = 880, 660
-- Simple mode keeps only Слот and Класс; these two are for the full table.
-- Что прячется в простом режиме. Источник отсюда убран: без него не понять,
-- куда идти за вещью, а это первое, зачем в список и заходят. Броня остаётся
-- только в полной таблице - она сужает выбор, а не объясняет его.
local FULL_MODE_DROPS = { armorDrop }
-- Rows shrink by exactly as much as the window does, so the list still fills it
-- edge to edge instead of leaving a dead strip on the right.
local ROW_WIDTH_NARROW = ROW_WIDTH - (FRAME_WIDTH_FULL - FRAME_WIDTH_NARROW)
local STAT_COLS = { "str", "agi", "int", "stam", "crit", "haste", "iskus", "vers" }

-- Label above, checkbox under it, top-right corner of the window.
local statsToggle = CreateFrame("CheckButton", "TrialGearFinderStatsToggle", frame, "UICheckButtonTemplate")
statsToggle:SetSize(24, 24)
StyleCheckBox(statsToggle, 11) -- тумблер без состояний: кружок остаётся белым

-- Подпись живёт на шапке, а не на самом квадратике: квадратик теперь привязан
-- к ней, и будь она его же регионом - вышла бы круговая зависимость.
statsToggle.label = frame.titleBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
-- Цепочка привязки развёрнута: подпись держится за окно, квадратик - за подпись.
-- Иначе не выходит одновременно и не вылезать за правый край (подпись втрое
-- шире квадратика), и стоять по её центру.
statsToggle.label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -48)
statsToggle:SetPoint("TOP", statsToggle.label, "BOTTOM", 0, -2)
statsToggle.label:SetText("Мин-Макс")
-- Шрифт GameFontNormalSmall золотой - единственное золото в окне после перехода
-- на свою палитру. Белым, как подписи колонок.
statsToggle.label:SetTextColor(C.text[1], C.text[2], C.text[3])

-- Тумблер «Комьюнити»: слева от «Мин-Макс». Включён - в списке появляются
-- пред-BiS от сообщества (BiS_Community.lua), помеченные «пред-BiS».
local commToggle = CreateFrame("CheckButton", "TrialGearFinderCommToggle", frame, "UICheckButtonTemplate")
commToggle:SetSize(24, 24)
StyleCheckBox(commToggle, 11)
commToggle.label = frame.titleBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
commToggle.label:SetPoint("TOPRIGHT", statsToggle.label, "TOPLEFT", -16, 0)
commToggle:SetPoint("TOP", commToggle.label, "BOTTOM", 0, -2)
commToggle.label:SetText("Комьюнити")
commToggle.label:SetTextColor(C.text[1], C.text[2], C.text[3])
commToggle:SetScript("OnClick", function()
    TrialGearFinderDB = TrialGearFinderDB or {}
    TrialGearFinderDB.showCommunity = not TrialGearFinderDB.showCommunity
    commToggle:SetChecked(TrialGearFinderDB.showCommunity and true or false)
    RefreshResults()
end)

local function UpdateToggleVisual(on)
    statsToggle:SetChecked(on)
    commToggle:SetChecked(TrialGearFinderDB and TrialGearFinderDB.showCommunity or false)
end

-- Source column slides left into the freed space and takes the extra width;
-- everything else keeps its position, so only these three move.
local function ApplyStatsLayout()
    local show = TrialGearFinderDB and TrialGearFinderDB.showStats or false
    local sourceX = show and COL_SOURCE_X or COL_STR_X
    local rowWidth = show and ROW_WIDTH or ROW_WIDTH_NARROW
    local sourceW = rowWidth - sourceX - 34 -- 34: место под галочку «уже был»

    frame:SetWidth(show and FRAME_WIDTH_FULL or FRAME_WIDTH_NARROW)

    -- Header carries the rows with it (row 1 anchors to it), so centring the
    -- header centres the whole list: equal margin left and right.
    header:ClearAllPoints()
    -- Сдвиг влево на пол-полосы. Шапка задаёт положение всего списка, но справа
    -- к нему прицеплена полоса прокрутки - она висит СНАРУЖИ, за правым краем
    -- строк. Центрируя одну шапку, мы получали блок «список + полоса», съехавший
    -- вправо ровно на её ширину. Половину отдаём влево, и видимый блок встаёт
    -- по центру окна - как футер с фильтрами.
    header:SetPoint("TOP", frame, "TOP", -SCROLLBAR_PAD / 2, -106)
    header:SetWidth(rowWidth)
    for _, drop in ipairs(FULL_MODE_DROPS) do drop:SetShown(show) end
    if not show then
        -- Спрятанный фильтр с выбором отсеивал бы список без видимой причины.
        filters.armor = "ALL"
        armorDrop:SetSelected("ALL")
    end
    -- Источник цепляется за броню, а она в простом режиме спрятана. Привязка
    -- к спрятанному фрейму работает, но оставляет на его месте дыру, поэтому
    -- перецепляем на класс.
    sourceDrop:ClearAllPoints()
    sourceDrop:SetPoint("LEFT", show and armorDrop or classDrop, "RIGHT", 4, 0)

    -- Filters are centred as a group: width is measured from the actual dropdowns
    -- so it works for three of them as well as four. The rest chain off the first.
    local groupWidth = slotDrop:GetWidth() + classDrop:GetWidth() + sourceDrop:GetWidth() + 8
    if show then
        groupWidth = groupWidth + armorDrop:GetWidth() + 4
    end
    slotDrop:ClearAllPoints()
    slotDrop:SetPoint("LEFT", footer, "CENTER", -groupWidth / 2, 0)

    UpdateToggleVisual(show)

    for _, key in ipairs(STAT_COLS) do
        local entry = headerLabels[key]
        if entry then entry.fs:SetShown(show) end
    end
    local srcEntry = headerLabels.source
    if srcEntry then
        srcEntry.fs:ClearAllPoints()
        srcEntry.fs:SetPoint("TOPLEFT", header, "TOPLEFT", sourceX, 0)
        srcEntry.fs:SetWidth(sourceW)
    end

    for _, row in ipairs(rows) do
        row:SetWidth(rowWidth)
        for _, key in ipairs(STAT_COLS) do
            if row[key] then row[key]:SetShown(show) end
        end
        row.source:ClearAllPoints()
        row.source:SetPoint("TOPLEFT", row, "TOPLEFT", sourceX, -4)
        row.source:SetWidth(sourceW)
        row.sourceboss:SetWidth(sourceW)
        row.sourceHitbox:ClearAllPoints()
        row.sourceHitbox:SetPoint("TOPLEFT", row, "TOPLEFT", sourceX, 0)
        row.sourceHitbox:SetWidth(sourceW)
    end
end

statsToggle:SetScript("OnClick", function(self)
    TrialGearFinderDB.showStats = not TrialGearFinderDB.showStats
    if not TrialGearFinderDB.showStats then
        -- With the columns gone a stat filter would silently keep filtering the
        -- list with no visible reason, so drop it along with its sort.
        wipe(statFilter)
        if sortState.key and sortState.key ~= "source" then
            sortState.key, sortState.dir = nil, "DESC"
        end
        UpdateHeaderSortIndicators()
    end
    ApplyStatsLayout()
    RefreshResults()
end)


------------------------------------------------------------
-- Filtering + rendering
------------------------------------------------------------

-- Which classes can have a given stat as their primary. Paladin/Druid/Monk/Shaman
-- are split across two (their spec decides which), everyone else is fixed.
local STAT_TO_CLASSES = {
    str = { "WARRIOR", "DEATHKNIGHT", "PALADIN" },
    agi = { "HUNTER", "ROGUE", "DEMONHUNTER", "DRUID", "MONK", "SHAMAN" },
    int = { "PRIEST", "MAGE", "WARLOCK", "EVOKER", "PALADIN", "DRUID", "MONK", "SHAMAN" },
}

-- Wowhead only publishes a "these specs can loot it" list for stat-restricted
-- armor - trinkets and proc weapons never get one, so item.classes == nil there
-- just means "no data", not "any class". When the item's own stats show exactly
-- one primary stat (not the 0-or-all-three universal-proc pattern), infer the
-- likely classes from that stat instead of showing it to everyone.
local function InferClassesFromStats(stats)
    local present = {}
    for _, key in ipairs({ "str", "agi", "int" }) do
        if stats[key] and stats[key] > 0 then table.insert(present, key) end
    end
    if #present == 1 then return STAT_TO_CLASSES[present[1]] end
    return nil
end

-- Cheap check using only static Data.lua fields (no item API calls). item.classes
-- comes straight from Wowhead's "players can loot this by picking these specs"
-- list; when that's missing, fall back to the primary-stat inference above.
local function PassesStaticFilters(item)
    if filters.class ~= "ALL" then
        local classes = item.classes or InferClassesFromStats(item.stats or {})
        if classes then
            local allowed = false
            for _, c in ipairs(classes) do
                if c == filters.class then allowed = true break end
            end
            if not allowed then return false end
        end
    end
    if filters.sourceType ~= "ALL" and item.sourceType ~= filters.sourceType then return false end
    return true
end

-- Name/icon/quality/slot come live via C_Item.GetItemInfo on the bonus-included
-- link - quality specifically CAN change with bonus IDs (some bonuses cap an item
-- at Rare instead of its natural Epic), so the plain itemID isn't safe here either.
-- Item level/armor/sockets/stats come from Data.lua instead, scraped straight from
-- Wowhead for the guide's exact bonus/ilvl - NOT from this link's own GetItemStats,
-- because these old items scale by a curve we can't reliably reproduce (see the
-- BuildItemLink comment). Returns nil while the client hasn't cached the item yet;
-- RefreshResults retries on GET_ITEM_INFO_RECEIVED.
local function BuildRowData(item)
    local link = BuildItemLink(item.itemID, item.bonusIDs or {})
    local name, _, quality, _, _, _, itemSubType, _, equipLoc, icon, _, classID, subclassID =
        C_Item.GetItemInfo(link)

    if not name then
        C_Item.RequestLoadItemDataByID(item.itemID)
        return nil
    end

    -- Categories still being worked on (neck, rings) are kept out of the list
    -- entirely, not just out of the Слот dropdown.
    if HIDDEN_INVTYPES[equipLoc] then return false end

    -- Вещи одной фракции. Пока такая пара одна - фамильный знак различия,
    -- у Орды и Альянса это два разных itemID с одинаковыми статами. Показываем
    -- только свой: чужой всё равно не надеть, а в списке он сбивает.
    if item.faction and item.faction ~= playerFaction then return false end

    if filters.search ~= "" then
        -- Name, note AND source, so typing a dungeon lists everything that drops there.
        local haystack = FoldCase(name) .. " " .. FoldCase(item.note or "")
            .. " " .. FoldCase(item.source or "")
        if not haystack:find(filters.search, 1, true) then return false end
    end

    -- Отмеченные кликом статы: у предмета должны быть все сразу.
    for statKey in pairs(statFilter) do
        local value = (item.stats or {})[statKey]
        if not value or value <= 0 then return false end
    end

    if filters.slot ~= "ALL" then
        local def
        for _, d in ipairs(SLOT_DEFS) do
            if d.key == filters.slot then
                def = d
                break
            end
        end
        if not def or not def.invTypes[equipLoc] then return false end
    end

    if filters.armor ~= "ALL" then
        if classID ~= ARMOR_CLASS_ID or subclassID ~= filters.armor then
            return false
        end
    end

    -- Цвет качества нужен и текстом (в названии), и числами (обводка значка).
    local qR, qG, qB, qualityHex = C_Item.GetItemQualityColor(quality)
    -- Armor material by numeric subclassID, slot by our own table: itemSubType and
    -- _G[equipLoc] are both client-localized and came out English on an EN client.
    local slotLabel = INVTYPE_RU[equipLoc] or _G[equipLoc] or equipLoc
    local materialLabel
    if classID == ARMOR_CLASS_ID then
        for _, sub in ipairs(ARMOR_SUBCLASSES) do
            if sub.id == subclassID then materialLabel = sub.label break end
        end
    end
    -- Подпись не повторяет то, что уже сказано фильтром: при «Слот: Голова»
    -- приписка «(Голова)» стоит в каждой строке и не несёт ничего, при
    -- «Броня: Ткань» - то же самое со словом «Ткань». Уровень остаётся всегда,
    -- он у предметов разный.
    local armorFree, slotFree = filters.armor == "ALL", filters.slot == "ALL"
    local showMaterial = materialLabel and armorFree
    local showSlot = slotFree
    local typeLabel
    if showMaterial and showSlot then
        typeLabel = string.format("%s (%s)", materialLabel, slotLabel)
    elseif showMaterial then
        typeLabel = materialLabel
    elseif showSlot then
        typeLabel = slotLabel
    else
        typeLabel = ""
    end
    -- Уровень тоже убираем, как только включён любой фильтр: строка под
    -- названием должна быть тихой, а не повторять то, что и так выбрано сверху.
    if item.ilvl and armorFree and slotFree then
        local lvl = string.format("%d ур.", item.ilvl)
        typeLabel = typeLabel ~= "" and (typeLabel .. " | " .. lvl) or lvl
    end
    local stats = item.stats or {}

    -- Вещь на руках сверяем с базой: рарник мог упасть без суффикса или другого
    -- уровня, и тогда это не тот предмет, который расписан как BiS.
    -- Считается только для реально имеющихся вещей, поэтому дёшево.
    -- Счётчик держим числом, а не превращаем сразу в да/нет: когда вещь
    -- числится, но найти её негде, единственное, что можно показать игроку, -
    -- это само число, по которому аддон и решил, что вещь есть.
    local ownedCount = C_Item.GetItemCount(item.itemID, true, false, true) or 0
    local owned = ownedCount > 0
    local ownedDiffs
    if owned then
        local ownedLink = FindOwnedLink(item.itemID)
        local live
        if ownedLink then
            live = ScanItemLink(ownedLink)
            -- Запоминаем ЗАМЕР живой вещи, а не готовый вывод. Содержимое банка
            -- игра отдаёт только пока он открыт, и без этой памяти вещь оттуда
            -- вдали от банка выглядела бы непроверенной.
            --
            -- Сначала запоминался именно вывод - и он протух в тот же день:
            -- поправили статы плащей в Data.lua, а подсказка на вещь из банка
            -- ещё показывала расхождения, посчитанные до правки. Вывод зависит
            -- от базы, а её правят постоянно; замер живой вещи не меняется.
            TrialGearFinderDB = TrialGearFinderDB or {}
            TrialGearFinderDB.compared = nil -- прежняя память выводов, формат другой
            TrialGearFinderDB.seen = TrialGearFinderDB.seen or {}
            TrialGearFinderDB.seen[item.itemID] = {
                ilvl = live.ilvl, stats = live.stats, socketTypes = live.socketTypes,
            }
        else
            live = TrialGearFinderDB and TrialGearFinderDB.seen
                and TrialGearFinderDB.seen[item.itemID]
        end

        if live then
            -- Уровень из сверки выброшен: база хранит вещь, отмасштабированную нашей
            -- связкой bonusIDs, а копия в сумке считает уровень по уровню персонажа -
            -- на не-двадцатке расхождение будет всегда и ни о чём не говорит.
            -- Гнездо сверяем наравне со статами: у вещей с рарников именно оно
            -- и делает копию BiS-версией, без него вещь надо перефармливать.
            local diffs = {}
            for _, d in ipairs(DiffData(item, live)) do
                if not (d.label or ""):find("уровню предмета", 1, true) then
                    table.insert(diffs, d)
                end
            end
            diffs = DropBalancedSocketDiffs(diffs)
            ownedDiffs = (#diffs == 0) and true or diffs
        else
            -- Вещь числится по счётчику, ссылки нет, замера в памяти тоже -
            -- сверять не с чем, и это НЕ то же самое, что «отличается».
            -- Раньше здесь оставался nil: он проходил проверку `~= true`,
            -- вещь краснела, а список расхождений был пуст - подсказка обещала
            -- причины, которых никто не считал.
            ownedDiffs = false
        end
    end

    -- Состояние кружка у рарника/сокровища. Считается от того, ЧТО СЛУЧИЛОСЬ
    -- в этот заход, а не от содержимого сумок: старая копия сама по себе кружок
    -- не красит. "bis" - BiS-версия на руках (залипает навсегда), "worse" - в
    -- этот заход выпала не-BiS копия, "nodrop" - убил, нужное не выпало, nil -
    -- не фармил в этот цикл.
    local markState
    if item.sourceType == "World" then
        TrialGearFinderCharDB = TrialGearFinderCharDB or {}
        local bisSeen = TrialGearFinderCharDB.bis
        if bisSeen and bisSeen[item.itemID] then
            markState = "bis"
        elseif owned and ownedDiffs == true then
            -- BiS-версия на руках (в т.ч. с давних пор) - подтверждаем и залипаем.
            -- ponytail: если база потом опишет версию лучше, кружок останется
            -- зелёным - «залипло навсегда», как и просили; настоящую разницу
            -- всё равно покажет /tgf scan.
            TrialGearFinderCharDB.bis = TrialGearFinderCharDB.bis or {}
            TrialGearFinderCharDB.bis[item.itemID] = true
            markState = "bis"
        else
            local mark = TrialGearFinderCharDB.done and TrialGearFinderCharDB.done[item.itemID]
            if mark ~= nil then
                -- true - отметка старого формата или ручная без базы сравнения:
                -- берём текущий счётчик, чтобы не показать ложный «worse».
                local baseline = (type(mark) == "number") and mark or ownedCount
                markState = (ownedCount > baseline) and "worse" or "nodrop"
            end
        end
    end

    return {
        icon = icon,
        name = string.format("|c%s%s|r", qualityHex, name)
            .. (ns_CommunityID[item.itemID] and "  |cff9a9a9aпред-BiS|r" or ""),
        rawName = name,
        community = ns_CommunityID[item.itemID] or nil,
        qualityColor = { qR or 1, qG or 1, qB or 1 },
        -- Ручной порядок внутри слота. Меньше - выше. Ставится в Data.lua
        -- только там, где догадка по заметке промахивается.
        rank = item.rank,
        type = typeLabel,
        equipLoc = equipLoc,
        subclassID = classID == ARMOR_CLASS_ID and subclassID or nil,
        itemID = item.itemID,
        -- Есть в сумках, банке или надета - значит уже забрана.
        -- includeBank/includeReagentBank выставлены, чтобы не пропустить лежащее в банке.
        owned = owned,
        -- Совпадает ли выпавшая копия с тем, что записано как BiS. nil - вещи нет,
        -- true - всё сходится, иначе список расхождений для подсказки.
        ownedDiffs = ownedDiffs,
        ownedCount = ownedCount,
        markState = markState, -- "bis" | "worse" | "nodrop" | nil, см. выше
        -- Номер карты из метки: по нему рарники группируются по зонам.
        mapID = (function()
            local key = PinKey(item.sourceType, item.itemID, item.source)
            local saved = TrialGearFinderDB and TrialGearFinderDB.pins
            local pin = (saved and saved[key]) or SOURCE_PINS[key]
            return pin and pin[1] or 9999
        end)(),
        str = stats.str,
        agi = stats.agi,
        int = stats.int,
        stam = stats.stam,
        crit = stats.crit,
        haste = stats.haste,
        iskus = stats.iskus,
        vers = stats.vers,
        source = item.source,
        sourceType = item.sourceType,
        sourceboss = item.note,
        hyperlink = link,
        twink = {
            ilvl = item.ilvl, armor = item.armor, sockets = item.sockets, stats = stats,
            socketTypes = item.socketTypes, socketBonus = item.socketBonus,
        },
    }
end

RefreshResults = function()
    local matches = {}
    local pending = false

    local function collect(list)
        for _, item in ipairs(list) do
            if PassesStaticFilters(item) then
                local rowData = BuildRowData(item)
                if rowData == nil then
                    pending = true
                elseif rowData ~= false then
                    table.insert(matches, rowData)
                end
            end
        end
    end

    collect(ns.Items)
    -- Пред-BiS от сообщества — только по тумблеру «Комьюнити».
    if TrialGearFinderDB and TrialGearFinderDB.showCommunity and ns.CommunityItems then
        collect(ns.CommunityItems)
    end

    if #matches == 0 then
        for _, row in ipairs(rows) do row:Hide() end
        content:SetHeight(1)
        scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
        emptyText:Show()
        emptyText:SetText(pending and "|cFF888888Загрузка данных...|r"
            or "|cFF888888Нет предметов под эти фильтры.|r")
        return
    end

    if sortState.key then
        local key = sortState.key
        local ascending = sortState.dir == "ASC"
        local function value(entry)
            if key == "source" then return entry.source or "" end
            return entry[key] or 0
        end
        table.sort(matches, function(a, b)
            if ascending then return value(a) < value(b) end
            return value(a) > value(b)
        end)
    else
        -- Standard order: grouped by slot (head, neck, shoulder, ... down to
        -- trinkets, then weapons), matching SLOT_DEFS - not insertion order.
        -- Exception: with the Рарники filter on, zone comes first - they are
        -- farmed by flying around a zone, not by gear slot.
        table.sort(matches, function(a, b)
            -- При фильтре по рарникам сперва группируем по месту: список тогда
            -- читается как маршрут - Зандалар отдельно, Кул-Тирас отдельно,
            -- Дренор отдельно, - а не как набор слотов вразнобой. Раньше здесь
            -- стоял только mapID, а у рарников он не проставлен, и группировка
            -- молча не работала.
            if filters.sourceType == "World" and (a.source or "") ~= (b.source or "") then
                return (a.source or "") < (b.source or "")
            end
            if filters.sourceType == "World" and (a.mapID or 9999) ~= (b.mapID or 9999) then
                return (a.mapID or 9999) < (b.mapID or 9999)
            end
            local rankA, rankB = SlotRank(a.equipLoc), SlotRank(b.equipLoc)
            if rankA ~= rankB then return rankA < rankB end
            -- Within the same slot: Cloth, Leather, Mail, Plate (ARMOR_SUBCLASSES'
            -- own id order already matches that sequence) before by-name.
            local subA, subB = a.subclassID or 99, b.subclassID or 99
            if subA ~= subB then return subA < subB end
            -- Затем по полезности. Сначала ручной rank из Data.lua: он бьёт
            -- любую догадку, потому что какая вещь лучшая в слоте - знание
            -- игры, а не свойство данных.
            local rankA, rankB2 = a.rank or 99, b.rank or 99
            if rankA ~= rankB2 then return rankA < rankB2 end
            -- И только потом оценка по заметке, для записей без rank.
            local noteA, noteB = NoteRank(a.sourceboss), NoteRank(b.sourceboss)
            if noteA ~= noteB then return noteA < noteB end
            -- Then by zone, so вещи из одного места стоят рядом и их удобно
            -- собирать за один заход - иначе Дренор и Кул-Тирас чередуются.
            local mapA, mapB = a.mapID or 9999, b.mapID or 9999
            if mapA ~= mapB then return mapA < mapB end
            return (a.rawName or "") < (b.rawName or "")
        end)
    end

    emptyText:Hide()

    -- Строк ровно столько, сколько предметов. Высота content - вся стопка,
    -- по ней игра сама считает и ход полосы, и размер ползунка, и прокручивает
    -- по пикселям. Лишние строки прячем, а не удаляем: при следующем показе
    -- пригодятся.
    local poolSize = #rows
    for i = 1, #matches do
        local row = GetRow(i)
        row:SetData(matches[i])
        row:SetLastInList(i == #matches)
    end
    for i = #matches + 1, #rows do
        rows[i]:Hide()
    end
    -- Новые строки рождаются с шириной и колонками по умолчанию; раскладка
    -- знает текущий режим Мин-Макс и приводит их в общий вид.
    if #rows > poolSize then ApplyStatsLayout() end

    content:SetWidth(math.max(scrollBox:GetWidth(), 1))
    content:SetHeight(#matches * ROW_PITCH - ROW_SPACING)
    scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
end

-- Автоотметка «был здесь». Скрытый квестовый флаг рарника знал бы это точно, но
-- его id в базе нет ни для одного моба. Поэтому ловим смерть моба в боевом логе:
-- цель после смерти рарника обычно уже сброшена, а лог называет погибшего прямо.
-- Имя моба из игры и текст заметки - оба на языке клиента, но совпадать буква
-- в букву они не обязаны, и прямое сравнение их разводило уже дважды:
--   регистр  - в игре «Сквиргл-Из-Глубин», в заметке «Сквиргл-из-Глубин»;
--   апостроф - в игре «Темноуст Джо'ла», в заметке «Темноуст Джола».
-- Поэтому перед сравнением обе стороны приводим к общему виду: опускаем регистр
-- и выбрасываем апострофы с дефисами - в именах WoW это украшение, а не смысл.
--
-- string.lower кириллицу не берёт: она в UTF-8 двухбайтная, а lower работает
-- побайтно. Хуже того, на байты выше 127 он смотрит по локали, и предсказать
-- его поведение нельзя - в кодировке Windows-1251 он бы порвал UTF-8 пополам.
-- Поэтому не зовём его вовсе, а переводим сами: латиницу по A-Z, кириллицу
-- по таблице. А-Я это D0 90..AF, при этом D0 90..9F → D0 B0..BF,
-- а D0 A0..AF → D1 80..8F; отдельно Ё (D0 81) → ё (D1 91).
local function NormalizeName(s)
    s = s:gsub("[A-Z]", function(c) return string.char(c:byte() + 32) end)
    s = s:gsub("\208([\144-\175])", function(c)
        local b = c:byte()
        if b <= 0x9F then return "\208" .. string.char(b + 0x20) end
        return "\209" .. string.char(b - 0x20)
    end)
    s = s:gsub("\208\129", "\209\145")
    -- Типографский апостроф - целой последовательностью, а не набором байтов:
    -- его 80 и 99 встречаются хвостами в других буквах (у «р» это D1 80),
    -- и выбрасывать их поодиночке значило бы рвать кириллицу.
    s = s:gsub("\226\128\153", "")
    return (s:gsub("['%-]", "")) -- прямой апостроф и дефис - оба ASCII, безопасно
end

-- Считается один раз: в бою эта функция вызывается на каждую смерть, и перебирать
-- всю базу из 122 записей там ни к чему - рарников всего два с половиной десятка.
local rareItems
local function MarkKilledByName(name)
    if not name then return end
    -- В Midnight UnitName у части юнитов возвращает «секретное» значение, пока
    -- код аддона в стеке (защита от автоматизации). Сравнивать его нельзя —
    -- по такому имени отметку просто не ставим.
    if issecretvalue and issecretvalue(name) then return end
    if name == "" then return end

    if not rareItems then
        rareItems = {}
        for _, item in ipairs(ns.Items) do
            if item.sourceType == "World" and item.note then
                -- Заметку опускаем один раз при сборке, а не на каждую смерть.
                table.insert(rareItems, { item = item, note = NormalizeName(item.note) })
            end
        end
    end

    TrialGearFinderCharDB = TrialGearFinderCharDB or {}
    TrialGearFinderCharDB.done = TrialGearFinderCharDB.done or {}
    local needle = NormalizeName(name)
    local marked
    for _, entry in ipairs(rareItems) do
        local id = entry.item.itemID
        if entry.note:find(needle, 1, true) and TrialGearFinderCharDB.done[id] == nil then
            -- Запоминаем ЧИСЛО копий предмета в момент убийства. Дальше по росту
            -- этого числа BuildRowData понимает, выпало что-то с рарника или нет:
            -- старая вещь в сумке счётчик не двигает.
            -- ponytail: при мгновенном автолуте LOOT_OPENED может прийти уже
            -- после подбора - тогда база включит дроп и «не-BiS» покажется как
            -- «не выпало» (жёлтый вместо красного). Оба сбрасываются одинаково.
            TrialGearFinderCharDB.done[id] = C_Item.GetItemCount(id, true, false, true) or 0
            marked = name
        end
    end
    if marked then
        print(string.format("|cFFFFD100[TGF]|r Отмечен как убитый: %s", marked))
        if frame:IsShown() then RefreshResults() end
    end
end

frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:RegisterEvent("ADDON_LOADED") -- SavedVariables only exist by the time this fires
frame:RegisterEvent("PLAYER_LOGIN")  -- UnitClass is reliable from here on
frame:RegisterEvent("BAG_UPDATE_DELAYED")     -- picked something up: recheck the "owned" ticks
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
-- Смерть рарника ловим по трупу: боевой лог клиент этому аддону регистрировать
-- не даёт (ADDON_ACTION_FORBIDDEN), а эти события открыты.
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT"
        or event == "LOOT_OPENED" or event == "PLAYER_REGEN_ENABLED" then
        for _, unit in ipairs({ "target", "mouseover" }) do
            if UnitExists(unit) and UnitIsDead(unit) then MarkKilledByName(UnitName(unit)) end
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        -- Preselect the character's own class: on a twink you almost always want
        -- your own gear, and "Класс: Все" is one click away when you don't.
        local _, classToken = UnitClass("player")
        if classToken then
            filters.class = classToken
            classDrop:SetSelected(classToken)
        end
        -- Фракция для отсева вещей чужой стороны. Здесь же, а не при
        -- выполнении файла: до входа UnitFactionGroup возвращает nil.
        playerFaction = UnitFactionGroup("player")

        -- Разовый перенос старых отметок из общего хранилища в персонажное.
        --
        -- Берём их ТОЛЬКО на двадцатке, и вот почему: набивал их тот, кто ходил
        -- по рарникам, а ходить по ним имеет смысл только двадцаткой - на других
        -- уровнях аддон и так показывает неверные числа. Если первым зайдёт
        -- девяностый, он чужих отметок не заберёт и не потеряет их: старая
        -- таблица остаётся на месте, пока за ней не придёт двадцатка.
        TrialGearFinderCharDB = TrialGearFinderCharDB or {}
        if not TrialGearFinderCharDB.migrated and UnitLevel("player") == 20 then
            local old = TrialGearFinderDB and TrialGearFinderDB.done
            if old and next(old) then
                TrialGearFinderCharDB.done = TrialGearFinderCharDB.done or {}
                local n = 0
                for itemID, v in pairs(old) do
                    if TrialGearFinderCharDB.done[itemID] == nil then
                        TrialGearFinderCharDB.done[itemID] = v
                        n = n + 1
                    end
                end
                TrialGearFinderCharDB.migrated = true
                if n > 0 then
                    print(string.format(
                        "|cFFFFD100[TGF]|r Отметки рарников теперь у каждого персонажа свои. Перенесено на этого: %d.", n))
                end
            end
        end

        if frame:IsShown() then RefreshResults() end
        return
    end

    if event == "ADDON_LOADED" then
        if addonName ~= "TrialGearFinder" then return end
        -- Перенос сохранений со старого имени. Аддон назывался TwinkGearFinder,
        -- и смена имени переменной сама по себе стёрла бы отметки «уже был»
        -- и запомненные метки у всех, кто уже пользовался сборкой. Старое имя
        -- оставлено в .toc вторым - только поэтому оно здесь ещё видно.
        --
        -- Условие именно на nil, а не на пустоту: переносим ровно один раз,
        -- дальше TrialGearFinderDB уже существует и старое не перетрёт новое.
        if TrialGearFinderDB == nil and TwinkGearFinderDB ~= nil then
            TrialGearFinderDB = TwinkGearFinderDB
            print("|cFFFFD100[TGF]|r Настройки перенесены со старого имени аддона.")
        end
        TrialGearFinderDB = TrialGearFinderDB or {}
        if TrialGearFinderDB.showStats == nil then TrialGearFinderDB.showStats = false end
        if TrialGearFinderDB.showCommunity == nil then TrialGearFinderDB.showCommunity = false end

        -- Отметки «убит» лежат ОТДЕЛЬНО, на персонажа. Лут у рарников «раз
        -- на персонажа» игра так и считает, а у нас отметки были общими:
        -- убил двадцаткой - и на девяностом уровне список показывал рарников
        -- пройденными. Поймано в игре 7 сентября 2026.
        --
        -- Метки карты, замеры вещей и настройки окна остаются общими: они
        -- от персонажа не зависят.
        TrialGearFinderCharDB = TrialGearFinderCharDB or {}

        ApplyStatsLayout()
        return
    end
    -- Only worth rebuilding while the window is up. This event fires whenever the
    -- client caches any item at all (passing players, auction house, bags), so
    -- without this the addon rebuilt all 121 rows hundreds of times a second in
    -- a busy city - top CPU consumer among addons and 199 MB of garbage.
    if frame:IsShown() then RefreshResults() end
end)

------------------------------------------------------------
-- Сброс отметок «был, но не выпало» на дневном сбросе.
--
-- Сбрасываем ТОЛЬКО ежедневных. Из 28 отмечаемых записей ежедневных семь -
-- дренорские; остальные 18 кул-тирасских берутся раз на персонажа и не
-- сбрасываются никогда. Стереть их значило бы стереть фарм, поэтому признак
-- ищем в тексте источника и по умолчанию НЕ трогаем ничего.
--
-- Час сброса у самой игры, а не «5 утра» числом: он разный по регионам,
-- и серверное время не совпадает с местным - у пользователя разница в час.
------------------------------------------------------------

local function NextDailyReset()
    if C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset then
        local secs = C_DateAndTime.GetSecondsUntilDailyReset()
        if secs and secs > 0 then return time() + secs end
    end
    return nil
end

local function ClearExpiredDailyMarks()
    -- Персонажное хранилище: дневной лок у рарников тоже персонажный, и граница
    -- сброса вместе с отметками должна лежать там же, иначе один персонаж
    -- сбрасывал бы счётчик другому.
    local db = TrialGearFinderCharDB
    if not db then return end

    -- Первый запуск: границу запоминаем, но ничего не стираем - иначе снесли бы
    -- отметки, поставленные до появления этой возможности.
    if not db.dailyResetAt then
        db.dailyResetAt = NextDailyReset()
        return
    end
    if time() < db.dailyResetAt then return end

    local cleared = 0
    for itemID in pairs(db.done or {}) do
        local item = ns_ItemsByID[itemID]
        if item and item.source and item.source:find(DAILY_SOURCE_MARK, 1, true) then
            db.done[itemID] = nil -- удалять текущий ключ внутри pairs разрешено
            cleared = cleared + 1
        end
    end
    db.dailyResetAt = NextDailyReset()
    if cleared > 0 then
        print(string.format("|cFFFFD100[TGF]|r Дневной сброс: снято отметок с ежедневных рарников - %d", cleared))
    end
end

-- При входе в игру. Через хук, а не в обработчике ADDON_LOADED: тот объявлен
-- выше по файлу и этой функции ещё не видит. PLAYER_LOGIN там уже зарегистрирован,
-- и к этому моменту SavedVariables загружены.
frame:HookScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then ClearExpiredDailyMarks() end
end)

frame:SetScript("OnShow", function()
    ClearExpiredDailyMarks() -- сброс мог случиться посреди сессии
    RefreshResults()
end)

------------------------------------------------------------
-- Кнопка на миникарте.
--
-- Без библиотеки: LibDBIcon тянет за собой LibStub и Ace, а нужно от неё
-- ровно две вещи - посадить кнопку на край круга и дать её таскать.
--
-- Кольцо и заливка - один и тот же circle.tga, покрашенный по-разному:
-- больший круг цветом рамки, поверх меньший цветом фона.
------------------------------------------------------------

local MINIMAP_DEFAULT_ANGLE = 200 -- левый нижний край, где обычно меньше всего чужих кнопок

local minimapButton = CreateFrame("Button", "TrialGearFinderMinimapButton", Minimap)
minimapButton:SetSize(31, 31)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8) -- поверх самой карты, но под её всплывашками

-- Кольцо своё, серебряное. Штатное золотое MiniMapTrackingBorder пробовали -
-- кнопка стала неотличима от дюжины соседей, все они в таком же золоте.
-- Отличать нас должен именно цвет кольца, это единственное, что выделяет
-- кнопку в общем ряду.
--
-- Но не во всю кнопку, как в первом заходе: у соседей значок занимает не весь
-- квадрат, и наш диск на 31 пиксель казался крупнее прочих при том же размере.
-- 26 - вровень с чужими кольцами.
local mmEdge = minimapButton:CreateTexture(nil, "BACKGROUND")
mmEdge:SetTexture(CIRCLE_TEXTURE)
mmEdge:SetSize(26, 26)
mmEdge:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
mmEdge:SetVertexColor(C.silver[1], C.silver[2], C.silver[3], 1)

local mmBody = minimapButton:CreateTexture(nil, "BACKGROUND", nil, 1)
mmBody:SetTexture(CIRCLE_TEXTURE)
mmBody:SetSize(22, 22)
mmBody:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
mmBody:SetVertexColor(C.bg[1], C.bg[2], C.bg[3], 1)

minimapButton.label = minimapButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- Сдвиг на пиксель вправо и вниз - подгонка, а не логика. У цифр коробка
-- шрифта включает место под нижние выносные элементы, поэтому геометрически
-- отцентрованный текст всегда садится выше середины. Плюс полпикселя даёт
-- сам круг. Если на другом клиенте уедет - крутить надо здесь.
minimapButton.label:SetPoint("CENTER", mmBody, "CENTER", 1, -1)
minimapButton.label:SetText("20")
minimapButton.label:SetTextColor(C.text[1], C.text[2], C.text[3])

-- Подсветка штатная: игра сама зажигает и гасит её по наведению, свой
-- обработчик цвета для этого не нужен.
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Угол хранится в градусах: так его читаемо видно в SavedVariables.
local function PlaceMinimapButton()
    local angle = math.rad((TrialGearFinderDB and TrialGearFinderDB.minimapAngle) or MINIMAP_DEFAULT_ANGLE)
    local radius = (Minimap:GetWidth() / 2) + 5
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle) * radius, math.sin(angle) * radius)
end
PlaceMinimapButton()

-- И ещё раз после входа: пока файл выполняется, SavedVariables не загружены,
-- и сохранённый угол оттуда не прочитать - кнопка встала бы на место по
-- умолчанию у всех, кто её однажды подвинул.
minimapButton:RegisterEvent("PLAYER_LOGIN")
minimapButton:SetScript("OnEvent", PlaceMinimapButton)

minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function(self)
    -- Считаем угол от центра карты до курсора каждый кадр, пока тащат.
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB.minimapAngle = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
        PlaceMinimapButton()
    end)
end)
minimapButton:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

minimapButton:SetScript("OnClick", function()
    if frame:IsShown() then frame:Hide() else frame:Show() end
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Trial Gear Finder")
    GameTooltip:AddLine("Щелчок - открыть окно", 0.6, 0.6, 0.6)
    GameTooltip:AddLine("Перетаскивание - двигать по краю карты", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Rows show the tooltip on OnEnter and hide it on OnLeave. Close the window while
-- the cursor sits on a row (Escape, /tgf, the X button) and OnLeave never fires,
-- leaving the tooltip stranded on screen with nothing under it.
frame:SetScript("OnHide", function() GameTooltip:Hide() end)

------------------------------------------------------------
-- /tgf scan: same ground-truth check as ShowItemTooltip above, run over every
-- equipped/bagged item in one pass and reported to chat.
------------------------------------------------------------

-- Returns "match", "mismatch", or nil (not one of our tracked BiS items).
local function CompareToLive(itemID, link)
    if not ns_ItemsByID[itemID] then return nil end

    -- Уровень не сверяем: в базе вещь отмасштабирована нашей связкой bonusIDs,
    -- а живая копия считает уровень по уровню персонажа. Гнёзда сверяем -
    -- у вещей с рарников гнездо и определяет BiS-версию.
    local diffs = {}
    for _, d in ipairs(DiffAgainstLive(itemID, ScanItemLink(link))) do
        if not (d.label or ""):find("уровню предмета", 1, true) then
            table.insert(diffs, d)
        end
    end

    diffs = DropBalancedSocketDiffs(diffs)
    if #diffs > 0 then
        local name = C_Item.GetItemNameByID(itemID) or ("item:" .. itemID)
        local parts = {}
        for _, d in ipairs(diffs) do table.insert(parts, (FormatDiffLine(d))) end
        print(string.format("|cFFFFD100[TGF]|r %s (id %d): %s", name, itemID, table.concat(parts, ", ")))
        return "mismatch"
    end
    return "match"
end

-- Hover ANY item in the game (equipped, bags, vendor, auction house...) that's
-- one of our tracked BiS entries, and its real live numbers get compared against
-- Data.lua right on the spot - no need to run /tgf scan and dig through chat.
-- (TooltipDataProcessor is the current API; the old GameTooltip:HookScript(
-- "OnTooltipSetItem", ...) was removed and throws "bad argument #2" now.)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
    if not ENABLE_COMPARISON then return end
    if tooltip == ScanTooltip then return end -- our own scanner triggers this too; don't recurse into it
    -- Fires for every item tooltip, including Blizzard's ShoppingTooltip1/2
    -- (the side-by-side gear comparison shown next to bag items), which don't
    -- support AddLine the way GameTooltip does.
    if type(tooltip.GetItem) ~= "function" or type(tooltip.AddLine) ~= "function" then return end
    local _, link = tooltip:GetItem()
    if not link then return end
    local itemID = C_Item.GetItemInfoInstant(link)
    if not itemID then return end

    -- Always name the exact database entry being compared against, so it's never
    -- ambiguous whether this is the same item's own recorded numbers or a
    -- stand-in recommendation for the slot.
    local dataItem, header
    dataItem = ns_ItemsByID[itemID]
    if dataItem then
        header = "[TGF] сравнение с базой (тот же предмет):"
    else
        -- Not one of our 103 tracked items by itemID - fall back to the closest
        -- same-slot recommendation so a random drop can still be gut-checked.
        dataItem = FindClosestDatabaseItem(link)
        if not dataItem then return end
        local closestName = C_Item.GetItemNameByID(dataItem.itemID) or ("item:" .. dataItem.itemID)
        header = "[TGF] сравнение с базой (ближайшая рекомендация: " .. closestName .. "):"
    end

    local diffs = DiffData(dataItem, ScanItemLink(link))
    if #diffs == 0 then return end

    tooltip:AddLine(" ")
    tooltip:AddLine(header, 1, 0.82, 0)
    AddDiffLines(tooltip, diffs)
    tooltip:Show()
end)

local function ScanOwnedItems()
    -- Разовый прогон по надетому и сумкам: печатает в чат всё, что расходится
    -- с базой. Не зависит от ENABLE_COMPARISON - тот отключает хук на чужие
    -- тултипы, а это ручная команда, лишнего никому не показывает.
    local checked, mismatched = 0, 0

    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        local itemID = GetInventoryItemID("player", slot)
        local link = itemID and GetInventoryItemLink("player", slot)
        if link then
            local status = CompareToLive(itemID, link)
            if status then
                checked = checked + 1
                if status == "mismatch" then mismatched = mismatched + 1 end
            end
        end
    end

    -- Тот же список контейнеров, что у поиска копии: иначе лежащее в банке
    -- команда молча пропускала, хотя вещь числится в наличии.
    for _, bag in ipairs(OWNED_CONTAINERS) do
        for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.hyperlink then
                local status = CompareToLive(info.itemID, info.hyperlink)
                if status then
                    checked = checked + 1
                    if status == "mismatch" then mismatched = mismatched + 1 end
                end
            end
        end
    end

    print(string.format("|cFFFFD100[TGF]|r Проверено %d предметов из базы (надето, сумки, банк если открыт), расхождений: %d", checked, mismatched))
end

------------------------------------------------------------
-- Slash command
------------------------------------------------------------

SLASH_TRIALGEARFINDER1 = "/tgf"
-- Команды разработчика. В релизе они не удалены, а спрятаны за флагом:
-- держать вторую сборку дороже, чем один переключатель, и расходятся сборки
-- ровно тогда, когда про них забудут. Включается /tgf dev, флаг живёт
-- в SavedVariables, так что делается это один раз на аккаунт.
--
-- scan и gems наружу оставлены намеренно: по ним пользователи присылают
-- отчёты о расхождениях, а это главный источник исправлений базы.
local DEV_ONLY = { debug = true, ui = true, names = true, pins = true }

SlashCmdList["TRIALGEARFINDER"] = function(msg)
    if msg == "dev" then
        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB.dev = not TrialGearFinderDB.dev
        print(string.format("|cFFFFD100[TGF]|r Команды разработчика: %s",
            TrialGearFinderDB.dev and "включены" or "выключены"))
        return
    end
    if not (TrialGearFinderDB and TrialGearFinderDB.dev) then
        -- pin с именем подземелья тоже сюда: /tgf pin, /tgf pin сетекк.
        if DEV_ONLY[msg] or msg:match("^pin") then
            print("|cFFFFD100[TGF]|r Неизвестная команда.")
            return
        end
    end

    -- Dumps everything captured with Ctrl-click, ready to paste into SOURCE_PINS
    -- so the pins become part of the addon instead of one character's saved vars.
    -- Data.lua stores no item names - they come from the client at display time.
    -- This dumps id + name so they can be referred to by name outside the game.
    -- Диагностика гнёзд: печатает поля gemID из ссылки и то, что аддон насчитал.
    -- Нужна, чтобы понять, откуда берутся лишние гнёзда в /tgf scan.
    -- Разметка интерфейса: обводит каждый элемент окна и по наведению показывает
    -- имя, тип и размер. Нужна, чтобы не гадать, какой фрейм за что отвечает.
    -- Мышь в этом режиме перехватывается оверлеями, поэтому кликать по окну
    -- не выйдет - выключается тем же /tgf debug.
    if msg == "debug" then
        if debugOverlays and #debugOverlays > 0 then
            for _, o in ipairs(debugOverlays) do o:Hide() end
            debugOverlays = {}
            print("|cFFFFD100[TGF]|r Разметка выключена.")
            return
        end
        debugOverlays = {}

        local palette = {
            { 1, 0.3, 0.3 }, { 0.3, 1, 0.4 }, { 0.4, 0.6, 1 },
            { 1, 0.85, 0.3 }, { 0.9, 0.4, 1 }, { 0.3, 0.9, 0.9 },
        }

        local function Mark(element, depth, label)
            local o = CreateFrame("Frame", nil, element)
            o:SetAllPoints()
            o:SetFrameStrata("TOOLTIP")
            o:EnableMouse(true)
            AddBorder(o, palette[(depth - 1) % #palette + 1])
            o:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine(label, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%s  %dx%d", element:GetObjectType(),
                    math.floor(element:GetWidth() or 0), math.floor(element:GetHeight() or 0)), 1, 1, 1)
                GameTooltip:AddLine("уровень вложенности: " .. depth, 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end)
            o:SetScript("OnLeave", function() GameTooltip:Hide() end)
            table.insert(debugOverlays, o)
        end

        local function Walk(parent, depth)
            if depth > 5 then return end
            for _, child in ipairs({ parent:GetChildren() }) do
                if child:IsShown() then
                    Mark(child, depth, child:GetName() or ("(без имени, " .. child:GetObjectType() .. ")"))
                    Walk(child, depth + 1)
                end
            end
        end

        Mark(frame, 1, frame:GetName())
        Walk(frame, 2)

        -- Выпадающий список окну не принадлежит: это отдельный глобальный фрейм.
        -- Размечаем его тоже, причём при каждом показе - иначе не поймать,
        -- ведь ввод команды в чат список закрывает.
        for level = 1, 2 do
            local list = _G["DropDownList" .. level]
            if list then
                if list:IsShown() then
                    Mark(list, 2, list:GetName())
                    Walk(list, 3)
                end
                list:HookScript("OnShow", function(self)
                    if #debugOverlays == 0 then return end
                    C_Timer.After(0, function()
                        Mark(self, 2, self:GetName())
                        Walk(self, 3)
                    end)
                end)
            end
        end
        print(string.format("|cFFFFD100[TGF]|r Разметка включена: %d элементов. Наводи мышь; /tgf debug - выключить.",
            #debugOverlays))
        return
    end

    -- Диагностика полосы прокрутки: как называются её части в этой версии клиента.
    if msg == "ui" then
        local bar = scrollBar
        if not bar then
            print("|cFFFFD100[TGF]|r Полоса прокрутки не найдена вовсе.")
            return
        end
        print("|cFFFFD100[TGF]|r Полоса: " .. tostring(bar:GetName()))
        for _, child in ipairs({ bar:GetChildren() }) do
            print(string.format("   %s | %s | %dx%d",
                tostring(child:GetName()), child:GetObjectType(),
                math.floor(child:GetWidth() or 0), math.floor(child:GetHeight() or 0)))
        end
        for _, key in ipairs({ "Back", "Forward", "ScrollUpButton", "ScrollDownButton", "Track", "Thumb" }) do
            if bar[key] then print("   поле " .. key .. " = " .. tostring(bar[key]:GetObjectType())) end
        end
        return
    end

    if msg == "gems" then
        if ns.CaptureStart then ns.CaptureStart("gems") end
        if UnitLevel("player") ~= 20 then
            print("[TGF] ВНИМАНИЕ: не 20 уровня. Число гнёзд верно, статы и уровень — нет.")
        end
        local ok, err = pcall(function()
        for _, item in ipairs(ns.Items) do
            local link = FindOwnedLink(item.itemID)
            if link then
                local parts = { strsplit(":", link) }
                local live = ScanItemLink(link)
                local sb = item.socketBonus
                -- Компактно: гн база/насчитано, бонус, камни из полей 5-8 ссылки
                -- (в поле 4 чары). По этим полям CountGemsInLink и считает.
                local g = {}
                for f = 5, 8 do if parts[f] and parts[f] ~= "" and parts[f] ~= "0" then g[#g + 1] = parts[f] end end
                print(string.format("[TGF] %s | гн %d/%d | sb %s | камни %s",
                    C_Item.GetItemNameByID(item.itemID) or ("id " .. item.itemID),
                    item.sockets or 0, live.sockets or 0,
                    sb and (sb.key .. sb.value) or "-",
                    (#g > 0) and table.concat(g, ",") or "-"))
            end
        end
        end)
        if ns.CaptureStop then ns.CaptureStop() end
        if not ok then error(err) end
        print("|cFF86C7BD[TGF]|r Скопировать: /tgf copy")
        return
    end

    -- Полный слепок надетого/сумочного из базы: живые статы каждого предмета,
    -- компактно. Для сбора у людей с BiS — они прогоняют и присылают отчёт,
    -- по нему правится база. Не только расхождения, как /tgf scan, а всё.
    if msg == "ref" then
        if ns.CaptureStart then ns.CaptureStart("ref") end
        if UnitLevel("player") ~= 20 then
            print("[TGF] ВНИМАНИЕ: персонаж не 20 уровня — статы и уровни предметов неточны. Слепок годен только с двадцатки.")
        end
        local ok, err = pcall(function()
            local ORD = { "int", "agi", "str", "stam", "crit", "haste", "iskus", "vers" }
            local n = 0
            for _, item in ipairs(ns.Items) do
                local link = FindOwnedLink(item.itemID)
                if link then
                    local live = ScanItemLink(link)
                    local sp = {}
                    for _, k in ipairs(ORD) do
                        if live.stats[k] then sp[#sp + 1] = k .. live.stats[k] end
                    end
                    local sb = live.socketBonus
                    print(string.format("[TGF] %d %s | ур%s | %s | гн%d%s",
                        item.itemID,
                        C_Item.GetItemNameByID(item.itemID) or "?",
                        tostring(live.ilvl or "?"),
                        (#sp > 0) and table.concat(sp, " ") or "-",
                        live.sockets or 0,
                        sb and (" sb" .. sb.key .. sb.value) or ""))
                    n = n + 1
                end
            end
            print(string.format("[TGF] ref: %d предметов из базы у персонажа", n))
        end)
        if ns.CaptureStop then ns.CaptureStop() end
        if not ok then error(err) end
        print("|cFF86C7BD[TGF]|r Скопировать: /tgf copy")
        return
    end

    if msg == "names" then
        for _, item in ipairs(ns.Items) do
            print(string.format("%d = %s", item.itemID,
                C_Item.GetItemNameByID(item.itemID) or "?"))
        end
        return
    end

    if msg == "pins" then
        local saved = TrialGearFinderDB and TrialGearFinderDB.pins
        if not saved or not next(saved) then
            print("|cFFFFD100[TGF]|r Меток пока не запомнено.")
            return
        end
        local names = {}
        for name in pairs(saved) do table.insert(names, name) end
        table.sort(names)
        for _, name in ipairs(names) do
            local p = saved[name]
            -- item: keys mean nothing on their own, so name the mob next to them
            local comment = ""
            local id = name:match("^item:(%d+)$")
            if id then
                for _, item in ipairs(ns.Items) do
                    if tostring(item.itemID) == id and item.note then
                        comment = " -- " .. item.note
                        break
                    end
                end
            end
            print(string.format([[    ["%s"] = { %d, %.1f, %.1f },%s]], name, p[1], p[2], p[3], comment))
        end
        return
    end
    -- /tgf pin            - what waypoint does the addon actually see right now
    -- /tgf pin сетекк     - bind that waypoint to the source matching "сетекк"
    local pinName = msg:match("^pin%s*(.*)$")
    if pinName then
        local point = C_Map.GetUserWaypoint()
        if not point then
            print("|cFFFFD100[TGF]|r Метки на карте нет. Поставь её Ctrl+щелчком по карте и повтори.")
            return
        end

        local mapID = point.uiMapID
        local x, y = point.position.x * 100, point.position.y * 100

        if pinName == "" then
            print(string.format("|cFFFFD100[TGF]|r Текущая метка: карта %d, %.1f, %.1f", mapID, x, y))
            print("|cFFFFD100[TGF]|r Привязать: /tgf pin <часть названия подземелья>")
            return
        end

        -- Partial match, so "/tgf pin сетекк" is enough. But "стратхольм" matches
        -- three different dungeons, and silently taking the first one wrote the
        -- wrong coordinates once already - so ask instead of guessing.
        local needle = FoldCase(pinName)
        local matches, seen = {}, {}

        -- Dungeons match on the source name. Rare mobs have no source of their own
        -- (all share one category string), so they match on the note instead -
        -- "/tgf pin дикобраз" finds "падает с Дикобраз-матриарх в Друстваре".
        for _, item in ipairs(ns.Items) do
            local src, isDungeon = item.source, item.sourceType == "Dungeon"
            -- Dungeons are named by their source; everything else (rares, treasures,
            -- quest drops) is recognised by its note, which is where the actual
            -- spot is written.
            local label = isDungeon and src or (item.note or src)
            local key = PinKey(item.sourceType, item.itemID, src)
            local hit = (src and FoldCase(src):find(needle, 1, true))
                or (item.note and FoldCase(item.note):find(needle, 1, true))
            if hit and label and not seen[key] then
                seen[key] = true
                table.insert(matches, { key = key, label = label })
            end
        end

        -- An exact name always wins over the ones merely containing it.
        for _, m in ipairs(matches) do
            if FoldCase(m.label) == needle then
                matches = { m }
                break
            end
        end

        if #matches == 0 then
            print(string.format("|cFFFFD100[TGF]|r Источник со словом «%s» в базе не найден.", pinName))
            return
        end
        if #matches > 1 then
            print(string.format("|cFFFFD100[TGF]|r Подходит несколько, уточни (%d):", #matches))
            for _, m in ipairs(matches) do print("    " .. m.label) end
            return
        end
        local matched = matches[1]

        TrialGearFinderDB = TrialGearFinderDB or {}
        TrialGearFinderDB.pins = TrialGearFinderDB.pins or {}
        TrialGearFinderDB.pins[matched.key] = { mapID, x, y }
        print(string.format("|cFFFFD100[TGF]|r Запомнено: %s = карта %d, %.1f, %.1f", matched.label, mapID, x, y))
        return
    end

    if msg == "scan" then
        if ns.CaptureStart then ns.CaptureStart("scan") end
        if UnitLevel("player") ~= 20 then
            print("[TGF] ВНИМАНИЕ: персонаж не 20 уровня — статы масштабируются по уровню, сверка неточна. Прогонять только двадцаткой.")
        end
        local ok, err = pcall(ScanOwnedItems)
        if ns.CaptureStop then ns.CaptureStop() end -- вернуть print даже при ошибке
        if not ok then error(err) end
        print("|cFF86C7BD[TGF]|r Скопировать отчёт: /tgf copy")
        return
    end
    if msg == "copy" then
        if ns.ShowCopyWindow then ns.ShowCopyWindow() end
        return
    end
    if msg == "bis" then
        if ns.ToggleBiS then ns.ToggleBiS() end
        return
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        frame:Raise() -- pop to the front of its strata every open, in case some
                       -- other DIALOG-strata addon window is currently on top
    end
end
