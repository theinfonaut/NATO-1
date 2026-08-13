//
//  SettingsView.swift
//  NATO-1
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var appState = AppState.shared

    @State private var showingResetAlert = false
    @State private var showingJumpDrillAlert = false
    @State private var showingJumpMasteryAlert = false

    var body: some View {
        let _ = dynamicTypeSize

        GeometryReader { geo in
            let availableWidth = geo.size.width - 2 * DesignSystem.Metrics.minHorizontalMargin
            let cols = DesignSystem.Metrics.columns(fittingWidth: availableWidth)
            let blockWidth = CGFloat(cols) * DesignSystem.Metrics.columnWidth

            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                DOSDialogFrame(
                    columns: cols,
                    blockWidth: blockWidth,
                    title: " SYSTEM SETTINGS ",
                    dimColor: DesignSystem.Colors.dim,
                    tappableColor: DesignSystem.Colors.tappable,
                    onExit: { dismiss() }
                ) { innerCols in
                    // ── About ──
                    DOSBoxRow(text: "ABOUT", innerCols: innerCols, color: DesignSystem.Colors.tappable)
                    DOSBoxRow(text: AppConstants.App.name + " v" + AppConstants.App.version, innerCols: innerCols)
                    DOSBoxRow(text: "Made independently by \(AppConstants.App.studioName). Your purchase supports indie development.", innerCols: innerCols, dimmed: true)
                    DOSBoxRow(innerCols: innerCols)

                    // ── Features ──
                    DOSBoxRow(text: "FEATURES", innerCols: innerCols, color: DesignSystem.Colors.tappable)
                    DOSBoxRow(text: "Custom Words -- Coming soon", innerCols: innerCols, dimmed: true)
                    DOSBoxRow(text: "Notifications -- Coming soon", innerCols: innerCols, dimmed: true)
                    DOSBoxRow(innerCols: innerCols)

                    // ── Debug ──
                    DOSBoxRow(text: "DEBUG", innerCols: innerCols, color: DesignSystem.Colors.tappable)
                    Button { showingResetAlert = true } label: {
                        DOSBoxRow(text: "[ FULL RESET ]", innerCols: innerCols, color: DesignSystem.Colors.tappable)
                    }
                    .buttonStyle(.plain)
                    Button { showingJumpDrillAlert = true } label: {
                        DOSBoxRow(text: "[ JUMP TO DRILLING ]", innerCols: innerCols, color: DesignSystem.Colors.tappable)
                    }
                    .buttonStyle(.plain)
                    Button { showingJumpMasteryAlert = true } label: {
                        DOSBoxRow(text: "[ JUMP TO MASTERY ]", innerCols: innerCols, color: DesignSystem.Colors.tappable)
                    }
                    .buttonStyle(.plain)
                    DOSBoxRow(innerCols: innerCols)
                    DOSBoxRow(text: "Testing only. These options will be removed in the release version.", innerCols: innerCols, dimmed: true)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .alert("Reset All Progress?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appState.resetAll()
                dismiss()
            }
        } message: {
            Text("This will erase all your progress and return the app to a fresh install state. This cannot be undone.")
        }
        .alert("Jump to Drilling?", isPresented: $showingJumpDrillAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Jump") {
                appState.debugJumpToDrilling()
                dismiss()
            }
        } message: {
            Text("This will mark Batch 1 (A B C D) as complete and add those letters to the drill queue, due immediately.")
        }
        .alert("Jump to Mastery?", isPresented: $showingJumpMasteryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Jump") {
                appState.debugJumpToMastery()
                dismiss()
            }
        } message: {
            Text("This will set A–Y to Mastered and Z to Confident (due now). Answer Z correctly to trigger the mastery celebration.")
        }
    }
}

// MARK: - DOS Box Row

/// One or more bordered content rows for use inside a DOSDialogFrame:
/// ║ space content(padded) space ║ ░
/// Long text word-wraps across multiple bordered rows so nothing is lost.
/// Non-generic — can be used directly without type inference issues.
struct DOSBoxRow: View {
    var text: String = ""
    let innerCols: Int
    var color: Color = DesignSystem.Colors.dim
    var dimmed: Bool = false

    /// Word-wrap text into lines of at most `innerCols` characters.
    /// Breaks at word boundaries when possible; forces a break mid-word
    /// only when a single word exceeds the line width.
    private var wrappedLines: [String] {
        guard !text.isEmpty, innerCols > 0 else { return [""] }

        var lines: [String] = []
        var currentLine = ""

        for word in text.split(separator: " ", omittingEmptySubsequences: false) {
            let w = String(word)
            if currentLine.isEmpty {
                // First word on the line — force it even if it's too long
                if w.count > innerCols {
                    // Break the long word across lines
                    var remaining = w[w.startIndex...]
                    while !remaining.isEmpty {
                        let chunk = String(remaining.prefix(innerCols))
                        lines.append(chunk)
                        remaining = remaining.dropFirst(chunk.count)
                    }
                    currentLine = ""
                    // If the last chunk was a full line, start fresh
                    if let last = lines.last, last.count == innerCols {
                        continue
                    }
                    // Otherwise pop the last partial chunk back as the current line
                    currentLine = lines.removeLast()
                } else {
                    currentLine = w
                }
            } else if currentLine.count + 1 + w.count <= innerCols {
                // Fits on this line with a space
                currentLine += " " + w
            } else {
                // Doesn't fit — finish this line and start a new one
                lines.append(currentLine)
                if w.count > innerCols {
                    var remaining = w[w.startIndex...]
                    while !remaining.isEmpty {
                        let chunk = String(remaining.prefix(innerCols))
                        lines.append(chunk)
                        remaining = remaining.dropFirst(chunk.count)
                    }
                    currentLine = ""
                    if let last = lines.last, last.count == innerCols {
                        continue
                    }
                    currentLine = lines.removeLast()
                } else {
                    currentLine = w
                }
            }
        }
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        return lines.isEmpty ? [""] : lines
    }

    var body: some View {
        ForEach(Array(wrappedLines.enumerated()), id: \.offset) { _, line in
            borderedLine(line)
        }
    }

    private func borderedLine(_ line: String) -> some View {
        let pad = max(0, innerCols - line.count)
        let padded = line + String(repeating: " ", count: pad)

        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Left border
            Text("║ ")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: DesignSystem.Colors.dim)
                .fixedSize()

            // Inner content
            Text(padded)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
                .fixedSize()
                .opacity(dimmed ? 0.6 : 1.0)

            // Right border + shadow
            Text(" ║")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: DesignSystem.Colors.dim)
                .fixedSize()
            Text("░")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: DesignSystem.Colors.shadow)
                .fixedSize()
        }
    }
}

// MARK: - DOS Dialog Frame

/// Reusable DOS TUI dialog box frame with double-line borders and drop shadow.
/// The frame provides: a fixed header row (title + [EXIT]), a scrolling bordered
/// body, and a bottom border with shadow. Content is supplied via @ViewBuilder
/// and receives `innerCols` (the number of usable character columns inside the box).
/// Use DOSBoxRow to build content rows inside the frame.
struct DOSDialogFrame<Content: View>: View {
    let columns: Int
    let blockWidth: CGFloat
    let title: String
    let dimColor: Color
    let tappableColor: Color
    let onExit: () -> Void
    @ViewBuilder let content: (_ innerCols: Int) -> Content

    /// Box width in columns (1-col inset per side from screen block).
    private var boxCols: Int { max(0, columns - 2) }
    /// Usable inner content columns (box minus 2 borders minus 2 padding spaces).
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
                    DOSBoxRow(innerCols: innerCols)

                    content(innerCols)

                    DOSBoxRow(innerCols: innerCols)

                    bottomBorderRow

                    shadowBottomRow
                }
            }
            .scrollContentBackground(.hidden)
            .contentMargins(0)

            Spacer(minLength: 8)
        }
        .frame(width: blockWidth)
    }

    // MARK: - Top border row

    private var topBorderRow: some View {
        let exitLabel = "[EXIT]"
        let titleLen = title.count
        let exitLen = exitLabel.count
        let fixedLen = 2 + titleLen + exitLen
        let fillLen = max(0, boxCols - fixedLen)
        let leftFill = min(2, fillLen)
        let rightFill = max(0, fillLen - leftFill)

        // Left portion: ╔══ SYSTEM SETTINGS ══
        let leftPart = "╔"
            + String(repeating: "═", count: leftFill)
            + title
            + String(repeating: "═", count: rightFill)

        let line = leftPart + exitLabel + "╗"

        // The whole border row is a button so [EXIT] reliably receives taps.
        // Padding expands the tap target to 44pt; negative padding collapses
        // the layout back so the row renders at its natural text height
        // and sits flush against the scrolling body below.
        return Button(action: onExit) {
            Text(line)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
                .overlay(alignment: .trailing) {
                    Text(exitLabel + "╗")
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                        .fixedSize()
                        .overlay(alignment: .leading) {
                            Text(exitLabel)
                                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: tappableColor)
                                .fixedSize()
                        }
                }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .padding(.vertical, -12)
        .accessibilityLabel("Exit settings")
    }

    // MARK: - Bottom border row

    private var bottomBorderRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("╚" + String(repeating: "═", count: max(0, boxCols - 2)) + "╝")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .fixedSize()
            Text("░")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: DesignSystem.Colors.shadow)
                .fixedSize()
        }
    }

    // MARK: - Shadow bottom row

    private var shadowBottomRow: some View {
        let line = " " + String(repeating: "░", count: boxCols)
        return Text(line)
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: DesignSystem.Colors.shadow)
            .fixedSize()
    }
}

#Preview {
    SettingsView()
}
