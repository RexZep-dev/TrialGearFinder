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

    -- Паладин. Все три спека сняты с персонажа пользователя 13 сентября.
    [70] = {
        code = "CYEAzbn3egSOtoSwvPw1U1vTLAAAAAANbbzMz2YGzMAAAAAAzUmFDzMz2Y2GmZzYMGDDLsNAAggAAAAYAwYGGYGDbAYYMMA",
        note = "Воздаяние",
    },
    [66] = {
        code = "CIEAzbn3egSOtoSwvPw1U1vTLsNDjxwMmZGbMmtZhZMAADAAAAAAaamhZMzwY2aDADMgZwGAAABAIALLYAwYGGDAAAzMAsA",
        note = "Защита",
    },
    [65] = {
        code = "CEEAzbn3egSOtoSwvPw1U1vTLAAAALAwMAAwyYGmZMzMMGzMzyMMzGTTMLzYmZGjZLDADAbgNYmBABAAAAL8ADYA2MDAAAMgA",
        note = "Свет",
    },

    -- Разбойник. Все три спека сняты с персонажа пользователя 13 сентября.
    [259] = {
        code = "CMQA5HmDzx68KWyrW/8Y781L7PzYMLGMAAAAAwsNYbGAAAAAQbbzMzwMjxyMzMLzsMzMjZmxgZMzMjBAAACABADAwAA",
        note = "Ликвидация",
    },
    [260] = {
        code = "CQQA5HmDzx68KWyrW/8Y781L7DgBDzMzwMLmZGmZGbMzMzy02gtZAAAAAAz22MzMMzYmFzMzyAAAAwYAAAIAABMAADA",
        note = "Головорез",
    },
    [261] = {
        code = "CUQA5HmDzx68KWyrW/8Y781L7DghHYAAAAAgZZMWmM2wMzwMzgZmZWmZ2mZMjtZmZmZmxAmZZAAAAYwYAAAAIEwMAgZA",
        note = "Скрытность",
    },

    -- Жрец. Все три спека сняты с персонажа пользователя 13 сентября.
    [256] = {
        code = "CAQAR03Gt7xPmcDNOjs2Zlb3yCDsMGWmZmZGwMmZZmZGjZGAAAAAAAAAAzwiBzMzAzMDQzEDAACAAAAAwYmZGDzMAYmAA",
        note = "Послушание",
    },
    [257] = {
        code = "CEQAR03Gt7xPmcDNOjs2Zlb3yyYAAAAAAAgZmlxMjZGDzMzYZGmBAAAwMsMDGPwMWmxMDgZKAAQAAAgZmZBQzgxYYmBAzAA",
        note = "Свет",
    },
    [258] = {
        code = "CIQAR03Gt7xPmcDNOjs2Zlb3yOMDGAAAAAAAAAAAghZxMzMLzMmZWmZYG2MYmZGLMZYxMNAzAAIAgAAwgZYMzMjZhZAwMAA",
        note = "Тьма",
    },
}
