import SwiftUI
import SwiftData

/// Модальный экран для опционального уточнения интенсивности и заметки зафиксированного эпизода.
struct QuickLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var episode: AnxietyEpisode
    @State private var selectedIntensity: Int?
    @State private var noteText: String = ""

    private var repository: DataRepository {
        DataRepository(modelContext: modelContext)
    }

    private let intensityOptions: [(value: Int, title: String)] = [
        (1, "Слабая"),
        (2, "Умеренная"),
        (3, "Заметная"),
        (4, "Сильная"),
        (5, "Очень сильная")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Подтверждение моментальной фиксации
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(DesignSystem.Colors.anxietyAccent)

                    Text("Эпизод зафиксирован")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Время: \(episode.timestamp.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)

                // Выбор интенсивности (опционально)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Интенсивность (необязательно)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(intensityOptions, id: \.value) { option in
                            Button {
                                if selectedIntensity == option.value {
                                    selectedIntensity = nil
                                } else {
                                    selectedIntensity = option.value
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(option.value)")
                                        .font(.headline)
                                    Text(option.title)
                                        .font(.system(size: 9))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    selectedIntensity == option.value
                                        ? DesignSystem.Colors.anxietyAccent
                                        : Color.secondary.opacity(0.1)
                                )
                                .foregroundStyle(
                                    selectedIntensity == option.value
                                        ? Color.white
                                        : Color.primary
                                )
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Поле заметки (опционально)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Заметка или возможный триггер")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Что происходило вокруг? (необязательно)", text: $noteText, axis: .vertical)
                        .lineLimit(3...5)
                        .padding(12)
                        .background(DesignSystem.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                Spacer()

                // Кнопка сохранения и отмены
                VStack(spacing: 12) {
                    Button {
                        saveChanges()
                        dismiss()
                    } label: {
                        Text("Готово")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DesignSystem.Colors.anxietyAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    }

                    Button("Удалить эту запись (нажато случайно)", role: .destructive) {
                        dismiss()
                        repository.deleteEpisode(episode)
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(DesignSystem.Colors.screenBackground)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Закрыть") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedIntensity = episode.intensity
                noteText = episode.note ?? ""
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func saveChanges() {
        episode.intensity = selectedIntensity
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        episode.note = trimmed.isEmpty ? nil : trimmed
        try? modelContext.save()
    }
}
