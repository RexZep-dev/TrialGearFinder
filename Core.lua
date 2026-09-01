local addonName, ns = ...

local ROW_WIDTH, ROW_HEIGHT, ROW_SPACING = 800, 46, 2
local NUM_VISIBLE_ROWS = 8
local TWINK_LEVEL = 20

-- Ground-truth comparison (hover-any-item note, list tooltip, /tgf scan) is still
-- rough around the edges (gem detection etc.) - kept in the code, just switched
-- off for now. Flip back to true once it's solid.
local ENABLE_COMPARISON = false

local SLOT_DEFS = {
    { key = "HEAD",     label = _G.INVTYPE_HEAD,     invTypes = { INVTYPE_HEAD = true } },
    { key = "NECK",     label = _G.INVTYPE_NECK,     invTypes = { INVTYPE_NECK = true } },
    { key = "SHOULDER", label = _G.INVTYPE_SHOULDER, invTypes = { INVTYPE_SHOULDER = true } },
    { key = "BACK",     label = _G.INVTYPE_CLOAK,    invTypes = { INVTYPE_CLOAK = true } },
    { key = "CHEST",    label = _G.INVTYPE_CHEST,    invTypes = { INVTYPE_CHEST = true, INVTYPE_ROBE = true } },
    { key = "WRIST",    label = _G.INVTYPE_WRIST,    invTypes = { INVTYPE_WRIST = true } },
    { key = "HANDS",    label = _G.INVTYPE_HAND,     invTypes = { INVTYPE_HAND = true } },
    { key = "WAIST",    label = _G.INVTYPE_WAIST,    invTypes = { INVTYPE_WAIST = true } },
    { key = "LEGS",     label = _G.INVTYPE_LEGS,     invTypes = { INVTYPE_LEGS = true } },
    { key = "FEET",     label = _G.INVTYPE_FEET,     invTypes = { INVTYPE_FEET = true } },
    { key = "FINGER",   label = _G.INVTYPE_FINGER,   invTypes = { INVTYPE_FINGER = true } },
    { key = "TRINKET",  label = _G.INVTYPE_TRINKET,  invTypes = { INVTYPE_TRINKET = true } },
    { key = "MAINHAND", label = _G.INVTYPE_WEAPONMAINHAND, invTypes = { INVTYPE_WEAPONMAINHAND = true, INVTYPE_WEAPON = true } },
    { key = "OFFHAND",  label = _G.INVTYPE_WEAPONOFFHAND,  invTypes = { INVTYPE_WEAPONOFFHAND = true, INVTYPE_HOLDABLE = true, INVTYPE_SHIELD = true } },
    { key = "TWOHAND",  label = _G.INVTYPE_2HWEAPON,       invTypes = { INVTYPE_2HWEAPON = true } },
    { key = "RANGED",   label = _G.INVTYPE_RANGED,         invTypes = { INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true } },
}

-- Standard (no column clicked) row order: head/neck/shoulder/.../trinket first
-- in that fixed sequence, then weapons, matching SLOT_DEFS's own order.
local function SlotRank(equipLoc)
    for i, d in ipairs(SLOT_DEFS) do
        if d.invTypes[equipLoc] then return i end
    end
    return #SLOT_DEFS + 1
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
-- key stays in English - it's compared against item.sourceType from Data.lua.
local SOURCE_TYPES = {
    { key = "Dungeon", label = "Подземелье" },
    { key = "Quest", label = "Квест" },
    { key = "World", label = "Рарники" },
}

local filters = { slot = "ALL", class = "ALL", armor = "ALL", sourceType = "ALL", search = "" }

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

------------------------------------------------------------
-- Main window
------------------------------------------------------------

local frame = CreateFrame("Frame", "TwinkGearFinderFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(880, 632)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG") -- above plain HIGH-strata addon windows, which is
                                -- apparently where some testers were seeing this
                                -- get tucked behind other UI
frame:SetToplevel(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
tinsert(UISpecialFrames, "TwinkGearFinderFrame") -- closes on Escape, like Blizzard's own panels
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

-- Blizzard's own title-bar art is a fixed-width piece sized just for the title
-- text, so it doesn't stretch to also cover the search box - this draws our own
-- backing bar the full width instead, so title + search visually sit in one strip.
frame.titleBg = frame:CreateTexture(nil, "ARTWORK")
frame.titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -4)
frame.titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -4)
frame.titleBg:SetHeight(48)
frame.titleBg:SetColorTexture(0.05, 0.04, 0.03, 0.6)

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, -26)
frame.title:SetText("Поиск шмота для твинка (20 ур.)")

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
searchBox:SetSize(300, 20)
searchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -34, -30)
searchBox:SetAutoFocus(false)
searchBox.Instructions:SetText("Поиск")
searchBox:SetScript("OnEscapePressed", searchBox.ClearFocus)
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

local function CreateFilterDropdown(name, anchorTo, label, options, getKey, getLabel, onSelect)
    local drop = CreateFrame("Frame", name, footer, "UIDropDownMenuTemplate")
    if anchorTo then
        drop:SetPoint("LEFT", anchorTo, "RIGHT", 4, 0)
    else
        drop:SetPoint("LEFT", footer, "LEFT", -16, 0)
    end
    UIDropDownMenu_SetWidth(drop, 130)
    UIDropDownMenu_SetText(drop, label .. ": Все")

    UIDropDownMenu_Initialize(drop, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Все"
        info.func = function()
            onSelect("ALL")
            UIDropDownMenu_SetText(drop, label .. ": Все")
        end
        UIDropDownMenu_AddButton(info, level)

        for _, opt in ipairs(options) do
            local key = getKey(opt)
            local text = getLabel(opt)
            info = UIDropDownMenu_CreateInfo()
            info.text = text
            info.func = function()
                onSelect(key)
                UIDropDownMenu_SetText(drop, label .. ": " .. text)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    return drop
end

local slotDrop = CreateFilterDropdown("TwinkGearFinderSlotDrop", nil, "Слот", SLOT_DEFS,
    function(o) return o.key end, function(o) return o.label end,
    function(key) filters.slot = key; RefreshResults() end)

local classDrop = CreateFilterDropdown("TwinkGearFinderClassDrop", slotDrop, "Класс", CLASS_SORT_ORDER,
    function(c) return c end,
    function(c) return LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[c] or c end,
    function(key) filters.class = key; RefreshResults() end)

local armorDrop = CreateFilterDropdown("TwinkGearFinderArmorDrop", classDrop, "Броня", ARMOR_SUBCLASSES,
    function(a) return a.id end, function(a) return a.label end,
    function(key) filters.armor = key; RefreshResults() end)

local sourceDrop = CreateFilterDropdown("TwinkGearFinderSourceDrop", armorDrop, "Источник", SOURCE_TYPES,
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
local STAT_FILTER_KEYS = {
    str = true, agi = true, int = true, stam = true,
    crit = true, haste = true, iskus = true, vers = true,
}

local function UpdateHeaderSortIndicators()
    for key, entry in pairs(headerLabels) do
        local text = entry.text
        if sortState.key == key then
            text = text .. (sortState.dir == "DESC" and " v" or " ^")
        end
        entry.fs:SetText(text)
        if statFilter[key] then
            entry.fs:SetTextColor(1, 0.82, 0) -- отмечен как фильтр
        else
            entry.fs:SetTextColor(1, 1, 1)
        end
    end
end

local function AddHeaderLabel(x, width, text, justify, sortKey, fullName)
    local fs = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", header, "TOPLEFT", x, 0)
    fs:SetWidth(width)
    fs:SetJustifyH(justify or "LEFT")
    fs:SetText(text)

    if sortKey then
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
        headerLabels[sortKey] = { fs = fs, text = text }
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
AddHeaderLabel(COL_SOURCE_X, COL_SOURCE_W, "Источник", "LEFT", "source")

------------------------------------------------------------
-- Scroll area + rows
------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", "TwinkGearFinderScroll", frame, "FauxScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
scrollFrame:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", -24, 6)

local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
emptyText:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 4, -4)
emptyText:SetJustifyH("LEFT")
emptyText:SetJustifyV("TOP")
emptyText:Hide()

local function ColorStat(value)
    if value and value > 0 then
        return string.format("|cff00ff00%d|r", value)
    end
    return "|cff808080-|r"
end

local SOCKET_LABELS = {
    meta = "особое", prismatic = "бесцветное", red = "красное",
    yellow = "жёлтое", blue = "синее", cogwheel = "шестерёнка", domination = "владычества",
}

-- Socket icons shipped with the addon (Media/ folder). Only the two types this
-- guide's items actually use are provided; anything else falls back to text.
local SOCKET_ICON_PATHS = {
    meta = "Interface\\AddOns\\TwinkGearFinder\\socket-meta.png",
    prismatic = "Interface\\AddOns\\TwinkGearFinder\\socket-prismatic.png",
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

local REVERSE_SOCKET_LABELS = {}
for typeKey, word in pairs(SOCKET_LABELS) do REVERSE_SOCKET_LABELS[word] = typeKey end

local ScanTooltip = CreateFrame("GameTooltip", "TwinkGearFinderScanTooltip", nil, "GameTooltipTemplate")
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

local function ScanItemLink(link)
    ScanTooltip:ClearLines()
    ScanTooltip:SetHyperlink(link)

    local result = { ilvl = C_Item.GetDetailedItemLevelInfo(link), stats = {}, socketTypes = {} }
    local inSocketBonusZone = false

    -- "X гнездо" text only shows for EMPTY sockets; a filled one shows the gem's
    -- own effect line instead (icon + "+N к X и +N к Y") - C_Item.GetItemGem
    -- doesn't recognize these particular gems, so they're counted from the
    -- tooltip text itself, the same way the empty-socket lines are.
    local filledGems = 0

    for i = 1, ScanTooltip:NumLines() do
        local fs = _G["TwinkGearFinderScanTooltipTextLeft" .. i]
        local text = fs and fs:GetText()
        if text then
            if text:find("соответствии цвета") then inSocketBonusZone = true end

            if text:find("|T", 1, true) and text:match("%+%d+%s+к.+%s+и%s+%+%d+%s+к") then
                filledGems = filledGems + 1
            else
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

            for word, socketType in pairs(REVERSE_SOCKET_LABELS) do
                if text:find(word .. " гнездо", 1, true) then
                    table.insert(result.socketTypes, socketType)
                end
            end
        end
    end

    result.sockets = #result.socketTypes + filledGems
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
local function FormatDiffLine(diff)
    local sign = diff.delta > 0 and "+" or ""
    local colorCode = diff.delta > 0 and "|cFF20FF20" or "|cFFFF4040"
    local number = string.format("%s%s%d|r", colorCode, sign, diff.delta)

    if diff.isSocket then
        local iconPath = SOCKET_ICON_PATHS[diff.socketType]
        if iconPath then
            return string.format("%s |T%s:16:16|t %s", number, iconPath, diff.label)
        end
        return string.format("%s %s", number, diff.label)
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
local function FindOwnedLink(itemID)
    if not itemID then return nil end
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        if GetInventoryItemID("player", slot) == itemID then
            return GetInventoryItemLink("player", slot)
        end
    end
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID == itemID then return info.hyperlink end
        end
    end
    return nil
end

local function CreateRow(index)
    local row = CreateFrame("Frame", "TwinkGearFinderRow" .. index, frame)
    row:SetSize(ROW_WIDTH, ROW_HEIGHT)
    row:EnableMouse(true)

    row.bgAlt = row:CreateTexture(nil, "BACKGROUND", nil, 0)
    row.bgAlt:SetAllPoints()
    if index % 2 == 0 then
        row.bgAlt:SetColorTexture(0.247, 0.247, 0.247, 0.6)
    else
        row.bgAlt:SetColorTexture(0.17, 0.17, 0.17, 0.4)
    end

    row.bg = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.bg:SetAllPoints()
    row.bg:SetColorTexture(1, 1, 1, 0)
    row:SetScript("OnEnter", function(self) self.bg:SetColorTexture(1, 1, 1, 0.08) end)
    row:SetScript("OnLeave", function(self) self.bg:SetColorTexture(1, 1, 1, 0) end)

    row.iconFrame = CreateFrame("Button", nil, row)
    row.iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
    row.iconFrame:SetPoint("TOPLEFT", row, "TOPLEFT", COL_ICON_X, -6)
    row.icon = row.iconFrame:CreateTexture(nil, "ARTWORK")
    row.icon:SetAllPoints()
    -- Native tooltip via SetHyperlink - real item card, real Shift-compare
    -- against whatever's equipped, real Ctrl-dressup. Accuracy now depends on
    -- each item's bonusIDs in Data.lua actually reconstructing to ilvl 23 -
    -- fix those one at a time as wrong ones turn up in-game (like 24395,
    -- 28229, 17943 already were), there's no manual-tooltip fallback anymore.
    function row:ShowItemTooltip()
        if not self.hyperlink then return end
        GameTooltip:SetOwner(self.iconFrame, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.hyperlink)
        if self.fullSource and self.fullSource ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self.fullSource, 0.6, 0.85, 1, true)
        end
        if self.fullNote and self.fullNote ~= "" then
            GameTooltip:AddLine(self.fullNote, 1, 1, 1, true)
        end
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

    row.type = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
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

    row.source = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.source:SetPoint("TOPLEFT", row, "TOPLEFT", COL_SOURCE_X, -4)
    row.source:SetSize(COL_SOURCE_W, 14)
    row.source:SetJustifyH("LEFT")
    row.source:SetTextColor(0.6, 0.85, 1, 1)

    row.sourceboss = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.sourceboss:SetPoint("TOPLEFT", row.source, "BOTTOMLEFT", 0, -4)
    row.sourceboss:SetSize(COL_SOURCE_W, 14)
    row.sourceboss:SetJustifyH("LEFT")

    -- Source/sourceboss text gets clipped by column width; hover shows the full text.
    row.sourceHitbox = CreateFrame("Frame", nil, row)
    row.sourceHitbox:SetPoint("TOPLEFT", row, "TOPLEFT", COL_SOURCE_X, 0)
    row.sourceHitbox:SetSize(COL_SOURCE_W, ROW_HEIGHT)
    row.sourceHitbox:EnableMouse(true)
    function row:ShowSourceTooltip()
        if not self.fullSource then return end
        GameTooltip:SetOwner(self.sourceHitbox, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine(self.fullSource, 0.6, 0.85, 1, true)
        if self.fullNote and self.fullNote ~= "" then
            GameTooltip:AddLine(self.fullNote, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end
    row.sourceHitbox:SetScript("OnEnter", function() row:ShowSourceTooltip() end)
    row.sourceHitbox:SetScript("OnLeave", function() GameTooltip:Hide() end)

    function row:SetData(data)
        if not data then
            self:Hide()
            return
        end
        self:Show()
        self.icon:SetTexture(data.icon)
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
        self.sourceboss:SetText(data.sourceboss or "")
        self.fullSource = data.source
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

local rows = {}
for i = 1, NUM_VISIBLE_ROWS do
    local row = CreateRow(i)
    if i == 1 then
        row:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    else
        row:SetPoint("TOPLEFT", rows[i - 1], "BOTTOMLEFT", 0, -ROW_SPACING)
    end
    rows[i] = row
end

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

    if filters.search ~= "" then
        local haystack = FoldCase(name) .. " " .. FoldCase(item.note or "")
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

    local qualityHex = select(4, C_Item.GetItemQualityColor(quality))
    local typeLabel = (classID == ARMOR_CLASS_ID and itemSubType ~= "") and
        string.format("%s (%s)", itemSubType, _G[equipLoc] or equipLoc) or (_G[equipLoc] or equipLoc)
    if item.ilvl then
        typeLabel = typeLabel .. string.format(" | %d ур.", item.ilvl)
    end
    local stats = item.stats or {}
    return {
        icon = icon,
        name = string.format("|c%s%s|r", qualityHex, name),
        rawName = name,
        type = typeLabel,
        equipLoc = equipLoc,
        subclassID = classID == ARMOR_CLASS_ID and subclassID or nil,
        itemID = item.itemID,
        str = stats.str,
        agi = stats.agi,
        int = stats.int,
        stam = stats.stam,
        crit = stats.crit,
        haste = stats.haste,
        iskus = stats.iskus,
        vers = stats.vers,
        source = item.source,
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

    for _, item in ipairs(ns.Items) do
        if PassesStaticFilters(item) then
            local rowData = BuildRowData(item)
            if rowData == nil then
                pending = true
            elseif rowData ~= false then
                table.insert(matches, rowData)
            end
        end
    end

    if #matches == 0 then
        for _, row in ipairs(rows) do row:Hide() end
        FauxScrollFrame_Update(scrollFrame, 0, NUM_VISIBLE_ROWS, ROW_HEIGHT)
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
        table.sort(matches, function(a, b)
            local rankA, rankB = SlotRank(a.equipLoc), SlotRank(b.equipLoc)
            if rankA ~= rankB then return rankA < rankB end
            -- Within the same slot: Cloth, Leather, Mail, Plate (ARMOR_SUBCLASSES'
            -- own id order already matches that sequence) before by-name.
            local subA, subB = a.subclassID or 99, b.subclassID or 99
            if subA ~= subB then return subA < subB end
            return (a.rawName or "") < (b.rawName or "")
        end)
    end

    emptyText:Hide()
    local offset = FauxScrollFrame_GetOffset(scrollFrame)
    for i, row in ipairs(rows) do
        row:SetData(matches[i + offset])
    end
    FauxScrollFrame_Update(scrollFrame, #matches, NUM_VISIBLE_ROWS, ROW_HEIGHT)
end

scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, RefreshResults)
end)

-- One row per wheel notch. Without this the template's own handler decides the
-- step (it was jumping several rows at a time), and SetValue is clamped to the
-- scrollbar's own min/max, so no bounds check is needed here.
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local scrollBar = self.ScrollBar or _G[self:GetName() .. "ScrollBar"]
    if not scrollBar then return end
    scrollBar:SetValue(scrollBar:GetValue() - delta * ROW_HEIGHT)
end)

frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", RefreshResults)

frame:SetScript("OnShow", RefreshResults)

------------------------------------------------------------
-- /tgf scan: same ground-truth check as ShowItemTooltip above, run over every
-- equipped/bagged item in one pass and reported to chat.
------------------------------------------------------------

-- Returns "match", "mismatch", or nil (not one of our tracked BiS items).
local function CompareToLive(itemID, link)
    if not ns_ItemsByID[itemID] then return nil end
    local diffs = DiffAgainstLive(itemID, ScanItemLink(link))

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
    if not ENABLE_COMPARISON then
        print("|cFFFFD100[TGF]|r Сравнение с базой временно отключено.")
        return
    end
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

    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
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

    print(string.format("|cFFFFD100[TGF]|r Проверено %d предметов из базы (надето+сумки), расхождений: %d", checked, mismatched))
end

------------------------------------------------------------
-- Slash command
------------------------------------------------------------

SLASH_TWINKGEARFINDER1 = "/tgf"
SlashCmdList["TWINKGEARFINDER"] = function(msg)
    if msg == "scan" then
        ScanOwnedItems()
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
