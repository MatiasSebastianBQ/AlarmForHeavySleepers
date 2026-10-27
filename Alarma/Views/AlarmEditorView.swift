//
//  AlarmEditorView.swift
//  Alarma
//
//  Created by Matias Bq on 27/10/2026.
//

import SwiftUI

struct AlarmEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Alarm) -> Void
    private let originalAlarm: Alarm?

    @State private var name: String
    @State private var time: Date
    @State private var puzzle: PuzzleType

    init(
        alarm: Alarm? = nil,
        onSave: @escaping (Alarm) -> Void
    ) {
        self.originalAlarm = alarm
        self.onSave = onSave

        _name = State(initialValue: alarm?.name ?? "")

        var components = DateComponents()
        components.hour = alarm?.hour ?? 8
        components.minute = alarm?.minute ?? 0

        let initialTime = Calendar.current.date(
            from: components
        ) ?? Date()

        _time = State(initialValue: initialTime)
        _puzzle = State(initialValue: alarm?.puzzle ?? .memory)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles") {
                    TextField("Nombre de la alarma", text: $name)

                    DatePicker(
                        "Hora",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Reto para despertar") {
                    ForEach(PuzzleType.allCases) { type in
                        Button {
                            puzzle = type
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: type.icon)
                                    .font(.title2)
                                    .foregroundStyle(.purple)
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(type.rawValue)
                                        .foregroundStyle(.primary)

                                    Text(type.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if puzzle == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.purple)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    Text(
                        "La alarma se repetirá todos los días. "
                        + "Puedes cambiarlo en una versión posterior."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(
                originalAlarm == nil ? "Nueva alarma" : "Editar alarma"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveAlarm()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveAlarm() {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: time
        )

        let alarm = Alarm(
            id: originalAlarm?.id ?? UUID(),
            name: name.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            hour: components.hour ?? 8,
            minute: components.minute ?? 0,
            isEnabled: originalAlarm?.isEnabled ?? true,
            puzzle: puzzle
        )

        onSave(alarm)
        dismiss()
    }
}

