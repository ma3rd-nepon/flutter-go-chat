# Nova UI

> Flutter UI kit with a warm phoenix-inspired design system.

`Flutter` · `Dart` · `Linux` · `Android` · `iOS` · `MIT`

---

## Содержание

* [Установка](#установка)
* [Быстрый старт](#быстрый-старт)
* [Дизайн-система](#дизайн-система)

  * [Палитра «Феникс»](#палитра-феникс)
  * [Шрифты](#шрифты)
  * [Формы](#формы)
* [Каталог виджетов](#каталог-виджетов)

  * [Кнопки](#кнопки)
  * [Ввод](#ввод)
  * [Контролы выбора](#контролы-выбора)
  * [Чипы](#чипы)
  * [Поверхности и списки](#поверхности-и-списки)
  * [Чаты](#чаты)
  * [Прогресс и обратная связь](#прогресс-и-обратная-связь)
  * [Навигация](#навигация)
  * [Оверлеи](#оверлеи)
  * [Фирменное и декор](#фирменное-и-декор)
* [Структура проекта](#структура-проекта)
* [Сцена с фениксом](#сцена-с-фениксом)
* [Лицензия](#лицензия)

---

## Установка

### Linux

```bash
sudo dnf install git clang ninja-build cmake pkg-config gtk3-devel
```

### Опционально

| Платформа | Что нужно                                                     |
| :-------- | :------------------------------------------------------------ |
| `Android` | Android Studio + SDK 36 (`flutter doctor --android-licenses`) |
| `iOS`     | **только macOS** + Xcode (ограничение Apple, не Flutter)      |

---

## Быстрый старт

```bash
git clone https://github.com/rimanetcz/nova_ui.git
cd nova_ui
flutter pub get
flutter run -d linux
```

Все ассеты (шрифты и спрайты феникса) уже лежат в `assets/` после клона —
ничего докатывать не нужно.

---

## Дизайн-система

### Палитра «Феникс»

| Токен        |    HEX    | Смысл                             |
| :----------- | :-------: | :-------------------------------- |
| `background` | `#171008` | угольный фон сцены                |
| `surface`    | `#2A1D10` | поверхности карточек/панелей      |
| `paper`      | `#FFF6EC` | светлый текст, «бумага»           |
| `ink`        | `#120B04` | чернильные обводки и тёмный текст |
| `flame`      | `#FF6B00` | основной огненный акцент          |
| `gold`       | `#FFB300` | вторичный акцент                  |
| `ember`      | `#E5484D` | danger / тлеющие угли             |
| `muted`      | `#A89C8C` | приглушённый текст                |

Все цвета лежат в одном тёплом hue-секторе (0–45°) темы можно генерировать
сдвигом оттенка без потери характера.

### Шрифты

Шрифты входят в комплект и находятся в `assets/fonts/`.

| Шрифт             | Назначение                      |
| :---------------- | :------------------------------ |
| **Unbounded**     | дисплейный — заголовки, логотип |
| **Manrope**       | текстовый — кнопки, подписи     |
| **JetBrainsMono** | моно — время, ярлыки, «чек»     |

### Формы

* скругление кнопок — `12`
* «фирменный» срезанный угол — у карточек/стикеров (`NovaCutBox`)
* жёсткие тени без blur в брутальных элементах
* цветное свечение у «живых» кнопок

---

## Каталог виджетов

Всё подключается одним импортом:

```dart
import 'package:nova_ui/novakit.dart';
```

### Кнопки

| Виджет                     | Что это                                                                                       | Файл                                       |
| :------------------------- | :-------------------------------------------------------------------------------------------- | :----------------------------------------- |
| `NovaButton`               | кнопка: 4 варианта × 4 типа × 3 размера, «дышащий» градиент, блик, загрузка без смены размера | `lib/button/nova_button.dart`              |
| `NovaFloatingActionButton` | ромб-FAB с иконкой                                                                            | `lib/fab/nova_floating_action_button.dart` |

### Ввод

| Виджет              | Что это                                                          | Файл                                       |
| :------------------ | :--------------------------------------------------------------- | :----------------------------------------- |
| `NovaTextField`     | поле с плавающей подписью, огненным фокусом и правокликовым меню | `lib/text_field/nova_text_field.dart`      |
| `NovaTextFormField` | то же + валидация для `Form`                                     | `lib/text_field/nova_text_form_field.dart` |

### Контролы выбора

| Виджет         | Что это                                | Файл                              |
| :------------- | :------------------------------------- | :-------------------------------- |
| `NovaSwitch`   | квадратный тумблер с пружинным кружком | `lib/switch/nova_switch.dart`     |
| `NovaCheckbox` | чекбокс с рисованной галочкой          | `lib/checkbox/nova_checkbox.dart` |
| `NovaRadio<T>` | радио с огненной точкой                | `lib/radio/nova_radio.dart`       |
| `NovaSlider`   | слайдер с огоньком-заполнением         | `lib/slider/nova_slider.dart`     |

### Чипы

| Виджет           | Что это                         | Файл                             |
| :--------------- | :------------------------------ | :------------------------------- |
| `NovaChip`       | тег-пилюля с крестиком удаления | `lib/chip/nova_chip.dart`        |
| `NovaFilterChip` | мультивыбор с галочкой          | `lib/chip/nova_filter_chip.dart` |
| `NovaChoiceChip` | одиночный выбор с точкой        | `lib/chip/nova_choice_chip.dart` |

### Поверхности и списки

| Виджет         | Что это                                                     | Файл                                |
| :------------- | :---------------------------------------------------------- | :---------------------------------- |
| `NovaCard`     | карточка со срезанным углом и жёсткой тенью                 | `lib/card/nova_card.dart`           |
| `NovaListTile` | строка списка                                               | `lib/list_tile/nova_list_tile.dart` |
| `NovaDivider`  | разделитель                                                 | `lib/divider/nova_divider.dart`     |
| `NovaCutBox`   | базовая «рубленая» поверхность (используется внутри многих) | `lib/theme/nova_cut_box.dart`       |

### Чаты

| Виджет                | Что это                                                                       | Файл                                  |
| :-------------------- | :---------------------------------------------------------------------------- | :------------------------------------ |
| `NovaChatTile`        | строка чата: аватар, статус-точка, горящая полоса непрочитанных, ромб-счётчик | `lib/chat/nova_chat_tile.dart`        |
| `NovaFlameBar`        | живая полоса огня (анимированное пламя с искрами)                             | `lib/chat/nova_flame_bar.dart`        |
| `NovaMessageBubble`   | пузырь сообщения с галочками и копированием по ПКМ                            | `lib/chat/nova_message_bubble.dart`   |
| `NovaTypingIndicator` | «печатает…» с прыгающими точками                                              | `lib/chat/nova_typing_indicator.dart` |
| `NovaChatScreen`      | экран переписки с автоответами                                                | `lib/chat/nova_chat_screen.dart`      |

### Прогресс и обратная связь

| Виджет                 | Что это                                         | Файл                                       |
| :--------------------- | :---------------------------------------------- | :----------------------------------------- |
| `NovaLinearProgress`   | линейный прогресс с бегущими огненными полосами | `lib/progress/nova_linear_progress.dart`   |
| `NovaCircularProgress` | кольцо с золотым ромбом-головкой                | `lib/progress/nova_circular_progress.dart` |
| `NovaSnackBar`         | снекбар с горящей полосой (через Overlay)       | `lib/snackbar/nova_snack_bar.dart`         |
| `NovaTooltip`          | моно-тултип при наведении                       | `lib/tooltip/nova_tooltip.dart`            |

### Навигация

| Виджет               | Что это                       | Файл                                  |
| :------------------- | :---------------------------- | :------------------------------------ |
| `NovaAppBar`         | верхняя панель                | `lib/app_bar/nova_app_bar.dart`       |
| `NovaTabBar`         | вкладки с огненным бегунком   | `lib/tab_bar/nova_tab_bar.dart`       |
| `NovaNavigationBar`  | нижний навбар (для мобильных) | `lib/navigation/nova_navigation.dart` |
| `NovaNavigationRail` | боковая рельса (для десктопа) | `lib/navigation/nova_navigation.dart` |
| `NovaDrawer`         | выезжающее меню               | `lib/drawer/nova_drawer.dart`         |
| `NovaRouter`         | push/pop со слайд-переходом   | `lib/router/nova_router.dart`         |

### Оверлеи

| Виджет                                | Что это                                 | Файл                                      |
| :------------------------------------ | :-------------------------------------- | :---------------------------------------- |
| `NovaDialog` / `NovaAlertDialog`      | рубленые диалоговые окна                | `lib/dialog/nova_dialog.dart`             |
| `NovaBottomSheet`                     | выезжающая снизу панель                 | `lib/bottom_sheet/nova_bottom_sheet.dart` |
| `NovaPopupMenuButton`                 | меню у кнопки                           | `lib/menu/nova_popup_menu.dart`           |
| `NovaDropdownButton`                  | выпадающий список                       | `lib/menu/nova_dropdown.dart`             |
| `NovaContextMenu` + `NovaTextActions` | правокликовое меню и операции с буфером | `lib/menu/nova_context_menu.dart`         |

### Фирменное и декор

| Виджет                                                  | Что это                                          | Файл                              |
| :------------------------------------------------------ | :----------------------------------------------- | :-------------------------------- |
| `NovaReceipt` / `NovaReceiptRow` / `NovaBarcode`        | «чек» с зубцами и штрих-кодом (пасхалка/история) | `lib/receipt/nova_receipt.dart`   |
| `PhoenixEmbers`                                         | фон: тлеющие угольки                             | `lib/embers/phoenix_embers.dart`  |
| `PhoenixFlight`                                         | фон: летящий феникс (спрайт-анимация) + солнце   | `lib/phoenix/phoenix_flight.dart` |
| `NovaIcon*` (Menu, Chat, Flame, User, Gear, Back, Send) | рисованные иконки                                | `lib/icons/nova_icons.dart`       |
| `NovaTheme`                                             | токены палитры и шрифтов                         | `lib/theme/nova_theme.dart`       |

---

## Структура проекта

```text
lib/
├── main.dart            # демо-мессенджер (витрина кита)
├── novakit.dart         # единая точка экспорта всех виджетов
├── theme/               # токены дизайна и базовые поверхности
├── button/  switch/  checkbox/  radio/  slider/
├── text_field/  chip/  card/  list_tile/  divider/
├── chat/                # переписка: плитка, пузырь, экран, огонь
├── progress/  snackbar/  tooltip/
├── app_bar/  tab_bar/  navigation/  drawer/  router/
├── dialog/  bottom_sheet/  menu/  fab/
├── receipt/  icons/  models/
└── embers/  phoenix/    # анимированные фоновые сцены

assets/
├── fonts/               # Unbounded, Manrope, JetBrainsMono
└── images/              # спрайты феникса (phoenix1..4.png)
```

---

## Сцена с фениксом

`PhoenixFlight` перебирает кадры взмаха из `assets/images/` со скоростью
`_fps` (в `lib/phoenix/phoenix_flight.dart`).

---

## Лицензия

**MIT License**

```text
Copyright (c) 2026 Emir Samkhanov (rimanetcz), Danil Besedin (ma3rd-nepon)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

© 2026 Эмир Самарханов, Данил Беседин. Лицензия MIT.

