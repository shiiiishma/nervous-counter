import SwiftUI
import Charts

/// График динамики эпизодов тревожности с индикацией статуса энергетиков.
struct AnxietyChartView: View {
    let items: [ChartBarItem]
    let range: AnalyticsTimeRange

    private var maxEpisodes: Int {
        items.map(\.episodesCount).max() ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Динамика эпизодов")
                    .font(.headline)
                Spacer()
                legendView
            }

            if items.allSatisfy({ $0.episodesCount == 0 }) {
                emptyChartPlaceholder
            } else {
                chartContent
            }
        }
        .padding(18)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Subviews

    private var legendView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Circle()
                    .fill(DesignSystem.Colors.cleanAccent)
                    .frame(width: 8, height: 8)
                Text("Без энерг.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(DesignSystem.Colors.energyAccent)
                    .frame(width: 8, height: 8)
                Text("Энергетик")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var chartContent: some View {
        Chart {
            ForEach(items) { item in
                BarMark(
                    x: .value("Период", item.label),
                    y: .value("Эпизоды", item.episodesCount)
                )
                .foregroundStyle(
                    item.episodesCount > 0
                        ? DesignSystem.Colors.anxietyAccent
                        : Color.secondary.opacity(0.15)
                )
                .cornerRadius(4)
                .annotation(position: .top, spacing: 4) {
                    if item.episodesCount > 0 {
                        Text("\(item.episodesCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(DesignSystem.Colors.anxietyAccent)
                    }
                }
            }
        }
        .chartYScale(domain: 0...max(3, maxEpisodes + 1))
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.2))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel(centered: true, anchor: .top) {
                    if let label = value.as(String.self) {
                        VStack(spacing: 4) {
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            // Индикатор статуса энергетиков под столбцом дня
                            if range == .week, let matchingItem = items.first(where: { $0.label == label }) {
                                energyDot(for: matchingItem.energyStatus)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 200)
    }

    @ViewBuilder
    private func energyDot(for status: EnergyDrinkStatus) -> some View {
        switch status {
        case .notConsumed:
            Circle()
                .fill(DesignSystem.Colors.cleanAccent)
                .frame(width: 5, height: 5)
        case .consumed:
            Circle()
                .fill(DesignSystem.Colors.energyAccent)
                .frame(width: 5, height: 5)
        case .untracked:
            Circle()
                .fill(Color.clear)
                .frame(width: 5, height: 5)
        }
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.system(size: 36))
                .foregroundStyle(Color.secondary.opacity(0.4))
            Text("За выбранный период эпизодов нет")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }
}
