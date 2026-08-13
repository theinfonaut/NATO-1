//
//  DrillHomeView.swift
//  NATO-1
//

import Combine
import SwiftUI

struct DrillHomeView: View {
    @ObservedObject var appState = AppState.shared
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showingDrillSession = false
    @State private var showingEncodePractice = false
    @State private var showingSettings = false
    @State private var currentTime = Date()

    // Timer to refresh the view every second
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let _ = dynamicTypeSize

        GeometryReader { geo in
            let availableWidth = geo.size.width - 2 * DesignSystem.Metrics.minHorizontalMargin
            let cols = DesignSystem.Metrics.columns(fittingWidth: availableWidth)
            let blockWidth = CGFloat(cols) * DesignSystem.Metrics.columnWidth

            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

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
                        title: "DRILL",
                        columns: cols,
                        dimColor: DesignSystem.Colors.dim
                    )

                    // ── Existing content ──
                    VStack(spacing: 0) {
                        // Subtitle
                        Text("Drill at increasing intervals to encode it into permanent memory.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 24)

                        Spacer()

                        if appState.dueLetterCount > 0 {
                            dueStateView
                        } else if appState.letterProgress.isEmpty {
                            emptyStateView
                        } else {
                            allClearStateView
                        }

                        Spacer()
                    }
                    .padding()
                }
                .frame(width: blockWidth)
                .frame(maxWidth: .infinity)
            }
        }
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
        .onReceive(timer) { time in
            currentTime = time
        }
        .onAppear {
            currentTime = Date()
        }
        .fullScreenCover(isPresented: $showingDrillSession) {
            NavigationStack {
                DrillSessionView()
            }
        }
        .fullScreenCover(isPresented: $showingEncodePractice) {
            NavigationStack {
                EncodePracticeView()
            }
        }
    }

    // MARK: - Due State

    private var dueStateView: some View {
        VStack(spacing: 24) {
            // Due count
            VStack(spacing: 4) {
                Text("\(appState.dueLetterCount)")
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                Text(appState.dueLetterCount == 1 ? "card due" : "cards due")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Letter chips
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
                ForEach(appState.dueLetters, id: \.letterId) { progress in
                    Text(progress.letterId)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .frame(width: 44, height: 44)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            // Start button
            Button {
                showingDrillSession = true
            } label: {
                Text("Start Drill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No letters yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Complete a learning session to start drilling")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - All Clear State

    private var allClearStateView: some View {
        VStack(spacing: 24) {
            Text("All clear")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let nextReview = appState.nextReviewDate {
                VStack(spacing: 4) {
                    Text("Next review")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeUntil(nextReview))
                        .font(.system(.headline, design: .monospaced))
                }
            }

            // Unlocked letters count
            VStack(spacing: 4) {
                Text("\(appState.letterProgress.count)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                Text("letters unlocked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)

            // Encode practice button
            Button {
                showingEncodePractice = true
            } label: {
                Text("Encode Practice")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }

    // MARK: - Helpers

    private func timeUntil(_ date: Date) -> String {
        DesignSystem.timeUntil(date, from: currentTime)
    }
}

#Preview {
    DrillHomeView()
}
