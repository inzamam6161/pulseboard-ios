//
//  FocusTimerView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftData
import SwiftUI
import UIKit

struct FocusTimerView: View {
    let configuration: FocusConfiguration
    let onSessionSaved: () -> Void

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage("hapticsEnabled")
    private var hapticsEnabled = true

    @StateObject
    private var viewModel: FocusTimerViewModel

    @State private var startedAt = Date()
    @State private var hasSavedSession = false
    @State private var isShowingSaveError = false
    @State private var saveErrorMessage = ""

    init(
        configuration: FocusConfiguration,
        onSessionSaved: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.onSessionSaved = onSessionSaved

        _viewModel = StateObject(
            wrappedValue: FocusTimerViewModel(
                durationMinutes: configuration.durationMinutes
            )
        )
    }

    var body: some View {
        VStack(spacing: 28) {
            sessionInformation

            Spacer()

            timerRing

            statusText

            Spacer()

            controls
        }
        .padding(24)
        .background(
            AppTheme.pageBackground.ignoresSafeArea()
        )
        .navigationTitle("Focus")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startedAt = Date()
            viewModel.start()
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhase(newPhase)
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState == .completed {
                saveSessionIfNeeded()
            }
        }
        .alert(
            "Couldn’t Save Session",
            isPresented: $isShowingSaveError
        ) {
            Button("Try Again") {
                saveSessionIfNeeded()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    private var sessionInformation: some View {
        VStack(spacing: 8) {
            Text(configuration.category.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.indigo)

            Text(configuration.title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.navy)
                .multilineTextAlignment(.center)

            Text("\(configuration.durationMinutes)-minute session")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(
                    AppTheme.indigo.opacity(0.1),
                    lineWidth: 20
                )

            Circle()
                .trim(
                    from: 0,
                    to: viewModel.progress
                )
                .stroke(
                    AppTheme.primaryGradient,
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    .linear(duration: 0.25),
                    value: viewModel.progress
                )

            VStack(spacing: 8) {
                Text(viewModel.formattedRemainingTime)
                    .font(
                        .system(
                            size: 54,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.navy)

                Text(timerStateTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 270, height: 270)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Focus timer")
        .accessibilityValue(viewModel.formattedRemainingTime)
    }

    private var timerStateTitle: String {
        switch viewModel.state {
        case .ready:
            return "Preparing"

        case .running:
            return "Stay focused"

        case .paused:
            return "Session paused"

        case .completed:
            return "Session complete"
        }
    }

    @ViewBuilder
    private var statusText: some View {
        if viewModel.state == .completed {
            Label(
                hasSavedSession
                ? "Session saved successfully"
                : "Finishing your session",
                systemImage: hasSavedSession
                ? "checkmark.circle.fill"
                : "arrow.triangle.2.circlepath"
            )
            .font(.headline)
            .foregroundStyle(
                hasSavedSession ? Color.green : AppTheme.indigo
            )
        } else {
            Text(
                viewModel.state == .paused
                ? "Resume when you’re ready."
                : "Notifications and distractions can wait."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var controls: some View {
        if viewModel.state == .completed {
            completedControls
        } else {
            activeControls
        }
    }

    private var activeControls: some View {
        HStack(spacing: 14) {
            Button {
                if viewModel.state == .running {
                    viewModel.pause()
                } else {
                    viewModel.resume()
                }

                createSelectionHaptic()
            } label: {
                Label(
                    viewModel.state == .running
                    ? "Pause"
                    : "Resume",
                    systemImage: viewModel.state == .running
                    ? "pause.fill"
                    : "play.fill"
                )
                .font(.headline)
                .foregroundStyle(AppTheme.indigo)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppTheme.indigo.opacity(0.1))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.medium,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)

            Button {
                viewModel.finishEarly()
            } label: {
                Label(
                    "Finish",
                    systemImage: "checkmark"
                )
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppTheme.primaryGradient)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.medium,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var completedControls: some View {
        VStack(spacing: 12) {
            if hasSavedSession {
                Button {
                    onSessionSaved()
                } label: {
                    Label(
                        "Done",
                        systemImage: "checkmark"
                    )
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.indigo)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Radius.medium,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button("Retry Saving") {
                    saveSessionIfNeeded()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.indigo)
            }
        }
    }

    private func handleScenePhase(
        _ newPhase: ScenePhase
    ) {
        switch newPhase {
        case .active:
            viewModel.resumeUpdates()

        case .inactive, .background:
            viewModel.suspendUpdates()

        @unknown default:
            break
        }
    }

    private func saveSessionIfNeeded() {
        guard !hasSavedSession else {
            return
        }

        let completedSeconds =
            viewModel.completedSeconds ??
            viewModel.elapsedSeconds

        let durationMinutes = max(
            1,
            Int(
                ceil(
                    Double(completedSeconds) / 60
                )
            )
        )

        let repository = FocusSessionRepository(
            modelContext: modelContext
        )

        do {
            try repository.saveSession(
                title: configuration.title,
                category: configuration.category,
                startedAt: startedAt,
                durationMinutes: durationMinutes
            )

            hasSavedSession = true
            createSuccessHaptic()
        } catch {
            saveErrorMessage = error.localizedDescription
            isShowingSaveError = true
        }
    }

    private func createSelectionHaptic() {
        guard hapticsEnabled else {
            return
        }

        UISelectionFeedbackGenerator()
            .selectionChanged()
    }

    private func createSuccessHaptic() {
        guard hapticsEnabled else {
            return
        }

        UINotificationFeedbackGenerator()
            .notificationOccurred(.success)
    }
}

#Preview {
    NavigationStack {
        FocusTimerView(
            configuration: FocusConfiguration(
                title: "Build dashboard UI",
                category: "Development",
                durationMinutes: 25
            )
        ) {}
    }
    .modelContainer(
        for: FocusSession.self,
        inMemory: true
    )
}
