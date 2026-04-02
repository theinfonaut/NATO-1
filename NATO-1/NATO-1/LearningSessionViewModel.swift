//
//  LearningSessionViewModel.swift
//  NATO-1
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class LearningSessionViewModel: ObservableObject {
    let batch: Batch

    // MARK: - Published State

    @Published private(set) var currentStep: LearningStep = .meet(currentIndex: 0)
    @Published private(set) var isSessionComplete = false

    // Quiz state
    @Published private(set) var currentQuizLetter: Letter?
    @Published private(set) var quizShowingCorrectAnswer = false
    @Published var quizInput = ""

    // Encode state
    @Published private(set) var currentEncodeWord: EncodeWord?
    @Published private(set) var encodeShowingHint = false
    @Published var encodeInput = ""

    // MARK: - Internal State

    private var quizDeck: [Letter] = []
    private var quizResurfaceQueue: [Letter] = []
    private var quizFirstPassComplete = false

    private var encodeDeck: [EncodeWord] = []
    private var encodeResurfaceQueue: [EncodeWord] = []
    private var encodeFirstPassComplete = false

    // MARK: - Init

    init(batch: Batch) {
        self.batch = batch
    }

    // MARK: - Meet Step

    var currentMeetLetter: Letter? {
        guard case .meet(let index) = currentStep else { return nil }
        guard index < batch.letters.count else { return nil }
        return batch.letters[index]
    }

    var meetProgress: (current: Int, total: Int) {
        guard case .meet(let index) = currentStep else { return (0, batch.letters.count) }
        return (index + 1, batch.letters.count)
    }

    func advanceMeet() {
        guard case .meet(let index) = currentStep else { return }
        let nextIndex = index + 1
        if nextIndex < batch.letters.count {
            currentStep = .meet(currentIndex: nextIndex)
        } else {
            startQuiz()
        }
    }

    // MARK: - Quiz Step

    private func startQuiz() {
        quizDeck = batch.letters.shuffled()
        quizResurfaceQueue = []
        quizFirstPassComplete = false
        currentStep = .quiz
        serveNextQuizCard()
    }

    private func serveNextQuizCard() {
        if let letter = quizDeck.first {
            currentQuizLetter = letter
            quizInput = ""
            quizShowingCorrectAnswer = false
        } else if !quizFirstPassComplete {
            // First pass done, move resurface queue to deck
            quizFirstPassComplete = true
            quizDeck = quizResurfaceQueue
            quizResurfaceQueue = []
            serveNextQuizCard()
        } else if let letter = quizDeck.first {
            // Serving from what was the resurface queue
            currentQuizLetter = letter
            quizInput = ""
            quizShowingCorrectAnswer = false
        } else {
            // Quiz complete
            startEncode()
        }
    }

    func submitQuizAnswer() {
        guard let letter = currentQuizLetter else { return }

        let correct = quizInput.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == letter.natoWord.lowercased()

        if correct {
            quizDeck.removeFirst()
            serveNextQuizCard()
        } else {
            // Show correct answer briefly
            quizShowingCorrectAnswer = true

            // Add to resurface queue (only during first pass)
            if !quizFirstPassComplete && !quizResurfaceQueue.contains(where: { $0.id == letter.id }) {
                quizResurfaceQueue.append(letter)
            }

            // Move to back of deck
            quizDeck.removeFirst()
            quizDeck.append(letter)
        }
    }

    func dismissQuizCorrectAnswer() {
        quizShowingCorrectAnswer = false
        quizInput = ""
    }

    var quizCardsRemaining: Int {
        quizDeck.count + quizResurfaceQueue.count
    }

    // MARK: - Encode Step

    private func startEncode() {
        encodeDeck = Array(batch.encodeWords.shuffled())
        encodeResurfaceQueue = []
        encodeFirstPassComplete = false
        currentStep = .encode
        serveNextEncodeCard()
    }

    private func serveNextEncodeCard() {
        if let word = encodeDeck.first {
            currentEncodeWord = word
            encodeInput = ""
            encodeShowingHint = false
        } else if !encodeFirstPassComplete {
            // First pass done, move resurface queue to deck
            encodeFirstPassComplete = true
            encodeDeck = encodeResurfaceQueue
            encodeResurfaceQueue = []
            serveNextEncodeCard()
        } else if let word = encodeDeck.first {
            currentEncodeWord = word
            encodeInput = ""
            encodeShowingHint = false
        } else {
            // Encode complete
            completeSession()
        }
    }

    func submitEncodeAnswer() {
        guard let word = currentEncodeWord else { return }

        let correct = normalizeEncodeAnswer(encodeInput) == normalizeEncodeAnswer(word.natoSpelling.joined(separator: " "))

        if correct {
            encodeDeck.removeFirst()
            serveNextEncodeCard()
        } else {
            // Show hint briefly
            encodeShowingHint = true

            // Add to resurface queue (only during first pass)
            if !encodeFirstPassComplete && !encodeResurfaceQueue.contains(where: { $0.id == word.id }) {
                encodeResurfaceQueue.append(word)
            }

            // Move to back of deck
            encodeDeck.removeFirst()
            encodeDeck.append(word)
        }
    }

    func dismissEncodeHint() {
        encodeShowingHint = false
        encodeInput = ""
    }

    var encodeCardsRemaining: Int {
        encodeDeck.count + encodeResurfaceQueue.count
    }

    private func normalizeEncodeAnswer(_ input: String) -> String {
        // Accept space, dash, dot, or comma as separators
        // Normalize to lowercase, split on separators, filter empty, join with space
        let separators = CharacterSet(charactersIn: " -.,·")
        return input
            .lowercased()
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    // MARK: - Complete

    private func completeSession() {
        currentStep = .complete
        AppState.shared.completeBatch(batch.id)
        isSessionComplete = true
    }

    var nextReviewDate: Date {
        Date().addingTimeInterval(AppConstants.SRS.tier1Interval)
    }

    var nextReviewTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: nextReviewDate, relativeTo: Date())
    }
}
