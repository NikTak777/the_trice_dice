# The Trice Dice

## Оглавление

- [Описание проекта](#описание-проекта)
  - [Основная механика](#основная-механика)
- [Игровые уровни](#игровые-уровни)
- [Техническая информация](#техническая-информация)
- [Структура проекта](#структура-проекта)
- [Установка и запуск для работы с исходным кодом](#установка-и-запуск-для-работы-с-исходным-кодом)
- [Установка и запуск для игроков](#установка-и-запуск-для-игроков)
- [Команда разработчиков](#команда-разработчиков)

## Описание проекта
**The Trice Dice** — это roguelike 2D-инди-игра, в которой главный герой, живой игральный кубик, попадает в мир азартных игр. В процессе прохождения он сражается с врагами на трёх уникальных уровнях, стилизованных под казино.

### Основная механика
- Кубик имеет **6 граней**, каждая из которых даёт уникальную способность:
  - Увеличенный урон
  - Повышенное здоровье
  - Ускоренное передвижение
  - Дополнительная броня
  - Усиленная атака
  - Уменьшенный разброс 
- При попадании удара кубик **переворачивается**, случайным образом изменяя свою активную способность.
- Игрок должен использовать эту механику, чтобы адаптироваться к ситуациям и побеждать противников.

## Игровые уровни
1. **Игровые автоматы** — противники в виде анимированных автоматов, стреляющих жетонами.
2. **Покер** — враги-карты с различными эффектами, основанными на мастях и значениях карт.
3. **Рулетка** — уровень с динамическими ловушками и сильным боссом, представляющим собой колесо рулетки.

## Техническая информация
- **Движок**: Godot 4.x
- **Язык программирования**: GDScript
- **Графика**: 2D-растовая
- **Звук и музыка**: собственные и бесплатные ресурсы
- **Поддерживаемые платформы**: Windows
- **Системные требования**:
  - CPU: 2 ядра
  - RAM: 2 ГБ
  - GPU: поддержка OpenGL 3.3 / WebGL 2.0
- **Система ввода**: клавиатура + мышь
- **Сетевой режим**: отсутствует (одиночная игра)
- **Система сборки**: встроенный экспорт Godot

## Структура проекта
Обозначения:
* 📁 — папка
* 🎬 — сцена .tscn
* 📜 — скрипт .gd
* 🔑 — метаданные .gd.uid
```
the_trice_dice/
├── .godot
├── 📁 src/
│   ├── 📁 Assets/
│   ├── 📁 Entities/
│   │   ├── 📁 Boss/
│   │   ├── 📁 Enemies/
│   │   │   ├── 📁 BaseEnemy/
│   │   │   │   ├── 🎬 BaseEnemy.tscn
│   │   │   │   └── 📜 base_enemy.gd
│   │   │   ├── 📁 MeleeEnemy/
│   │   │   │   ├── 📜 damage_dealer.gd
│   │   │   │   ├── 📜 melee_enemy.gd
│   │   │   │   ├── 📜 melee_movement.gd
│   │   │   │   └── 🎬 MeleeEnemy.tscn
│   │   │   └── 📁 RangedEnemy/
│   │   │       ├── 📜 ranged_enemy.gd
│   │   │       ├── 📜 ranged_movement.gd
│   │   │       └── 🎬 RangedEnemy.tscn
│   │   └── 📁 Player/
│   │       ├── 📜 death_player.gd
│   │       ├── 📜 dice.gd
│   │       ├── 🎬 dice.tscn
│   │       └── 📜 victory_player.gd
│   ├── 📁 FX/
│   │   ├── 📁 DamagePopup/
│   │   │   ├── 📜 damage_popup.gd
│   │   │   ├── 🔑 damage_popup.gd.uid
│   │   │   └── 🎬 DamagePopup.tscn
│   │   └── 📁 WallHitEffect/
│   │       ├── 📜 wall_hit_effect.gd
│   │       ├── 🔑 wall_hit_effect.gd.uid
│   │       └── 🎬 WallHitEffect.tscn
│   ├── 📁 Game/
│   │   ├── 📁 Game/
│   │   │   ├── 📜 game.gd
│   │   │   ├── 🔑 game.gd.uid
│   │   │   └── 🎬 game.tscn
│   │   └── 📁 Main/
│   │       ├── 📜 main.gd
│   │       ├── 🔑 main.gd.uid
│   │       └── 🎬 Main.tscn
│   ├── 📁 Levels/
│   │   ├── 📁 DoorManager/
│   │   │   ├── 📜 door_manager.gd
│   │   │   ├── 🔑 door_manager.gd.uid
│   │   │   └── 🎬 DoorManager.tscn
│   │   ├── 📁 EnemyManager/
│   │   │   ├── 📜 enemy_manager.gd
│   │   │   ├── 🔑 enemy_manager.gd.uid
│   │   │   └── 🎬 EnemyManager.tscn
│   │   ├── 📁 EnemySpawner/
│   │   │   ├── 📜 enemy_spawner.gd
│   │   │   ├── 🔑 enemy_spawner.gd.uid
│   │   │   └── 🎬 EnemySpawner.tscn
│   │   ├── 📁 RoomArea/
│   │   │   ├── 📜 room_area.gd
│   │   │   ├── 🔑 room_area.gd.uid
│   │   │   └── 🎬 RoomArea.tscn
│   │   ├── 📜 corridor_graph.gd
│   │   ├── 🔑 corridor_graph.gd.uid
│   │   ├── 📜 map_drawer.gd
│   │   ├── 🔑 map_drawer.gd.uid
│   │   ├── 📜 map_generator.gd
│   │   ├── 🔑 map_generator.gd.uid
│   │   └── 🎬 MapGenerator.tscn
│   ├── 📁 Objects/
│   │   ├── 📁 Bullet/
│   │   │   ├── 📜 bullet.gd
│   │   │   ├── 🔑 bullet.gd.uid
│   │   │   └── 🎬 Bullet.tscn
│   │   ├── 📁 EnemyBullet/
│   │   │   ├── 📜 enemy_bullet.gd
│   │   │   ├── 🔑 enemy_bullet.gd.uid
│   │   │   └── 🎬 EnemyBullet.tscn
│   │   └── 📁 Weapon/
│   │   │   ├── 📜 weapon.gd
│   │   │   ├── 🔑 weapon.gd.uid
│   │   │   └── 🎬 weapon.tscn
│   ├── 📁 UserInterface/
│   │   ├── 📁 AbilityTitle/
│   │   ├── 📁 GameOverLabel/
│   │   ├── 📁 HealthBar/
│   │   ├── 📁 HintLabel/
│   │   ├── 📁 InGameMenu/
│   │   ├── 📁 MainMenu/
│   │   └── 📁 VictoryLabel/
│   └── 📁 Utils/
│       ├── 📁 AbilityManager/
│       │   ├── 📜 ability_manager.gd
│       │   └── 🔑 ability_manager.gd.uid
│       ├── 📁 Console/
│       │   ├── 📁 Commands/
│       │   │   ├── 📜 cmd_ability.gd
│       │   │   ├── 🔑 cmd_ability.gd.uid
│       │   │   ├── 📜 cmd_default.gd
│       │   │   ├── 🔑 cmd_default.gd.uid
│       │   │   ├── 📜 cmd_give.gd
│       │   │   ├── 🔑 cmd_give.gd.uid
│       │   │   ├── 📜 cmd_health.gd
│       │   │   ├── 🔑 cmd_health.gd.uid
│       │   │   ├── 📜 cmd_help.gd
│       │   │   ├── 🔑 cmd_help.gd.uid
│       │   │   ├── 📜 cmd_kill.gd
│       │   │   ├── 🔑 cmd_kill.gd.uid
│       │   │   ├── 📜 cmd_restart.gd
│       │   │   ├── 🔑 cmd_restart.gd.uid
│       │   │   ├── 📜 cmd_show_nodes.gd
│       │   │   ├── 🔑 cmd_show_nodes.gd.uid
│       │   │   ├── 📜 md_zoom.gd
│       │   │   └── 🔑 cmd_zoom.gd.uid
│       │   ├── 📜 console.gd
│       │   ├── 🔑 console.gd.uid
│       │   └── 🎬 Console.tscn
│       ├── 📁 Inventory/
│       │   ├── 📜 inventory.gd
│       │   ├── 🔑 inventory.gd.uid
│       │   └── 🎬 Inventory.tscn
│       ├── 📁 SeparationArea/
│       │   └── 🎬 SeparationArea.tscn
│       ├── 📁 SpriteFlipper/
│       │   ├── 📜 sprite_flipper.gd
│       │   ├── 🔑 sprite_flipper.gd.uid
│       │   └── 🎬 SpriteFlipper.tscn
│       ├── 📁 WeaponFactory/
│       │   ├── 📜 weapon_factory.gd
│       │   ├── 🔑 weapon_factory.gd.uid
│       │   └── 🎬 WeaponFactory.tscn
│       ├── 📁 WeaponSpawner/
│       │   ├── 📜 weapon_spawner.gd
│       │   ├── 🔑 weapon_spawner.gd.uid
│       │   └── 🎬 WeaponSpawner.tscn
│       ├── 📁 ZoomController/
│       │   ├── 📜zoom_controller.gd
│       │   ├── 🔑 zoom_controller.gd.uid
│       │   └── 🎬ZoomController.tscn
│       ├── 📜 Global.gd
│       └── 🔑 Global.gd.uid
├── README.md
├── export_presets.cfg
├── icon.svg
├── icon.svg.import
└── project.godot
```

## Установка и запуск для работы с исходным кодом
1. Установите движок Godot по [ссылке](https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_win64.exe.zip)
2. Склонируйте репозиторий:
   ```bash
   git clone https://github.com/NikTak777/the_trice_dice.git
   ```
3. Откройте проект в Godot.
4. Редактируйте проект и запускайте игру по нажатию кнопки ▶ для просмотра результата!

## Установка и запуск для игроков
1. Скачайте последний релиз The Trice Dice из раздела [Releases](https://github.com/NikTak777/the_trice_dice/releases).
2. Распакуйте в удобное для вас место на компьютере.
3. Запустите файл "The Trice Dice.exe" и наслаждайтесь игрой!

## Команда разработчиков
- [**Кондрахин Никита**](https://github.com/NikTak777) — лидер проекта, программист, геймдизайнер
- [**Подрабинович Максим**](https://github.com/psixonaut) — программист
- [**Олещук Станислав**](https://github.com/lRelezl) — документация
