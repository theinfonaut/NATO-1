//
//  LearningSessionView.swift
//  NATO-1
//

import SwiftUI

struct LearningSessionView: View {
    @StateObject private var viewModel: LearningSessionViewModel
    @Environment(\.dismiss) private var dismiss

    init(batch: Batch, savedState: LearningSessionState? = nil) {
        if let savedState = savedState,
           let restored = LearningSessionViewModel(savedState: savedState) {
            _viewModel = StateObject(wrappedValue: restored)
        } else {
            _viewModel = StateObject(wrappedValue: LearningSessionViewModel(batch: batch))
        }
    }

    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .meet:
                MeetStepView(viewModel: viewModel)
            case .quiz:
                QuizStepView(viewModel: viewModel)
            case .encode:
                EncodeStepView(viewModel: viewModel)
            case .complete:
                BatchCompleteView(viewModel: viewModel, onDismiss: { dismiss() })
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Exit") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Meet Step

struct MeetStepView: View {
    @ObservedObject var viewModel: LearningSessionViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                Text("MEET")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.meetProgress.current) / \(viewModel.meetProgress.total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            ScrollView {
                VStack(spacing: 0) {
                    if let letter = viewModel.currentMeetLetter {
                        // Letter
                        Text(String(letter.character))
                            .font(.system(size: 100, weight: .bold, design: .monospaced))
                            .padding(.top, 20)

                        // NATO word
                        Text(letter.natoWord)
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.top, 8)

                        // Emoji
                        Text(letter.emoji)
                            .font(.system(size: 50))
                            .padding(.top, 16)

                        // Mnemonic
                        Text(letter.mnemonic)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                    }
                }
            }

            // Tap to continue
            Button {
                viewModel.advanceMeet()
            } label: {
                Text("Tap to continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary.opacity(0.1))
            }
            .padding()
        }
    }
}

// MARK: - Quiz Step

struct QuizStepView: View {
    @ObservedObject var viewModel: LearningSessionViewModel
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                Text("QUIZ")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.quizCardsRemaining) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Spacer()

            if let letter = viewModel.currentQuizLetter {
                // Letter prompt
                Text(String(letter.character))
                    .font(.system(size: 100, weight: .bold, design: .monospaced))

                if viewModel.quizShowingCorrectAnswer {
                    // Show what user typed
                    VStack(spacing: 8) {
                        Text("You typed: \(viewModel.lastWrongAnswer)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Correct: \(letter.natoWord)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                    }
                    .padding(.top, 20)

                    Button("Try Again") {
                        viewModel.dismissQuizCorrectAnswer()
                        inputFocused = true
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 20)
                } else {
                    // Input field
                    TextField("NATO word", text: $viewModel.quizInput)
                        .font(.title2)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                        .padding(.top, 24)
                        .focused($inputFocused)
                        .onSubmit {
                            viewModel.submitQuizAnswer()
                        }

                    Button("Submit") {
                        viewModel.submitQuizAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                    .disabled(viewModel.quizInput.isEmpty)
                }
            }

            Spacer()
        }
        .onAppear {
            inputFocused = true
        }
        .onChange(of: viewModel.currentQuizLetter?.id) { _, _ in
            inputFocused = true
        }
    }
}

// MARK: - Encode Step

struct EncodeStepView: View {
    @ObservedObject var viewModel: LearningSessionViewModel
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                Text("ENCODE")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.encodeCardsRemaining) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Spacer()

            if let word = viewModel.currentEncodeWord {
                // Word prompt
                Text(word.word)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))

                if viewModel.encodeShowingHint {
                    // Show what user typed and correct spelling
                    VStack(spacing: 8) {
                        Text("You typed: \(viewModel.lastWrongAnswer)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Correct: \(word.formattedSpelling)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                    Button("Try Again") {
                        viewModel.dismissEncodeHint()
                        inputFocused = true
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 20)
                } else {
                    // Instructions
                    Text("Spell using NATO words")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)

                    // Input field
                    TextField("Alpha Bravo Charlie...", text: $viewModel.encodeInput)
                        .font(.title3)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        .focused($inputFocused)
                        .onSubmit {
                            viewModel.submitEncodeAnswer()
                        }

                    Button("Submit") {
                        viewModel.submitEncodeAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                    .disabled(viewModel.encodeInput.isEmpty)
                }
            }

            Spacer()
        }
        .onAppear {
            inputFocused = true
        }
        .onChange(of: viewModel.currentEncodeWord?.id) { _, _ in
            inputFocused = true
        }
    }
}

// MARK: - Batch Complete

struct BatchCompleteView: View {
    @ObservedObject var viewModel: LearningSessionViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Batch \(viewModel.batch.displayNumber) Complete")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Letters learned
            HStack(spacing: 12) {
                ForEach(viewModel.batch.letters) { letter in
                    VStack {
                        Text(String(letter.character))
                            .font(.title)
                            .fontWeight(.bold)
                        Text(letter.natoWord)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)

            // Next review
            VStack(spacing: 4) {
                Text("First drill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.nextReviewTimeString)
                    .font(.headline)
            }
            .padding(.top, 16)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    NavigationStack {
        LearningSessionView(batch: NATOData.batches[0])
    }
}
