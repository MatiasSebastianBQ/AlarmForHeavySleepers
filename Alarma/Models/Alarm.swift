//
//  Alarm.swift
//  Alarma
//
//  Created by Matias Bq on 27/10/2026.
//

import Foundation

enum PuzzleType: String, CaseIterable, Codable, Identifiable {
    case memory = "Memoria"
    case math = "Matemáticas"
    case writing = "Escritura"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .memory: return "brain.head.profile"
        case .math: return "function"
        case .writing: return "text.cursor"
        }
    }

    var description: String {
        switch self {
        case .memory: return "Repite una secuencia de símbolos."
        case .math: return "Resuelve una operación matemática."
        case .writing: return "Escribe correctamente una frase."
        }
    }
}

struct Alarm: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var hour: Int
    var minute: Int
    var isEnabled: Bool = true
    var puzzle: PuzzleType = .memory

    var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }
}

