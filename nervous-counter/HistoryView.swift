import SwiftUI
import SwiftData

/// Экран просмотра истории эпизодов тревожности и статуса энергетиков по дням.
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AnxietyEpisode.timestamp, order: .reverse) private var episodes: [AnxietyEpisode]
    @Query(sort: \EnergyDrinkDayLog.date, order: .reverse) private var energyLogs: [EnergyDrinkDayLog]

    @State private var selectedEpisodeForEdit: AnxietyEpisode?
    @State private var isShowingCreateNewSheet: Bool = false

    private var repository: DataRepository {
        DataRepository(modelContext: modelContext)
    }

    /// Список уникальных дней, за которые есть записи тревоги или отметки энергетиков
    private var recordedDays: [Date] {
        let calendar = Calendar.current
        var daysSet = Set<Date>()

        for episode in episodes {
            daysSet.insert(calendar.startOfDay(for: episode.timestamp))
        }
        for log in energyLogs where log.status != .untracked {
            daysSet.insert(calendar.startOfDay(for: log.date))
        }

        // Всегда включаем сегодняшний день для удобства ведения
        daysSet.insert(calendar.startOfDay(for: .now))

        return daysSet.sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            Group {
                if episodes.isEmpty && energyLogs.allSatisfy({ $0.status == .untracked }) {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .background(DesignSystem.Colors.screenBackground)
            .navigationTitle("История")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingCreateNewSheet = true
                    } label: {
                        Label("Добавить запись", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedEpisodeForEdit) { episode in
                EpisodeDetailEditView(episode: episode)
            }
            .sheet(isPresented: $isShowingCreateNewSheet) {
                EpisodeDetailEditView()
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 56))
                .foregroundStyle(DesignSystem.Colors.anxietyAccent.opacity(0.6))

            Text("История пока пуста")
                .font(.title3)
                .fontWeight(.medium)

            Text("Ваши зафиксированные эпизоды и отметки об энергетиках будут сохраняться здесь.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                isShowingCreateNewSheet = true
            } label: {
                Text("Добавить первую запись")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(DesignSystem.Colors.anxietyAccent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var historyListView: some View {
        List {
            ForEach(recordedDays, id: \.self) { day in
                daySection(for: day)
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }

    @ViewBuilder
    private func daySection(for day: Date) -> some View {
        let dayEpisodes = episodes.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: day)
        }
        let dayEnergyLog = energyLogs.first {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }

        Section {
            // Строка статуса энергетиков за этот день
            energyRowForDay(day: day, log: dayEnergyLog)

            // Список эпизодов тревоги за этот день
            if dayEpisodes.isEmpty {
                Text("Эпизодов тревоги не зафиксировано")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(dayEpisodes) { episode in
                    episodeRow(episode: episode)
                }
                .onDelete { indexSet in
                    deleteDayEpisodes(offsets: indexSet, dayEpisodes: dayEpisodes)
                }
            }
        } header: {
            Text(dayHeaderTitle(for: day))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }

    private func energyRowForDay(day: Date, log: EnergyDrinkDayLog?) -> some View {
        Menu {
            Button {
                repository.updateEnergyDrinkLog(for: day, status: .notConsumed)
            } label: {
                Label("Без энергетиков", systemImage: "checkmark.circle")
            }

            Button {
                repository.updateEnergyDrinkLog(for: day, status: .consumed, servingsCount: 1)
            } label: {
                Label("1 банка / порция", systemImage: "cup.and.saucer")
            }

            Button {
                repository.updateEnergyDrinkLog(for: day, status: .consumed, servingsCount: 2)
            } label: {
                Label("2 банки", systemImage: "cup.and.saucer.fill")
            }

            Button {
                repository.updateEnergyDrinkLog(for: day, status: .consumed, servingsCount: 3)
            } label: {
                Label("3+ банки", systemImage: "bolt.fill")
            }

            Divider()

            Button(role: .destructive) {
                repository.updateEnergyDrinkLog(for: day, status: .untracked)
            } label: {
                Label("Сбросить (нет данных)", systemImage: "slash.circle")
            }
        } label: {
            HStack {
                Label("Энергетики", systemImage: "bolt.fill")
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.Colors.energyAccent)

                Spacer()

                energyStatusBadge(log: log)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func energyStatusBadge(log: EnergyDrinkDayLog?) -> some View {
        let status = log?.status ?? .untracked
        switch status {
        case .untracked:
            Text("Нет данных")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .notConsumed:
            Text("Без энергетиков")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Colors.cleanAccent)
        case .consumed:
            Text("Выпито: \(log?.servingsCount ?? 1)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Colors.energyAccent)
        }
    }

    private func episodeRow(episode: AnxietyEpisode) -> some View {
        Button {
            selectedEpisodeForEdit = episode
        } label: {
            HStack(alignment: .top, spacing: 14) {
                // Метка времени
                Text(episode.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)

                // Содержимое: интенсивность и заметка
                VStack(alignment: .leading, spacing: 4) {
                    if let intensity = episode.intensity {
                        HStack(spacing: 6) {
                            Text("Уровень \(intensity)/5")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(DesignSystem.Colors.anxietyAccent.opacity(0.15))
                                .foregroundStyle(DesignSystem.Colors.anxietyAccent)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            Text(intensityDescription(for: intensity))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Интенсивность не указана")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    if let note = episode.note, !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func dayHeaderTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Сегодня, " + date.formatted(.dateTime.day().month(.wide))
        } else if calendar.isDateInYesterday(date) {
            return "Вчера, " + date.formatted(.dateTime.day().month(.wide))
        } else {
            return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        }
    }

    private func intensityDescription(for level: Int) -> String {
        switch level {
        case 1: return "Очень слабая"
        case 2: return "Слабая"
        case 3: return "Умеренная"
        case 4: return "Сильная"
        case 5: return "Очень сильная"
        default: return ""
        }
    }

    private func deleteDayEpisodes(offsets: IndexSet, dayEpisodes: [AnxietyEpisode]) {
        for index in offsets {
            let episode = dayEpisodes[index]
            repository.deleteEpisode(episode)
        }
    }
}
