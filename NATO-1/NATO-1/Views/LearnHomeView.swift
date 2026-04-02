//
//  LearnHomeView.swift
//  NATO-1
//

import SwiftUI

struct LearnHomeView: View {
    @ObservedObject var appState = AppState.shared
    @State private var selectedBatch: Batch?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Progress summary
                    progressHeader

                    // Batch list
                    VStack(spacing: 12) {
                        ForEach(NATOData.batches) { batch in
                            BatchRow(
                                batch: batch,
                                status: batchStatus(for: batch),
                                onTap: {
                                    if batchStatus(for: batch) == .available {
                                        selectedBatch = batch
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Learn")
            .fullScreenCover(item: $selectedBatch) { batch in
                NavigationStack {
                    LearningSessionView(batch: batch)
                }
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 8) {
            let completed = appState.batchProgress.completedBatchIndices.count
            let total = NATOData.batches.count

            if completed == total {
                Text("All batches complete")
                    .font(.headline)
            } else {
                Text("\(completed) of \(total) batches")
                    .font(.headline)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 8)
                            .cornerRadius(4)
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: geometry.size.width * CGFloat(completed) / CGFloat(total), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Batch Status

    enum BatchStatus {
        case completed
        case available
        case locked
    }

    private func batchStatus(for batch: Batch) -> BatchStatus {
        if appState.batchProgress.completedBatchIndices.contains(batch.id) {
            return .completed
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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Batch number
                Text("\(batch.displayNumber)")
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 40)

                // Letters
                HStack(spacing: 8) {
                    ForEach(batch.letters) { letter in
                        Text(String(letter.character))
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                    }
                }

                Spacer()

                // Status indicator
                statusIndicator
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(status == .locked)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .available:
            Image(systemName: "play.circle.fill")
                .foregroundStyle(.primary)
        case .locked:
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .completed:
            return Color.green.opacity(0.1)
        case .available:
            return Color.primary.opacity(0.1)
        case .locked:
            return Color.primary.opacity(0.05)
        }
    }
}

// Make BatchStatus accessible to BatchRow
extension LearnHomeView.BatchStatus: Equatable {}

#Preview {
    LearnHomeView()
}
