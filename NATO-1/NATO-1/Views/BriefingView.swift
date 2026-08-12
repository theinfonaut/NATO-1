//
//  BriefingView.swift
//  NATO-1
//
//  First-run briefing interstitial for Batch 1.
//  Typewriter-prints the mission briefing, then shows a blinking › [BEGIN] affordance.
//  Shown once ever (UserDefaults flag). Reduce Motion shows full text immediately.

import SwiftUI

struct BriefingView: View {
    let onBegin: () -> Void
    var overrideReduceMotion: Bool? = nil

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var reduceMotion: Bool { overrideReduceMotion ?? systemReduceMotion }

    // Typewriter state
    @State private var phase: Phase = .headerCursor
    @State private var visibleLineIndex = -1  // which physical line is printing (-1 = none)
    @State private var visibleCharInLine = 0  // chars visible on the current physical line
    @State private var printingTask: Task<Void, Never>?
    @State private var measuredCols = 0       // set by GeometryReader

    // ── Authored copy ──
    // Each logical line is rendered exactly as given. Empty strings produce
    // blank-line beats. Long lines are word-wrapped to the measured column
    // count BEFORE typing begins — the layout is frozen, then revealed.
    private struct LogicalLine {
        let text: String
        let isBright: Bool
    }

    private static let logicalLines: [LogicalLine] = [
        LogicalLine(text: "INITIATING LEARNING PROTOCOL...",                                isBright: true),
        LogicalLine(text: "BATCH 1: A B C D",                                               isBright: true),
        LogicalLine(text: "",                                                                isBright: false),
        LogicalLine(text: "MEET EACH LETTER. LEARN THE CODE WORD AND A MEMORIZATION HOOK.",  isBright: false),
        LogicalLine(text: "",                                                                isBright: false),
        LogicalLine(text: "BUILD YOUR RECALL FROM MEMORY, NO MULTIPLE CHOICE HERE.",         isBright: false),
        LogicalLine(text: "",                                                                isBright: false),
        LogicalLine(text: "TIME TO COMPLETE < 5 MINUTES.",                                   isBright: false),
        LogicalLine(text: "HAVE FUN.",                                                       isBright: false),
    ]

    private static let beginLabel = "[BEGIN]"

    // Header lines (~40 cps = 25ms per char) — machine-fast boot sequence
    private static let headerCharDelayMs: Double = 25
    // Body lines (~20 cps = 50ms per char) — slower, readable teletype
    private static let bodyCharDelayMs: Double = 50
    // Pause at authored line endings before the next line begins
    private static let lineEndPauseMs: Double = 300
    // Blank lines get their own beat
    private static let blankLineBeatMs: Double = 300

    // Delay between caret appearing and [BEGIN] resolving next to it
    private static let beginResolveDelayMs: Double = 400

    private enum Phase {
        case headerCursor   // Block cursor blinks alone
        case printing       // Characters appearing line by line
        case closingPause   // Brief pause before caret appears
        case caretOnly      // › blinking alone, [BEGIN] not yet visible
        case complete       // › [BEGIN] visible, caret blinking
    }

    // ── Physical lines ──
    // Logical lines word-wrapped to the measured column count.
    // Computed from measuredCols so they update if the screen changes.

    private struct PhysicalLine: Identifiable {
        let id: Int
        let text: String
        let isBright: Bool
        /// True when this is the last physical line of its authored logical line.
        /// Only authored endings get line-end beats; soft-wrap points do not.
        let isAuthoredEnd: Bool
    }

    private var wrappedLines: [PhysicalLine] {
        Self.wrap(Self.logicalLines, columns: measuredCols)
    }

    /// Greedy word-wrap for monospace text. Authored blank lines pass through
    /// as empty physical lines. Long lines split at word boundaries to fit
    /// within `columns`.
    private static func wrap(_ logical: [LogicalLine], columns: Int) -> [PhysicalLine] {
        guard columns > 0 else { return [] }
        var result: [PhysicalLine] = []
        var nextId = 0

        for line in logical {
            if line.text.isEmpty {
                result.append(PhysicalLine(id: nextId, text: "", isBright: line.isBright, isAuthoredEnd: true))
                nextId += 1
            } else {
                let words = line.text.components(separatedBy: " ")
                var current = ""
                var segments: [String] = []

                for word in words {
                    if current.isEmpty {
                        current = word
                    } else if current.count + 1 + word.count <= columns {
                        current += " " + word
                    } else {
                        segments.append(current)
                        current = word
                    }
                }
                if !current.isEmpty {
                    segments.append(current)
                }

                for (i, seg) in segments.enumerated() {
                    let isLast = i == segments.count - 1
                    result.append(PhysicalLine(id: nextId, text: seg, isBright: line.isBright, isAuthoredEnd: isLast))
                    nextId += 1
                }
            }
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        let _ = dynamicTypeSize

        GeometryReader { geo in
            let colWidth = DesignSystem.Metrics.columnWidth
            let availableWidth = geo.size.width - 2 * DesignSystem.Metrics.minHorizontalMargin
            let cols = DesignSystem.Metrics.columns(fittingWidth: availableWidth)
            let blockWidth = CGFloat(cols) * colWidth

            ZStack(alignment: .topLeading) {
                DesignSystem.Colors.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    if reduceMotion {
                        staticContent
                    } else {
                        animatedContent
                    }
                }
                .frame(width: blockWidth, alignment: .topLeading)
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .onChange(of: cols) { _, newCols in
                measuredCols = newCols
            }
            .onAppear {
                measuredCols = cols
                if !reduceMotion {
                    startTypewriter()
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if reduceMotion {
                onBegin()
            } else if phase == .complete {
                onBegin()
            } else {
                skipToComplete()
            }
        }
        .onDisappear {
            printingTask?.cancel()
        }
        // Disable the fullScreenCover slide-up transition under Reduce Motion
        .transaction { t in
            if reduceMotion { t.disablesAnimations = true }
        }
    }

    // MARK: - Static content (Reduce Motion)

    private var staticContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(wrappedLines) { line in
                physicalLineView(text: line.text, isBright: line.isBright)
            }

            // Blank line before › [BEGIN]
            physicalLineView(text: "", isBright: false)

            // › [BEGIN] — caret steady, [BEGIN] steady (no blink under Reduce Motion)
            beginRow(caretBlinks: false)
        }
    }

    // MARK: - Animated content (typewriter)

    private var animatedContent: some View {
        let lines = wrappedLines

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(lines) { line in
                if line.id < visibleLineIndex {
                    // Fully printed line
                    physicalLineView(text: line.text, isBright: line.isBright)
                } else if line.id == visibleLineIndex {
                    // Currently printing line
                    if line.text.isEmpty {
                        physicalLineView(text: "", isBright: line.isBright)
                    } else {
                        let partial = String(line.text.prefix(visibleCharInLine))
                        physicalLineView(text: partial, isBright: line.isBright)
                    }
                }
                // else: not yet reached — not rendered
            }

            // Block cursor blinks alone before any text
            if phase == .headerCursor {
                blinkingCursor
            }

            // Caret appears first, then [BEGIN] resolves next to it
            if phase == .caretOnly {
                physicalLineView(text: "", isBright: false)
                caretOnlyRow
            } else if phase == .complete {
                physicalLineView(text: "", isBright: false)
                beginRow(caretBlinks: true)
            }
        }
    }

    // MARK: - Line rendering

    @ViewBuilder
    private func physicalLineView(text: String, isBright: Bool) -> some View {
        let color = isBright ? DesignSystem.Colors.tappable : DesignSystem.Colors.dim

        if text.isEmpty {
            Text(" ")
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
        } else {
            Text(text)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
                .textCase(.uppercase)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - › caret alone (before [BEGIN] resolves)

    private var caretOnlyRow: some View {
        TimelineView(.periodic(from: .now, by: DesignSystem.Blink.phaseSeconds)) { ctx in
            let tick = Int(ctx.date.timeIntervalSinceReferenceDate / DesignSystem.Blink.phaseSeconds)
            Text("›")
                .terminalStyle(
                    size: DesignSystem.Typography.minDimSize,
                    color: DesignSystem.Colors.tappable
                )
                .fixedSize()
                .opacity(tick % 2 == 0 ? 1 : 0)
        }
    }

    // MARK: - › [BEGIN] row

    /// Renders "› [BEGIN]" — the caret blinks (or stays steady under Reduce Motion),
    /// [BEGIN] is always steady in the tappable color.
    @ViewBuilder
    private func beginRow(caretBlinks: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if caretBlinks {
                TimelineView(.periodic(from: .now, by: DesignSystem.Blink.phaseSeconds)) { ctx in
                    let tick = Int(ctx.date.timeIntervalSinceReferenceDate / DesignSystem.Blink.phaseSeconds)
                    Text("› ")
                        .terminalStyle(
                            size: DesignSystem.Typography.minDimSize,
                            color: DesignSystem.Colors.tappable
                        )
                        .fixedSize()
                        .opacity(tick % 2 == 0 ? 1 : 0)
                }
            } else {
                Text("› ")
                    .terminalStyle(
                        size: DesignSystem.Typography.minDimSize,
                        color: DesignSystem.Colors.tappable
                    )
                    .fixedSize()
            }

            Text(Self.beginLabel)
                .terminalStyle(
                    size: DesignSystem.Typography.minDimSize,
                    color: DesignSystem.Colors.tappable
                )
                .fixedSize()
        }
    }

    // MARK: - Blinking cursor

    private var blinkingCursor: some View {
        TimelineView(.periodic(from: .now, by: DesignSystem.Blink.phaseSeconds)) { ctx in
            let tick = Int(ctx.date.timeIntervalSinceReferenceDate / DesignSystem.Blink.phaseSeconds)
            Text("█")
                .terminalStyle(
                    size: DesignSystem.Typography.minDimSize,
                    color: DesignSystem.Colors.tappable
                )
                .fixedSize()
                .opacity(tick % 2 == 0 ? 1 : 0)
        }
    }

    // MARK: - Typewriter engine

    private func startTypewriter() {
        printingTask = Task {
            // Phase 1: block cursor blinks alone
            phase = .headerCursor
            try? await Task.sleep(for: .milliseconds(
                DesignSystem.Typewriter.headerCursorDuration * 1000
            ))
            guard !Task.isCancelled else { return }

            // Phase 2: print physical lines one character at a time
            phase = .printing
            let lines = wrappedLines

            for line in lines {
                guard !Task.isCancelled else { return }

                visibleLineIndex = line.id
                visibleCharInLine = 0

                if line.text.isEmpty {
                    // Authored blank line: hold as its own beat
                    try? await Task.sleep(for: .milliseconds(Self.blankLineBeatMs))
                } else {
                    // Header lines print fast (~40 cps), body lines slower (~20 cps)
                    let delay = line.isBright ? Self.headerCharDelayMs : Self.bodyCharDelayMs

                    for i in 1...line.text.count {
                        guard !Task.isCancelled else { return }
                        visibleCharInLine = i
                        try? await Task.sleep(for: .milliseconds(delay))
                    }

                    // Beat only at authored line endings, not soft-wrap points
                    if line.isAuthoredEnd {
                        try? await Task.sleep(for: .milliseconds(Self.lineEndPauseMs))
                    }
                }
            }

            guard !Task.isCancelled else { return }

            // Phase 3: pause before caret appears
            phase = .closingPause
            try? await Task.sleep(for: .milliseconds(
                DesignSystem.Typewriter.closingPauseMs
            ))

            guard !Task.isCancelled else { return }

            // Phase 4: caret appears and blinks alone
            phase = .caretOnly
            try? await Task.sleep(for: .milliseconds(Self.beginResolveDelayMs))

            guard !Task.isCancelled else { return }

            // Phase 5: [BEGIN] resolves next to the caret
            phase = .complete
        }
    }

    private func skipToComplete() {
        printingTask?.cancel()
        let lines = wrappedLines
        if let last = lines.last {
            visibleLineIndex = last.id
            visibleCharInLine = last.text.count
        }
        phase = .complete
    }
}

#Preview("Briefing — Animated") {
    BriefingView(onBegin: {})
}

#Preview("Briefing — Reduce Motion") {
    BriefingView(onBegin: {}, overrideReduceMotion: true)
}
