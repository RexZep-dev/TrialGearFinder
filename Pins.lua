-- Имена подземелий из игрового журнала, не из базы вещей.
-- Нужно, чтобы /tgf pin записывал вход даже к данжу, которого в гайде нет.

local addonName, ns = ...

local function LoadJournal()
    if C_AddOns and C_AddOns.LoadAddOn then
        C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
    elseif LoadAddOn then
        LoadAddOn("Blizzard_EncounterJournal")
    end
    return EJ_GetNumTiers and EJ_SelectTier and EJ_GetInstanceByIndex
end

-- Обход 5-игроковых подземелий журнала. Рейды не трогает.
-- Возвращает false, если игра журнал не отдала.
function ns.ForEachJournalDungeon(callback)
    if not LoadJournal() then return false end
    local saved = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local seen = {}
    for t = 1, EJ_GetNumTiers() do
        local tierName = select(1, EJ_GetTierInfo(t))
        EJ_SelectTier(t)
        local i = 1
        while true do
            local id, name = EJ_GetInstanceByIndex(i, false)
            if not id then break end
            -- «Подземелья с ключом» — заголовок сезона, не данж.
            if name and name ~= "Подземелья с ключом" and not seen[name] then
                seen[name] = true
                callback(name, id, tierName or "")
            end
            i = i + 1
        end
    end
    if saved then EJ_SelectTier(saved) end
    return true
end

-- Журнал пишет три крыла: «Забытый город – квартал Криводревов» и т.д.
-- Регистр, тире и двоеточие в клиенте плавают — смотрим на «абытый».
function ns.IsDireMaulName(name)
    return type(name) == "string" and name:find("абытый", 1, true) and true
end

function ns.PinFamilySharesAll(matches)
    if not matches or #matches < 2 then return false end
    for i = 1, #matches do
        if not ns.IsDireMaulName(matches[i].key) then return false end
    end
    return true
end
