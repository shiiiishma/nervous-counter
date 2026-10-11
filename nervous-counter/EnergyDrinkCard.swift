import SwiftUI
import SwiftData

/// Карточка управления статусом энергетиков на текущий день.
struct EnergyDrinkCard: View {
    @Environment(\.modelContext) private var modelContext
    let todayLog: EnergyDrinkDayLog?

    private var repository: DataRepository {
        DataRepository(modelContext: modelContext)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Энергетики сегодня", systemImage: "bolt.fill")
                    .font(.headline)
                    .foregroundStyle(DesignSystem.Colors.energyAccent)
                Spacer()
                statusBadge
            }

            switch currentStatus {
            case .untracked:
                untrackedView
            case .notConsumed:
                notConsumedView
            case .consumed:
                consumedView
            }
        }
        .padding(18)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var currentStatus: EnergyDrinkStatus {
        todayLog?.status ?? .untracked
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch currentStatus {
        case .untracked:
            Text("Не отмечено")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.12))
                .foregroundStyle(.secondary)
                .clipShape(Capsule())
        case .notConsumed:
            Text("Чистый день")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DesignSystem.Colors.cleanSoft)
                .foregroundStyle(DesignSystem.Colors.cleanAccent)
                .clipShape(Capsule())
        case .consumed:
            Text("\(todayLog?.servingsCount ?? 1) порц.")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DesignSystem.Colors.energySoft)
                .foregroundStyle(DesignSystem.Colors.energyAccent)
                .clipShape(Capsule())
        }
    }

    private var untrackedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Употребляли энергетики сегодня?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    repository.updateEnergyDrinkLog(status: .notConsumed)
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Не пил")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(DesignSystem.Colors.cleanSoft)
                    .foregroundStyle(DesignSystem.Colors.cleanAccent)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                }

                Button {
                    repository.updateEnergyDrinkLog(status: .consumed, servingsCount: 1)
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Выпил (1)")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(DesignSystem.Colors.energySoft)
                    .foregroundStyle(DesignSystem.Colors.energyAccent)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                }
            }
        }
    }

    private var notConsumedView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignSystem.Colors.cleanAccent)
                .font(.title3)

            Text("Отмечено: без энергетиков")
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Button("Изменить") {
                repository.updateEnergyDrinkLog(status: .untracked)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var consumedView: some View {
        HStack(spacing: 16) {
            Text("Выпито банок / порций:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    let current = todayLog?.servingsCount ?? 1
                    if current > 1 {
                        repository.updateEnergyDrinkLog(status: .consumed, servingsCount: current - 1)
                    } else {
                        repository.updateEnergyDrinkLog(status: .untracked)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(DesignSystem.Colors.energyAccent)
                }

                Text("\(todayLog?.servingsCount ?? 1)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(minWidth: 24)

                Button {
                    let current = todayLog?.servingsCount ?? 1
                    repository.updateEnergyDrinkLog(status: .consumed, servingsCount: current + 1)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(DesignSystem.Colors.energyAccent)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
