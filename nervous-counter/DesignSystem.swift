import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Единая дизайн-система приложения: спокойные цвета, формы и стили.
enum DesignSystem {
    enum Colors {
        /// Спокойный акцентный оттенок для тревоги (шалфейно-лавандовый)
        static let anxietyAccent = Color(red: 0.42, green: 0.52, blue: 0.65)
        static let anxietySoft = Color(red: 0.90, green: 0.93, blue: 0.96)
        
        /// Тёплый оттенок для энергетиков (песочно-янтарный)
        static let energyAccent = Color(red: 0.85, green: 0.55, blue: 0.28)
        static let energySoft = Color(red: 0.98, green: 0.94, blue: 0.90)

        /// Спокойный зелёный для подтверждённого отказа от энергетиков
        static let cleanAccent = Color(red: 0.30, green: 0.62, blue: 0.45)
        static let cleanSoft = Color(red: 0.91, green: 0.96, blue: 0.92)

        #if canImport(UIKit)
        /// Фоновый нейтральный цвет для карточек
        static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
        static let screenBackground = Color(uiColor: .systemGroupedBackground)
        #else
        static let cardBackground = Color.secondary.opacity(0.1)
        static let screenBackground = Color.clear
        #endif
    }

    enum CornerRadius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let pill: CGFloat = 999
    }
}
