//
//  MasteryCelebrationView.swift
//  NATO-1
//

import SwiftUI

struct MasteryCelebrationView: View {
    @ObservedObject var appState = AppState.shared
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Trophy
            Text("🏆")
                .font(.system(size: 80))
                .padding(.bottom, 24)

            // Congratulations
            Text("Mastery Achieved")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("You've done it.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            // All 26 letters
            VStack(spacing: 16) {
                Text("All 26 letters mastered")
                    .font(.headline)
                    .padding(.top, 32)

                // Letter grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 9), spacing: 8) {
                    ForEach(NATOData.allLetters) { letter in
                        Text(String(letter.character))
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .frame(width: 32, height: 32)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                .padding(.horizontal)
            }

            // Maintenance mode note
            VStack(spacing: 8) {
                Text("Welcome to maintenance mode")
                    .font(.headline)
                    .padding(.top, 32)

                Text("Your weekly drills will keep the alphabet fresh. If you miss one, no worries — the letters will be waiting when you return.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Continue button
            Button {
                appState.markMasteryAchieved()
                onDismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    MasteryCelebrationView(onDismiss: {})
}
