//
//  DesignPreview.swift
//  NATO-1
//
//  Standalone visual prototype of the restyled Learn tab.
//  NOT wired to AppState, NATOData, or any real app logic.
//  Preview state: Batch 1 active, Batches 2–7 locked.
//
//  Layout: A single top-level GeometryReader computes one column count
//  and one blockWidth (cols × columnWidth). That block is centered on
//  screen. All children receive `columns: Int` — no per-component
//  GeometryReaders, no fractional accumulation.

import SwiftUI

// MARK: - Preview root

struct DesignPreview: View {
    @Environment(\.colorSchemeContrast) private var systemContrast
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Preview overrides — nil means "use system value"
    var overrideHighContrast: Bool? = nil
    var overrideReduceMotion: Bool? = nil

    private var isHighContrast: Bool { overrideHighContrast ?? (systemContrast == .increased) }
    private var isReduceMotion: Bool { overrideReduceMotion ?? systemReduceMotion }
    private var dimColor: Color { isHighContrast ? DesignSystem.Colors.dimHighContrast : DesignSystem.Colors.dim }
    private var tappableColor: Color { isHighContrast ? DesignSystem.Colors.tappableHighContrast : DesignSystem.Colors.tappable }

    var body: some View {
        // Reading dynamicTypeSize registers the SwiftUI dependency so the
        // body is re-evaluated whenever the user's text size changes.
        let _ = dynamicTypeSize

        GeometryReader { geo in
            let colWidth = DesignSystem.Metrics.columnWidth
            let availableWidth = geo.size.width - 2 * DesignSystem.Metrics.minHorizontalMargin
            let cols = DesignSystem.Metrics.columns(fittingWidth: availableWidth)
            let blockWidth = CGFloat(cols) * colWidth
            let _ = print("[LAYOUT] geo.width=\(geo.size.width) columnWidth=\(colWidth) cols=\(cols) blockWidth=\(blockWidth) availableWidth=\(availableWidth) dynamicType=\(dynamicTypeSize)")

            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // ── Header ───────────────────────────────────────
                    TerminalHeader(columns: cols, dimColor: dimColor)
                        .padding(.top, 16)

                    // ── Batch rows ───────────────────────────────────
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(PreviewData.batches) { batch in
                                TerminalBatchRow(
                                    batch: batch,
                                    columns: cols,
                                    dimColor: dimColor,
                                    tappableColor: tappableColor,
                                    reduceMotion: isReduceMotion
                                )
                                .padding(.vertical, 10)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }

                    // ── Tab bar ──────────────────────────────────────
                    TerminalTabBar(columns: cols, dimColor: dimColor, tappableColor: tappableColor)
                }
                .frame(width: blockWidth, alignment: .center)
            }
        }
    }
}

// MARK: - Header

private struct TerminalHeader: View {
    let columns: Int
    let dimColor: Color

    private static let headerTitle = "LEARNING PROTOCOL"
    private var titleLength: Int { Self.headerTitle.count }

    // Title fits with dashes when columns >= title + 2 spaces + at least 2 dashes
    private var titleFitsWithDashes: Bool { columns >= titleLength + 4 }
    private var titleFitsOnOneLine: Bool { columns >= titleLength }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top rule
            Text(String(repeating: "-", count: columns))
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()

            // Title line — Rule 4 fallback
            if titleFitsWithDashes {
                dashedTitleLine
            } else {
                // No dashes — title alone, wrapping if needed
                Text(Self.headerTitle)
                    .font(DesignSystem.Typography.title)
                    .tracking(DesignSystem.Typography.tracking(for: DesignSystem.Typography.minDimSize))
                    .foregroundStyle(dimColor)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Bottom rule
            Text(String(repeating: "-", count: columns))
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
        }
    }

    private var dashedTitleLine: some View {
        let titleCols = titleLength + 2 // +2 for spaces
        let dashBudget = max(0, columns - titleCols)
        let leftDashes = dashBudget / 2
        let rightDashes = dashBudget - leftDashes // odd remainder goes right

        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(String(repeating: "-", count: leftDashes) + " ")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
            Text(Self.headerTitle)
                .font(DesignSystem.Typography.title)
                .tracking(DesignSystem.Typography.tracking(for: DesignSystem.Typography.minDimSize))
                .foregroundStyle(dimColor)
                .fixedSize()
            Text(" " + String(repeating: "-", count: rightDashes))
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
        }
    }
}

// MARK: - Batch row

// Future: at very large Dynamic Type sizes, progressive abbreviation
// (e.g. BATCH 1 → B1) would keep rows on a single line and read as more
// terminal-authentic than wrapping. Deferred because abbreviation is
// content-specific and must be decided per screen; wrapping is
// content-agnostic and works system-wide. Revisit once Meet, Quiz, and
// Codex layouts are designed.

private struct TerminalBatchRow: View {
    let batch: PreviewBatch
    let columns: Int
    let dimColor: Color
    let tappableColor: Color
    let reduceMotion: Bool

    private var isActive: Bool { batch.state == .active }
    private var nameColor: Color   { isActive ? tappableColor : dimColor }
    private var letterColor: Color { isActive ? tappableColor : dimColor }

    private var nameString: String { "BATCH \(batch.number) " }
    private var lettersString: String { " " + batch.lettersDisplay + " " }
    private var glyphString: String { batch.state == .active ? ">" : "!" }

    private var fixedColumns: Int {
        nameString.count + lettersString.count + glyphString.count
    }

    var body: some View {
        Button(action: {}) {
            if fixedColumns <= columns {
                singleLineContent
            } else {
                wrappedContent
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .frame(minHeight: 44)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }

    private var singleLineContent: some View {
        let leaderBudget = max(0, columns - fixedColumns)
        let dotCount = leaderBudget > 0 ? (leaderBudget + 1) / 2 : 0
        let dotsColumns = dotCount > 0 ? dotCount * 2 - 1 : 0
        let trailingPad = leaderBudget - dotsColumns
        let leaderText = dotCount > 0
            ? Array(repeating: ".", count: dotCount).joined(separator: " ")
                + String(repeating: " ", count: trailingPad)
            : String(repeating: " ", count: leaderBudget)

        let fullLine = nameString + leaderText + lettersString

        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(fullLine)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .textCase(.uppercase)
                .fixedSize()
                .overlay(alignment: .leading) {
                    Text(nameString)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: nameColor)
                        .textCase(.uppercase)
                        .fixedSize()
                }
                .overlay(alignment: .trailing) {
                    Text(lettersString)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: letterColor)
                        .textCase(.uppercase)
                        .fixedSize()
                }

            trailingGlyph
        }
    }

    // Rule 4: wrap onto two lines, no leader dots.
    // The 44pt min-height applies to the row as a whole; wrapped lines
    // sit at normal line spacing (no extra gap).
    private var wrappedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Line 1: name + letters (no leader — it connects nothing across lines)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(nameString)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: nameColor)
                    .textCase(.uppercase)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text(batch.lettersDisplay)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: letterColor)
                    .textCase(.uppercase)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // Line 2: glyph right-aligned
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                trailingGlyph
            }
        }
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

private struct DashedRule: View {
    let columns: Int
    let color: Color

    var body: some View {
        Text(String(repeating: "-", count: columns))
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
            .fixedSize()
    }
}

// MARK: - Tab bar

private struct TerminalTabBar: View {
    let columns: Int
    let dimColor: Color
    let tappableColor: Color

    // Column counts for each label (brackets included)
    private static let labels = ["[LEARN]", "[DRILL]", "[CODEX]"]
    // Minimum columns: all three labels + 1 space between each pair
    private static let minSingleLineColumns: Int = {
        labels.map(\.count).reduce(0, +) + (labels.count - 1)
    }()

    private var fitsOnOneLine: Bool { columns >= Self.minSingleLineColumns }

    var body: some View {
        VStack(spacing: 0) {
            DashedRule(columns: columns, color: dimColor)
                .padding(.bottom, 12)

            if fitsOnOneLine {
                horizontalTabs
            } else {
                verticalTabs
            }
        }
        .padding(.bottom, 8)
        .background(DesignSystem.Colors.background)
    }

    private var horizontalTabs: some View {
        HStack {
            learnChip
            Spacer()
            drillLabel
            Spacer()
            codexLabel
        }
    }

    private var verticalTabs: some View {
        VStack(alignment: .leading, spacing: 4) {
            learnChip
            drillLabel
            codexLabel
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var learnChip: some View {
        Text("[LEARN]")
            .terminalStyle(
                size: DesignSystem.Typography.minDimSize,
                color: DesignSystem.Colors.background
            )
            .textCase(.uppercase)
            .fixedSize()
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(dimColor)
    }

    private var drillLabel: some View {
        Text("[DRILL]")
            .terminalStyle(
                size: DesignSystem.Typography.minDimSize,
                color: tappableColor
            )
            .textCase(.uppercase)
            .fixedSize()
    }

    private var codexLabel: some View {
        Text("[CODEX]")
            .terminalStyle(
                size: DesignSystem.Typography.minDimSize,
                color: tappableColor
            )
            .textCase(.uppercase)
            .fixedSize()
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
