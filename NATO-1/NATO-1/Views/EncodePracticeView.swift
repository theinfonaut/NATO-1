//
//  EncodePracticeView.swift
//  NATO-1
//

import SwiftUI

struct EncodePracticeView: View {
    @StateObject private var viewModel = EncodePracticeViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("ENCODE PRACTICE")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.wordsRemaining) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()

            if viewModel.isRoundComplete {
                roundCompleteView
            } else {
                practiceView
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
        .onAppear {
            inputFocused = true
        }
        .onChange(of: viewModel.currentWord?.id) { _, _ in
            inputFocused = true
        }
    }

    // MARK: - Practice View

    private var practiceView: some View {
        VStack {
            Spacer()

            if let word = viewModel.currentWord {
                // Word prompt
                Text(word.word)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))

                if viewModel.showingHint {
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
                        viewModel.dismissHint()
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
                    TextField("Alpha Bravo Charlie...", text: $viewModel.input)
                        .font(.title3)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        .focused($inputFocused)
                        .onSubmit {
                            viewModel.submitAnswer()
                        }

                    Button("Submit") {
                        viewModel.submitAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                    .disabled(viewModel.input.isEmpty)
                }
            }

            Spacer()
        }
    }

    // MARK: - Round Complete

    private var roundCompleteView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Round Complete")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(viewModel.correctCount)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                    Text("correct")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(viewModel.missedCount)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(viewModel.missedCount > 0 ? .red : .primary)
                    Text("missed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    viewModel.startNewRound()
                    inputFocused = true
                } label: {
                    Text("Another Round")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary)
                        .foregroundStyle(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    NavigationStack {
        EncodePracticeView()
    }
}
