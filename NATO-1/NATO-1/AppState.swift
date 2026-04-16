//
//  AppState.swift
//  NATO-1
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published private(set) var batchProgress: BatchProgress
    @Published private(set) var letterProgress: [String: LetterProgress]

    private let persistence = PersistenceManager.shared

    private init() {
        self.batchProgress = persistence.loadBatchProgress()
        self.letterProgress = persistence.loadLetterProgress()
    }

    // MARK: - Batch Progress

    func completeBatch(_ batchIndex: Int) {
        batchProgress.completedBatchIndices.insert(batchIndex)
        batchProgress.currentLearningBatchIndex = nil
        persistence.saveBatchProgress(batchProgress)

        // Initialize SRS for letters in this batch
        let batch = NATOData.batches[batchIndex]
        let now = Date()
        let firstReviewDate = now.addingTimeInterval(AppConstants.SRS.tier1Interval)

        for letter in batch.letters {
            let progress = LetterProgress(
                letterId: String(letter.id),
                tier: .learning,
                nextReviewDate: firstReviewDate
            )
            letterProgress[progress.letterId] = progress
        }
        persistence.saveLetterProgress(Array(letterProgress.values))
    }

    func startLearningBatch(_ batchIndex: Int) {
        batchProgress.currentLearningBatchIndex = batchIndex
        persistence.saveBatchProgress(batchProgress)
    }

    // MARK: - Letter Progress

    func recordCorrectAnswer(for letterId: String) {
        guard var progress = letterProgress[letterId] else { return }
        progress.recordCorrectAnswer()
        letterProgress[letterId] = progress
        persistence.updateLetterProgress(progress)
    }

    func recordWrongAnswer(for letterId: String) {
        guard var progress = letterProgress[letterId] else { return }
        progress.recordWrongAnswer()
        letterProgress[letterId] = progress
        persistence.updateLetterProgress(progress)
    }

    func resetSessionPenaltyFlags() {
        var updated: [LetterProgress] = []
        for (id, var progress) in letterProgress {
            progress.resetSessionPenaltyFlag()
            letterProgress[id] = progress
            updated.append(progress)
        }
        persistence.saveLetterProgress(updated)
    }

    // MARK: - Queries

    var dueLetters: [LetterProgress] {
        letterProgress.values.filter { $0.isDue }.sorted { $0.letterId < $1.letterId }
    }

    var dueLetterCount: Int {
        dueLetters.count
    }

    var nextReviewDate: Date? {
        letterProgress.values
            .map { $0.nextReviewDate }
            .min()
    }

    var allLettersMastered: Bool {
        guard letterProgress.count == 26 else { return false }
        return letterProgress.values.allSatisfy { $0.tier == .mastered }
    }

    var unlockedLetterIds: Set<String> {
        Set(letterProgress.keys)
    }

    func tier(for letterId: String) -> SRSTier? {
        letterProgress[letterId]?.tier
    }

    // MARK: - Debug Actions

    func resetAll() {
        persistence.resetAll()
        batchProgress = BatchProgress()
        letterProgress = [:]
    }

    /// Debug: Reset everything, then mark Batch 1 complete with letters due immediately
    func debugJumpToDrilling() {
        // First, wipe all progress
        persistence.resetAll()
        batchProgress = BatchProgress()
        letterProgress = [:]

        // Mark Batch 1 as complete
        batchProgress.completedBatchIndices.insert(0)
        batchProgress.currentLearningBatchIndex = nil
        persistence.saveBatchProgress(batchProgress)

        // Add A, B, C, D to SRS at Tier 1, due now
        let batch = NATOData.batches[0]
        let now = Date()

        for letter in batch.letters {
            let progress = LetterProgress(
                letterId: String(letter.id),
                tier: .learning,
                nextReviewDate: now  // Due immediately
            )
            letterProgress[progress.letterId] = progress
        }
        persistence.saveLetterProgress(Array(letterProgress.values))
    }
}
