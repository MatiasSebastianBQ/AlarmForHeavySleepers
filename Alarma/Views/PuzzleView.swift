//
//  PuzzleView.swift
//  Alarma
//
//  Created by Matias Bq on 27/10/2026.
//

import SwiftUI

struct PuzzleView: View {
    let alarm: Alarm

    @Environment(\.dismiss) private var dismiss

    @State private var completed = false
    @State private var feedback = ""

    // Memoria
    private let sequence = ["★", "●", "▲"]
    @State private var memoryInput: [String] = []

    // Matemáticas
    @State private var firstNumber = Int.random(in: 2...9)
    @State private var secondNumber = Int.random(in: 2...9)
    @State private var answer = ""

    // Escritura
    private let phrases = [
        "Hoy será un buen día",
        "Estoy listo para empezar",
        "Cada día cuenta",
        "Levántate y ve a por ello"
    ]

    @State private var phraseIndex = Int.random(in: 0...3)
    @State private var typedText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.055, green: 0.06, blue: 0.10)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: completed
                              ? "checkmark.seal.fill"
                              : "brain.head.profile")
                            .font(.system(size: 54))
                            .foregroundStyle(completed ? .green : .purple)
                            .padding(.top, 25)

                        Text(completed ? "¡Reto superado!" : alarm.name)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text(
                            completed
                            ? "Has completado el desafío."
                            : "Resuelve el reto para terminar."
                        )
                        .foregroundStyle(.secondary)

                        if completed {
                            Button {
                                dismiss()
                            } label: {
                                Text("Terminar")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.purple)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        } else {
                            puzzleContent
                        }

                        if !feedback.isEmpty {
                            Text(feedback)
                                .font(.subheadline.bold())
                                .foregroundStyle(.orange)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(alarm.puzzle.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var puzzleContent: some View {
        switch alarm.puzzle {
        case .memory:
            memoryPuzzle

        case .math:
            mathPuzzle

        case .writing:
            writingPuzzle
        }
    }

    private var memoryPuzzle: some View {
        VStack(spacing: 20) {
            Text("Memoriza la secuencia")
                .font(.headline)

            HStack(spacing: 16) {
                ForEach(Array(sequence.enumerated()), id: \.offset) {
                    _, symbol in

                    Text(symbol)
                        .font(.system(size: 35))
                        .frame(width: 65, height: 65)
                        .background(.purple.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Text("Pulsa los símbolos en el mismo orden")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                ForEach(["▲", "★", "●"], id: \.self) { symbol in
                    Button {
                        tapMemorySymbol(symbol)
                    } label: {
                        Text(symbol)
                            .font(.system(size: 30))
                            .frame(maxWidth: .infinity)
                            .frame(height: 65)
                            .background(.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            ForEach(sequence, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 35))
                    .frame(width: 65, height: 65)
                    .background(.purple.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }


            Text("Progreso: \(memoryInput.count) / \(sequence.count)")
                .foregroundStyle(.secondary)

            Button("Reiniciar secuencia") {
                memoryInput = []
                feedback = ""
            }
            .font(.subheadline)
        }
    }

    private func tapMemorySymbol(_ symbol: String) {
        let position = memoryInput.count

        guard position < sequence.count else { return }

        if sequence[position] == symbol {
            memoryInput.append(symbol)
            feedback = ""

            if memoryInput.count == sequence.count {
                completed = true
            }
        } else {
            memoryInput = []
            feedback = "Secuencia incorrecta. ¡Inténtalo otra vez!"
        }
    }

    private var mathPuzzle: some View {
        VStack(spacing: 22) {
            Text("Resuelve la operación")
                .font(.headline)

            Text("\(firstNumber) × \(secondNumber) = ?")
                .font(.system(size: 38, weight: .bold, design: .rounded))

            TextField("Tu respuesta", text: $answer)
                .keyboardType(.numberPad)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                if Int(answer) == firstNumber * secondNumber {
                    completed = true
                    feedback = ""
                } else {
                    feedback = "No es correcto. Prueba otra vez."
                    answer = ""
                }
            } label: {
                primaryButton("Comprobar")
            }
        }
    }

    private var writingPuzzle: some View {
        VStack(spacing: 22) {
            Text("Copia la frase")
                .font(.headline)

            Text(phrases[phraseIndex])
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.purple.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            TextField("Escribe la frase aquí", text: $typedText, axis: .vertical)
                .lineLimit(2...4)
                .padding()
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                let entered = typedText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .folding(
                        options: [.diacriticInsensitive, .caseInsensitive],
                        locale: .current
                    )

                let expected = phrases[phraseIndex]
                    .folding(
                        options: [.diacriticInsensitive, .caseInsensitive],
                        locale: .current
                    )

                if entered == expected {
                    completed = true
                    feedback = ""
                } else {
                    feedback = "El texto no coincide. Revísalo."
                }
            } label: {
                primaryButton("Comprobar texto")
            }
        }
    }

    private func primaryButton(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.purple)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

