//
//  DesignPreview.swift
//  NATO-1
//
//  Standalone visual prototype of the restyled app.
//  NOT wired to AppState, NATOData, or any real app logic.
//  Preview state: Batch 1 active, Batches 2–7 locked.
//
//  Layout: A single top-level GeometryReader computes one column count
//  and one blockWidth (cols × columnWidth). That block is centered on
//  screen. All children receive `columns: Int` — no per-component
//  GeometryReaders, no fractional accumulation.

import SwiftUI

// MARK: - Tab model

private enum PreviewTab: String, CaseIterable {
    case learn, drill, codex

    var label: String {
        switch self {
        case .learn: return "[LEARN]"
        case .drill: return "[DRILL]"
        case .codex: return "[CODEX]"
        }
    }

    var headerTitle: String {
        switch self {
        case .learn: return "LEARNING PROTOCOL"
        case .drill: return "DRILL PROTOCOL"
        case .codex: return "CODEX"
        }
    }
}

// MARK: - Preview root

struct DesignPreview: View {
    @Environment(\.colorSchemeContrast) private var systemContrast
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedTab: PreviewTab = .learn
    @State private var showSysSheet = false

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

                if showSysSheet {
                    // Full-screen dialog view depicting a floating box
                    DOSDialogScreen(
                        columns: cols,
                        blockWidth: blockWidth,
                        dimColor: dimColor,
                        tappableColor: tappableColor,
                        showDialog: $showSysSheet
                    )
                } else {
                    VStack(spacing: 0) {
                        AppBanner(
                            columns: cols,
                            dimColor: dimColor,
                            tappableColor: tappableColor,
                            showSysSheet: $showSysSheet
                        )
                        .padding(.top, 16)

                        switch selectedTab {
                        case .learn:
                            LearnContent(
                                columns: cols,
                                dimColor: dimColor,
                                tappableColor: tappableColor,
                                reduceMotion: isReduceMotion
                            )
                        case .drill:
                            PlaceholderContent(
                                title: PreviewTab.drill.headerTitle,
                                columns: cols,
                                dimColor: dimColor
                            )
                        case .codex:
                            PlaceholderContent(
                                title: PreviewTab.codex.headerTitle,
                                columns: cols,
                                dimColor: dimColor
                            )
                        }

                        TerminalTabBar(
                            columns: cols,
                            selectedTab: $selectedTab,
                            dimColor: dimColor,
                            tappableColor: tappableColor
                        )
                    }
                    .frame(width: blockWidth, alignment: .center)
                }
            }
        }
    }
}

// MARK: - Learn content

private struct LearnContent: View {
    let columns: Int
    let dimColor: Color
    let tappableColor: Color
    let reduceMotion: Bool

    var body: some View {
        ScreenHeader(title: "LEARNING PROTOCOL", columns: columns, dimColor: dimColor)

        ScrollView {
            VStack(spacing: 0) {
                ForEach(PreviewData.batches) { batch in
                    TerminalBatchRow(
                        batch: batch,
                        columns: columns,
                        dimColor: dimColor,
                        tappableColor: tappableColor,
                        reduceMotion: reduceMotion
                    )
                    .padding(.vertical, 10)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Placeholder content (Drill / Codex)

private struct PlaceholderContent: View {
    let title: String
    let columns: Int
    let dimColor: Color

    var body: some View {
        ScreenHeader(title: title, columns: columns, dimColor: dimColor)

        Spacer()
    }
}

// MARK: - App banner

/// Top-of-screen identity line shared across all tabs.
/// Replaces the old top dashed rule in the header.
/// NATO-1 ----------- [SYS]
private struct AppBanner: View {
    let columns: Int
    let dimColor: Color
    let tappableColor: Color
    @Binding var showSysSheet: Bool

    private static let appName = "NATO-1"
    private static let sysLabel = "[SYS]"
    // Fixed columns: app name + 1 space + 1 space + sys label
    private static let fixedCols = appName.count + 1 + 1 + sysLabel.count

    var body: some View {
        let dashBudget = max(0, columns - Self.fixedCols)
        let dashes = String(repeating: "-", count: dashBudget)
        let bannerText = Self.appName + " " + dashes + " " + Self.sysLabel

        // Render the full line in dim, then overlay the endpoints in their colors.
        // App name is dim (not tappable); [SYS] is bright (tappable).
        Button { showSysSheet.toggle() } label: {
            Text(bannerText)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
                .overlay(alignment: .trailing) {
                    Text(Self.sysLabel)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: tappableColor)
                        .fixedSize()
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("System settings")
    }
}

// MARK: - Screen header

/// Per-screen title line + bottom rule. Sits below the app banner.
private struct ScreenHeader: View {
    let title: String
    let columns: Int
    let dimColor: Color

    private var titleLength: Int { title.count }

    // Title fits with dashes when columns >= title + 2 spaces + at least 2 dashes
    private var titleFitsWithDashes: Bool { columns >= titleLength + 4 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title line — Rule 4 fallback
            if titleFitsWithDashes {
                dashedTitleLine
            } else {
                // No dashes — title alone, wrapping if needed
                Text(title)
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
            Text(title)
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

// MARK: - DOS dialog

/// Full-screen view depicting a DOS TUI dialog box.
///
/// FIXED HEADER: top border with title and [EXIT], pinned.
/// SCROLLING DOCUMENT: bordered content rows (borders scroll WITH content),
///   bottom border + shadow row at the very end.
///
/// At scroll-top the document's top edge aligns seamlessly with the fixed
/// header's bottom edge, reading as one continuous box.
private struct DOSDialogScreen: View {
    let columns: Int
    let blockWidth: CGFloat
    let dimColor: Color
    let tappableColor: Color
    @Binding var showDialog: Bool

    // Box-drawing characters
    private static let tl = "╔", tr = "╗", bl = "╚", br = "╝"
    private static let hz = "═", vt = "║"
    private static let sh = "░"

    private static let title = " SYSTEM SETTINGS "
    private static let exitLabel = "[EXIT]"

    // Shadow color: between background (#041302) and dim (#1C835B)
    private static let shadowColor = Color(hex: "0A2A12")

    // Box inset: 1 column per side from the screen block.
    // Total row width = boxCols + 1 (shadow) must fit in columns.
    private var boxCols: Int { max(0, columns - 2) }
    // Inner content: box minus 2 border chars minus 2 padding spaces
    private var innerCols: Int { max(0, boxCols - 4) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 8)

            // FIXED HEADER: top border, always visible
            topBorderRow
                .background(DesignSystem.Colors.background)

            // SCROLLING DOCUMENT: bordered content + bottom border + shadow
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    contentRow(innerText: "")

                    ForEach(RuleSpecimenSheet.specimens) { spec in
                        // Specimen rule: truncate to exact inner column count
                        let rule = String(spec.build(innerCols).prefix(innerCols))
                        contentRow(innerText: rule)
                        // Label: truncate to inner column count
                        let label = String("\(spec.id). \(spec.name)".prefix(innerCols))
                        contentRow(
                            innerText: label,
                            dimContent: true
                        )
                    }

                    contentRow(innerText: "")

                    // Bottom border (scrolls with content)
                    bottomBorderRow

                    // Shadow bottom row (scrolls with content)
                    shadowBottomRow
                }
            }

            Spacer(minLength: 8)
        }
        .frame(width: blockWidth)
    }

    // MARK: - Top border row (fixed, no shadow)

    private var topBorderRow: some View {
        let titleLen = Self.title.count
        let exitLen = Self.exitLabel.count
        let fixedLen = 2 + titleLen + exitLen
        let fillLen = max(0, boxCols - fixedLen)
        let leftFill = min(2, fillLen)
        let rightFill = max(0, fillLen - leftFill)

        let line = Self.tl
            + String(repeating: Self.hz, count: leftFill)
            + Self.title
            + String(repeating: Self.hz, count: rightFill)
            + Self.exitLabel
            + Self.tr

        return Button { showDialog = false } label: {
            Text(line)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
                .overlay(alignment: .trailing) {
                    Text(Self.exitLabel + Self.tr)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .fixedSize()
                        .overlay(alignment: .leading) {
                            Text(Self.exitLabel)
                                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: tappableColor)
                                .fixedSize()
                        }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content row

    /// A single content row: ║ space content(padded) space ║ ░
    /// Borders are ALWAYS full dimColor. Content may be dimmed independently.
    private func contentRow(innerText: String, dimContent: Bool = false) -> some View {
        let padded: String
        if innerText.isEmpty {
            padded = String(repeating: " ", count: innerCols)
        } else {
            let pad = max(0, innerCols - innerText.count)
            padded = innerText + String(repeating: " ", count: pad)
        }

        // Build the full row as three pieces to keep border color independent
        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Left border
            Text(Self.vt + " ")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()

            // Inner content (may be dimmed)
            Text(padded)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
                .opacity(dimContent ? 0.6 : 1.0)

            // Right border + shadow
            Text(" " + Self.vt)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
            Text(Self.sh)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: Self.shadowColor)
                .fixedSize()
        }
    }

    // MARK: - Bottom border row (with shadow)

    private var bottomBorderRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(Self.bl + String(repeating: Self.hz, count: max(0, boxCols - 2)) + Self.br)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
            Text(Self.sh)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: Self.shadowColor)
                .fixedSize()
        }
    }

    // MARK: - Shadow bottom row

    private var shadowBottomRow: some View {
        let line = " " + String(repeating: Self.sh, count: boxCols)
        return Text(line)
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: Self.shadowColor)
            .fixedSize()
    }
}

// MARK: - Tab bar

private struct TerminalTabBar: View {
    let columns: Int
    @Binding var selectedTab: PreviewTab
    let dimColor: Color
    let tappableColor: Color

    // Minimum columns: all three labels + 1 space between each pair
    private static let minSingleLineColumns: Int = {
        PreviewTab.allCases.map(\.label.count).reduce(0, +) + (PreviewTab.allCases.count - 1)
    }()

    private var fitsOnOneLine: Bool { columns >= Self.minSingleLineColumns }

    private let haptic = UIImpactFeedbackGenerator(style: .light)

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
            tabButton(for: .learn)
            Spacer()
            tabButton(for: .drill)
            Spacer()
            tabButton(for: .codex)
        }
    }

    private var verticalTabs: some View {
        VStack(alignment: .leading, spacing: 4) {
            tabButton(for: .learn)
            tabButton(for: .drill)
            tabButton(for: .codex)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func tabButton(for tab: PreviewTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            if selectedTab != tab {
                haptic.impactOccurred()
                selectedTab = tab
            }
        } label: {
            if isSelected {
                Text(tab.label)
                    .terminalChip(
                        textColor: DesignSystem.Colors.background,
                        backgroundColor: dimColor
                    )
            } else {
                Text(tab.label)
                    .terminalStyle(
                        size: DesignSystem.Typography.minDimSize,
                        color: tappableColor
                    )
                    .textCase(.uppercase)
                    .fixedSize()
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Rule specimen sheet

private struct RuleSpecimen: Identifiable {
    let id: Int
    let name: String
    /// A closure that builds the rule string for a given column count.
    let build: (Int) -> String
}

private struct RuleSpecimenSheet: View {
    let columns: Int
    let dimColor: Color

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("RULE SPECIMENS")
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor, weight: .bold)
                    .fixedSize()
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ForEach(Self.specimens) { spec in
                    // Rule line
                    Text(spec.build(columns))
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .fixedSize()

                    // Label
                    Text("\(spec.id). \(spec.name)")
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .fixedSize()
                        .opacity(0.6)
                        .padding(.bottom, 12)
                }
            }
            .padding(.bottom, 32)
        }
    }

    // Helper: repeat a unit to fill columns exactly
    private static func fill(_ unit: String, cols: Int) -> String {
        let unitLen = unit.count
        guard unitLen > 0, cols > 0 else { return "" }
        let fullRepeats = cols / unitLen
        let remainder = cols % unitLen
        return String(repeating: unit, count: fullRepeats) + String(unit.prefix(remainder))
    }

    // Helper: repeat a unit to fill, but trim to exact column count
    private static func repeat_exact(_ char: Character, cols: Int) -> String {
        String(repeating: char, count: cols)
    }

    // Helper: spaced repeat (char + space), filling cols
    private static func spaced(_ char: Character, cols: Int) -> String {
        fill(String(char) + " ", cols: cols)
    }

    // Helper: end-capped rule
    private static func capped(_ left: String, _ fill_char: Character, _ right: String, cols: Int) -> String {
        let innerCols = max(0, cols - left.count - right.count)
        return left + String(repeating: fill_char, count: innerCols) + right
    }

    static let specimens: [RuleSpecimen] = [
        // ── Simple repeats ──────────────────────────────────
        RuleSpecimen(id: 1, name: "hyphen") { cols in
            repeat_exact("-", cols: cols)
        },
        RuleSpecimen(id: 2, name: "equals") { cols in
            repeat_exact("=", cols: cols)
        },
        RuleSpecimen(id: 3, name: "underscore") { cols in
            repeat_exact("_", cols: cols)
        },
        RuleSpecimen(id: 4, name: "period") { cols in
            repeat_exact(".", cols: cols)
        },
        RuleSpecimen(id: 5, name: "tilde") { cols in
            repeat_exact("~", cols: cols)
        },
        RuleSpecimen(id: 6, name: "asterisk") { cols in
            repeat_exact("*", cols: cols)
        },
        RuleSpecimen(id: 7, name: "plus") { cols in
            repeat_exact("+", cols: cols)
        },
        RuleSpecimen(id: 8, name: "hash") { cols in
            repeat_exact("#", cols: cols)
        },
        RuleSpecimen(id: 9, name: "colon") { cols in
            repeat_exact(":", cols: cols)
        },
        RuleSpecimen(id: 10, name: "semicolon") { cols in
            repeat_exact(";", cols: cols)
        },
        RuleSpecimen(id: 11, name: "pipe") { cols in
            repeat_exact("|", cols: cols)
        },
        RuleSpecimen(id: 12, name: "forward slash") { cols in
            repeat_exact("/", cols: cols)
        },
        RuleSpecimen(id: 13, name: "backslash") { cols in
            repeat_exact("\\", cols: cols)
        },
        RuleSpecimen(id: 14, name: "caret") { cols in
            repeat_exact("^", cols: cols)
        },
        RuleSpecimen(id: 15, name: "backtick") { cols in
            repeat_exact("`", cols: cols)
        },
        RuleSpecimen(id: 16, name: "single quote") { cols in
            repeat_exact("'", cols: cols)
        },
        RuleSpecimen(id: 17, name: "double quote") { cols in
            repeat_exact("\"", cols: cols)
        },

        // ── Spaced repeats ──────────────────────────────────
        RuleSpecimen(id: 18, name: "spaced hyphen") { cols in
            spaced("-", cols: cols)
        },
        RuleSpecimen(id: 19, name: "spaced equals") { cols in
            spaced("=", cols: cols)
        },
        RuleSpecimen(id: 20, name: "spaced period") { cols in
            spaced(".", cols: cols)
        },
        RuleSpecimen(id: 21, name: "spaced tilde") { cols in
            spaced("~", cols: cols)
        },
        RuleSpecimen(id: 22, name: "spaced asterisk") { cols in
            spaced("*", cols: cols)
        },
        RuleSpecimen(id: 23, name: "spaced plus") { cols in
            spaced("+", cols: cols)
        },
        RuleSpecimen(id: 24, name: "spaced hash") { cols in
            spaced("#", cols: cols)
        },
        RuleSpecimen(id: 25, name: "spaced colon") { cols in
            spaced(":", cols: cols)
        },
        RuleSpecimen(id: 26, name: "spaced pipe") { cols in
            spaced("|", cols: cols)
        },
        RuleSpecimen(id: 27, name: "spaced caret") { cols in
            spaced("^", cols: cols)
        },

        // ── Double-character units ──────────────────────────
        RuleSpecimen(id: 28, name: "double hyphen") { cols in
            fill("--", cols: cols)
        },
        RuleSpecimen(id: 29, name: "double plus") { cols in
            fill("++", cols: cols)
        },
        RuleSpecimen(id: 30, name: "double equals") { cols in
            fill("==", cols: cols)
        },
        RuleSpecimen(id: 31, name: "double underscore") { cols in
            fill("__", cols: cols)
        },
        RuleSpecimen(id: 32, name: "double tilde") { cols in
            fill("~~", cols: cols)
        },
        RuleSpecimen(id: 33, name: "double asterisk") { cols in
            fill("**", cols: cols)
        },

        // ── Alternating pairs ───────────────────────────────
        RuleSpecimen(id: 34, name: "hyphen-plus") { cols in
            fill("-+", cols: cols)
        },
        RuleSpecimen(id: 35, name: "hyphen-equals") { cols in
            fill("-=", cols: cols)
        },
        RuleSpecimen(id: 36, name: "hyphen-period") { cols in
            fill("-.", cols: cols)
        },
        RuleSpecimen(id: 37, name: "hyphen-asterisk") { cols in
            fill("-*", cols: cols)
        },
        RuleSpecimen(id: 38, name: "hyphen-tilde") { cols in
            fill("-~", cols: cols)
        },
        RuleSpecimen(id: 39, name: "equals-plus") { cols in
            fill("=+", cols: cols)
        },
        RuleSpecimen(id: 40, name: "period-colon") { cols in
            fill(".:", cols: cols)
        },
        RuleSpecimen(id: 41, name: "period-space") { cols in
            fill(". ", cols: cols)
        },
        RuleSpecimen(id: 42, name: "colon-space") { cols in
            fill(": ", cols: cols)
        },

        // ── Three-character cycles ──────────────────────────
        RuleSpecimen(id: 43, name: "hyphen-plus-hyphen") { cols in
            fill("-+-", cols: cols)
        },
        RuleSpecimen(id: 44, name: "equals-asterisk-equals") { cols in
            fill("=*=", cols: cols)
        },
        RuleSpecimen(id: 45, name: "period-colon-period") { cols in
            fill(".:.", cols: cols)
        },
        RuleSpecimen(id: 46, name: "tilde-hyphen-tilde") { cols in
            fill("~-~", cols: cols)
        },
        RuleSpecimen(id: 47, name: "plus-equals-plus") { cols in
            fill("+=+", cols: cols)
        },
        RuleSpecimen(id: 48, name: "hyphen-space-hyphen") { cols in
            fill("- -", cols: cols)
        },
        RuleSpecimen(id: 49, name: "equals-space-equals") { cols in
            fill("= =", cols: cols)
        },
        RuleSpecimen(id: 50, name: "hash-hyphen-hash") { cols in
            fill("#-#", cols: cols)
        },

        // ── Bracket-flanked ─────────────────────────────────
        RuleSpecimen(id: 51, name: "square bracket hyphen") { cols in
            capped("[", "-", "]", cols: cols)
        },
        RuleSpecimen(id: 52, name: "square bracket equals") { cols in
            capped("[", "=", "]", cols: cols)
        },
        RuleSpecimen(id: 53, name: "curly bracket equals") { cols in
            capped("{", "=", "}", cols: cols)
        },
        RuleSpecimen(id: 54, name: "paren tilde") { cols in
            capped("(", "~", ")", cols: cols)
        },
        RuleSpecimen(id: 55, name: "angle bracket hyphen") { cols in
            capped("<", "-", ">", cols: cols)
        },

        // ── End-capped ──────────────────────────────────────
        RuleSpecimen(id: 56, name: "plus-capped hyphen") { cols in
            capped("+", "-", "+", cols: cols)
        },
        RuleSpecimen(id: 57, name: "angle-capped hyphen") { cols in
            capped(">", "-", "<", cols: cols)
        },
        RuleSpecimen(id: 58, name: "pipe-capped hyphen") { cols in
            capped("|", "-", "|", cols: cols)
        },
        RuleSpecimen(id: 59, name: "hash-capped hyphen") { cols in
            capped("#", "-", "#", cols: cols)
        },
        RuleSpecimen(id: 60, name: "asterisk-capped hyphen") { cols in
            capped("*", "-", "*", cols: cols)
        },
        RuleSpecimen(id: 61, name: "plus-capped equals") { cols in
            capped("+", "=", "+", cols: cols)
        },
        RuleSpecimen(id: 62, name: "pipe-capped equals") { cols in
            capped("|", "=", "|", cols: cols)
        },

        // ── Terminal-flavored ───────────────────────────────
        RuleSpecimen(id: 63, name: "chevron repeat") { cols in
            repeat_exact(">", cols: cols)
        },
        RuleSpecimen(id: 64, name: "spaced chevron") { cols in
            spaced(">", cols: cols)
        },
        RuleSpecimen(id: 65, name: "dollar repeat") { cols in
            repeat_exact("$", cols: cols)
        },
        RuleSpecimen(id: 66, name: "spaced dollar") { cols in
            spaced("$", cols: cols)
        },
        RuleSpecimen(id: 67, name: "at sign repeat") { cols in
            repeat_exact("@", cols: cols)
        },
        RuleSpecimen(id: 68, name: "ampersand repeat") { cols in
            repeat_exact("&", cols: cols)
        },
        RuleSpecimen(id: 69, name: "percent repeat") { cols in
            repeat_exact("%", cols: cols)
        },
        RuleSpecimen(id: 70, name: "exclamation repeat") { cols in
            repeat_exact("!", cols: cols)
        },

        // ── Density plays ───────────────────────────────────
        RuleSpecimen(id: 71, name: "sparse hyphen (3-space)") { cols in
            fill("-   ", cols: cols)
        },
        RuleSpecimen(id: 72, name: "sparse period (3-space)") { cols in
            fill(".   ", cols: cols)
        },
        RuleSpecimen(id: 73, name: "sparse asterisk (3-space)") { cols in
            fill("*   ", cols: cols)
        },
        RuleSpecimen(id: 74, name: "medium hyphen (2-space)") { cols in
            fill("-  ", cols: cols)
        },
        RuleSpecimen(id: 75, name: "medium period (2-space)") { cols in
            fill(".  ", cols: cols)
        },
        RuleSpecimen(id: 76, name: "asymmetric dot-dash") { cols in
            fill(". --", cols: cols)
        },
        RuleSpecimen(id: 77, name: "morse-style dot-dash") { cols in
            fill(".-", cols: cols)
        },
        RuleSpecimen(id: 78, name: "morse spaced") { cols in
            fill(". - ", cols: cols)
        },

        // ── Multi-character patterns ────────────────────────
        RuleSpecimen(id: 79, name: "arrow right") { cols in
            fill("->", cols: cols)
        },
        RuleSpecimen(id: 80, name: "arrow left") { cols in
            fill("<-", cols: cols)
        },
        RuleSpecimen(id: 81, name: "bidirectional arrow") { cols in
            fill("<->", cols: cols)
        },
        RuleSpecimen(id: 82, name: "zigzag /\\") { cols in
            fill("/\\", cols: cols)
        },
        RuleSpecimen(id: 83, name: "zigzag \\/") { cols in
            fill("\\/", cols: cols)
        },
        RuleSpecimen(id: 84, name: "wave /~") { cols in
            fill("/~", cols: cols)
        },
        RuleSpecimen(id: 85, name: "fence ||--") { cols in
            fill("||--", cols: cols)
        },
        RuleSpecimen(id: 86, name: "railroad |-") { cols in
            fill("|-", cols: cols)
        },
        RuleSpecimen(id: 87, name: "ladder |=") { cols in
            fill("|=", cols: cols)
        },
        RuleSpecimen(id: 88, name: "barbed wire -<>-") { cols in
            fill("-<>-", cols: cols)
        },
        RuleSpecimen(id: 89, name: "chain -o-") { cols in
            fill("-o-", cols: cols)
        },
        RuleSpecimen(id: 90, name: "dash dot dot") { cols in
            fill("-..  ", cols: cols)
        },
        RuleSpecimen(id: 91, name: "section marker --+--") { cols in
            fill("--+--", cols: cols)
        },
        RuleSpecimen(id: 92, name: "ticker tape -|") { cols in
            fill("-|", cols: cols)
        },
        RuleSpecimen(id: 93, name: "circuit --||--") { cols in
            fill("--||--", cols: cols)
        },
        RuleSpecimen(id: 94, name: "crosshatch #-") { cols in
            fill("#-", cols: cols)
        },
        RuleSpecimen(id: 95, name: "frequency .:':") { cols in
            fill(".:'.:", cols: cols)
        },
    ]
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
