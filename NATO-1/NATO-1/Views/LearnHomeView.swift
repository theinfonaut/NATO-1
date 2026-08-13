//
//  LearnHomeView.swift
//  NATO-1
//

import Combine
import SwiftUI

struct LearnHomeView: View {
    @ObservedObject var appState = AppState.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedBatch: Batch?
    @State private var savedSession: LearningSessionState?
    @State private var showingResumeSession = false
    @State private var showingDrillSession = false
    @State private var showingSettings = false
    @State private var showingBriefing = false
    @State private var currentTime = Date()

    // Timer to refresh the "NEXT DRILL IN" countdown every second
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private static let briefingSeenKey = "nato1.briefingSeen"
    private var briefingSeen: Bool {
        UserDefaults.standard.bool(forKey: Self.briefingSeenKey)
    }

    var body: some View {
        // Reading dynamicTypeSize registers the SwiftUI dependency so the
        // body is re-evaluated whenever the user's text size changes.
        let _ = dynamicTypeSize

        GeometryReader { geo in
            let colWidth = DesignSystem.Metrics.columnWidth
            let availableWidth = geo.size.width - 2 * DesignSystem.Metrics.minHorizontalMargin
            let cols = DesignSystem.Metrics.columns(fittingWidth: availableWidth)
            let blockWidth = CGFloat(cols) * colWidth

            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                // Shared blink clock: one time source owns Reduce Motion and
                // provides caretColor (dim↔bright) to all carets on this tab.
                BlinkClock(
                    brightColor: DesignSystem.Colors.tappable,
                    dimColor: DesignSystem.Colors.dim,
                    reduceMotion: reduceMotion
                ) { caretColor in
                    VStack(spacing: 0) {
                        // ── Terminal header ──
                        AppBanner(
                            columns: cols,
                            dimColor: DesignSystem.Colors.dim,
                            tappableColor: DesignSystem.Colors.tappable,
                            showSysSheet: $showingSettings
                        )
                        .padding(.top, 16)

                        ScreenHeader(
                            title: "LEARNING PROTOCOL",
                            columns: cols,
                            dimColor: DesignSystem.Colors.dim
                        )

                        // ── Next-step prompt ──
                        NextStepPrompt(
                            promptState: nextStepState,
                            columns: cols,
                            dimColor: DesignSystem.Colors.dim,
                            tappableColor: DesignSystem.Colors.tappable,
                            caretColor: caretColor,
                            onTap: handlePromptTap
                        )

                        DashedRule(columns: cols, color: DesignSystem.Colors.dim)

                        // ── Scrollable content ──
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(NATOData.batches) { batch in
                                    BatchRow(
                                        batch: batch,
                                        status: batchStatus(for: batch),
                                        columns: cols,
                                        caretColor: caretColor,
                                        onTap: {
                                            let status = batchStatus(for: batch)
                                            guard status == .available || status == .inProgress else { return }
                                            // First-ever Batch 1 tap: show briefing instead
                                            if batch.id == 0 && !briefingSeen {
                                                showingBriefing = true
                                            } else {
                                                selectedBatch = batch
                                            }
                                        }
                                    )
                                    .padding(.vertical, 10)
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        }
                    }
                    .frame(width: blockWidth)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .fullScreenCover(isPresented: $showingSettings, onDismiss: {
            // Reload after Settings dismisses — covers Full Reset and any
            // other settings change that invalidates the saved session.
            savedSession = PersistenceManager.shared.loadLearningSession()
        }) {
            SettingsView()
        }
        .onAppear {
            savedSession = PersistenceManager.shared.loadLearningSession()
            currentTime = Date()
        }
        .onReceive(timer) { time in
            currentTime = time
        }
        .fullScreenCover(item: $selectedBatch, onDismiss: {
            // Refresh saved session state after dismissing
            savedSession = PersistenceManager.shared.loadLearningSession()
        }) { batch in
            NavigationStack {
                LearningSessionView(batch: batch, savedState: savedSessionFor(batch: batch))
            }
        }
        .fullScreenCover(isPresented: $showingResumeSession, onDismiss: {
            savedSession = PersistenceManager.shared.loadLearningSession()
        }) {
            if let session = savedSession,
               let batch = NATOData.batch(at: session.batchIndex) {
                NavigationStack {
                    LearningSessionView(batch: batch, savedState: session)
                }
            }
        }
        .fullScreenCover(isPresented: $showingBriefing) {
            BriefingView(onBegin: {
                UserDefaults.standard.set(true, forKey: Self.briefingSeenKey)
                showingBriefing = false
                // After briefing dismisses, open Batch 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedBatch = NATOData.batches[0]
                }
            })
        }
        .fullScreenCover(isPresented: $showingDrillSession) {
            NavigationStack {
                DrillSessionView()
            }
        }
        // Disable the cover's slide-up transition under Reduce Motion
        .transaction { t in
            if reduceMotion { t.disablesAnimations = true }
        }
    }

    // MARK: - Next-Step State

    /// Priority-ordered prompt state derived from real app state.
    /// 1. Drills due → drill deep-link
    /// 2. Resume saved session → resume fullScreenCover
    /// 3. Begin next batch → start batch (with briefing intercept)
    /// 4. All clear → countdown to next drill
    // Future: UNLOCK state (purchase gate) — no purchase state exists yet.
    private var nextStepState: NextStepPrompt.PromptState {
        // 1. Drills due?
        let dueCount = appState.dueLetterCount
        if dueCount > 0 {
            return .drillDue(count: dueCount)
        }

        // 2. Session to resume?
        if let session = savedSession {
            return .resume(batchNumber: session.batchIndex + 1)
        }

        // 3. Next unlearned batch available?
        if let nextIndex = appState.batchProgress.nextUnlearnedBatchIndex {
            return .beginBatch(number: nextIndex + 1)
        }

        // 4. All clear
        if let nextDate = appState.nextReviewDate {
            let formatted = DesignSystem.timeUntil(nextDate, from: currentTime)
            return .allClear(nextDrillIn: formatted)
        }

        return .allClear(nextDrillIn: nil)
    }

    private func handlePromptTap() {
        switch nextStepState {
        case .drillDue:
            showingDrillSession = true
        case .resume:
            // Re-check persistence before presenting — if the session was
            // deleted (e.g. by a reset) but savedSession is stale, refresh
            // it and bail instead of presenting a broken resume.
            savedSession = PersistenceManager.shared.loadLearningSession()
            guard savedSession != nil else { return }
            showingResumeSession = true
        case .beginBatch(let number):
            let batchIndex = number - 1
            if batchIndex == 0 && !briefingSeen {
                showingBriefing = true
            } else if let batch = NATOData.batch(at: batchIndex) {
                selectedBatch = batch
            }
        case .allClear:
            break // Not tappable
        }
    }

    private func savedSessionFor(batch: Batch) -> LearningSessionState? {
        guard let session = savedSession, session.batchIndex == batch.id else {
            return nil
        }
        return session
    }

    // MARK: - Batch Status

    enum BatchStatus {
        case completed
        case inProgress
        case available
        case locked
    }

    private func batchStatus(for batch: Batch) -> BatchStatus {
        if appState.batchProgress.completedBatchIndices.contains(batch.id) {
            return .completed
        }
        // Check if this batch has a session in progress
        if let session = savedSession, session.batchIndex == batch.id {
            return .inProgress
        }
        // First batch is always available, others require previous batch completed
        if batch.id == 0 {
            return .available
        }
        if appState.batchProgress.completedBatchIndices.contains(batch.id - 1) {
            return .available
        }
        return .locked
    }
}

// MARK: - Batch Row

struct BatchRow: View {
    let batch: Batch
    let status: LearnHomeView.BatchStatus
    let columns: Int
    /// Current caret color from the shared BlinkClock (dim↔bright).
    let caretColor: Color
    let onTap: () -> Void

    // ── Derived properties ──

    private var dimColor: Color { DesignSystem.Colors.dim }
    private var tappableColor: Color { DesignSystem.Colors.tappable }

    /// Letters as a compact display string (e.g. "ABCD").
    private var lettersDisplay: String {
        String(batch.letters.map(\.character))
    }

    /// The display text for the status marker.
    private var markerText: String {
        switch status {
        case .completed:  return "COMPLETE"
        case .available:  return "[LEARN >]"
        case .inProgress: return "[RESUME >]"
        case .locked:     return "[LOCKED]"
        }
    }

    /// Whether the row uses bright/tappable color.
    private var isBright: Bool {
        status == .available || status == .inProgress
    }

    /// Whether the marker has a blinking ">" caret.
    private var hasBlinkingCaret: Bool {
        status == .available || status == .inProgress
    }

    private var rowColor: Color { isBright ? tappableColor : dimColor }
    private var markerColor: Color { isBright ? tappableColor : dimColor }

    // Left side: "BATCH # " + letters + " " (space before leader starts)
    private var nameString: String { "BATCH \(batch.displayNumber) " }
    private var leftText: String { nameString + lettersDisplay + " " }

    // Fixed columns: left text + marker's actual width
    private var fixedColumns: Int { leftText.count + markerText.count }

    // ── Popover state (stub) ──
    @State private var showLockedPopover = false

    var body: some View {
        Button(action: handleTap) {
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
        .popover(isPresented: $showLockedPopover) {
            lockedPopoverContent
        }
    }

    private func handleTap() {
        switch status {
        case .available, .inProgress:
            onTap()
        case .locked:
            showLockedPopover = true
        case .completed:
            break // Not tappable
        }
    }

    // ── Single-line layout ──

    private var singleLineContent: some View {
        // Dot leader fills the gap between left text and the marker.
        // Reserve 1 space before the marker so a dot never sits flush against it.
        let leaderBudget = max(0, columns - fixedColumns)
        let dotBudget = max(0, leaderBudget - 1)
        let dotCount = dotBudget > 0 ? (dotBudget + 1) / 2 : 0
        let dotsColumns = dotCount > 0 ? dotCount * 2 - 1 : 0
        let innerPad = dotBudget - dotsColumns  // 0 or 1 parity leftover absorbed into dots
        let leaderText = dotCount > 0
            ? Array(repeating: ".", count: dotCount).joined(separator: " ")
                + String(repeating: " ", count: innerPad) + " "  // +1 trailing space gap
            : String(repeating: " ", count: leaderBudget)

        // Full line as a single string (dim base layer for dots/spacing)
        let fullLine = leftText + leaderText + markerText

        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(fullLine)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                .textCase(.uppercase)
                .fixedSize()
                // Overlay left text (name + letters) in row color
                .overlay(alignment: .leading) {
                    Text(leftText)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: rowColor)
                        .textCase(.uppercase)
                        .fixedSize()
                }
                // Overlay marker in its color, with blinking caret for actionable states
                .overlay(alignment: .trailing) {
                    markerView
                }
        }
    }

    // ── Marker rendering ──
    // For [LEARN >] and [RESUME >], the ">" blinks while the rest stays steady.
    // For all other markers, the full text renders steady.

    /// The steady text before the blinking ">" in actionable markers.
    private var caretSteadyPrefix: String {
        switch status {
        case .available:  return "[LEARN "
        case .inProgress: return "[RESUME "
        default:          return ""
        }
    }

    @ViewBuilder
    private var markerView: some View {
        if hasBlinkingCaret {
            // Split: steady prefix + blinking ">" + steady "]"
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(caretSteadyPrefix)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: markerColor)
                    .textCase(.uppercase)
                    .fixedSize()
                blinkingCaret
                Text("]")
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: markerColor)
                    .textCase(.uppercase)
                    .fixedSize()
            }
        } else {
            Text(markerText)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: markerColor)
                .textCase(.uppercase)
                .fixedSize()
        }
    }

    /// The ">" caret that blinks inside actionable markers.
    /// Color oscillates dim↔bright via the shared BlinkClock;
    /// Reduce Motion is handled by the clock (steady bright).
    private var blinkingCaret: some View {
        Text(">")
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: caretColor)
            .fixedSize()
    }

    // ── Wrapped layout (Rule 4) ──
    // Two lines, no leader dots. Name + letters on line 1, marker right-aligned on line 2.

    private var wrappedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(nameString)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: rowColor)
                    .textCase(.uppercase)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Text(lettersDisplay)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: rowColor)
                    .textCase(.uppercase)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                if hasBlinkingCaret {
                    markerView
                } else {
                    Text(markerText)
                        .terminalStyle(size: DesignSystem.Typography.minDimSize, color: markerColor)
                        .textCase(.uppercase)
                        .fixedSize()
                }
            }
        }
    }

    // ── Popover content (stub) ──

    private var lockedPopoverContent: some View {
        VStack(spacing: 12) {
            Text("BATCH LOCKED")
                .font(.headline)
            Text("Complete the previous batch first to unlock this one.")
                .font(.body)
                .multilineTextAlignment(.center)
            Button("OK") { showLockedPopover = false }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }

    private var accessibilityLabel: String {
        switch status {
        case .completed:
            return "Batch \(batch.displayNumber), \(lettersDisplay), complete"
        case .available:
            return "Batch \(batch.displayNumber), \(lettersDisplay), learn"
        case .inProgress:
            return "Batch \(batch.displayNumber), \(lettersDisplay), resume"
        case .locked:
            return "Batch \(batch.displayNumber), \(lettersDisplay), locked"
        }
    }
}

// Make BatchStatus accessible to BatchRow
extension LearnHomeView.BatchStatus: Equatable {}

// MARK: - Next-step prompt

/// Smart prompt box driven by real app state.
/// Sits between the screen header and the batch list, separated by a DashedRule below.
struct NextStepPrompt: View {
    let promptState: PromptState
    let columns: Int
    let dimColor: Color
    let tappableColor: Color
    /// Current caret color from the shared BlinkClock (dim↔bright).
    let caretColor: Color
    var onTap: (() -> Void)? = nil

    enum PromptState {
        case drillDue(count: Int)
        case resume(batchNumber: Int)
        case beginBatch(number: Int)
        case allClear(nextDrillIn: String?)
    }

    private var displayText: String {
        switch promptState {
        case .drillDue(let count):
            return "> DRILL [\(count) DUE]"
        case .resume(let batchNumber):
            return "> RESUME BATCH \(batchNumber)"
        case .beginBatch(let number):
            return "> BEGIN BATCH \(number)"
        case .allClear(let nextDrillIn):
            if let time = nextDrillIn {
                return "ALL CLEAR \u{00B7} NEXT DRILL IN \(time)"
            }
            return "ALL CLEAR"
        }
    }

    private var isActionable: Bool {
        switch promptState {
        case .allClear: return false
        default: return true
        }
    }

    /// The ">" prefix for actionable states.
    private var caretPrefix: String { "> " }

    /// The text after the ">" caret for actionable states.
    private var textAfterCaret: String {
        String(displayText.dropFirst(caretPrefix.count))
    }

    var body: some View {
        Button(action: { onTap?() }) {
            if isActionable {
                actionableContent
            } else {
                Text(displayText)
                    .terminalStyle(size: DesignSystem.Typography.minDimSize, color: dimColor)
                    .textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .frame(minHeight: 44)
        .padding(.vertical, 8)
        .disabled(!isActionable)
    }

    private var actionableContent: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(caretPrefix)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: caretColor)
                .fixedSize()

            Text(textAfterCaret)
                .terminalStyle(size: DesignSystem.Typography.minDimSize, color: tappableColor)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dashed rule

/// A full-width horizontal rule built from dashes, filling the given column count.
/// Reused across tabs (headers, separators).
struct DashedRule: View {
    let columns: Int
    let color: Color

    var body: some View {
        Text(String(repeating: "-", count: columns))
            .terminalStyle(size: DesignSystem.Typography.minDimSize, color: color)
            .fixedSize()
    }
}

// MARK: - App banner

/// Top-of-screen identity line shared across all tabs.
/// NATO-1 ----------- [SYS]
/// App name is dim; [SYS] is bright (tappable). Tapping opens the SYS sheet.
struct AppBanner: View {
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

        // Render the full line in dim, then overlay [SYS] in tappable color.
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
/// Reused across tabs — each tab provides its own title.
struct ScreenHeader: View {
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
            DashedRule(columns: columns, color: dimColor)
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

// MARK: - Shared blink clock

/// Single shared time source for all blinking carets on the Learn tab.
/// Owns the Reduce Motion check: when Reduce Motion is on, reports a fixed
/// bright (steady) state — individual carets never check Reduce Motion
/// themselves. Carets blink dim↔bright (never fully hidden).
struct BlinkClock<Content: View>: View {
    let brightColor: Color
    let dimColor: Color
    let reduceMotion: Bool
    @ViewBuilder let content: (_ caretColor: Color) -> Content

    var body: some View {
        if reduceMotion {
            // Reduce Motion: all carets rest steady at bright
            content(brightColor)
        } else {
            TimelineView(.periodic(from: .now, by: DesignSystem.Blink.phaseSeconds)) { ctx in
                let tick = Int(ctx.date.timeIntervalSinceReferenceDate / DesignSystem.Blink.phaseSeconds)
                let color = tick % 2 == 0 ? brightColor : dimColor
                content(color)
            }
        }
    }
}

#Preview {
    LearnHomeView()
}
