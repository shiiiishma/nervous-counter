import SwiftUI
import SwiftData

/// Экран настроек, параметров приватности и управления данными.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var isShowingClearAlert: Bool = false
    @State private var isShowingClearedNotification: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // Раздел: Приватность
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundStyle(DesignSystem.Colors.anxietyAccent)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% приватность")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Все ваши записи хранятся исключительно на этом устройстве в локальной базе SwiftData. Никаких серверов, телеметрии или рекламы.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Конфиденциальность")
                }

                // Раздел: Управление данными
                Section {
                    Button(role: .destructive) {
                        isShowingClearAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Очистить все данные", systemImage: "trash")
                            Spacer()
                        }
                    }
                } header: {
                    Text("Управление хранилищем")
                } footer: {
                    Text("Удаление всех эпизодов тревоги и истории употребления энергетиков.")
                }

                // Раздел: О приложении
                Section {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0 (iOS 17+)")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("О проекте")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Приложение создано как бережный инструмент самонаблюдения. Оно не ставит диагнозов и не оценивает привычки, а помогает увидеть честные факты и закономерности на основе ежедневных отметок.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("О приложении")
                }
            }
            .navigationTitle("Настройки")
            .confirmationDialog(
                "Очистить все данные?",
                isPresented: $isShowingClearAlert,
                titleVisibility: .visible
            ) {
                Button("Да, удалить всё", role: .destructive) {
                    clearAllData()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Все сохранённые эпизоды тревоги и отметки энергетиков будут удалены. Это действие необратимо.")
            }
            .alert("Данные очищены", isPresented: $isShowingClearedNotification) {
                Button("ОК", role: .cancel) {}
            } message: {
                Text("Все записи успешно удалены.")
            }
        }
    }

    private func clearAllData() {
        do {
            try modelContext.delete(model: AnxietyEpisode.self)
            try modelContext.delete(model: EnergyDrinkDayLog.self)
            try modelContext.save()
            isShowingClearedNotification = true
        } catch {
            print("Ошибка при очистке данных: \(error)")
        }
    }
}
