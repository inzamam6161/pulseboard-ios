//
//  HomeView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(
        sort: \FocusSession.startedAt,
        order: .reverse
    )
    private var sessions: [FocusSession]

    @AppStorage("profileName")
    private var profileName = "Inzamam"
    
    @State private var isShowingFocusSetup = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var analytics: FocusAnalytics {
        FocusAnalytics(sessions: sessions)
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 20
            ) {
                header
                weeklyScoreCard
                metrics
                startFocusButton
            }
            .padding()
            .padding(.bottom, 24)
        }
        .background(
            AppTheme.pageBackground.ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .sheet(
            isPresented: $isShowingFocusSetup
        ) {
            FocusSetupView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(greeting)
                    .font(.title2.weight(.semibold))

                Text(displayName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.navy)

                Text(
                    Date.now,
                    format: .dateTime
                        .weekday(.wide)
                        .month()
                        .day()
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                // Notifications can be added later.
            } label: {
                Image(systemName: "bell.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.navy)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(AppTheme.coral)
                            .frame(width: 9, height: 9)
                            .offset(x: -3, y: 3)
                    }
            }
            .accessibilityLabel("Notifications")
        }
    }
    
    private var displayName: String {
        let cleanedName = profileName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        return cleanedName.isEmpty
            ? "Inzamam"
            : cleanedName
    }

    private var weeklyScoreCard: some View {
        HStack(spacing: 20) {
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                Text("WEEKLY FOCUS SCORE")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(
                    analytics.weeklyScore,
                    format: .percent.precision(
                        .fractionLength(0)
                    )
                )
                .font(
                    .system(
                        size: 38,
                        weight: .bold
                    )
                )
                .foregroundStyle(AppTheme.indigo)

                Text(scoreMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(
                    trendMessage,
                    systemImage: trendSystemImage
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(trendColor)
            }

            Spacer(minLength: 8)

            ScoreRing(
                progress: analytics.weeklyScore
            )
            .frame(width: 112, height: 112)
        }
        .dashboardCard()
    }

    private var metrics: some View {
        LazyVGrid(
            columns: columns,
            spacing: 12
        ) {
            MetricCard(
                title: "Focus Time",
                value: analytics.formattedDuration(
                    analytics.currentWeekMinutes
                ),
                message: "This week",
                systemImage: "timer",
                tint: AppTheme.indigo
            )

            MetricCard(
                title: "Sessions",
                value: "\(analytics.currentWeekSessions.count)",
                message: "Completed this week",
                systemImage: "checkmark.circle.fill",
                tint: .green
            )

            MetricCard(
                title: "Momentum",
                value: "\(analytics.currentStreak) days",
                message: streakMessage,
                systemImage: "flame.fill",
                tint: AppTheme.coral
            )

            MetricCard(
                title: "Best Day",
                value: analytics.bestDayName(
                    for: .week
                ),
                message: "Strongest focus day",
                systemImage: "star.fill",
                tint: AppTheme.orange
            )
        }
    }

    private var startFocusButton: some View {
        Button {
            isShowingFocusSetup = true
        } label: {
            Label(
                "Start Focus",
                systemImage: "play.fill"
            )
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.primaryGradient)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium,
                    style: .continuous
                )
            )
            .shadow(
                color: AppTheme.coral.opacity(0.25),
                radius: 12,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }

    private var greeting: String {
        let hour = Calendar.current.component(
            .hour,
            from: Date()
        )

        switch hour {
        case 5..<12:
            return "Good morning,"

        case 12..<17:
            return "Good afternoon,"

        default:
            return "Good evening,"
        }
    }

    private var scoreMessage: String {
        switch analytics.weeklyScore {
        case 0:
            return "Start a session to build momentum."

        case 0..<0.4:
            return "A strong week starts with one session."

        case 0.4..<0.8:
            return "You’re building strong momentum."

        default:
            return "Excellent focus this week."
        }
    }

    private var trendMessage: String {
        guard let trend =
                analytics.weeklyTrendPercentage
        else {
            return "First tracked week"
        }

        if trend == 0 {
            return "Same as last week"
        }

        return "\(abs(trend))% \(trend > 0 ? "above" : "below") last week"
    }

    private var trendSystemImage: String {
        guard let trend =
                analytics.weeklyTrendPercentage
        else {
            return "sparkles"
        }

        if trend > 0 {
            return "arrow.up.right"
        }

        if trend < 0 {
            return "arrow.down.right"
        }

        return "minus"
    }

    private var trendColor: Color {
        guard let trend =
                analytics.weeklyTrendPercentage
        else {
            return AppTheme.indigo
        }

        if trend > 0 {
            return .green
        }

        if trend < 0 {
            return AppTheme.coral
        }

        return .secondary
    }

    private var streakMessage: String {
        analytics.currentStreak == 0
            ? "Start your streak today"
            : "Keep the streak alive"
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(
        for: FocusSession.self,
        inMemory: true
    )
}
