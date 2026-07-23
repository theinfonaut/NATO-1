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

    private static let headerTitle = "LEARNING PROTOCOL"

    private var learnHeader: some View {
        GeometryReader { geo in
            let columns = DesignSystem.Metrics.columns(fittingWidth: geo.size.width)
            let fullRule = String(repeating: "-", count: columns)

            // Title line: dashes + space + LEARNING PROTOCOL + space + dashes
            let titleCols = Self.headerTitle.count + 2
            let dashBudget = max(0, columns - titleCols)
            let leftDashes = dashBudget / 2
            let rightDashes = dashBudget - leftDashes
            let leftPart = String(repeating: "-", count: leftDashes) + " "
            let rightPart = " " + String(repeating: "-", count: rightDashes)

            VStack(alignment: .leading, spacing: 0) {
                // Top rule
                Text(fullRule)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                    .fixedSize()

                // Title line
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(leftPart)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .fixedSize()
                    Text(Self.headerTitle)
                        .font(DesignSystem.Typography.title)
                        .tracking(DesignSystem.Typography.tracking(for: DesignSystem.Typography.minDimSize))
                        .foregroundStyle(dimColor)
                        .fixedSize()
                    Text(rightPart)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .fixedSize()
                }

                // Bottom rule
                Text(fullRule)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 66) // 3 lines × 22pt
        .clipped()
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

    // Fixed column strings for each row part (including spacing gaps)
    private var nameString: String { "BATCH \(batch.number) " }
    private var lettersString: String { " " + batch.lettersDisplay + " " }
    private var glyphString: String { batch.state == .active ? ">" : "!" }

    private var fixedColumns: Int {
        nameString.count + lettersString.count + glyphString.count
    }

    var body: some View {
        Button(action: {}) {
            GeometryReader { geo in
                let totalColumns = DesignSystem.Metrics.columns(fittingWidth: geo.size.width)
                let leaderBudget = max(0, totalColumns - fixedColumns)
                // Leader pattern: ". . . . ." — ends on a period (2n-1 columns for n dots).
                // n dots fit when budget >= 2n-1, i.e. n = (budget + 1) / 2
                let dotCount = leaderBudget > 0 ? (leaderBudget + 1) / 2 : 0
                let dotsColumns = dotCount > 0 ? dotCount * 2 - 1 : 0
                let trailingPad = leaderBudget - dotsColumns // 0 or 1
                let leaderText = dotCount > 0
                    ? Array(repeating: ".", count: dotCount).joined(separator: " ")
                        + String(repeating: " ", count: trailingPad)
                    : String(repeating: " ", count: leaderBudget)

                let fullLine = nameString + leaderText + lettersString

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    // Batch name + leader + letters as one Text
                    Text(fullLine)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .textCase(.uppercase)
                        .fixedSize()
                        .overlay(alignment: .leading) {
                            // Color overlay for batch name
                            Text(nameString)
                                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: nameColor)
                                .textCase(.uppercase)
                                .fixedSize()
                        }
                        .overlay(alignment: .trailing) {
                            // Color overlay for letters
                            Text(lettersString)
                                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: letterColor)
                                .textCase(.uppercase)
                                .fixedSize()
                        }

                    // Trailing glyph
                    trailingGlyph
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 22)
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

// MARK: - Dashed rule

/// Full-width rule built from contiguous hyphen characters.
/// Column count computed from available width — no truncation.
private struct DashedRule: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let columns = DesignSystem.Metrics.columns(fittingWidth: geo.size.width)
            Text(String(repeating: "-", count: columns))
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 22)
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
                // Active tab: bracketed label with dim-fill chip, dark text
                // Chip background starts at the left margin (no extra padding before bracket)
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
            }
            .padding(.horizontal, 20)
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
        PreviewBatch(id: 1, lettersDisplay: "ABCD", state: .active),
        PreviewBatch(id: 2, lettersDisplay: "EFGH", state: .locked),
        PreviewBatch(id: 3, lettersDisplay: "IJKL", state: .locked),
        PreviewBatch(id: 4, lettersDisplay: "MNOP", state: .locked),
        PreviewBatch(id: 5, lettersDisplay: "QRST", state: .locked),
        PreviewBatch(id: 6, lettersDisplay: "UVW",  state: .locked),
        PreviewBatch(id: 7, lettersDisplay: "XYZ",  state: .locked),
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
