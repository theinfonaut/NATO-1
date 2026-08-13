//
//  ContentView.swift
//  NATO-1
//
//  Created by Leslie Chicoine on 4/1/26.
//

import SwiftUI

// MARK: - App tab model

enum AppTab: String, CaseIterable {
    case learn, drill, codex

    var label: String {
        switch self {
        case .learn: return "[LEARN]"
        case .drill: return "[DRILL]"
        case .codex: return "[CODEX]"
        }
    }
}

// MARK: - Root view

struct ContentView: View {
    @State private var selectedTab: AppTab = .learn
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let _ = dynamicTypeSize

        GeometryReader { geo in
            let availableWidth = geo.size.width - 2 * DesignSystem.Metrics.minHorizontalMargin
            let cols = DesignSystem.Metrics.columns(fittingWidth: availableWidth)
            let blockWidth = CGFloat(cols) * DesignSystem.Metrics.columnWidth

            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab content — all three stay alive, opacity-switched
                    ZStack {
                        LearnHomeView()
                            .zIndex(selectedTab == .learn ? 1 : 0)
                            .opacity(selectedTab == .learn ? 1 : 0)
                            .allowsHitTesting(selectedTab == .learn)
                        DrillHomeView()
                            .zIndex(selectedTab == .drill ? 1 : 0)
                            .opacity(selectedTab == .drill ? 1 : 0)
                            .allowsHitTesting(selectedTab == .drill)
                        CodexView()
                            .zIndex(selectedTab == .codex ? 1 : 0)
                            .opacity(selectedTab == .codex ? 1 : 0)
                            .allowsHitTesting(selectedTab == .codex)
                    }

                    // Terminal tab bar
                    TerminalTabBar(
                        columns: cols,
                        selectedTab: $selectedTab
                    )
                    .frame(width: blockWidth)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Terminal tab bar

/// Bracketed text tab bar in terminal style. Replaces the system UITabBar.
/// Selected tab renders as a chip (background-on-dim); unselected tabs are
/// bright/tappable text. A dashed rule separates the bar from content above.
struct TerminalTabBar: View {
    let columns: Int
    @Binding var selectedTab: AppTab

    // Minimum columns: all three labels + 1 space between each pair
    private static let minSingleLineColumns: Int = {
        AppTab.allCases.map(\.label.count).reduce(0, +) + (AppTab.allCases.count - 1)
    }()

    private var fitsOnOneLine: Bool { columns >= Self.minSingleLineColumns }

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 0) {
            DashedRule(columns: columns, color: DesignSystem.Colors.dim)
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
    private func tabButton(for tab: AppTab) -> some View {
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
                        backgroundColor: DesignSystem.Colors.dim
                    )
            } else {
                Text(tab.label)
                    .terminalStyle(
                        size: DesignSystem.Typography.minDimSize,
                        color: DesignSystem.Colors.tappable
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

#Preview {
    ContentView()
}
