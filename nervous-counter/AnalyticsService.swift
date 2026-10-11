import Foundation

/// Чистый сервисный слой аналитики и математических расчетов для экранов статистики.
struct AnalyticsService {
    private static var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Начинаем неделю с понедельника
        return cal
    }

    // MARK: - Интервалы времени

    /// Границы периода для выбранного диапазона и опорной даты
    static func dateInterval(for range: AnalyticsTimeRange, referenceDate: Date = .now) -> DateInterval {
        let cal = calendar

        switch range {
        case .week:
            let startOfWeek = cal.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? referenceDate
            let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek)?.addingTimeInterval(-1) ?? referenceDate
            return DateInterval(start: startOfWeek, end: endOfWeek)

        case .month:
            let startOfMonth = cal.dateInterval(of: .month, for: referenceDate)?.start ?? referenceDate
            let endOfMonth = cal.dateInterval(of: .month, for: referenceDate)?.end.addingTimeInterval(-1) ?? referenceDate
            return DateInterval(start: startOfMonth, end: endOfMonth)

        case .year:
            let startOfYear = cal.dateInterval(of: .year, for: referenceDate)?.start ?? referenceDate
            let endOfYear = cal.dateInterval(of: .year, for: referenceDate)?.end.addingTimeInterval(-1) ?? referenceDate
            return DateInterval(start: startOfYear, end: endOfYear)
        }
    }

    /// Сдвиг опорной даты вперед или назад по шагам диапазона (например, прошлая неделя)
    static func shift(referenceDate: Date, range: AnalyticsTimeRange, by step: Int) -> Date {
        let cal = calendar
        let component: Calendar.Component
        switch range {
        case .week: component = .weekOfYear
        case .month: component = .month
        case .year: component = .year
        }
        return cal.date(byAdding: component, value: step, to: referenceDate) ?? referenceDate
    }

    // MARK: - Подготовка данных для столбчатого графика

    /// Генерация элементов столбчатого графика для выбранного периода
    static func buildChartItems(
        range: AnalyticsTimeRange,
        referenceDate: Date,
        episodes: [AnxietyEpisode],
        energyLogs: [EnergyDrinkDayLog]
    ) -> [ChartBarItem] {
        let interval = dateInterval(for: range, referenceDate: referenceDate)
        let cal = calendar

        // Индексируем логи энергетиков по нормализованному дню
        var energyMap: [Date: EnergyDrinkDayLog] = [:]
        for log in energyLogs {
            let dayKey = cal.startOfDay(for: log.date)
            energyMap[dayKey] = log
        }

        switch range {
        case .week:
            return buildWeekItems(startOfWeek: interval.start, episodes: episodes, energyMap: energyMap)
        case .month:
            return buildMonthItems(startOfMonth: interval.start, interval: interval, episodes: episodes, energyMap: energyMap)
        case .year:
            return buildYearItems(startOfYear: interval.start, episodes: episodes, energyMap: energyMap)
        }
    }

    private static func buildWeekItems(
        startOfWeek: Date,
        episodes: [AnxietyEpisode],
        energyMap: [Date: EnergyDrinkDayLog]
    ) -> [ChartBarItem] {
        let cal = calendar
        var items: [ChartBarItem] = []
        let weekdaySymbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

        for dayOffset in 0..<7 {
            guard let dayDate = cal.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }
            let dayStart = cal.startOfDay(for: dayDate)
            let nextDayStart = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

            let dayEpisodes = episodes.filter { $0.timestamp >= dayStart && $0.timestamp < nextDayStart }
            let energyLog = energyMap[dayStart]

            let intensities = dayEpisodes.compactMap { $0.intensity }
            let avgIntensity = intensities.isEmpty ? nil : Double(intensities.reduce(0, +)) / Double(intensities.count)

            items.append(ChartBarItem(
                date: dayStart,
                label: weekdaySymbols[dayOffset],
                episodesCount: dayEpisodes.count,
                averageIntensity: avgIntensity,
                energyStatus: energyLog?.status ?? .untracked,
                energyServings: energyLog?.servingsCount ?? 0
            ))
        }

        return items
    }

    private static func buildMonthItems(
        startOfMonth: Date,
        interval: DateInterval,
        episodes: [AnxietyEpisode],
        energyMap: [Date: EnergyDrinkDayLog]
    ) -> [ChartBarItem] {
        let cal = calendar
        var items: [ChartBarItem] = []
        let daysInMonth = cal.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30

        for dayOffset in 0..<daysInMonth {
            guard let dayDate = cal.date(byAdding: .day, value: dayOffset, to: startOfMonth) else { continue }
            let dayStart = cal.startOfDay(for: dayDate)
            let nextDayStart = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let dayNumber = cal.component(.day, from: dayStart)

            let dayEpisodes = episodes.filter { $0.timestamp >= dayStart && $0.timestamp < nextDayStart }
            let energyLog = energyMap[dayStart]

            let intensities = dayEpisodes.compactMap { $0.intensity }
            let avgIntensity = intensities.isEmpty ? nil : Double(intensities.reduce(0, +)) / Double(intensities.count)

            items.append(ChartBarItem(
                date: dayStart,
                label: "\(dayNumber)",
                episodesCount: dayEpisodes.count,
                averageIntensity: avgIntensity,
                energyStatus: energyLog?.status ?? .untracked,
                energyServings: energyLog?.servingsCount ?? 0
            ))
        }

        return items
    }

    private static func buildYearItems(
        startOfYear: Date,
        episodes: [AnxietyEpisode],
        energyMap: [Date: EnergyDrinkDayLog]
    ) -> [ChartBarItem] {
        let cal = calendar
        var items: [ChartBarItem] = []
        let monthShortNames = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]

        for monthOffset in 0..<12 {
            guard let monthStart = cal.date(byAdding: .month, value: monthOffset, to: startOfYear),
                  let nextMonthStart = cal.date(byAdding: .month, value: 1, to: monthStart) else { continue }

            let monthEpisodes = episodes.filter { $0.timestamp >= monthStart && $0.timestamp < nextMonthStart }

            let intensities = monthEpisodes.compactMap { $0.intensity }
            let avgIntensity = intensities.isEmpty ? nil : Double(intensities.reduce(0, +)) / Double(intensities.count)

            items.append(ChartBarItem(
                date: monthStart,
                label: monthShortNames[monthOffset],
                episodesCount: monthEpisodes.count,
                averageIntensity: avgIntensity,
                energyStatus: .untracked,
                energyServings: 0
            ))
        }

        return items
    }

    // MARK: - Сопоставление с энергетиками

    /// Расчёт сравнительной статистики по дням «с энергетиками» и «без»
    static func calculateCorrelation(
        range: AnalyticsTimeRange,
        referenceDate: Date,
        episodes: [AnxietyEpisode],
        energyLogs: [EnergyDrinkDayLog]
    ) -> CorrelationSummary {
        let cal = calendar
        let interval = dateInterval(for: range, referenceDate: referenceDate)

        // Фильтруем логи энергетиков в рамках выбранного интервала
        let relevantLogs = energyLogs.filter { $0.date >= interval.start && $0.date <= interval.end }

        var cleanDays = 0
        var consumedDays = 0
        var cleanEpisodesCount = 0
        var consumedEpisodesCount = 0
        var processedDays = Set<Date>()

        for log in relevantLogs {
            let dayStart = cal.startOfDay(for: log.date)
            if processedDays.contains(dayStart) { continue }
            processedDays.insert(dayStart)

            let nextDay = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let dayEpisodes = episodes.filter { $0.timestamp >= dayStart && $0.timestamp < nextDay }.count

            switch log.status {
            case .notConsumed:
                cleanDays += 1
                cleanEpisodesCount += dayEpisodes
            case .consumed:
                consumedDays += 1
                consumedEpisodesCount += dayEpisodes
            case .untracked:
                break
            }
        }

        // Общее число календарных дней в интервале
        let startDay = cal.startOfDay(for: interval.start)
        let endDay = cal.startOfDay(for: interval.end)
        let totalDaysInInterval = max(1, (cal.dateComponents([.day], from: startDay, to: endDay).day ?? 6) + 1)
        let untrackedDays = max(0, totalDaysInInterval - (cleanDays + consumedDays))

        return CorrelationSummary(
            cleanDaysCount: cleanDays,
            consumedDaysCount: consumedDays,
            untrackedDaysCount: untrackedDays,
            episodesInCleanDays: cleanEpisodesCount,
            episodesInConsumedDays: consumedEpisodesCount
        )
    }

    // MARK: - Непрерывный стрик отказа

    /// Подсчет количества дней подряд без энергетиков до сегодняшнего дня
    static func calculateCleanStreak(energyLogs: [EnergyDrinkDayLog], today: Date = .now) -> Int {
        let cal = calendar
        var currentDay = cal.startOfDay(for: today)
        var streak = 0

        var statusMap: [Date: EnergyDrinkStatus] = [:]
        for log in energyLogs {
            statusMap[cal.startOfDay(for: log.date)] = log.status
        }

        // Если сегодня еще не отмечено, начинаем проверку со вчерашнего дня
        if statusMap[currentDay] == nil || statusMap[currentDay] == .untracked {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: currentDay) else { return 0 }
            currentDay = yesterday
        }

        while true {
            guard let status = statusMap[currentDay] else { break }

            if status == .notConsumed {
                streak += 1
                guard let previousDay = cal.date(byAdding: .day, value: -1, to: currentDay) else { break }
                currentDay = previousDay
            } else {
                // Прерывание стрика (выпил или нет отметки)
                break
            }
        }

        return streak
    }

    // MARK: - Сравнение До и После отказа

    /// Анализ частоты эпизодов до и после заданной даты отказа от энергетиков
    static func calculateQuitComparison(
        quitDate: Date,
        episodes: [AnxietyEpisode],
        windowDays: Int = 14
    ) -> QuitComparisonSummary {
        let cal = calendar
        let normalizedQuitDate = cal.startOfDay(for: quitDate)

        guard let beforeStart = cal.date(byAdding: .day, value: -windowDays, to: normalizedQuitDate),
              let afterEnd = cal.date(byAdding: .day, value: windowDays, to: normalizedQuitDate) else {
            return QuitComparisonSummary(
                quitDate: quitDate,
                windowDays: windowDays,
                episodesBeforeCount: 0,
                episodesAfterCount: 0,
                averageDailyBefore: 0,
                averageDailyAfter: 0
            )
        }

        let beforeEpisodes = episodes.filter { $0.timestamp >= beforeStart && $0.timestamp < normalizedQuitDate }.count
        let afterEpisodes = episodes.filter { $0.timestamp >= normalizedQuitDate && $0.timestamp <= afterEnd }.count

        let avgBefore = Double(beforeEpisodes) / Double(max(1, windowDays))
        let avgAfter = Double(afterEpisodes) / Double(max(1, windowDays))

        return QuitComparisonSummary(
            quitDate: quitDate,
            windowDays: windowDays,
            episodesBeforeCount: beforeEpisodes,
            episodesAfterCount: afterEpisodes,
            averageDailyBefore: avgBefore,
            averageDailyAfter: avgAfter
        )
    }
}
