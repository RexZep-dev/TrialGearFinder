# Trial Gear Finder

[![CurseForge downloads](https://img.shields.io/curseforge/dt/1681964?label=downloads&color=orange)](https://www.curseforge.com/wow/addons/trial-gear-finder) [![Release](https://img.shields.io/github/v/release/RexZep-dev/TrialGearFinder?label=release)](https://github.com/RexZep-dev/TrialGearFinder/releases) [![Last commit](https://img.shields.io/github/last-commit/RexZep-dev/TrialGearFinder?label=last%20commit)](https://github.com/RexZep-dev/TrialGearFinder/commits/master) [![License: MIT](https://img.shields.io/badge/license-MIT-blue)](https://github.com/RexZep-dev/TrialGearFinder/blob/master/LICENSE.txt) [![Support — Donate](https://img.shields.io/badge/support-donate-e3342f)](https://boosty.to/rexzep)

Лучшие вещи для персонажей 20 уровня (триал) — прямо в игре, без альт-табов
в браузер. Интерфейс на русском и английском.

## Зачем

Триальный аккаунт не растёт выше 20 уровня. Для кого-то это ограничение,
для кого-то отдельная игра: вечный персонаж со своим потолком силы и своим
списком лучших вещей.

Загвоздка в цифрах. Старые вещи на двадцатке пересчитываются в 23, 26 и 32
уровень предмета, а базы вроде Wowhead этот пересчёт не показывают. Поэтому
характеристики, уровень и гнёзда в аддоне сверены с игрой и армори гильдии.

## Что умеет

- **Список вещей по слотам** — характеристики, гнёзда, источник, заметка.
  Фильтры по слоту, классу, броне и источнику; «Мин-Макс» — полная таблица
  с сортировкой по любому стату.
- **«Комьюнити»** — к гайду добавляются вещи, которые игроки считают BiS,
  и добыча недель Путешествия во времени (32 уровень).
- **Окно BiS-сборок** — для каждого класса и спека вещь в каждый из 16 слотов,
  камни и чары. Итог сборки диаграммой или цифрами, перебор после 30%
  подсвечен. Наведи на стат — подсветятся вещи, которые его дают. Кнопка
  «Таланты» — код сборки для окна талантов.
- **Сравнение с надетым** — сборка слева, твой персонаж справа: вещи, камни,
  чары и разница по статам.
- **Путеводитель по приключениям** — значок у подземелий с Путешествием
  во времени; вкладка «Текущий сезон» показывает подземелья его недели или
  дату следующей.
- **Метки на карте** — щелчок по источнику ставит указатель на вход.
- **Проверка твоих вещей** — кружок в строке: вещь совпала с лучшей версией,
  слабее её или ещё не выпала. Отметки ежедневных рарников снимаются сами.
- **Модули** — окно сборок и путеводитель можно выключить в списке аддонов,
  если они не нужны.

## Команды

| Команда | Что делает |
|---|---|
| `/tgf` | открыть или закрыть окно |
| `/tgf bis` | окно BiS-сборок |
| `/tgf compare` | сравнение сборки с надетым |
| `/tgf scan` | сверить надетое, сумки и банк с базой |
| `/tgf new` | вещи, которых нет в базе, — прислать нам |
| `/tgf copy` | скопировать отчёт из чата |

Язык и части путеводителя — в Параметрах → Модификации → Trial Gear Finder.

## Нашёл ошибку — пришли скриншот

Наведи курсор на свою вещь и сравни с тем, что показывает аддон. Не сходится —
пришли скриншот тултипа или вывод `/tgf scan`. Так исправлено уже много записей.

Красный кружок не всегда ошибка: база описывает лучшую версию вещи, а обычная
копия бывает слабее. Ошибка — когда отличается **набор** характеристик.

## Важно

Верные цифры аддон показывает только на персонаже 20 уровня: уровень предмета
игра считает по уровню того, кто смотрит.

Требуется World of Warcraft Retail 12.x. Библиотек не нужно.

## Спасибо

Гильдии «Отвергнутые и Забытые» (https://forsaken.ucoz.net/) — за исходный
список вещей. Forsaken Dungeons (https://forsaken-dungeons.online/) —
за оформление окна.

## Лицензия

Код — MIT, подробности в `LICENSE.txt`.

Автор: **RexZep**

---

## English

Best-in-slot gear for level-20 trial characters, right inside the game.
Russian and English interface — picked from your client language or set in
Settings. Gear list with filters and a full stat table, BiS builds for every
class and spec with gems, enchants and build totals, a compare window against
your equipped gear, Adventure Guide Timewalking icons, map pins and a check of
the items you own. The Builds and Journal modules can be turned off in the
AddOns list. Numbers are correct on a level-20 character only.
