//
//  EncodePracticeViewModel.swift
//  NATO-1
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class EncodePracticeViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentWord: EncodeWord?
    @Published private(set) var isRoundComplete = false
    @Published private(set) var showingHint = false
    @Published var input = ""

    // Round stats
    @Published private(set) var correctCount = 0
    @Published private(set) var missedCount = 0

    // MARK: - Internal State

    private var deck: [EncodeWord] = []
    private var resurfaceQueue: [EncodeWord] = []
    private var firstPassComplete = false
    private var missedWords: Set<String> = []

    private let appState = AppState.shared

    // MARK: - Init

    init() {
        startNewRound()
    }

    // MARK: - Round Management

    func startNewRound() {
        let completedBatches = appState.batchProgress.completedBatchIndices
        deck = NATOData.randomEncodeWords(
            count: AppConstants.Drill.encodePracticeRoundSize,
            fromCompletedBatches: completedBatches
        )
        resurfaceQueue = []
        firstPassComplete = false
        missedWords = []
        correctCount = 0
        missedCount = 0
        isRoundComplete = false

        serveNextCard()
    }

    private func serveNextCard() {
        if let word = deck.first {
            currentWord = word
            input = ""
            showingHint = false
        } else if !firstPassComplete {
            firstPassComplete = true
            deck = resurfaceQueue
            resurfaceQueue = []
            serveNextCard()
        } else if let word = deck.first {
            currentWord = word
            input = ""
            showingHint = false
        } else {
            completeRound()
        }
    }

    // MARK: - Answer Handling

    func submitAnswer() {
        guard let word = currentWord else { return }

        let correct = normalizeEncodeAnswer(input) == normalizeEncodeAnswer(word.natoSpelling.joined(separator: " "))

        if correct {
            // Track stats only on first encounter
            if !missedWords.contains(word.word) {
                correctCount += 1
            }
            deck.removeFirst()
            serveNextCard()
        } else {
            // Track miss only once per word
            if !missedWords.contains(word.word) {
                missedWords.insert(word.word)
                missedCount += 1
            }

            showingHint = true

            // Add to resurface queue (only during first pass)
            if !firstPassComplete && !resurfaceQueue.contains(where: { $0.id == word.id }) {
                resurfaceQueue.append(word)
            }

            // Move to back of deck
            deck.removeFirst()
            deck.append(word)
        }
    }

    func dismissHint() {
        showingHint = false
        input = ""
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

    // MARK: - Round Complete

    private func completeRound() {
        currentWord = nil
        isRoundComplete = true
    }

    var wordsRemaining: Int {
        deck.count + resurfaceQueue.count
    }
}
