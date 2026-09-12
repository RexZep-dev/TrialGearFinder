-- Коды талантов по спекам: строка, которую игра принимает в окне талантов
-- кнопкой «Загрузить сборку». Новичку не нужен список названий — ему нужен
-- код, который вставляется целиком.
--
-- ОТКУДА БЕРУТСЯ. Только от живых игроков: команда `/tgf talents` печатает
-- код текущей сборки (игра отдаёт его через C_Traits.GenerateImportString).
-- Из логов Warcraft Logs коды не собрать: там таланты записаны номерами
-- узлов дерева, а строка загрузки кодирует ещё и порядок обхода дерева.
--
-- Таблица наполняется по мере того, как люди присылают свои коды, ровно
-- как наполнялась база предметов.

local addonName, ns = ...

ns.TalentCodes = {
    -- Воин. Все три спека сняты с персонажа пользователя 13 сентября.
    [71] = {
        code = "CcEASWsDSHNyPDXnbxuIhH3ZdjZmZmFzMmZGAAAAMNMzYmZzMzMzYGmZAAAAAMWmZABAAAACxAADMGYZsMAAgZAA",
        note = "Оружие: сборка Кавочавоо",
    },
    [72] = {
        code = "CgEASWsDSHNyPDXnbxuIhH3ZdDAAAAAAgGDzMmZ2MzMzMPgZMzwYmZmlZYmZMmZmZAAgAAACABMAAMzGAAgBDMGA",
        note = "Неистовство: сборка Кавочавоо, 247 заходов в логах рейтинга",
    },
    [73] = {
        code = "CkEASWsDSHNyPDXnbxuIhH3ZdHAAwYGmZmZmxsxMLDjxohZmZxMmZGzMMDAAAAMAMjBAAABAImBmZmBMAAAAwMAD",
        note = "Защита: сборка Кавочавоо",
    },

    -- Охотник. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [253] = {
        code = "C0PAD57yiELKEty14ekTDtZEqAAAAAIAAAzMmZGzMYMzYm5BmHYmhZMzMzwMLLzMjZMDGaGAAAAAAAAMmZAACYWAAwA",
        note = "Повелитель зверей",
    },
    [254] = {
        code = "C4PAD57yiELKEty14ekTDtZEqAAACABAAAAAAAAAMjhZWWmxMzYGM0MGMLLLzMzMzMzMDmZZwAAAMPwMDDAAMAwsMzMA",
        note = "Стрельба",
    },
    [255] = {
        code = "C8PAD57yiELKEty14ekTDtZEqMAAQAACYmZmxMWGAAAAAAmxYmZZZGjZYwQzAAAAMA4BYbZmZWMzMzMzYAAghxYGAA",
        note = "Выживание",
    },
}
