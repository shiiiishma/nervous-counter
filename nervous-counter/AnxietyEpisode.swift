import Foundation
import SwiftData

/// Модель отдельного эпизода тревоги.
/// Фиксирует момент возникновения, необязательную интенсивность по шкале 1–5 и комментарий.
@Model
final class AnxietyEpisode {
    var id: UUID
    var timestamp: Date
    var intensity: Int?
    var note: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        intensity: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.note = note
    }
}
