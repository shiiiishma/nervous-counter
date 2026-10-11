import Foundation
import SwiftData

/// Вспомогательный сервис для работы с базой данных SwiftData.
@MainActor
struct DataRepository {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Anxiety Episodes

    /// Быстрая фиксация эпизода тревоги с текущим временем
    @discardableResult
    func recordEpisode(
        intensity: Int? = nil,
        note: String? = nil,
        timestamp: Date = .now
    ) -> AnxietyEpisode {
        let episode = AnxietyEpisode(
            timestamp: timestamp,
            intensity: intensity,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? note : nil
        )
        modelContext.insert(episode)
        try? modelContext.save()
        return episode
    }

    /// Удаление эпизода тревоги
    func deleteEpisode(_ episode: AnxietyEpisode) {
        modelContext.delete(episode)
        try? modelContext.save()
    }

    // MARK: - Energy Drinks

    /// Поиск записи об энергетиках за указанный день
    func findEnergyDrinkLog(for date: Date = .now) -> EnergyDrinkDayLog? {
        let targetDay = Calendar.current.startOfDay(for: date)
        var descriptor = FetchDescriptor<EnergyDrinkDayLog>(
            predicate: #Predicate<EnergyDrinkDayLog> { log in
                log.date == targetDay
            }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    /// Обновление или удаление статуса энергетиков за день
    func updateEnergyDrinkLog(
        for date: Date = .now,
        status: EnergyDrinkStatus,
        servingsCount: Int = 0,
        note: String? = nil
    ) {
        let targetDay = Calendar.current.startOfDay(for: date)

        if let existing = findEnergyDrinkLog(for: targetDay) {
            if status == .untracked {
                // Если пользователь сбросил отметку — удаляем запись из базы
                modelContext.delete(existing)
            } else {
                existing.status = status
                existing.servingsCount = (status == .consumed) ? max(1, servingsCount) : 0
                if let note {
                    existing.note = note
                }
            }
        } else if status != .untracked {
            let newLog = EnergyDrinkDayLog(
                date: targetDay,
                status: status,
                servingsCount: (status == .consumed) ? max(1, servingsCount) : 0,
                note: note
            )
            modelContext.insert(newLog)
        }

        try? modelContext.save()
    }
}
