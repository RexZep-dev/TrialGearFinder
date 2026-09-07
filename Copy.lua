-- Копирование из чата — чтобы тестеры отправляли вывод /tgf scan и /tgf gems
-- без отдельного аддона.
--
-- Написано с нуля. Приём стандартный (GetNumMessages/GetMessageInfo, окно
-- с многострочным EditBox) — так делают все, от ElvUI до мелких аддонов;
-- код аддона ChatCopy (лицензия «personal use») НЕ взят.

local addonName, ns = ...

local S = ns.Style or {}
local C = S.C or {}

local WHITE = "Interface\\Buttons\\WHITE8X8"
local frame, editBox, scroll

-- Чистим то, что в буфер обмена не нужно: иконки, цвета, обёртки ссылок,
-- игровые «4 дня» через |4singular:plural;.
local function Clean(msg)
    if not msg or msg == "" then return "" end
    msg = msg:gsub("|T.-|t", "")
    msg = msg:gsub("|A.-|a", "")
    msg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
    msg = msg:gsub("|r", "")
    msg = msg:gsub("|H.-|h", "") -- открывающий тег ссылки
    msg = msg:gsub("|h", "")
    msg = msg:gsub("%s*|4[^;]*;", "")
    return msg
end

-- Последний отчёт: /tgf scan и /tgf gems перехватывают сюда свой вывод.
local report, capturing, realPrint = {}, false, nil

function ns.CaptureStart()
    if capturing then return end
    capturing = true
    wipe(report)
    realPrint = _G.print
    _G.print = function(...)
        realPrint(...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
        report[#report + 1] = Clean(table.concat(parts, " "))
    end
end

function ns.CaptureStop()
    if not capturing then return end
    _G.print = realPrint
    capturing = false
end

local function GatherChat()
    local lines = {}
    for i = 1, NUM_CHAT_WINDOWS or 10 do
        local cf = _G["ChatFrame" .. i]
        if cf and cf:IsVisible() then
            local n = cf.GetNumMessages and cf:GetNumMessages() or 0
            for j = math.max(1, n - 500), n do
                local ok, m = pcall(cf.GetMessageInfo, cf, j)
                if ok and m and m ~= "" then lines[#lines + 1] = Clean(m) end
            end
        end
    end
    return lines
end

local function Build()
    if frame then return frame end
    frame = CreateFrame("Frame", "TrialGearFinderCopyFrame", UIParent, "BackdropTemplate")
    frame:SetSize(560, 420)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then frame:SetResizeBounds(360, 220, 1100, 800) end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    tinsert(UISpecialFrames, "TrialGearFinderCopyFrame")

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    local b = C.bg or { 0.03, 0.03, 0.04 }
    bg:SetColorTexture(b[1], b[2], b[3], 0.97)
    if S.AddBorder then S.AddBorder(frame, C.border or { 0.18, 0.2, 0.22 }) end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -8)
    title:SetText("Копировать из чата — Ctrl+A, Ctrl+C")
    if C.text then title:SetTextColor(C.text[1], C.text[2], C.text[3]) end

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)

    scroll = CreateFrame("ScrollFrame", "TrialGearFinderCopyScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -28)
    scroll:SetPoint("BOTTOMRIGHT", -30, 14)

    editBox = CreateFrame("EditBox", nil, scroll)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetWidth(scroll:GetWidth())
    editBox:SetMaxLetters(0)
    editBox:EnableMouse(true)
    editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    scroll:SetScrollChild(editBox)

    -- Уголок для растягивания.
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -4, 4)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

    frame:SetScript("OnSizeChanged", function()
        editBox:SetWidth(scroll:GetWidth())
    end)
    frame:Hide()
    return frame
end

-- Показать окно. Если был свежий отчёт (/tgf scan, /tgf gems) — его, иначе
-- весь видимый чат.
function ns.ShowCopyWindow()
    Build()
    local lines = (#report > 0) and report or GatherChat()
    local text = table.concat(lines, "\n")
    if text == "" then
        print("|cFF86C7BD[TGF]|r Копировать нечего.")
        return
    end
    editBox:SetWidth(scroll:GetWidth())
    local _, fh = editBox:GetFont()
    editBox:SetHeight(math.max(scroll:GetHeight(), (#lines + 1) * (fh or 14) + 16))
    editBox:SetText(text)
    frame:Show()
    scroll:SetVerticalScroll(0)
    editBox:SetFocus()
    editBox:HighlightText()
end
