//
//  DesignPreview.swift
//  NATO-1
//
//  Standalone visual prototype of the restyled Learn tab.
//  NOT wired to AppState, NATOData, or any real app logic.
//  Preview state: Batch 1 active, Batches 2–7 locked.

import SwiftUI

// MARK: - Preview root

struct DesignPreview: View {
    @Environment(\.colorSchemeContrast) private var systemContrast
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    // Preview overrides — nil means "use system value"
    var overrideHighContrast: Bool? = nil
    var overrideReduceMotion: Bool? = nil

    private var isHighContrast: Bool { overrideHighContrast ?? (systemContrast == .increased) }
    private var isReduceMotion: Bool { overrideReduceMotion ?? systemReduceMotion }
    private var dimColor: Color { isHighContrast ? DesignSystem.Colors.dimHighContrast : DesignSystem.Colors.dim }
    private var tappableColor: Color { isHighContrast ? DesignSystem.Colors.tappableHighContrast : DesignSystem.Colors.tappable }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────
                learnHeader
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                // ── Batch rows ───────────────────────────────────────────
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(PreviewData.batches) { batch in
                            TerminalBatchRow(
                                batch: batch,
                                dimColor: dimColor,
                                tappableColor: tappableColor,
                                reduceMotion: isReduceMotion
                            )
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            TerminalTabBar(dimColor: dimColor, tappableColor: tappableColor)
        }
    }

    // MARK: Header

    private var learnHeader: some View {
        VStack(spacing: 6) {
            DashedRule(color: dimColor)
            Text("-LEARNING--PROTOCOL-")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
            DashedRule(color: dimColor)
        }
    }
}

// MARK: - Batch row

private struct TerminalBatchRow: View {
    let batch: PreviewBatch
    let dimColor: Color
    let tappableColor: Color
    let reduceMotion: Bool

    private var isActive: Bool { batch.state == .active }
    private var nameColor: Color   { isActive ? tappableColor : dimColor }
    private var letterColor: Color { isActive ? tappableColor : dimColor }

    var body: some View {
        Button(action: {}) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                // Batch name — pinned left
                Text("BATCH \(batch.number)")
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: nameColor)
                    .textCase(.uppercase)
                    .fixedSize()

                // Letters
                Text(batch.lettersDisplay)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: letterColor)
                    .textCase(.uppercase)
                    .fixedSize()

                // Dotted leader — fills gap between letters and trailing glyph
                DottedLeader(color: dimColor)

                // Trailing glyph — pinned right
                trailingGlyph
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .frame(minHeight: 44)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var trailingGlyph: some View {
        switch batch.state {
        case .active:
            BlinkingChevron(tappableColor: tappableColor, reduceMotion: reduceMotion)
        case .locked:
            Text("!")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: tappableColor)
                .fixedSize()
                .accessibilityLabel("locked — tap to unlock")
        }
    }

    private var accessibilityLabel: String {
        switch batch.state {
        case .active:
            return "Batch \(batch.number), \(batch.lettersDisplay), start batch"
        case .locked:
            return "Batch \(batch.number), locked — tap to unlock"
        }
    }
}

// MARK: - Blinking chevron

private struct BlinkingChevron: View {
    let tappableColor: Color
    let reduceMotion: Bool

    var body: some View {
        if reduceMotion {
            glyphView(visible: true)
        } else {
            TimelineView(.periodic(from: .now, by: DesignSystem.Blink.phaseSeconds)) { ctx in
                let tick = Int(ctx.date.timeIntervalSinceReferenceDate / DesignSystem.Blink.phaseSeconds)
                glyphView(visible: tick % 2 == 0)
            }
        }
    }

    private func glyphView(visible: Bool) -> some View {
        Text(">")
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: tappableColor)
            .fixedSize()
            .opacity(visible ? 1 : 0)
            .accessibilityLabel("start batch")
    }
}

// MARK: - Dotted leader

/// Fills available horizontal space with real period characters from the font.
/// Pattern: ".  .  .  " (period + double space), clipped at the container edge.
/// Dots are always dim — spec: "Leader dots always dim regardless of row state."
private struct DottedLeader: View {
    let color: Color

    var body: some View {
        Text(String(repeating: DesignSystem.Typography.leaderDotUnit, count: 60))
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
    }
}

// MARK: - Dashed rule

/// Full-width rule using real hyphen characters from the font, clipped at the container edge.
private struct DashedRule: View {
    let color: Color

    var body: some View {
        Text(String(repeating: DesignSystem.Typography.ruleDashUnit, count: 120))
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
            .lineLimit(1)
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
    }
}

// MARK: - Tab bar

private struct TerminalTabBar: View {
    let dimColor: Color
    let tappableColor: Color

    var body: some View {
        VStack(spacing: 0) {
            DashedRule(color: dimColor)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            HStack {
                Spacer()

                // Active tab: bracketed label with dim-fill chip, dark text
                Text("[LEARN]")
                    .terminalStyle(
                        size: DesignSystem.Typography.minDimSize,
                        color: DesignSystem.Colors.background
                    )
                    .textCase(.uppercase)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(dimColor)

                Spacer()

                // Inactive tabs: bright bracketed text
                Text("[DRILL]")
                    .terminalStyle(
                        size: DesignSystem.Typography.minDimSize,
                        color: tappableColor
                    )
                    .textCase(.uppercase)

                Spacer()

                Text("[CODEX]")
                    .terminalStyle(
                        size: DesignSystem.Typography.minDimSize,
                        color: tappableColor
                    )
                    .textCase(.uppercase)

                Spacer()
            }
            .padding(.bottom, 8)
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Preview data (static, not wired to NATOData)

private enum BatchState { case active, locked }

private struct PreviewBatch: Identifiable {
    let id: Int
    var number: Int { id }
    let lettersDisplay: String
    let state: BatchState
}

private enum PreviewData {
    static let batches: [PreviewBatch] = [
        PreviewBatch(id: 1, lettersDisplay: "A  B  C  D", state: .active),
        PreviewBatch(id: 2, lettersDisplay: "E  F  G  H", state: .locked),
        PreviewBatch(id: 3, lettersDisplay: "I  J  K  L", state: .locked),
        PreviewBatch(id: 4, lettersDisplay: "M  N  O  P", state: .locked),
        PreviewBatch(id: 5, lettersDisplay: "Q  R  S  T", state: .locked),
        PreviewBatch(id: 6, lettersDisplay: "U  V  W",    state: .locked),
        PreviewBatch(id: 7, lettersDisplay: "X  Y  Z",    state: .locked),
    ]
}

// MARK: - Preview

#Preview("Learn Tab — DOS Terminal") {
    DesignPreview()
}

#Preview("Learn Tab — Increase Contrast") {
    DesignPreview(overrideHighContrast: true)
}

#Preview("Learn Tab — Reduce Motion") {
    DesignPreview(overrideReduceMotion: true)
}
