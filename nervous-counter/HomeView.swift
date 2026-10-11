import SwiftUI
import SwiftData

/// Главный экран: быстрая фиксация тревоги в 1 тап и сводка за текущий день.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AnxietyEpisode.timestamp, order: .reverse) private var allEpisodes: [AnxietyEpisode]
    @Query private var energyLogs: [EnergyDrinkDayLog]

    @State private var activeEpisodeForEditing: AnxietyEpisode?
    @State private var hapticTrigger: Int = 0

    private var repository: DataRepository {
        DataRepository(modelContext: modelContext)
    }

    private var todayStart: Date {
        Calendar.current.startOfDay(for: .now)
    }

    private var todayEpisodes: [AnxietyEpisode] {
        allEpisodes.filter { $0.timestamp >= todayStart }
    }

    private var todayEnergyLog: EnergyDrinkDayLog? {
        energyLogs.first { $0.date == todayStart }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView

                    // Центральная кнопка быстрой фиксации
                    recordButtonSection

                    // Сводка за сегодня
                    todaySummaryCard

                    // Карточка учёта энергетиков
                    EnergyDrinkCard(todayLog: todayEnergyLog)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(DesignSystem.Colors.screenBackground)
            .sheet(item: $activeEpisodeForEditing) { episode in
                QuickLogSheet(episode: episode)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Как вы себя чувствуете?")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            Spacer()
        }
    }

    private var recordButtonSection: some View {
        VStack(spacing: 12) {
            Button {
                triggerQuickRecord()
            } label: {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.anxietySoft)
                            .frame(width: 140, height: 140)

                        Circle()
                            .fill(DesignSystem.Colors.anxietyAccent)
                            .frame(width: 110, height: 110)
                            .shadow(color: DesignSystem.Colors.anxietyAccent.opacity(0.35), radius: 12, x: 0, y: 6)

                        Image(systemName: "plus")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 4) {
                        Text("Зафиксировать тревогу")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                        Text("Одно нажатие сохранит время")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }

    private var todaySummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Сводка за сегодня")
                .font(.headline)

            HStack(spacing: 16) {
                // Карточка количества
                VStack(alignment: .leading, spacing: 6) {
                    Text("Эпизодов")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(todayEpisodes.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(todayEpisodes.isEmpty ? Color.primary : DesignSystem.Colors.anxietyAccent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(DesignSystem.Colors.screenBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))

                // Карточка времени последнего эпизода
                VStack(alignment: .leading, spacing: 6) {
                    Text("Последний")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let last = todayEpisodes.first {
                        Text(last.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 22, weight: .semibold))
                            .lineLimit(1)
                    } else {
                        Text("Пока нет")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(DesignSystem.Colors.screenBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            }
        }
        .padding(18)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Actions

    private func triggerQuickRecord() {
        hapticTrigger += 1
        let newEpisode = repository.recordEpisode()
        activeEpisodeForEditing = newEpisode
    }
}
