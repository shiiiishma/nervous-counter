import Foundation

/// Выбранный временной диапазон для анализа
enum AnalyticsTimeRange: String, CaseIterable, Identifiable {
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"

    var id: String { rawValue }
}

/// Точка данных для построения графиков
struct ChartBarItem: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let label: String
    let episodesCount: Int
    let averageIntensity: Double?
    let energyStatus: EnergyDrinkStatus
    let energyServings: Int
}

/// Результат сопоставления эпизодов тревоги и употребления энергетиков
struct CorrelationSummary: Equatable {
    /// Количество подтверждённых дней без энергетиков
    let cleanDaysCount: Int
    /// Количество дней с употреблением энергетиков
    let consumedDaysCount: Int
    /// Количество дней без отметок в выбранном периоде
    let untrackedDaysCount: Int

    /// Суммарно эпизодов в чистые дни
    let episodesInCleanDays: Int
    /// Суммарно эпизодов в дни с употреблением
    let episodesInConsumedDays: Int

    /// Среднее количество эпизодов в дни БЕЗ энергетиков
    var averageEpisodesInCleanDay: Double? {
        guard cleanDaysCount > 0 else { return nil }
        return Double(episodesInCleanDays) / Double(cleanDaysCount)
    }

    /// Среднее количество эпизодов в дни С энергетиками
    var averageEpisodesInConsumedDay: Double? {
        guard consumedDaysCount > 0 else { return nil }
        return Double(episodesInConsumedDays) / Double(consumedDaysCount)
    }

    /// Достаточно ли данных для предварительного сопоставления
    var hasSufficientData: Bool {
        cleanDaysCount >= 2 && consumedDaysCount >= 2
    }
}

/// Сравнение показателей тревожности до и после даты отказа
struct QuitComparisonSummary: Equatable {
    let quitDate: Date
    let windowDays: Int
    let episodesBeforeCount: Int
    let episodesAfterCount: Int
    let averageDailyBefore: Double
    let averageDailyAfter: Double
}
