//
//  DrillSessionView.swift
//  NATO-1
//

import SwiftUI

struct DrillSessionView: View {
    @StateObject private var viewModel = DrillSessionViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 4)

            if viewModel.isSessionComplete {
                sessionCompleteView
            } else if let card = viewModel.currentCard {
                switch card {
                case .letter:
                    letterCardView
                case .encode:
                    encodeCardView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Exit") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(viewModel.cardsRemaining) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            inputFocused = true
        }
    }

    private var progress: Double {
        guard viewModel.totalCards > 0 else { return 0 }
        return Double(viewModel.completedCards) / Double(viewModel.totalCards)
    }

    // MARK: - Letter Card

    private var letterCardView: some View {
        VStack {
            Spacer()

            if let letter = viewModel.currentLetter {
                // Letter prompt
                Text(String(letter.character))
                    .font(.system(size: 120, weight: .bold, design: .monospaced))

                if viewModel.showingCorrectAnswer {
                    // Show correct answer
                    Text(letter.natoWord)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .padding(.top, 24)

                    Button("Continue") {
                        viewModel.dismissCorrectAnswer()
                        inputFocused = true
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 24)
                } else {
                    // Input field
                    TextField("NATO word", text: $viewModel.input)
                        .font(.title2)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                        .padding(.top, 32)
                        .focused($inputFocused)
                        .onSubmit {
                            viewModel.submitLetterAnswer()
                        }

                    Button("Submit") {
                        viewModel.submitLetterAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 16)
                    .disabled(viewModel.input.isEmpty)
                }
            }

            Spacer()
        }
    }

    // MARK: - Encode Card

    private var encodeCardView: some View {
        VStack {
            Spacer()

            if let word = viewModel.currentEncodeWord {
                // Word prompt
                Text(word.word)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))

                if viewModel.showingEncodeHint {
                    // Show correct spelling
                    Text(word.formattedSpelling)
                        .font(.body)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)

                    Button("Continue") {
                        viewModel.dismissEncodeHint()
                        inputFocused = true
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 24)
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
                        .padding(.top, 24)
                        .focused($inputFocused)
                        .onSubmit {
                            viewModel.submitEncodeAnswer()
                        }

                    Button("Submit") {
                        viewModel.submitEncodeAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 16)
                    .disabled(viewModel.input.isEmpty)
                }
            }

            Spacer()
        }
    }

    // MARK: - Session Complete

    private var sessionCompleteView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Drill Complete")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 4) {
                Text("\(viewModel.completedCards)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                Text("cards reviewed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                dismiss()
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
        DrillSessionView()
    }
}
