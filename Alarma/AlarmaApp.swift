//
//  AlarmaApp.swift
//  Alarma
//
//  Created by Matias Bq on 27/10/2026.
//


import SwiftUI

@main
struct WakeMindApp: App {
    @StateObject private var alarmManager = AlarmManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
                .preferredColorScheme(.dark)
        }
    }
}

