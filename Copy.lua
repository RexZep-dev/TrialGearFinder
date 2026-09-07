-- Копирование из чата — тестерам, чтобы слали вывод сверки без доп. аддона.
--
-- Иконка на активном окне чата и приём с многострочным EditBox взяты по идее
-- из аддона CopyThat (Josh «Kkthnx» Russell), лицензия MIT. Оттуда же важное:
-- CopyToClipboard аддонам запрещён (ADDON_ACTION_FORBIDDEN), единственный путь —
-- Ctrl+C по выделенному тексту в поле с фокусом. Код не копировался.
-- Аддон ChatCopy (Ginutty, «personal use») не использован.

local addonName, ns = ...

local S = ns.Style or {}
local C = S.C or {}
local WHITE = "Interface\\Buttons\\WHITE8X8"
local TAG = "[TGF]" -- по этой метке ловим свои строки в чате

local frame, editBox, scroll, chatBtn

-- ---------------------------------------------------------------------------
-- Чистка строки под буфер обмена
-- ---------------------------------------------------------------------------
local function Clean(msg)
    if not msg or msg == "" then return "" end
    msg = msg:gsub("|K.-|k", "?")            -- секретные K-строки Midnight
    msg = msg:gsub("|T.-|t", "")
    msg = msg:gsub("|A.-|a", "")
    msg = msg:gsub("|H.-|h(.-)|h", "%1")     -- ссылка -> её видимый текст
    msg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
    msg = msg:gsub("|r", "")
    msg = msg:gsub("%s*|4[^;]*;", "")
    return msg
end

-- ---------------------------------------------------------------------------
-- Лог: пассивный хук AddMessage. Всегда пишем строки с меткой TGF; во время
-- прогона /tgf scan и /tgf gems — вообще всё (флаг captureAll).
-- ---------------------------------------------------------------------------
local log, captureAll, MAX = {}, false, 500

local function Push(line)
    log[#log + 1] = line
    if #log > MAX then table.remove(log, 1) end
end

do
    local function hook(_, msg)
        if type(msg) ~= "string" or msg == "" then return end
        if captureAll or msg:find(TAG, 1, true) then
            Push(Clean(msg))
        end
    end
    for i = 1, NUM_CHAT_WINDOWS or 10 do
        local cf = _G["ChatFrame" .. i]
        if cf and cf.AddMessage then hooksecurefunc(cf, "AddMessage", hook) end
    end
end

function ns.CaptureStart()
    captureAll = true
    Push("───────── /tgf прогон ─────────")
end

function ns.CaptureStop()
    captureAll = false
end

-- ---------------------------------------------------------------------------
-- Весь видимый чат — запасной вариант, если лог пуст
-- ---------------------------------------------------------------------------
local function GatherChat()
    local out = {}
    for i = 1, NUM_CHAT_WINDOWS or 10 do
        local cf = _G["ChatFrame" .. i]
        if cf and cf:IsVisible() and cf.GetNumMessages then
            local n = cf:GetNumMessages() or 0
            for j = math.max(1, n - 500), n do
                local ok, m = pcall(cf.GetMessageInfo, cf, j)
                if ok and m and m ~= "" then out[#out + 1] = Clean(m) end
            end
        end
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Окно
-- ---------------------------------------------------------------------------
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
    close:SetFrameLevel(frame:GetFrameLevel() + 5)

    -- Панелька сверху: прогнать команду прямо отсюда + переключатель.
    local function bar(text, x, w, onClick)
        local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btn:SetSize(w, 20)
        btn:SetPoint("TOPLEFT", x, -26)
        btn:SetFrameLevel(frame:GetFrameLevel() + 5)
        btn:SetText(text)
        btn:SetScript("OnClick", onClick)
        return btn
    end
    frame.scanBtn = bar("Прогнать /tgf scan", 12, 150, function()
        if SlashCmdList.TRIALGEARFINDER then SlashCmdList.TRIALGEARFINDER("scan") end
        ns.ShowCopyWindow(true)
    end)
    frame.gemsBtn = bar("Прогнать /tgf gems", 166, 150, function()
        if SlashCmdList.TRIALGEARFINDER then SlashCmdList.TRIALGEARFINDER("gems") end
        ns.ShowCopyWindow(true)
    end)
    frame.modeBtn = bar("", 320, 170, function()
        frame.showAll = not frame.showAll
        ns.ShowCopyWindow(true)
    end)

    scroll = CreateFrame("ScrollFrame", "TrialGearFinderCopyScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -52)
    scroll:SetPoint("BOTTOMRIGHT", -30, 40)

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

    -- Прокрученное поле перекрывает кнопки — ограничиваем область клика видимой
    -- частью (приём из CopyThat).
    scroll:HookScript("OnVerticalScroll", function(self, offset)
        offset = offset or self:GetVerticalScroll()
        editBox:SetHitRectInsets(0, 0, offset, editBox:GetHeight() - offset - self:GetHeight())
    end)

    local selectAll = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    selectAll:SetSize(150, 20)
    selectAll:SetPoint("BOTTOMLEFT", 12, 12)
    selectAll:SetFrameLevel(frame:GetFrameLevel() + 5)
    selectAll:SetText("Выделить всё")
    selectAll:SetScript("OnClick", function()
        editBox:SetFocus()
        editBox:HighlightText()
    end)

    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -4, 4)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

    frame:SetScript("OnSizeChanged", function() editBox:SetWidth(scroll:GetWidth()) end)
    frame:Hide()
    return frame
end

-- Показать. По умолчанию — лог (метки TGF + прогоны). Кнопка переключает
-- на весь видимый чат. keepMode = не трогать флаг (вызов из кнопки).
function ns.ShowCopyWindow(keepMode)
    Build()
    if not keepMode and #log == 0 then frame.showAll = true end -- нечего фильтровать

    local lines
    if frame.showAll then
        lines = GatherChat()
        frame.modeBtn:SetText("Показать: весь чат")
    else
        lines = log
        frame.modeBtn:SetText("Показать: только TGF")
    end

    local text = table.concat(lines, "\n")
    if text == "" then
        text = frame.showAll
            and "Чат пуст."
            or "Строк [TGF] пока нет.\n\nНажми кнопку сверху — «Прогнать /tgf scan» или «Прогнать /tgf gems» — и вывод появится здесь.\nЛибо переключи на «весь чат»."
    end

    frame:Show()
    -- Ширину берём от окна, а не от скролла: у только что показанного скролла
    -- размер ещё может быть не посчитан (был пустой EditBox).
    local w = math.max(1, (scroll:GetWidth() or 0))
    if w < 50 then w = frame:GetWidth() - 46 end
    editBox:SetWidth(w)
    local _, fh = editBox:GetFont()
    editBox:SetHeight(math.max(200, (#lines + 3) * (fh or 14) + 16))
    editBox:SetText(text)
    scroll:SetVerticalScroll(0)
    editBox:SetCursorPosition(0)
    editBox:SetFocus()
    editBox:HighlightText()
end

-- ---------------------------------------------------------------------------
-- Иконка на активном окне чата (идея из CopyThat)
-- ---------------------------------------------------------------------------
local function ActiveChat()
    return _G.SELECTED_DOCK_FRAME or _G.ChatFrame1
end

function ns.MakeChatCopyButton()
    if chatBtn then return end
    chatBtn = CreateFrame("Button", "TrialGearFinderCopyButton", UIParent, "BackdropTemplate")
    chatBtn:SetSize(26, 24)
    chatBtn:SetFrameStrata("HIGH")
    chatBtn:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    local bb = C.block or { 0.06, 0.07, 0.08 }
    chatBtn:SetBackdropColor(bb[1], bb[2], bb[3], 0.9)
    chatBtn:SetBackdropBorderColor((C.border or { 0.25, 0.25, 0.28 })[1], (C.border or { 0.25, 0.25, 0.28 })[2], (C.border or { 0.25, 0.25, 0.28 })[3], 1)

    local t = chatBtn:CreateTexture(nil, "ARTWORK")
    t:SetPoint("CENTER")
    t:SetSize(16, 16)
    t:SetTexture("Interface\\ICONS\\INV_Misc_Note_01")
    t:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    chatBtn:SetAlpha(0.55)
    chatBtn:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Копировать из чата (TGF)")
        GameTooltip:AddLine("После /tgf scan или /tgf gems — здесь их вывод", 1, 0.82, 0, true)
        GameTooltip:Show()
    end)
    chatBtn:SetScript("OnLeave", function(self)
        self:SetAlpha(0.55)
        GameTooltip:Hide()
    end)
    chatBtn:SetScript("OnClick", function() ns.ShowCopyWindow() end)

    local function place()
        local cf = ActiveChat()
        if not cf then return end
        chatBtn:ClearAllPoints()
        chatBtn:SetPoint("BOTTOMLEFT", cf, "BOTTOMRIGHT", 3, 0)
        chatBtn:Show()
    end
    place()
    if _G.FCFDock_SelectWindow then
        hooksecurefunc("FCFDock_SelectWindow", function(dock)
            if dock == _G.GENERAL_CHAT_DOCK then place() end
        end)
    end
end

-- Иконку вешаем после входа: окна чата к этому моменту на месте.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function() ns.MakeChatCopyButton() end)
