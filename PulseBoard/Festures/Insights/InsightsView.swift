//
//  InsightsView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import Charts
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Query(
        sort: \FocusSession.startedAt,
        order: .reverse
    )
    private var sessions: [FocusSession]

    @State private var selectedPeriod =
        InsightsPeriod.week

    private var analytics: FocusAnalytics {
        FocusAnalytics(sessions: sessions)
    }

    private var chartData: [DailyFocusMetric] {
        analytics.dailyMetrics(
            for: selectedPeriod
        )
    }

    private var periodSessions: [FocusSession] {
        analytics.sessions(
            for: selectedPeriod
        )
    }

    private var chartUpperBound: Double {
        let maximum = chartData
            .map(\.hours)
            .max() ?? 0

        return max(maximum * 1.25, 1)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                periodPicker
                chartCard
                summaryCards
                insightCard
            }
            .padding()
        }
        .background(
            AppTheme.pageBackground.ignoresSafeArea()
        )
        .navigationTitle("Insights")
    }

    private var periodPicker: some View {
        Picker(
            "Reporting period",
            selection: $selectedPeriod
        ) {
            ForEach(InsightsPeriod.allCases) {
                period in

                Text(period.title)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var chartCard: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text("Focus Time")
                    .font(.headline)

                Text(
                    selectedPeriod == .week
                        ? "Hours completed this week"
                        : "Hours completed during the last 30 days"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if periodSessions.isEmpty {
                ContentUnavailableView(
                    "No Focus Data",
                    systemImage: "chart.xyaxis.line",
                    description: Text(
                        "Complete a focus session to see your progress."
                    )
                )
                .frame(height: 230)
            } else {
                Chart(chartData) { point in
                    AreaMark(
                        x: .value(
                            "Day",
                            point.label
                        ),
                        y: .value(
                            "Hours",
                            point.hours
                        )
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                AppTheme.indigo.opacity(0.3),
                                AppTheme.indigo.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value(
                            "Day",
                            point.label
                        ),
                        y: .value(
                            "Hours",
                            point.hours
                        )
                    )
                    .foregroundStyle(AppTheme.indigo)
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    if point.minutes > 0 {
                        PointMark(
                            x: .value(
                                "Day",
                                point.label
                            ),
                            y: .value(
                                "Hours",
                                point.hours
                            )
                        )
                        .foregroundStyle(AppTheme.indigo)
                        .symbolSize(45)
                    }
                }
                .chartYScale(
                    domain: 0...chartUpperBound
                )
                .frame(height: 230)
                .accessibilityLabel(
                    "Focus time chart"
                )
            }
        }
        .dashboardCard()
    }

    private var summaryCards: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            MetricCard(
                title: "Focus Time",
                value: analytics.formattedDuration(
                    analytics.totalMinutes(
                        for: selectedPeriod
                    )
                ),
                message: selectedPeriod.title,
                systemImage: "clock.fill",
                tint: AppTheme.indigo
            )

            MetricCard(
                title: "Sessions",
                value: "\(periodSessions.count)",
                message: "Completed sessions",
                systemImage: "checkmark.circle.fill",
                tint: .green
            )

            MetricCard(
                title: "Average",
                value: analytics.formattedDuration(
                    analytics.averageSessionMinutes(
                        for: selectedPeriod
                    )
                ),
                message: "Per focus session",
                systemImage: "divide.circle.fill",
                tint: AppTheme.coral
            )

            MetricCard(
                title: "Best Day",
                value: analytics.bestDayName(
                    for: selectedPeriod
                ),
                message: "Highest focus time",
                systemImage: "star.fill",
                tint: AppTheme.orange
            )
        }
    }

    private var insightCard: some View {
        HStack(
            alignment: .top,
            spacing: 14
        ) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(AppTheme.indigo)

            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                Text("PRODUCTIVITY INSIGHT")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.indigo)

                Text(
                    periodSessions.isEmpty
                        ? "Your insight will appear here"
                        : "Your strongest focus window is \(analytics.strongestFocusWindow(for: selectedPeriod))"
                )
                .font(.headline)

                Text(
                    periodSessions.isEmpty
                        ? "Complete sessions and PulseBoard will identify your strongest working patterns."
                        : "Schedule demanding work during this window when possible."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.lavender)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium,
                style: .continuous
            )
        )
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
    .modelContainer(
        for: FocusSession.self,
        inMemory: true
    )
}
