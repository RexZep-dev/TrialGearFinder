-- Плашка «20» над игроками 20 уровня, чёрная. Сделано по образцу плашек
-- аддона Level20 (PlayerMarks.lua), только своим цветом. Если в Level20 его
-- плашки тоже включены, над игроком будут две в одном месте: их выключает
-- галочка в окне Level20.
--
-- Рамка и цифры - в цвет рейтинга Forsaken Dungeons+ (модуль
-- TrialGearFinder_Forsaken или отдельный ForsakenIO: цвет места, как на
-- сайте). Нет модуля или игрока в снимке - серая рамка и золотые цифры.
--
-- По умолчанию выключено (пользователь 2 октября): включается галочкой
-- в Параметрах, флаг TrialGearFinderDB.playerMarks.
--
-- Файл пропал 5 октября (приложение CurseForge перезаписало рабочую папку,
-- в git его ещё не было) и восстановлен 11 октября по журналу сессии.
local _, ns = ...

local marks = setmetatable({}, { __mode = "k" })

local function PlateUnit(plate)
    return plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
end

local function GetMark(plate)
    local mark = marks[plate]
    if mark then return mark end
    mark = CreateFrame("Frame", nil, plate, "BackdropTemplate")
    mark:SetSize(38, 24)
    mark:SetPoint("BOTTOM", plate, "TOP", 0, 18)
    mark:SetFrameLevel((plate:GetFrameLevel() or 0) + 20)
    mark:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    mark:SetBackdropColor(0, 0, 0, 0.92)
    mark:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
    mark.text = mark:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mark.text:SetPoint("CENTER")
    mark.text:SetText("20")
    mark.text:SetTextColor(1, 0.82, 0)
    marks[plate] = mark
    return mark
end

local function Refresh(unit)
    local plate = unit and C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end
    local on = TrialGearFinderDB and TrialGearFinderDB.playerMarks
    if on and UnitIsPlayer(unit) and UnitLevel(unit) == 20 then
        local mark = GetMark(plate)
        local fio = ForsakenIO
        local profile = fio and fio.GetProfileForUnit and fio.GetProfileForUnit(unit)
        if profile then
            -- Цвет как на сайте (место в таблице), у старого ForsakenIO - пороги.
            local r, g, b
            if fio.ProfileColor then r, g, b = fio.ProfileColor(profile) else r, g, b = fio.ScoreColor(profile.score) end
            mark:SetBackdropBorderColor(r, g, b, 1)
            mark.text:SetTextColor(r, g, b)
        else
            mark:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
            mark.text:SetTextColor(1, 0.82, 0)
        end
        mark:Show()
    elseif marks[plate] then
        marks[plate]:Hide()
    end
end

function ns.RefreshPlayerMarks()
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do Refresh(PlateUnit(plate)) end
end

local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        Refresh(unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate and marks[plate] then marks[plate]:Hide() end
    else
        ns.RefreshPlayerMarks()
    end
end)
