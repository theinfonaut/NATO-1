//
//  LearnHomeView.swift
//  NATO-1
//

import SwiftUI

struct LearnHomeView: View {
    @ObservedObject var appState = AppState.shared
    @State private var selectedBatch: Batch?
    @State private var savedSession: LearningSessionState?
    @State private var showingResumeSession = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Resume banner if session in progress
                    if let session = savedSession {
                        resumeBanner(for: session)
                    }

                    // Progress summary
                    progressHeader

                    // Batch list
                    VStack(spacing: 12) {
                        ForEach(NATOData.batches) { batch in
                            BatchRow(
                                batch: batch,
                                status: batchStatus(for: batch),
                                onTap: {
                                    if batchStatus(for: batch) == .available ||
                                       batchStatus(for: batch) == .inProgress {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                savedSession = PersistenceManager.shared.loadLearningSession()
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
        }
    }

    // MARK: - Resume Banner

    private func resumeBanner(for session: LearningSessionState) -> some View {
        Button {
            showingResumeSession = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session in progress")
                        .font(.headline)
                    Text("Batch \(session.batchIndex + 1) — \(stepName(for: session.currentStep))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Resume")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primary)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.orange.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private func stepName(for step: LearningStep) -> String {
        switch step {
        case .meet: return "Meet"
        case .quiz: return "Quiz"
        case .encode: return "Encode"
        case .complete: return "Complete"
        }
    }

    private func savedSessionFor(batch: Batch) -> LearningSessionState? {
        guard let session = savedSession, session.batchIndex == batch.id else {
            return nil
        }
        return session
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
        case .inProgress:
            Image(systemName: "play.circle.fill")
                .foregroundStyle(.orange)
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
        case .inProgress:
            return Color.orange.opacity(0.1)
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
