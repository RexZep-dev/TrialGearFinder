-- Коды талантов по спекам: строка, которую игра принимает в окне талантов
-- кнопкой «Загрузить сборку». Новичку не нужен список названий — ему нужен
-- код, который вставляется целиком.
--
-- ОТКУДА БЕРУТСЯ. Два источника, оба — живые сборки живых игроков.
-- Первый: команда `/tgf talents` печатает код текущей сборки того, кто
-- сидит в игре (игра отдаёт его через C_Traits.GenerateImportString).
-- Второй: страница персонажа на армори отдаёт тот же код готовой строкой.
-- Из логов Warcraft Logs коды не собрать: там таланты записаны номерами
-- узлов дерева, а строка загрузки кодирует ещё и порядок обхода дерева.
--
-- ВАЖНО: код снимать только с двадцатки. С персонажа высокого уровня код
-- в игре на двадцатке не загрузится — в нём взяты таланты, до которых она
-- ещё не доросла. Проверка одной командой: симулятор такой код отвергает
-- с ошибкой «Hash ...», а чужой спек — с ошибкой «Wrong specialization».
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

    -- Охотник. Все три спека взяты с армори двадцаток гильдии 18 сентября
    -- и проверены симулятором. Прежние были сняты на высоком уровне: в игре
    -- на двадцатке не загружались, а в симуляторе давали 920, 893 и 670 урона
    -- против 623, 324 и 254 у настоящих двадцаточных.
    [253] = {
        code = "C0PAD57yiELKEty14ekTDtZEqAAAAAAAAgBDYGMAAAMGAwDwwAAAAAAAAAAAAAAMAAA",
        note = "Повелитель зверей: лучшая из 35 сборок двадцаток гильдии",
    },
    [254] = {
        code = "C4PAD57yiELKEty14ekTDtZEqAAAAAAAAAAAAAAAzAAeAGGAAADMDDADAAAAAAAMAAA",
        note = "Стрельба: лучшая из тех, где есть Быстрая стрельба — её жмут 98 % игроков",
    },
    [255] = {
        code = "C8PAD57yiELKEty14ekTDtZEqAAAAAAwYmBYAAAAAAYGAAGGgGAAAAAAAAAAAAYAAA",
        note = "Выживание: с Огнебомбой — её берут 83 % игроков",
    },
    -- ПОЧЕМУ НЕ ЛУЧШАЯ ПО СИМУЛЯТОРУ НА ОДНОЙ ЦЕЛИ. У Выживания две ветки:
    -- через Обрез (253 на одной цели, 262 на трёх) и через Огнебомбу
    -- (240 на одной, 309 на трёх). Гильдия дерётся пачками, поэтому взята
    -- вторая; её же берут 83 % игроков. Кому нужна одиночная цель — Обрез.
    -- «Огнестрел» в логах — это и есть Обрез (русские названия совпали,
    -- номера разные: Обрез 1261193, Огнестрел Стрельбы 212431).
    -- Укус мангуста из дерева убран, в свежих логах его уже нет.

    -- Паладин. Все три спека взяты с армори двадцаток гильдии 18 сентября
    -- и проверены симулятором: прежние коды были сняты на высоком уровне
    -- и в игре на двадцатке не загружались — в них взяты таланты, до которых
    -- двадцатка ещё не доросла (в симуляторе они давали 1685 урона вместо 517).
    [70] = {
        code = "CYEAzbn3egSOtoSwvPw1U1vTLAAAAAAZhZGAAAAAAAMTBAAwAAAYDAAAAAAAAAAAAAADjBA",
        note = "Воздаяние: сборка Эбеко, лучшая из 43 сборок двадцаток гильдии",
    },
    [66] = {
        code = "CIEAzbn3egSOtoSwvPw1U1vTLsAMgxAAGgBAAAAAAAAwMAAsAAAAAAAAAAAAAAAAAAAYMAA",
        note = "Защита: сборка Пурдюшечки, лучшая из 37 сборок двадцаток гильдии",
    },
    [65] = {
        code = "CEEAzbn3egSOtoSwvPw1U1vTLAAAAAgBAAYAMYAAgB0EDAglMAAAAADAAAAAAAwDAAAAAAAA",
        note = "Свет: сборка Вечнойжизни. Лекаря симулятор не считает — код не замерен",
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

    -- Рыцарь смерти. Все три спека взяты с армори двадцаток гильдии
    -- 19 сентября и проверены симулятором; прежние были с высокого уровня.
    [252] = {
        code = "CwPAkXBWxkyfx9CbGaHonEAhLBAAADMDDwAAAAAAAAAAwAAAMzAAAAAAAAAAwAAAA",
        note = "Нечестивость: лучшая из сборок двадцаток гильдии",
    },
    [251] = {
        code = "CsPAkXBWxkyfx9CbGaHonEAhLBwAAAGzAQGAMAAMzMAAAAAAAAAAAAAAAAAAAAAAA",
        note = "Лёд: лучшая из сборок двадцаток гильдии",
    },
    [250] = {
        code = "CoPAkXBWxkyfx9CbGaHonEAhLBAAAwMTYgBAAAAAMAAAAAzMAAAAAAAAAAAAAAAAA",
        note = "Кровь: лучшая из сборок двадцаток гильдии",
    },

    -- Чернокнижник. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [265] = {
        code = "CkQAMrNP5kak+EBqLfUa3dMm+aMjZGNbmx2MzY2AAAmZmlZxMziZAAAAIAEAAAAgBAAAGzMMLjBGzMzMzDwMzYAAzAA",
        note = "Колдовство",
    },
    [266] = {
        code = "CoQAMrNP5kak+EBqLfUa3dMm+aMjZGNbmx2MzY2AAAAAAAAAAAQIAzMjZbGzMzAAzYGzMAYMzwsAAAGzMjZMGGDAA",
        note = "Демонология",
    },
    [267] = {
        code = "CsQAMrNP5kak+EBqLfUa3dMm+aMzMzoZD2MzYYxMmZZGWWMDAAGzYmZ2AAgAAEYAAgBwsAAAMmZYWAAAMzMzAAYmB",
        note = "Разрушение",
    },

    -- Монах. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [269] = {
        code = "C0QAQnG51S19isUJoJoTeJ/IKbGmBMDbzM2mZGAAAAAAAAAAAYZYEmxGGwMGmZAzyYmhZZmAAWmZWGzMzMzMQAAABBAAAAglZGwAA",
        note = "Танцующий с ветром",
    },
    [270] = {
        code = "C4QAQnG51S19isUJoJoTeJ/IKDAAAAAAAgxMWmZZMbWMjZsNzsgxgZWsMzYhZ0MmBMYWMYZMzMMLwDwsMTAAAAAEAAAIAYAAAMAbTAA",
        note = "Ткач туманов",
    },
    [268] = {
        code = "CwQAQnG51S19isUJoJoTeJ/IKDAAAgxyMmhZYmZhZmBAAAAAAglFMiZGYGGLmxYegZmhZBGzsMssZZb2YmFAAACAAAEADLAAmmZAAAA",
        note = "Хмелевар",
    },

    -- Друид. Все четыре спека взяты с армори двадцаток гильдии 19 сентября
    -- и проверены симулятором; прежние были сняты на высоком уровне.
    [102] = {
        code = "CYGA8cL7tpvige+kkmGM9zUPWDAAAAAAAAAAAAAAAAMAwDAzAAwAYADAwYwAAAGAAAAAAAAAAAAAAAA",
        note = "Баланс: лучшая из 14 сборок двадцаток гильдии",
    },
    [103] = {
        code = "CcGADBD3hSPCL9Y9gz68WcKvMAAAAAAAAAAAAmZGAAAAAAMGwAAGDAAAAAAAAAAAAAAAAAAAAAAAA",
        note = "Сила зверя: лучшая из 16 сборок двадцаток гильдии",
    },
    [104] = {
        code = "CgGA8cL7tpvige+kkmGM9zUPWDAAAAAAAAAAAgZAAAghBAMGwAAGAAAAAAgBAAAAAAAAAAAAwAAAAA",
        note = "Страж: лучшая из 14 сборок двадцаток гильдии",
    },
    [105] = {
        code = "CkGADBD3hSPCL9Y9gz68WcKvMgxMwAAAgNAAAAAAAAAAAGEwEM8AAgBAAAAAAAAAAAAAAAAAAABAAAAA",
        note = "Исцеление: сборка двадцатки гильдии. Лекаря симулятор не считает — не замерена",
    },

    -- Охотник на демонов. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [577] = {
        code = "CEkAp/epaxe7D0A403L+Tvk0iamZGzMzmxMzMzMz0MGDAAAAAAYMmhBGmZGMzYmlZGYZAAAJmxYGAAAAAAQAAYGACAAA",
        note = "Истребление",
    },
    [581] = {
        code = "CUkAp/epaxe7D0A403L+Tvk0iCAYMzMzMmxkxMYWMjZMmZMDzYmZGDzMzM2GzghBAAAAAAQAmZAAAAADMACAAzAAAAA",
        note = "Месть",
    },
    [1480] = {
        code = "CgcBp/epaxe7D0A403L+Tvk0iCA2mxMmZmZmxwMAAAAAAAMGwMAAAAAAAAMjZYmZmZmZmZmxMLmxgW2AQAAMGACYMDjB",
        note = "Пожиратель",
    },

    -- Пробудитель. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [1467] = {
        code = "CsbBPJc41CfcseY0baneJ1IHrBAAAAAAAAAAAzYGmZYGzMwMYmZamZmJjxyMMzMzMzMzAMzAmxYGMDAAABgQAgBAmB",
        note = "Опустошитель",
    },
    [1468] = {
        code = "CwbBPJc41CfcseY0baneJ1IHrBAAAAAmZmZ2WGzYYmxsAwyMGAAMzMzYGMMTmxMAAAgZmRwMzMbjZAAAAAAhwMADAAA",
        note = "Хранитель",
    },
    [1473] = {
        code = "CEcBPJc41CfcseY0baneJ1IHrNmZGmZmZsMYmZZmZMMDAAAAAAAAzMzgZYGqxMzMAAAAwMDYmtxMDMz2AAAAAEBMmBAGA",
        note = "Насыщатель",
    },

    -- Маг. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [64] = {
        code = "CAEAche08tHz49KSVf7iKFnyuBGLzMzsxMzEzMGzMzMDzMzMmxABAAAgAAAbAAAgFA22GzMzgZzwMzYBAAAAMDjBMAA",
        note = "Лед",
    },
    [63] = {
        code = "C8DAche08tHz49KSVf7iKFnyuZmNYmZmNbPwMjMzYAAAYAAQAAAMzMWGzMzYDAAAAAbMzMDAAMmxMjZmZmNDAQGjxAAA",
        note = "Огонь",
    },
    [62] = {
        code = "C4DAche08tHz49KSVf7iKFnyuxsYsMzY2wMDNzMDAAADAACAACAAsBzMzstZZmxsgxMzMzM2YGzMzAAMAAADAAGAAzM",
        note = "Тайная магия",
    },

    -- Шаман. Все три спека сняты с пробного персонажа пользователя 13 сентября.
    [262] = {
        code = "CYQALMl7AwW51MWzGneuHE3tPCAAAAmZZZmZmZmZZZZGmxMAAAAAAAAACBAYWmZMDLGBjFziZmZmZYWmxiZmxMLAADAAYA",
        note = "Стихии",
    },
    [263] = {
        code = "CcQALMl7AwW51MWzGneuHE3tPOzMDjZmZmZmhZmZAAAAAAAAAWAAACAQAAmlZMzwiBYmFziZmZGDjZAAmhxMDzEAYwAA",
        note = "Совершенствование",
    },
    [264] = {
        code = "CgQALMl7AwW51MWzGneuHE3tPCAAAgBAAAAzMzsssMjZGjZYmZMAAgAQAYGmhZZMmphZGmxswiZmZegBWmBAAAYAAYmBG",
        note = "Исцеление",
    },
}
