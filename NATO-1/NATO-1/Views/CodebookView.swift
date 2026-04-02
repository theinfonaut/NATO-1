//
//  CodebookView.swift
//  NATO-1
//

import SwiftUI

struct CodebookView: View {
    @ObservedObject var appState = AppState.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(NATOData.allLetters) { letter in
                        LetterCard(
                            letter: letter,
                            tier: appState.tier(for: String(letter.id)),
                            isUnlocked: appState.letterProgress[String(letter.id)] != nil
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Codebook")
        }
    }
}

// MARK: - Letter Card

struct LetterCard: View {
    let letter: Letter
    let tier: SRSTier?
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Letter
            Text(String(letter.character))
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary.opacity(0.5))

            // NATO word
            Text(letter.natoWord)
                .font(.caption)
                .foregroundStyle(isUnlocked ? Color.secondary : Color.secondary.opacity(0.3))

            // Tier indicator
            if let tier = tier {
                TierBadge(tier: tier)
            } else {
                // Placeholder for locked letters
                Text("—")
                    .font(.caption2)
                    .foregroundStyle(Color.secondary.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(8)
    }

    private var backgroundColor: Color {
        guard isUnlocked, let tier = tier else {
            return Color.primary.opacity(0.03)
        }
        switch tier {
        case .learning:
            return Color.orange.opacity(0.1)
        case .familiar:
            return Color.yellow.opacity(0.1)
        case .confident:
            return Color.blue.opacity(0.1)
        case .mastered:
            return Color.green.opacity(0.1)
        }
    }
}

// MARK: - Tier Badge

struct TierBadge: View {
    let tier: SRSTier

    var body: some View {
        Text(tier.name.uppercased())
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .cornerRadius(4)
    }

    private var foregroundColor: Color {
        switch tier {
        case .learning:
            return .orange
        case .familiar:
            return .yellow
        case .confident:
            return .blue
        case .mastered:
            return .green
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.2)
    }
}

#Preview {
    CodebookView()
}
