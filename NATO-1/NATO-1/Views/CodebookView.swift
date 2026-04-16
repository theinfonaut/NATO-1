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
                VStack(spacing: 20) {
                    // Progress summary
                    progressSummary

                    // Letter grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(NATOData.allLetters) { letter in
                            LetterCard(
                                letter: letter,
                                tier: appState.tier(for: String(letter.id)),
                                isUnlocked: appState.letterProgress[String(letter.id)] != nil
                            )
                        }
                    }

                    // Tier legend
                    tierLegend
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Codebook")
        }
    }

    // MARK: - Progress Summary

    private var progressSummary: some View {
        HStack(spacing: 16) {
            ForEach(SRSTier.allCases, id: \.rawValue) { tier in
                VStack(spacing: 4) {
                    Text("\(tierCount(for: tier))")
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(tierColor(for: tier))
                    Text(tier.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
    }

    private func tierCount(for tier: SRSTier) -> Int {
        appState.letterProgress.values.filter { $0.tier == tier }.count
    }

    private func tierColor(for tier: SRSTier) -> Color {
        switch tier {
        case .learning: return .orange
        case .familiar: return .yellow
        case .confident: return .blue
        case .mastered: return .green
        }
    }

    // MARK: - Tier Legend

    private var tierLegend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIER PROGRESSION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                legendRow(tier: .learning, description: "Just learned — drill again in 4 hours")
                legendRow(tier: .familiar, description: "Getting it — drill again in 1 day")
                legendRow(tier: .confident, description: "Solid recall — drill again in 3 days")
                legendRow(tier: .mastered, description: "Locked in — drill again in 7 days")
            }
        }
        .padding()
        .background(Color.primary.opacity(0.03))
        .cornerRadius(12)
    }

    private func legendRow(tier: SRSTier, description: String) -> some View {
        HStack(spacing: 12) {
            TierBadge(tier: tier)
                .frame(width: 80, alignment: .leading)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
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
