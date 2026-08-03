//
//  FocusAnalytics.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import Foundation

enum InsightsPeriod: String, CaseIterable, Identifiable {
    case week
    case month

    var id: String {
        rawValue
    }

    var title: String {
        rawValue.capitalized
    }
}

struct DailyFocusMetric: Identifiable {
    let date: Date
    let label: String
    let minutes: Int

    var id: Date {
        date
    }

    var hours: Double {
        Double(minutes) / 60
    }
}

struct FocusAnalytics {
    private let sessions: [FocusSession]
    private let calendar: Calendar
    private let now: Date

    let weeklyGoalMinutes = 600

    init(
        sessions: [FocusSession],
        calendar: Calendar = .current,
        now: Date = .now
    ) {
        self.sessions = sessions
        self.calendar = calendar
        self.now = now
    }

    var currentWeekInterval: DateInterval {
        if let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        ) {
            return interval
        }

        let start = calendar.startOfDay(for: now)
        let end = calendar.date(
            byAdding: .day,
            value: 7,
            to: start
        ) ?? now

        return DateInterval(
            start: start,
            end: end
        )
    }

    var currentWeekSessions: [FocusSession] {
        sessions(in: currentWeekInterval)
    }

    var previousWeekSessions: [FocusSession] {
        guard
            let start = calendar.date(
                byAdding: .day,
                value: -7,
                to: currentWeekInterval.start
            )
        else {
            return []
        }

        return sessions(
            in: DateInterval(
                start: start,
                end: currentWeekInterval.start
            )
        )
    }

    var currentWeekMinutes: Int {
        totalMinutes(for: currentWeekSessions)
    }

    var previousWeekMinutes: Int {
        totalMinutes(for: previousWeekSessions)
    }

    var weeklyScore: Double {
        min(
            Double(currentWeekMinutes) /
            Double(weeklyGoalMinutes),
            1
        )
    }

    var weeklyTrendPercentage: Int? {
        guard previousWeekMinutes > 0 else {
            return nil
        }

        let difference =
            Double(currentWeekMinutes - previousWeekMinutes)

        return Int(
            (
                difference /
                Double(previousWeekMinutes) *
                100
            ).rounded()
        )
    }

    var currentStreak: Int {
        let activeDays = Set(
            sessions.map {
                calendar.startOfDay(
                    for: $0.startedAt
                )
            }
        )

        let today = calendar.startOfDay(for: now)

        let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        )

        let startingDay: Date

        if activeDays.contains(today) {
            startingDay = today
        } else if let yesterday,
                  activeDays.contains(yesterday) {
            startingDay = yesterday
        } else {
            return 0
        }

        var streak = 0
        var currentDay = startingDay

        while activeDays.contains(currentDay) {
            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: currentDay
            ) else {
                break
            }

            currentDay = previousDay
        }

        return streak
    }

    func sessions(
        for period: InsightsPeriod
    ) -> [FocusSession] {
        sessions(in: interval(for: period))
    }

    func totalMinutes(
        for period: InsightsPeriod
    ) -> Int {
        totalMinutes(
            for: sessions(for: period)
        )
    }

    func averageSessionMinutes(
        for period: InsightsPeriod
    ) -> Int {
        let periodSessions = sessions(for: period)

        guard !periodSessions.isEmpty else {
            return 0
        }

        return totalMinutes(for: periodSessions) /
            periodSessions.count
    }

    func bestDayName(
        for period: InsightsPeriod
    ) -> String {
        guard let bestMetric = dailyMetrics(for: period)
            .filter({ $0.minutes > 0 })
            .max(by: { $0.minutes < $1.minutes })
        else {
            return "—"
        }

        return bestMetric.date.formatted(
            .dateTime.weekday(.wide)
        )
    }

    func strongestFocusWindow(
        for period: InsightsPeriod
    ) -> String {
        let periodSessions = sessions(for: period)

        guard !periodSessions.isEmpty else {
            return "Complete a session to unlock insights"
        }

        let groupedByHour = Dictionary(
            grouping: periodSessions
        ) { session in
            calendar.component(
                .hour,
                from: session.startedAt
            )
        }

        let totalsByHour = groupedByHour.mapValues {
            totalMinutes(for: $0)
        }

        guard let strongestHour = totalsByHour.max(
            by: { $0.value < $1.value }
        )?.key else {
            return "Complete more sessions to unlock insights"
        }

        let nextHour = (strongestHour + 1) % 24

        return "\(hourLabel(strongestHour))–\(hourLabel(nextHour))"
    }

    func dailyMetrics(
        for period: InsightsPeriod
    ) -> [DailyFocusMetric] {
        let periodInterval = interval(for: period)

        let dayCount = period == .week ? 7 : 30

        return (0..<dayCount).compactMap { offset in
            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: periodInterval.start
            ) else {
                return nil
            }

            let daySessions = sessions.filter {
                calendar.isDate(
                    $0.startedAt,
                    inSameDayAs: date
                )
            }

            let label: String

            switch period {
            case .week:
                label = date.formatted(
                    .dateTime.weekday(.abbreviated)
                )

            case .month:
                label = date.formatted(
                    .dateTime.month(.abbreviated).day()
                )
            }

            return DailyFocusMetric(
                date: date,
                label: label,
                minutes: totalMinutes(
                    for: daySessions
                )
            )
        }
    }

    func formattedDuration(
        _ minutes: Int
    ) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours == 0 {
            return "\(remainingMinutes)m"
        }

        if remainingMinutes == 0 {
            return "\(hours)h"
        }

        return "\(hours)h \(remainingMinutes)m"
    }

    private func interval(
        for period: InsightsPeriod
    ) -> DateInterval {
        switch period {
        case .week:
            return currentWeekInterval

        case .month:
            let today = calendar.startOfDay(for: now)

            let start = calendar.date(
                byAdding: .day,
                value: -29,
                to: today
            ) ?? today

            let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: today
            ) ?? now

            return DateInterval(
                start: start,
                end: end
            )
        }
    }

    private func sessions(
        in interval: DateInterval
    ) -> [FocusSession] {
        sessions.filter {
            $0.startedAt >= interval.start &&
            $0.startedAt < interval.end &&
            $0.isCompleted
        }
    }

    private func totalMinutes(
        for sessions: [FocusSession]
    ) -> Int {
        sessions.reduce(0) {
            $0 + $1.durationMinutes
        }
    }

    private func hourLabel(
        _ hour: Int
    ) -> String {
        var components = DateComponents()
        components.hour = hour

        guard let date = calendar.date(
            from: components
        ) else {
            return "\(hour):00"
        }

        return date.formatted(
            .dateTime.hour()
        )
    }
}
