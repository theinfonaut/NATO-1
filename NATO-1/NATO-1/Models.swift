//
//  Models.swift
//  NATO-1
//

import Foundation

// MARK: - SRS Tier

enum SRSTier: Int, Codable, CaseIterable {
    case learning = 1
    case familiar = 2
    case confident = 3
    case mastered = 4

    var name: String {
        switch self {
        case .learning: return "Learning"
        case .familiar: return "Familiar"
        case .confident: return "Confident"
        case .mastered: return "Mastered"
        }
    }

    var interval: TimeInterval {
        AppConstants.SRS.interval(for: rawValue)
    }

    var tierAfterWrongAnswer: SRSTier {
        switch self {
        case .learning: return .learning  // Stay at tier 1, just reset timer
        case .familiar: return .learning
        case .confident: return .familiar
        case .mastered: return .confident
        }
    }

    var nextTier: SRSTier? {
        switch self {
        case .learning: return .familiar
        case .familiar: return .confident
        case .confident: return .mastered
        case .mastered: return nil
        }
    }
}

// MARK: - Letter

struct Letter: Identifiable, Hashable {
    let id: Character
    let natoWord: String
    let emoji: String
    let mnemonic: String
    let batchIndex: Int

    var character: Character { id }
}

// MARK: - Batch

struct Batch: Identifiable {
    let id: Int  // 0-indexed
    let letters: [Letter]
    let encodeWords: [EncodeWord]

    var displayNumber: Int { id + 1 }  // 1-indexed for display
    var isFree: Bool { id == AppConstants.freeBatchIndex }
}

// MARK: - Encode Word

struct EncodeWord: Identifiable, Hashable {
    let id: String  // The word itself
    let natoSpelling: [String]  // Array of NATO words

    var word: String { id }

    var formattedSpelling: String {
        natoSpelling.joined(separator: " - ")
    }
}

// MARK: - Letter Progress (SRS State)

struct LetterProgress: Codable, Identifiable {
    let letterId: String  // Single character stored as String for Codable
    var tier: SRSTier
    var nextReviewDate: Date
    var penalizedThisSession: Bool = false  // Tracks one-penalty-per-session rule

    var id: String { letterId }

    var character: Character { letterId.first! }

    var isDue: Bool {
        Date() >= nextReviewDate
    }

    mutating func recordCorrectAnswer() {
        if let next = tier.nextTier {
            tier = next
        }
        nextReviewDate = Date().addingTimeInterval(tier.interval)
        penalizedThisSession = false
    }

    mutating func recordWrongAnswer() {
        if !penalizedThisSession {
            tier = tier.tierAfterWrongAnswer
            penalizedThisSession = true
        }
        // Timer resets regardless of penalty
        nextReviewDate = Date().addingTimeInterval(tier.interval)
    }

    mutating func resetSessionPenaltyFlag() {
        penalizedThisSession = false
    }
}

// MARK: - Batch Progress

struct BatchProgress: Codable {
    var completedBatchIndices: Set<Int> = []
    var currentLearningBatchIndex: Int? = nil  // nil if not mid-learning

    var nextUnlearnedBatchIndex: Int? {
        for i in 0..<NATOData.batches.count {
            if !completedBatchIndices.contains(i) {
                return i
            }
        }
        return nil
    }

    var unlockedLetters: [Letter] {
        completedBatchIndices.sorted().flatMap { NATOData.batches[$0].letters }
    }

    var allBatchesCompleted: Bool {
        completedBatchIndices.count == NATOData.batches.count
    }
}

// MARK: - Learning Session State

enum LearningStep: Codable {
    case meet(currentIndex: Int)
    case quiz
    case encode
    case complete
}

struct LearningSessionState: Codable {
    let batchIndex: Int
    var currentStep: LearningStep
    var quizDeck: [String]  // Letter IDs remaining in quiz
    var quizResurfaceQueue: [String]  // Letter IDs to resurface after first pass
    var encodeDeck: [String]  // Words remaining in encode
    var encodeResurfaceQueue: [String]  // Words to resurface
}

// MARK: - Drill Session State

struct DrillSessionState {
    var letterQueue: [String]  // Letter IDs to drill
    var resurfaceQueue: [String]  // Letter IDs that need another attempt
    var encodeQueue: [String]  // Encode words to show
    var lettersAnsweredCount: Int = 0  // For tracking encode frequency
    var penalizedLetters: Set<String> = []  // One penalty per card per session

    var currentCard: DrillCard? {
        // Check if it's time for an encode card
        if lettersAnsweredCount > 0 &&
           lettersAnsweredCount % AppConstants.Drill.encodeCardFrequency == 0 &&
           !encodeQueue.isEmpty {
            return .encode(encodeQueue.first!)
        }
        // Otherwise, serve a letter card
        if let letter = letterQueue.first {
            return .letter(letter)
        }
        // Resurface queue
        if let letter = resurfaceQueue.first {
            return .letter(letter)
        }
        return nil
    }

    var isComplete: Bool {
        letterQueue.isEmpty && resurfaceQueue.isEmpty
    }
}

enum DrillCard {
    case letter(String)  // Letter ID
    case encode(String)  // Encode word
}
