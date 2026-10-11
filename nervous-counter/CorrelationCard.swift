import SwiftUI

/// Карточка сопоставления тревожности с употреблением энергетиков.
struct CorrelationCard: View {
    let summary: CorrelationSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Влияние энергетиков", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(DesignSystem.Colors.energyAccent)
                Spacer()
                if summary.hasSufficientData {
                    Text("Наблюдение")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(DesignSystem.Colors.energySoft)
                        .foregroundStyle(DesignSystem.Colors.energyAccent)
                        .clipShape(Capsule())
                }
            }

            if summary.hasSufficientData {
                comparisonMetricsView
            } else {
                insufficientDataNotice
            }
        }
        .padding(18)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Subviews

    private var comparisonMetricsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                // Без энергетиков
                metricTile(
                    title: "Без энергетиков",
                    value: String(format: "%.1f", summary.averageEpisodesInCleanDay ?? 0),
                    unit: "эпиз. / день",
                    color: DesignSystem.Colors.cleanAccent,
                    bgColor: DesignSystem.Colors.cleanSoft
                )

                // С энергетиками
                metricTile(
                    title: "С энергетиками",
                    value: String(format: "%.1f", summary.averageEpisodesInConsumedDay ?? 0),
                    unit: "эпиз. / день",
                    color: DesignSystem.Colors.energyAccent,
                    bgColor: DesignSystem.Colors.energySoft
                )
            }

            if let clean = summary.averageEpisodesInCleanDay,
               let consumed = summary.averageEpisodesInConsumedDay {
                diffSummary(clean: clean, consumed: consumed)
            }
        }
    }

    private func metricTile(
        title: String,
        value: String,
        unit: String,
        color: Color,
        bgColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(bgColor.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    private func diffSummary(clean: Double, consumed: Double) -> some View {
        let diff = consumed - clean
        let absDiff = abs(diff)

        return HStack(spacing: 8) {
            Image(systemName: diff > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundStyle(diff > 0 ? DesignSystem.Colors.cleanAccent : DesignSystem.Colors.energyAccent)

            if absDiff < 0.1 {
                Text("Частота эпизодов примерно одинакова")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if diff > 0 {
                Text("В дни без энергетиков в среднем на **\(String(format: "%.1f", absDiff))** эпизода меньше")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("В дни без энергетиков в среднем на **\(String(format: "%.1f", absDiff))** эпизода больше")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }

    private var insufficientDataNotice: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Пока недостаточно данных для сопоставления")
                .font(.subheadline)
                .fontWeight(.medium)

            Text("Чтобы увидеть объективную разницу, отметьте ещё хотя бы пару дней с энергетиками и без них.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
