# Счётчик тревожки (Nervous Counter)

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue?style=for-the-badge&logo=apple" alt="Platform iOS 17+" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/UI-SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Storage-SwiftData-orange?style=for-the-badge" alt="SwiftData" />
  <img src="https://img.shields.io/badge/Charts-Swift_Charts-success?style=for-the-badge" alt="Swift Charts" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" alt="License MIT" />
</p>

Бережный, автономный трекер для фиксации эпизодов тревожности и исследования их корреляции с употреблением энергетических напитков.

Приложение создано как инструмент объективного самонаблюдения: **без серверов, без аккаунтов, без нравоучений и геймификации**. Только честные факты о вашем состоянии.

---

## Основные возможности

### Запись в один тап
- **Мгновенная фиксация:** большая кнопка на главном экране позволяет записать эпизод за долю секунды прямо во время приступа.
- **Тактильный отклик:** мягкая вибрация (`SensoryFeedback`) подтверждает факт записи без необходимости смотреть на экран.
- **Опциональные детали:** после нажатия открывается шторка, где можно (но не обязательно) указать интенсивность по шкале 1–5 и записать возможный триггер.

### Учёт энергетиков
- Фиксация статуса за день в один клик: «Не пил» или «Выпил» (с указанием количества банок).
- Возможность восстановить или изменить статус за любой прошедший день в календаре.

### Объективная аналитика (Swift Charts)
- **Столбчатые графики:** визуализация количества эпизодов по Неделям, Месяцам и Годам с цветными точками-маркерами энергетиков.
- **Анализ влияния:** сопоставление средней частоты тревоги в дни с энергетиками и без них.
- **Стрик отказа:** автоматический подсчёт дней непрерывной трезвости от энергетических напитков.

### Полная история и свобода правок
- Список всех эпизодов, сгруппированный по датам.
- Возможность редактировать интенсивность, время и заметки.
- Добавление эпизодов задним числом, если не было возможности отметить сразу.
- Быстрое удаление ошибочных записей свайпом.

### 100% приватность
- Все данные сохраняются **исключительно на устройстве** в локальной базе **SwiftData**.
- Никакой аналитики, телеметрии, рекламы или отправки данных на сторонние серверы.

---

## Технологический стек

- **Язык:** Swift 5.9+
- **Интерфейс:** SwiftUI (iOS 17+)
- **Хранение данных:** SwiftData (`@Model`, `ModelContext`, `FetchDescriptor`)
- **Графика и чарты:** Swift Charts (`BarMark`, `AxisMarks`)
- **Системные эффекты:** SwiftUI SensoryFeedback, Dynamic Type
- **Архитектура:** Сервисно-репозиторный подход с изоляцией контекста (`DataRepository` на `@MainActor`, чистый сервисный слой `AnalyticsService`)

---

## Структура проекта

```text
nervous-counter/
├── Models/
│   ├── AnxietyEpisode.swift        # Модель эпизода тревоги (SwiftData)
│   ├── EnergyDrinkDayLog.swift     # Модель ежедневного учёта энергетиков
│   └── AnalyticsModels.swift       # Структуры данных для аналитических срезов
├── Services & Repository/
│   ├── DataRepository.swift        # CRUD-операции и синхронизация SwiftData
│   └── AnalyticsService.swift       # Чистая математика расчёта трендов, стриков и корреляций
├── DesignSystem/
│   └── DesignSystem.swift          # Цвета, скругления и константы интерфейса
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift          # Главный экран с кнопкой быстрой фиксации
│   │   ├── EnergyDrinkCard.swift   # Карточка отметки энергетиков за день
│   │   └── QuickLogSheet.swift     # Шторка уточнения интенсивности и заметки
│   ├── History/
│   │   ├── HistoryView.swift       # Экран истории со списком дней
│   │   └── EpisodeDetailEditView.swift # Редактирование / создание задним числом
│   ├── Analytics/
│   │   ├── AnalyticsView.swift     # Экран графиков и статистики
│   │   ├── AnxietyChartView.swift  # Столбчатый график на Swift Charts
│   │   ├── CorrelationCard.swift   # Карточка сравнения влияния энергетиков
│   │   └── StreakCard.swift        # Счётчик дней отказа
│   ├── Settings/
│   │   └── SettingsView.swift      # Настройки, приватность и очистка данных
│   └── Navigation/
│       ├── MainTabView.swift       # Таб-бар приложения (4 вкладки)
│       ├── ContentView.swift       # Корневой контейнер
│       └── MyApp.swift             # Точка входа и инициализация ModelContainer
├── nervous-counter.xcodeproj       # Проект Xcode
├── LICENSE                         # Лицензия MIT
├── .gitignore                      # Исключения версионирования для Xcode / macOS
└── README.md                       # Документация проекта
```

---

## Сборка и запуск

### Требования
- Mac с macOS Sonoma (14.0+) или новее
- Xcode 15.0+ (рекомендуется Xcode 16+)
- Симулятор или устройство с iOS 17.0+

### Инструкция
1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/<ваш-username>/nervous-counter.git
   cd nervous-counter
   ```
2. Откройте проект в Xcode:
   ```bash
   open nervous-counter.xcodeproj
   ```
3. Выберите целевое устройство (например, `iPhone 16 Pro` или подключённый физический iPhone).
4. Нажмите `Cmd + R` для сборки и запуска.

---

## 📄 Лицензия

Проект распространяется под открытой лицензией [MIT](LICENSE). Вы можете свободно использовать, модифицировать и распространять данный код.
