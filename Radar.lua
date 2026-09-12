-- Диаграмма статов сборки: многоугольник вместо строки цифр.
--
-- Просьба пользователя 12 сентября: строка «Итог сборки: ...» не влезала по
-- ширине, а читать её всё равно приходилось по слогам. Форма читается быстрее:
-- видно перекос, не вчитываясь в числа.
--
-- Число осей НЕ зашито: сколько статов передали, столько и граней. Основная
-- характеристика показывается только своя — жрецу интеллект, воину сила,
-- лишние оси просто не приходят.
--
-- Рисуется линиями (frame:CreateLine): в WoW нет ни канваса, ни заливки
-- произвольной фигуры. Заливка изображается веером линий из центра — дёшево
-- и выглядит как закрашенный треугольник в играх с таким же виджетом.

local addonName, ns = ...

local S = ns.Style or {}
local C = S.C or {}

-- Докуда тянется ось. У вторичек это СОФТКАП: край диаграммы = 30%, дальше
-- рейтинг слабеет (см. вики «Софткапы Вторичек»). У основной характеристики
-- и выносливости порога нет, поэтому взят потолок, реально достигнутый
-- в гильдии: по слепку 324 твинков максимум 108 интеллекта, 88 силы,
-- 76 ловкости, 126 выносливости. Округлено вверх, чтобы фигура не упиралась.
local AXIS_MAX = {
    crit = 132.96, haste = 127.18, vers = 156.08, iskus = 132.96,
    str = 120, agi = 120, int = 120, stam = 150,
}

local LABEL = {
    str = "Сила", agi = "Ловкость", int = "Интеллект", stam = "Вын",
    crit = "Крит", haste = "Скор", vers = "Верса", iskus = "Иск",
}

-- Порядок обхода: основная характеристика наверху, дальше по часовой.
local ORDER = { "str", "agi", "int", "crit", "haste", "iskus", "vers", "stam" }

local function Line(frame, layer, r, g, b, a, thickness)
    local l = frame:CreateLine(nil, layer or "ARTWORK")
    l:SetThickness(thickness or 1)
    l:SetColorTexture(r, g, b, a)
    return l
end

-- Точка на оси i из n, доля d от радиуса. Вершина 1 смотрит вверх.
local function Point(i, n, d, radius)
    local a = -math.pi / 2 + (i - 1) * 2 * math.pi / n
    return math.cos(a) * radius * d, -math.sin(a) * radius * d
end

function ns.MakeRadar(parent, radius)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(radius * 2, radius * 2)
    f.radius = radius
    f.grid, f.spokes, f.edges, f.fill, f.labels = {}, {}, {}, {}, {}

    -- Обновляет диаграмму. axes — список { key = "crit", value = 120 },
    -- порядок задаём сами по ORDER, чтобы фигура не прыгала между спеками.
    function f:Update(values)
        local keys = {}
        for _, k in ipairs(ORDER) do
            if values[k] then keys[#keys + 1] = k end
        end
        local n = #keys
        for _, t in ipairs({ self.grid, self.spokes, self.edges, self.fill }) do
            for _, l in ipairs(t) do l:Hide() end
        end
        for _, fs in ipairs(self.labels) do fs:Hide() end
        if n < 3 then return end

        local r = self.radius
        local dim = C.borderSoft or { 0.15, 0.16, 0.18 }
        local gold = C.gold or { 1, 0.82, 0 }
        local warm = C.warm or { 0.85, 0.72, 0.42 }

        local gi, si, ei, fi, li = 0, 0, 0, 0, 0
        local function take(t, mk)
            local idx = #t + 1
            return t[idx] or mk(idx)
        end

        -- Сетка: два кольца, 50% и 100%.
        for _, frac in ipairs({ 0.5, 1.0 }) do
            for i = 1, n do
                gi = gi + 1
                local l = self.grid[gi]
                if not l then
                    l = Line(self, "ARTWORK", dim[1], dim[2], dim[3], 1, 1)
                    self.grid[gi] = l
                end
                local x1, y1 = Point(i, n, frac, r)
                local x2, y2 = Point(i % n + 1, n, frac, r)
                l:SetStartPoint("CENTER", x1, y1)
                l:SetEndPoint("CENTER", x2, y2)
                l:SetColorTexture(dim[1], dim[2], dim[3], frac == 1 and 0.9 or 0.5)
                l:Show()
            end
        end

        -- Лучи и подписи.
        for i, key in ipairs(keys) do
            si = si + 1
            local l = self.spokes[si]
            if not l then
                l = Line(self, "ARTWORK", dim[1], dim[2], dim[3], 0.7, 1)
                self.spokes[si] = l
            end
            local x, y = Point(i, n, 1, r)
            l:SetStartPoint("CENTER", 0, 0)
            l:SetEndPoint("CENTER", x, y)
            l:Show()

            li = li + 1
            local fs = self.labels[li]
            if not fs then
                fs = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                self.labels[li] = fs
            end
            local v = values[key] or 0
            local max = AXIS_MAX[key] or 100
            local text = LABEL[key] .. " " .. math.floor(v + 0.5)
            local over = false
            if key == "crit" or key == "haste" or key == "vers" or key == "iskus" then
                local pct = v * 30 / max
                text = string.format("%s %d (%.0f%%)", LABEL[key], v, pct)
                over = pct >= 30
            end
            fs:SetText(text)
            if over then
                fs:SetTextColor(0.88, 0.42, 0.37) -- перебор: дальше рейтинг слабеет
            else
                fs:SetTextColor(0.68, 0.71, 0.74)
            end
            fs:ClearAllPoints()
            local lx, ly = Point(i, n, 1.22, r)
            local anchor = "CENTER"
            if lx > r * 0.3 then anchor = "LEFT" elseif lx < -r * 0.3 then anchor = "RIGHT" end
            fs:SetPoint(anchor, self, "CENTER", lx, ly)
            fs:Show()
        end

        -- Фигура значений: контур плюс веер «заливки».
        local px, py = {}, {}
        for i, key in ipairs(keys) do
            local max = AXIS_MAX[key] or 100
            local d = math.min((values[key] or 0) / max, 1)
            if d < 0.02 then d = 0.02 end -- иначе вершина схлопывается в точку
            px[i], py[i] = Point(i, n, d, r)
        end
        for i = 1, n do
            fi = fi + 1
            local l = self.fill[fi]
            if not l then
                l = Line(self, "ARTWORK", gold[1], gold[2], gold[3], 0.16, 1)
                self.fill[fi] = l
            end
            l:SetStartPoint("CENTER", 0, 0)
            l:SetEndPoint("CENTER", px[i], py[i])
            l:SetColorTexture(warm[1], warm[2], warm[3], 0.22)
            l:SetThickness(math.max(2, r / 6))
            l:Show()

            ei = ei + 1
            local e = self.edges[ei]
            if not e then
                e = Line(self, "OVERLAY", gold[1], gold[2], gold[3], 1, 2)
                self.edges[ei] = e
            end
            local j = i % n + 1
            e:SetStartPoint("CENTER", px[i], py[i])
            e:SetEndPoint("CENTER", px[j], py[j])
            e:SetColorTexture(gold[1], gold[2], gold[3], 0.95)
            e:Show()
        end
    end

    return f
end
