//
//  SampleDataService.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import Foundation
import SwiftData

@MainActor
struct SampleDataService {
    private let modelContext: ModelContext
    private let calendar: Calendar
    private let now: Date

    init(
        modelContext: ModelContext,
        calendar: Calendar = .current,
        now: Date = .now
    ) {
        self.modelContext = modelContext
        self.calendar = calendar
        self.now = now
    }

    func replaceWithSampleData() throws {
        try deleteAllSessions(saveChanges: false)

        for sample in Self.samples {
            let session = FocusSession(
                title: sample.title,
                category: sample.category,
                startedAt: sessionDate(
                    dayOffset: sample.dayOffset,
                    hour: sample.hour,
                    minute: sample.minute
                ),
                durationMinutes: sample.durationMinutes,
                isCompleted: true
            )

            modelContext.insert(session)
        }

        try modelContext.save()
    }

    @discardableResult
    func deleteAllSessions(
        saveChanges: Bool = true
    ) throws -> Int {
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try modelContext.fetch(descriptor)

        for session in sessions {
            modelContext.delete(session)
        }

        if saveChanges {
            try modelContext.save()
        }

        return sessions.count
    }

    private func sessionDate(
        dayOffset: Int,
        hour: Int,
        minute: Int
    ) -> Date {
        let today = calendar.startOfDay(for: now)

        let targetDay = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: today
        ) ?? today

        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: targetDay
        ) ?? targetDay
    }
}

private extension SampleDataService {
    struct SampleSession {
        let title: String
        let category: String
        let dayOffset: Int
        let hour: Int
        let minute: Int
        let durationMinutes: Int
    }

    static let samples = [
        SampleSession(
            title: "Product strategy",
            category: "Planning",
            dayOffset: -9,
            hour: 9,
            minute: 0,
            durationMinutes: 90
        ),
        SampleSession(
            title: "Design system",
            category: "Design",
            dayOffset: -8,
            hour: 10,
            minute: 0,
            durationMinutes: 75
        ),
        SampleSession(
            title: "API integration",
            category: "Development",
            dayOffset: -7,
            hour: 9,
            minute: 30,
            durationMinutes: 120
        ),
        SampleSession(
            title: "Build dashboard UI",
            category: "Development",
            dayOffset: -6,
            hour: 9,
            minute: 0,
            durationMinutes: 110
        ),
        SampleSession(
            title: "Short Break",
            category: "Break",
            dayOffset: -5,
            hour: 11,
            minute: 15,
            durationMinutes: 15
        ),
        SampleSession(
            title: "User research",
            category: "Research",
            dayOffset: -5,
            hour: 11,
            minute: 30,
            durationMinutes: 95
        ),
        SampleSession(
            title: "Architecture planning",
            category: "Planning",
            dayOffset: -4,
            hour: 9,
            minute: 15,
            durationMinutes: 80
        ),
        SampleSession(
            title: "Code review",
            category: "Development",
            dayOffset: -3,
            hour: 14,
            minute: 0,
            durationMinutes: 60
        ),
        SampleSession(
            title: "SwiftData integration",
            category: "Development",
            dayOffset: -2,
            hour: 10,
            minute: 0,
            durationMinutes: 105
        ),
        SampleSession(
            title: "Performance polish",
            category: "Development",
            dayOffset: -1,
            hour: 9,
            minute: 0,
            durationMinutes: 90
        ),
        SampleSession(
            title: "Portfolio cleanup",
            category: "Deep Work",
            dayOffset: 0,
            hour: 9,
            minute: 0,
            durationMinutes: 75
        )
    ]
}
