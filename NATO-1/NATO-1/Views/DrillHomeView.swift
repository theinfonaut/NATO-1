//
//  DrillHomeView.swift
//  NATO-1
//

import SwiftUI

struct DrillHomeView: View {
    @ObservedObject var appState = AppState.shared
    @State private var showingDrillSession = false
    @State private var showingEncodePractice = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
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
            .navigationTitle("Drill")
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
                    Text(nextReview, style: .relative)
                        .font(.headline)
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
}

#Preview {
    DrillHomeView()
}
