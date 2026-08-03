//
//  FocusTimerViewModel.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class FocusTimerViewModel: ObservableObject {
    enum State: Equatable {
        case ready
        case running
        case paused
        case completed
    }

    @Published private(set) var remainingSeconds: Int
    @Published private(set) var state: State = .ready

    let totalSeconds: Int

    private(set) var completedSeconds: Int?

    private var targetEndDate: Date?
    private var updateTask: Task<Void, Never>?

    init(durationMinutes: Int) {
        let safeDuration = max(durationMinutes, 1)

        totalSeconds = safeDuration * 60
        remainingSeconds = safeDuration * 60
    }

    var progress: Double {
        let elapsed = completedSeconds ?? elapsedSeconds

        return min(
            max(Double(elapsed) / Double(totalSeconds), 0),
            1
        )
    }

    var elapsedSeconds: Int {
        max(totalSeconds - remainingSeconds, 0)
    }

    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }

    func start() {
        guard state == .ready else {
            return
        }

        state = .running
        createTargetEndDate()
        beginUpdates()
    }

    func pause() {
        guard state == .running else {
            return
        }

        refreshRemainingTime()

        updateTask?.cancel()
        updateTask = nil
        targetEndDate = nil
        state = .paused
    }

    func resume() {
        guard state == .paused else {
            return
        }

        state = .running
        createTargetEndDate()
        beginUpdates()
    }

    func finishEarly() {
        guard state == .running || state == .paused else {
            return
        }

        if state == .running {
            refreshRemainingTime()
        }

        completedSeconds = max(elapsedSeconds, 1)
        completeSession()
    }

    func suspendUpdates() {
        guard state == .running else {
            return
        }

        updateTask?.cancel()
        updateTask = nil
    }

    func resumeUpdates() {
        guard state == .running else {
            return
        }

        refreshRemainingTime()

        if state == .running {
            beginUpdates()
        }
    }

    func stopUpdates() {
        updateTask?.cancel()
        updateTask = nil
    }

    private func createTargetEndDate() {
        targetEndDate = Date().addingTimeInterval(
            TimeInterval(remainingSeconds)
        )
    }

    private func beginUpdates() {
        updateTask?.cancel()

        updateTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(
                    for: .milliseconds(250)
                )

                guard !Task.isCancelled else {
                    return
                }

                self?.refreshRemainingTime()
            }
        }
    }

    private func refreshRemainingTime() {
        guard let targetEndDate else {
            return
        }

        let newRemainingSeconds = max(
            0,
            Int(ceil(targetEndDate.timeIntervalSinceNow))
        )

        remainingSeconds = newRemainingSeconds

        if newRemainingSeconds == 0 {
            completedSeconds = totalSeconds
            completeSession()
        }
    }

    private func completeSession() {
        updateTask?.cancel()
        updateTask = nil
        targetEndDate = nil
        state = .completed
    }
}
