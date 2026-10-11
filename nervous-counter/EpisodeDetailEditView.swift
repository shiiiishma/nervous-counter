import SwiftUI
import SwiftData

/// Экран подробного редактирования записи тревоги или добавления записи задним числом.
struct EpisodeDetailEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    /// Редактируемый эпизод (nil при создании новой записи задним числом)
    let episodeToEdit: AnxietyEpisode?

    @State private var timestamp: Date = .now
    @State private var selectedIntensity: Int?
    @State private var note: String = ""
    @State private var showDeleteConfirmation: Bool = false

    private var repository: DataRepository {
        DataRepository(modelContext: modelContext)
    }

    private var isCreatingNew: Bool {
        episodeToEdit == nil
    }

    private let intensityOptions: [(value: Int, title: String)] = [
        (1, "1 — Очень слабая"),
        (2, "2 — Слабая"),
        (3, "3 — Умеренная"),
        (4, "4 — Сильная"),
        (5, "5 — Очень сильная")
    ]

    init(episode: AnxietyEpisode? = nil) {
        self.episodeToEdit = episode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Время фиксации") {
                    DatePicker(
                        "Дата и время",
                        selection: $timestamp,
                        in: ...Date.now,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Интенсивность") {
                    Picker("Уровень", selection: $selectedIntensity) {
                        Text("Не указана").tag(nil as Int?)
                        ForEach(intensityOptions, id: \.value) { option in
                            Text(option.title).tag(option.value as Int?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Заметка или триггер") {
                    TextField("Что вы чувствовали или что произошло?", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                if !isCreatingNew {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("Удалить запись", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isCreatingNew ? "Новая запись" : "Редактирование")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        save()
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Удалить эту запись?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) {
                    dismiss()
                    if let episodeToEdit {
                        repository.deleteEpisode(episodeToEdit)
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие нельзя будет отменить.")
            }
            .onAppear {
                if let episodeToEdit {
                    timestamp = episodeToEdit.timestamp
                    selectedIntensity = episodeToEdit.intensity
                    note = episodeToEdit.note ?? ""
                }
            }
        }
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = trimmedNote.isEmpty ? nil : trimmedNote

        if let episodeToEdit {
            episodeToEdit.timestamp = timestamp
            episodeToEdit.intensity = selectedIntensity
            episodeToEdit.note = finalNote
            try? modelContext.save()
        } else {
            repository.recordEpisode(
                intensity: selectedIntensity,
                note: finalNote,
                timestamp: timestamp
            )
        }
    }
}
