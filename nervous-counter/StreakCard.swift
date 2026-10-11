import SwiftUI

/// Карточка отображения непрерывного периода без энергетиков.
struct StreakCard: View {
    let streakDays: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.cleanSoft)
                    .frame(width: 50, height: 50)

                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.cleanAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(streakDays)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Colors.cleanAccent)

                    Text(daysDeclension(count: streakDays))
                        .font(.headline)
                        .foregroundStyle(DesignSystem.Colors.cleanAccent)
                }

                Text("Непрерывный период без энергетиков")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(18)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func daysDeclension(count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder100 >= 11 && remainder100 <= 19 {
            return "дней подряд"
        }
        switch remainder10 {
        case 1:
            return "день подряд"
        case 2, 3, 4:
            return "дня подряд"
        default:
            return "дней подряд"
        }
    }
}
