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
    private var quizCurrentCardHadWrongAnswer = false

    private var encodeDeck: [EncodeWord] = []
    private var encodeResurfaceQueue: [EncodeWord] = []
    private var encodeFirstPassComplete = false
    private var encodeCurrentCardHadWrongAnswer = false

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
        quizCurrentCardHadWrongAnswer = false
        currentStep = .quiz
        serveNextQuizCard()
    }

    private func serveNextQuizCard() {
        quizCurrentCardHadWrongAnswer = false

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
            // Add to resurface queue if had wrong answer (only during first pass)
            if !quizFirstPassComplete && quizCurrentCardHadWrongAnswer {
                quizResurfaceQueue.append(letter)
            }
            quizDeck.removeFirst()
            serveNextQuizCard()
        } else {
            // Mark that this card had a wrong answer
            quizCurrentCardHadWrongAnswer = true
            // Show correct answer
            quizShowingCorrectAnswer = true
        }
    }

    func dismissQuizCorrectAnswer() {
        // Stay on the same card, just clear input for retry
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
        encodeCurrentCardHadWrongAnswer = false
        currentStep = .encode
        serveNextEncodeCard()
    }

    private func serveNextEncodeCard() {
        encodeCurrentCardHadWrongAnswer = false

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
        } else {
            // Encode complete
            completeSession()
        }
    }

    func submitEncodeAnswer() {
        guard let word = currentEncodeWord else { return }

        let correct = normalizeEncodeAnswer(encodeInput) == normalizeEncodeAnswer(word.natoSpelling.joined(separator: " "))

        if correct {
            // Add to resurface queue if had wrong answer (only during first pass)
            if !encodeFirstPassComplete && encodeCurrentCardHadWrongAnswer {
                encodeResurfaceQueue.append(word)
            }
            encodeDeck.removeFirst()
            serveNextEncodeCard()
        } else {
            // Mark that this card had a wrong answer
            encodeCurrentCardHadWrongAnswer = true
            // Show hint
            encodeShowingHint = true
        }
    }

    func dismissEncodeHint() {
        // Stay on the same card, just clear input for retry
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
