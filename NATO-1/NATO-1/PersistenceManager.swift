//
//  PersistenceManager.swift
//  NATO-1
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let batchProgress = "nato1.batchProgress"
        static let letterProgress = "nato1.letterProgress"
        static let learningSession = "nato1.learningSession"
    }

    private init() {}

    // MARK: - Batch Progress

    func saveBatchProgress(_ progress: BatchProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            defaults.set(data, forKey: Keys.batchProgress)
        }
    }

    func loadBatchProgress() -> BatchProgress {
        guard let data = defaults.data(forKey: Keys.batchProgress),
              let progress = try? JSONDecoder().decode(BatchProgress.self, from: data) else {
            return BatchProgress()
        }
        return progress
    }

    // MARK: - Letter Progress

    func saveLetterProgress(_ progressList: [LetterProgress]) {
        if let data = try? JSONEncoder().encode(progressList) {
            defaults.set(data, forKey: Keys.letterProgress)
        }
    }

    func loadLetterProgress() -> [String: LetterProgress] {
        guard let data = defaults.data(forKey: Keys.letterProgress),
              let progressList = try? JSONDecoder().decode([LetterProgress].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: progressList.map { ($0.letterId, $0) })
    }

    // MARK: - Convenience

    func letterProgress(for letterId: String) -> LetterProgress? {
        loadLetterProgress()[letterId]
    }

    func updateLetterProgress(_ progress: LetterProgress) {
        var all = loadLetterProgress()
        all[progress.letterId] = progress
        saveLetterProgress(Array(all.values))
    }

    func updateLetterProgressBatch(_ progressList: [LetterProgress]) {
        var all = loadLetterProgress()
        for progress in progressList {
            all[progress.letterId] = progress
        }
        saveLetterProgress(Array(all.values))
    }

    // MARK: - Learning Session

    func saveLearningSession(_ session: LearningSessionState?) {
        if let session = session,
           let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: Keys.learningSession)
        } else {
            defaults.removeObject(forKey: Keys.learningSession)
        }
    }

    func loadLearningSession() -> LearningSessionState? {
        guard let data = defaults.data(forKey: Keys.learningSession),
              let session = try? JSONDecoder().decode(LearningSessionState.self, from: data) else {
            return nil
        }
        return session
    }

    func clearLearningSession() {
        defaults.removeObject(forKey: Keys.learningSession)
    }

    // MARK: - Reset (for testing)

    func resetAll() {
        defaults.removeObject(forKey: Keys.batchProgress)
        defaults.removeObject(forKey: Keys.letterProgress)
        defaults.removeObject(forKey: Keys.learningSession)
    }
}
