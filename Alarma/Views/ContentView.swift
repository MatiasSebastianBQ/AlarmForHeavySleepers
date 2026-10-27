
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager

    @State private var showingEditor = false
    @State private var editingAlarm: Alarm?
    @State private var puzzleAlarm: Alarm?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.055, green: 0.06, blue: 0.10)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WAKEMIND")
                                .font(.caption.bold())
                                .tracking(3)
                                .foregroundStyle(.purple)

                            Text("Hora de despertar.")
                                .font(.system(size: 32, weight: .bold))

                            Text("Tus mañanas empiezan aquí.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            showingEditor = true
                        } label: {
                            Label("Crear alarma", systemImage: "plus")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.purple)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }

                        HStack {
                            Text("Mis alarmas")
                                .font(.title2.bold())

                            Spacer()

                            Text("\(alarmManager.alarms.count)")
                                .foregroundStyle(.secondary)
                        }

                        if alarmManager.alarms.isEmpty {
                            ContentUnavailableView(
                                "Sin alarmas",
                                systemImage: "alarm",
                                description: Text(
                                    "Crea tu primera alarma para empezar."
                                )
                            )
                            .padding(.top, 30)
                        } else {
                            ForEach(alarmManager.alarms.sorted {
                                if $0.hour != $1.hour {
                                    return $0.hour < $1.hour
                                }
                                return $0.minute < $1.minute
                            }) { alarm in
                                alarmCard(alarm)
                            }
                        }
                    }
                    .padding(22)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingEditor) {
                AlarmEditorView { alarm in
                    alarmManager.add(alarm)
                }
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditorView(alarm: alarm) { updated in
                    alarmManager.update(updated)
                }
            }
            .sheet(item: $puzzleAlarm) { alarm in
                PuzzleView(alarm: alarm)
            }
            .task {
                _ = await alarmManager.requestPermission()
            }
        }
    }

    private func alarmCard(_ alarm: Alarm) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(alarm.name)
                        .font(.headline)

                    Label(
                        "\(alarm.puzzle.rawValue)",
                        systemImage: alarm.puzzle.icon
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle(
                    "Activada",
                    isOn: Binding(
                        get: { alarmManager.alarms.first {
                            $0.id == alarm.id
                        }?.isEnabled ?? false },
                        set: { _ in alarmManager.toggle(alarm) }
                    )
                )
                .labelsHidden()
                .tint(.purple)
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(alarm.formattedTime)
                    .font(.system(size: 42, weight: .light, design: .rounded))
                    .monospacedDigit()

                Spacer()

                Button("Probar reto") {
                    puzzleAlarm = alarm
                }
                .font(.subheadline.bold())
                .foregroundStyle(.purple)
            }

            HStack {
                Button {
                    editingAlarm = alarm
                } label: {
                    Label("Editar", systemImage: "pencil")
                }

                Spacer()

                Button(role: .destructive) {
                    alarmManager.delete(alarm)
                } label: {
                    Label("Eliminar", systemImage: "trash")
                }
            }
            .font(.caption)
        }
        .padding(18)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.white.opacity(0.08))
        }
    }
}
