import Foundation
import SwiftData

/// Статус употребления энергетических напитков за конкретный день.
enum EnergyDrinkStatus: String, Codable, CaseIterable {
    /// Данные за день отсутствуют (пользователь не делал отметку)
    case untracked = "untracked"
    /// Подтверждённое отсутствие употребления (пользователь явно отметил, что не пил)
    case notConsumed = "notConsumed"
    /// Подтверждённое употребление
    case consumed = "consumed"
}

/// Модель ежедневного учёта энергетиков.
/// Дата нормализуется до начала суток (startOfDay), чтобы на один день приходилась одна запись.
@Model
final class EnergyDrinkDayLog {
    var id: UUID
    var date: Date
    var statusRawValue: String
    var servingsCount: Int
    var note: String?

    /// Типобезопасная обёртка над строковым значением статуса
    var status: EnergyDrinkStatus {
        get { EnergyDrinkStatus(rawValue: statusRawValue) ?? .untracked }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        date: Date = .now,
        status: EnergyDrinkStatus = .untracked,
        servingsCount: Int = 0,
        note: String? = nil
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.statusRawValue = status.rawValue
        self.servingsCount = servingsCount
        self.note = note
    }
}
