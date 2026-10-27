//
//  AlarmManager.swift
//  Alarma
//
//  Created by Matias Bq on 27/10/2026.
//

import Foundation
import Combine
import UserNotifications

final class AlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = [] {
        didSet {
            saveAlarms()
        }
    }

    private let storageKey = "wakemind.alarms"

    init() {
        loadAlarms()
    }

    private func loadAlarms() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let saved = try? JSONDecoder().decode([Alarm].self, from: data)
        else {
            return
        }

        alarms = saved
    }

    private func saveAlarms() {
        guard let data = try? JSONEncoder().encode(alarms) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error solicitando permisos: \(error)")
            return false
        }
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        updateNotification(for: alarm)
    }

    func update(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: {
            $0.id == alarm.id
        }) else {
            return
        }

        alarms[index] = alarm
        updateNotification(for: alarm)
    }

    func delete(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [alarm.id.uuidString]
            )
    }

    func toggle(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: {
            $0.id == alarm.id
        }) else {
            return
        }

        alarms[index].isEnabled.toggle()
        updateNotification(for: alarms[index])
    }

    private func updateNotification(for alarm: Alarm) {
        let center = UNUserNotificationCenter.current()
        let identifier = alarm.id.uuidString

        center.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )

        guard alarm.isEnabled else { return }

        var components = DateComponents()
        components.hour = alarm.hour
        components.minute = alarm.minute

        let content = UNMutableNotificationContent()
        content.title = alarm.name
        content.body = "Es hora de levantarse. Abre WakeMind."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Error programando alarma: \(error)")
            }
        }
    }
}

