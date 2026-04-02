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
    @Published var input = ""

    // Session stats
    @Published private(set) var totalCards: Int = 0
    @Published private(set) var completedCards: Int = 0

    // MARK: - Internal State

    private var letterQueue: [String] = []
    private var resurfaceQueue: [String] = []
    private var encodeQueue: [EncodeWord] = []
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
        resurfaceQueue = []
        penalizedLetters = []
        lettersAnsweredCount = 0

        // Generate encode cards based on frequency
        let encodeCount = max(1, dueLetters.count / AppConstants.Drill.encodeCardFrequency)
        let completedBatches = appState.batchProgress.completedBatchIndices
        encodeQueue = NATOData.randomEncodeWords(count: encodeCount, fromCompletedBatches: completedBatches)

        totalCards = letterQueue.count + encodeQueue.count
        completedCards = 0

        serveNextCard()
    }

    // MARK: - Card Serving

    private func serveNextCard() {
        // Check if it's time for an encode card
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

        // Serve from resurface queue
        if let letterId = resurfaceQueue.first {
            currentCard = .letter(letterId)
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

        // Remove from queue
        if let index = letterQueue.firstIndex(of: letterId) {
            letterQueue.remove(at: index)
        } else if let index = resurfaceQueue.firstIndex(of: letterId) {
            resurfaceQueue.remove(at: index)
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

        // Show correct answer
        showingCorrectAnswer = true

        // Move to resurface queue if in main queue
        if let index = letterQueue.firstIndex(of: letterId) {
            letterQueue.remove(at: index)
            if !resurfaceQueue.contains(letterId) {
                resurfaceQueue.append(letterId)
            }
        }
        // If already in resurface queue, move to back
        else if let index = resurfaceQueue.firstIndex(of: letterId) {
            resurfaceQueue.remove(at: index)
            resurfaceQueue.append(letterId)
        }
    }

    func dismissCorrectAnswer() {
        showingCorrectAnswer = false
        input = ""
        serveNextCard()
    }

    // MARK: - Encode Card Handling

    func submitEncodeAnswer() {
        guard case .encode(let word) = currentCard,
              let encodeWord = encodeQueue.first(where: { $0.word == word }) else { return }

        let correct = normalizeEncodeAnswer(input) == normalizeEncodeAnswer(encodeWord.natoSpelling.joined(separator: " "))

        if correct {
            encodeQueue.removeFirst()
            completedCards += 1
            serveNextCard()
        } else {
            showingEncodeHint = true
            // Move to back of queue
            encodeQueue.removeFirst()
            encodeQueue.append(encodeWord)
        }
    }

    func dismissEncodeHint() {
        showingEncodeHint = false
        input = ""
        serveNextCard()
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
        let alreadyQueued = Set(letterQueue + resurfaceQueue + penalizedLetters)
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
        letterQueue.count + resurfaceQueue.count + encodeQueue.count
    }

    // MARK: - Current Card Helpers

    var currentLetter: Letter? {
        guard case .letter(let letterId) = currentCard else { return nil }
        return NATOData.letter(forId: letterId)
    }

    var currentEncodeWord: EncodeWord? {
        guard case .encode(let word) = currentCard else { return nil }
        return encodeQueue.first { $0.word == word }
    }
}
