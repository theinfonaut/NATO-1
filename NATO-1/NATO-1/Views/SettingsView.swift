//
//  SettingsView.swift
//  NATO-1
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState = AppState.shared

    @State private var showingResetAlert = false
    @State private var showingJumpAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - About Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(AppConstants.App.name)
                                .font(.headline)
                            Spacer()
                            Text("v\(AppConstants.App.version)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text("Made independently by \(AppConstants.App.studioName). Your purchase supports indie development.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About")
                }

                // MARK: - Coming Soon Section
                Section {
                    HStack {
                        Text("Custom Words")
                        Spacer()
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .foregroundStyle(.secondary)

                    HStack {
                        Text("Notifications")
                        Spacer()
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .foregroundStyle(.secondary)
                } header: {
                    Text("Features")
                }

                // MARK: - Debug Section
                Section {
                    // Full Reset
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Full Reset")
                        }
                    }

                    // Jump to Drilling
                    Button {
                        showingJumpAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "forward.fill")
                            Text("Jump to Drilling")
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Debug — testing only")
                            .foregroundStyle(.orange)
                    }
                } footer: {
                    Text("These options are for development testing. They will be removed in the release version.")
                        .foregroundStyle(.orange.opacity(0.8))
                }
                .listRowBackground(Color.orange.opacity(0.05))
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset All Progress?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    appState.resetAll()
                    dismiss()
                }
            } message: {
                Text("This will erase all your progress and return the app to a fresh install state. This cannot be undone.")
            }
            .alert("Jump to Drilling?", isPresented: $showingJumpAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Jump") {
                    appState.debugJumpToDrilling()
                    dismiss()
                }
            } message: {
                Text("This will mark Batch 1 (A B C D) as complete and add those letters to the drill queue, due immediately.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
