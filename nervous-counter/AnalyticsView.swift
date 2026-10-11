import SwiftUI
import SwiftData

/// Главный экран статистики, графиков и сопоставления с энергетиками.
struct AnalyticsView: View {
    @Query(sort: \AnxietyEpisode.timestamp, order: .reverse) private var episodes: [AnxietyEpisode]
    @Query(sort: \EnergyDrinkDayLog.date, order: .reverse) private var energyLogs: [EnergyDrinkDayLog]

    @State private var selectedRange: AnalyticsTimeRange = .week
    @State private var referenceDate: Date = .now

    private var chartItems: [ChartBarItem] {
        AnalyticsService.buildChartItems(
            range: selectedRange,
            referenceDate: referenceDate,
            episodes: episodes,
            energyLogs: energyLogs
        )
    }

    private var correlationSummary: CorrelationSummary {
        AnalyticsService.calculateCorrelation(
            range: selectedRange,
            referenceDate: referenceDate,
            episodes: episodes,
            energyLogs: energyLogs
        )
    }

    private var cleanStreak: Int {
        AnalyticsService.calculateCleanStreak(energyLogs: energyLogs)
    }

    private var totalPeriodEpisodes: Int {
        chartItems.reduce(0) { $0 + $1.episodesCount }
    }

    private var averageDailyEpisodes: Double {
        let count = max(1, chartItems.count)
        return Double(totalPeriodEpisodes) / Double(count)
    }

    private var isCurrentPeriod: Bool {
        let cal = Calendar.current
        let currentInterval = AnalyticsService.dateInterval(for: selectedRange, referenceDate: .now)
        let viewedInterval = AnalyticsService.dateInterval(for: selectedRange, referenceDate: referenceDate)
        return cal.isDate(currentInterval.start, inSameDayAs: viewedInterval.start)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Переключатель диапазонов: Неделя | Месяц | Год
                    Picker("Период", selection: $selectedRange) {
                        ForEach(AnalyticsTimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedRange) { _, _ in
                        referenceDate = .now
                    }

                    // Навигация по периодам (< Период >)
                    periodNavigator

                    // Сводные метрики периода
                    periodSummaryTiles

                    // Столбчатый график динамики
                    AnxietyChartView(items: chartItems, range: selectedRange)

                    // Карточка сопоставления с энергетиками
                    CorrelationCard(summary: correlationSummary)

                    // Карточка непрерывного отказа
                    StreakCard(streakDays: cleanStreak)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(DesignSystem.Colors.screenBackground)
            .navigationTitle("Статистика")
        }
    }

    // MARK: - Subviews

    private var periodNavigator: some View {
        HStack {
            Button {
                referenceDate = AnalyticsService.shift(referenceDate: referenceDate, range: selectedRange, by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(DesignSystem.Colors.cardBackground)
                    .clipShape(Circle())
            }

            Spacer()

            Text(periodTitle)
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Button {
                if !isCurrentPeriod {
                    referenceDate = AnalyticsService.shift(referenceDate: referenceDate, range: selectedRange, by: 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background(DesignSystem.Colors.cardBackground)
                    .clipShape(Circle())
            }
            .opacity(isCurrentPeriod ? 0.3 : 1.0)
            .disabled(isCurrentPeriod)
        }
    }

    private var periodSummaryTiles: some View {
        HStack(spacing: 12) {
            // Всего эпизодов
            summaryTile(
                title: "Всего эпизодов",
                value: "\(totalPeriodEpisodes)",
                subtitle: "за период"
            )

            // В среднем за день
            summaryTile(
                title: "В среднем в день",
                value: String(format: "%.1f", averageDailyEpisodes),
                subtitle: "эпиз. / день"
            )
        }
    }

    private func summaryTile(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.anxietyAccent)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Helpers

    private var periodTitle: String {
        let interval = AnalyticsService.dateInterval(for: selectedRange, referenceDate: referenceDate)
        switch selectedRange {
        case .week:
            let startStr = interval.start.formatted(.dateTime.day().month(.abbreviated))
            let endStr = interval.end.formatted(.dateTime.day().month(.abbreviated))
            return "\(startStr) — \(endStr)"
        case .month:
            return interval.start.formatted(.dateTime.month(.wide).year())
        case .year:
            return interval.start.formatted(.dateTime.year()) + " год"
        }
    }
}
