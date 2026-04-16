//
//  DrillSessionViewModel.swift
//  NATO-1
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class DrillSessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentCard: DrillCard?
    @Published private(set) var isSessionComplete = false
    @Published private(set) var showingCorrectAnswer = false
    @Published private(set) var showingEncodeHint = false
    @Published private(set) var lastWrongAnswer = ""  // What the user typed
    @Published var input = ""

    // Session stats
    @Published private(set) var totalCards: Int = 0
    @Published private(set) var completedCards: Int = 0

    // MARK: - Internal State

    private var letterQueue: [String] = []
    private var letterResurfaceQueue: [String] = []
    private var letterCurrentCardHadWrongAnswer = false

    private var encodeQueue: [EncodeWord] = []
    private var encodeResurfaceQueue: [EncodeWord] = []
    private var encodeCurrentCardHadWrongAnswer = false

    private var lettersAnsweredCount: Int = 0
    private var penalizedLetters: Set<String> = []

    private let appState = AppState.shared

    // MARK: - Init

    init() {
        loadDueCards()
    }

    private func loadDueCards() {
        // Get all due letters
        let dueLetters = appState.dueLetters.map { $0.letterId }
        letterQueue = dueLetters.shuffled()
        letterResurfaceQueue = []
        letterCurrentCardHadWrongAnswer = false
        penalizedLetters = []
        lettersAnsweredCount = 0

        // Generate encode cards based on frequency
        let encodeCount = max(1, dueLetters.count / AppConstants.Drill.encodeCardFrequency)
        let completedBatches = appState.batchProgress.completedBatchIndices
        encodeQueue = NATOData.randomEncodeWords(count: encodeCount, fromCompletedBatches: completedBatches)
        encodeResurfaceQueue = []
        encodeCurrentCardHadWrongAnswer = false

        totalCards = letterQueue.count + encodeQueue.count
        completedCards = 0

        serveNextCard()
    }

    // MARK: - Card Serving

    private func serveNextCard() {
        letterCurrentCardHadWrongAnswer = false
        encodeCurrentCardHadWrongAnswer = false

        // Check if it's time for an encode card (from main queue)
        if lettersAnsweredCount > 0 &&
           lettersAnsweredCount % AppConstants.Drill.encodeCardFrequency == 0 &&
           !encodeQueue.isEmpty {
            currentCard = .encode(encodeQueue.first!.word)
            input = ""
            showingCorrectAnswer = false
            showingEncodeHint = false
            return
        }

        // Serve from letter queue
        if let letterId = letterQueue.first {
            currentCard = .letter(letterId)
            input = ""
            showingCorrectAnswer = false
            showingEncodeHint = false
            return
        }

        // Serve from letter resurface queue
        if let letterId = letterResurfaceQueue.first {
            currentCard = .letter(letterId)
            input = ""
            showingCorrectAnswer = false
            showingEncodeHint = false
            return
        }

        // Serve remaining encode cards from main queue
        if let encodeWord = encodeQueue.first {
            currentCard = .encode(encodeWord.word)
            input = ""
            showingCorrectAnswer = false
            showingEncodeHint = false
            return
        }

        // Serve from encode resurface queue
        if let encodeWord = encodeResurfaceQueue.first {
            currentCard = .encode(encodeWord.word)
            input = ""
            showingCorrectAnswer = false
            showingEncodeHint = false
            return
        }

        // Session complete
        completeSession()
    }

    // MARK: - Letter Card Handling

    func submitLetterAnswer() {
        guard case .letter(let letterId) = currentCard,
              let letter = NATOData.letter(forId: letterId) else { return }

        let correct = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == letter.natoWord.lowercased()

        if correct {
            handleCorrectLetterAnswer(letterId: letterId)
        } else {
            handleWrongLetterAnswer(letterId: letterId)
        }
    }

    private func handleCorrectLetterAnswer(letterId: String) {
        // Update SRS
        appState.recordCorrectAnswer(for: letterId)

        // Remove from whichever queue it's in
        if let index = letterQueue.firstIndex(of: letterId) {
            letterQueue.remove(at: index)
            // Add to resurface if had wrong answer
            if letterCurrentCardHadWrongAnswer {
                letterResurfaceQueue.append(letterId)
            }
        } else if let index = letterResurfaceQueue.firstIndex(of: letterId) {
            letterResurfaceQueue.remove(at: index)
        }

        lettersAnsweredCount += 1
        completedCards += 1

        // Check if new cards became due during session
        checkForNewDueCards()

        serveNextCard()
    }

    private func handleWrongLetterAnswer(letterId: String) {
        // Apply tier penalty (once per session per card)
        if !penalizedLetters.contains(letterId) {
            appState.recordWrongAnswer(for: letterId)
            penalizedLetters.insert(letterId)
        }

        // Mark that this card had a wrong answer
        letterCurrentCardHadWrongAnswer = true

        // Store what the user typed
        lastWrongAnswer = input

        // Show correct answer
        showingCorrectAnswer = true
    }

    func dismissCorrectAnswer() {
        showingCorrectAnswer = false
        input = ""
        // Stay on the same card for retry (don't call serveNextCard)
    }

    // MARK: - Encode Card Handling

    func submitEncodeAnswer() {
        guard case .encode(let word) = currentCard else { return }

        // Find the encode word in either queue
        let encodeWord: EncodeWord?
        if let found = encodeQueue.first(where: { $0.word == word }) {
            encodeWord = found
        } else {
            encodeWord = encodeResurfaceQueue.first(where: { $0.word == word })
        }

        guard let encodeWord = encodeWord else { return }

        let correct = normalizeEncodeAnswer(input) == normalizeEncodeAnswer(encodeWord.natoSpelling.joined(separator: " "))

        if correct {
            // Remove from whichever queue it's in
            if let index = encodeQueue.firstIndex(where: { $0.word == word }) {
                encodeQueue.remove(at: index)
                // Add to resurface if had wrong answer
                if encodeCurrentCardHadWrongAnswer {
                    encodeResurfaceQueue.append(encodeWord)
                }
            } else if let index = encodeResurfaceQueue.firstIndex(where: { $0.word == word }) {
                encodeResurfaceQueue.remove(at: index)
            }
            completedCards += 1
            serveNextCard()
        } else {
            // Mark that this card had a wrong answer
            encodeCurrentCardHadWrongAnswer = true

            // Store what the user typed
            lastWrongAnswer = input

            showingEncodeHint = true
        }
    }

    func dismissEncodeHint() {
        showingEncodeHint = false
        input = ""
        // Stay on the same card for retry (don't call serveNextCard)
    }

    private func normalizeEncodeAnswer(_ input: String) -> String {
        let separators = CharacterSet(charactersIn: " -.,·")
        return input
            .lowercased()
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    // MARK: - New Due Cards

    private func checkForNewDueCards() {
        let currentDue = Set(appState.dueLetters.map { $0.letterId })
        let alreadyQueued = Set(letterQueue + letterResurfaceQueue + penalizedLetters)
        let newDue = currentDue.subtracting(alreadyQueued)

        if !newDue.isEmpty {
            letterQueue.append(contentsOf: newDue.shuffled())
            totalCards += newDue.count
        }
    }

    // MARK: - Session Complete

    private func completeSession() {
        currentCard = nil
        isSessionComplete = true
        appState.resetSessionPenaltyFlags()
    }

    var cardsRemaining: Int {
        letterQueue.count + letterResurfaceQueue.count + encodeQueue.count + encodeResurfaceQueue.count
    }

    // MARK: - Current Card Helpers

    var currentLetter: Letter? {
        guard case .letter(let letterId) = currentCard else { return nil }
        return NATOData.letter(forId: letterId)
    }

    var currentEncodeWord: EncodeWord? {
        guard case .encode(let word) = currentCard else { return nil }
        if let found = encodeQueue.first(where: { $0.word == word }) {
            return found
        }
        return encodeResurfaceQueue.first(where: { $0.word == word })
    }
}
