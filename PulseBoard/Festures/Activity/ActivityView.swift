//
//  ActivityView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftData
import SwiftUI

struct ActivityView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \FocusSession.startedAt,
        order: .reverse
    )
    private var sessions: [FocusSession]

    @State private var searchText = ""
    @State private var selectedFilter =
        ActivityFilter.all

    @State private var isShowingDeleteError = false
    @State private var deleteErrorMessage = ""

    private var filteredSessions: [FocusSession] {
        sessions.filter { session in
            let matchesSearch =
                searchText.isEmpty ||
                session.title.localizedCaseInsensitiveContains(
                    searchText
                ) ||
                session.category.localizedCaseInsensitiveContains(
                    searchText
                )

            let matchesFilter: Bool

            switch selectedFilter {
            case .all:
                matchesFilter = true

            case .focus:
                matchesFilter = !session.isBreakSession

            case .breakTime:
                matchesFilter = session.isBreakSession
            }

            return matchesSearch && matchesFilter
        }
    }

    private var sections: [ActivitySection] {
        let grouped = Dictionary(
            grouping: filteredSessions
        ) { session in
            Calendar.current.startOfDay(
                for: session.startedAt
            )
        }

        return grouped
            .map {
                ActivitySection(
                    date: $0.key,
                    sessions: $0.value.sorted {
                        $0.startedAt > $1.startedAt
                    }
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }

    var body: some View {
        VStack(spacing: 12) {
            filterPicker

            if sessions.isEmpty {
                emptyActivityView
            } else if filteredSessions.isEmpty {
                ContentUnavailableView.search(
                    text: searchText
                )
                .frame(maxHeight: .infinity)
            } else {
                activityList
            }
        }
        .background(AppTheme.pageBackground)
        .navigationTitle("Activity")
        .searchable(
            text: $searchText,
            prompt: "Search title or category"
        )
        .alert(
            "Couldn’t Delete Session",
            isPresented: $isShowingDeleteError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage)
        }
    }

    private var filterPicker: some View {
        Picker(
            "Activity filter",
            selection: $selectedFilter
        ) {
            ForEach(ActivityFilter.allCases) {
                filter in

                Text(filter.title)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var activityList: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(
                        section.sessions,
                        id: \.id
                    ) { session in
                        ActivityRow(
                            session: session
                        )
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: true
                        ) {
                            Button(
                                role: .destructive
                            ) {
                                deleteSession(session)
                            } label: {
                                Label(
                                    "Delete",
                                    systemImage: "trash"
                                )
                            }
                        }
                    }
                } header: {
                    Text(
                        sectionTitle(
                            for: section.date
                        )
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var emptyActivityView: some View {
        ContentUnavailableView {
            Label(
                "No Activity Yet",
                systemImage: "clock.badge.questionmark"
            )
        } description: {
            Text(
                "Complete your first focus session and it will appear here."
            )
        }
        .frame(maxHeight: .infinity)
    }

    private func deleteSession(
        _ session: FocusSession
    ) {
        let repository = FocusSessionRepository(
            modelContext: modelContext
        )

        do {
            try repository.deleteSession(session)
        } catch {
            deleteErrorMessage =
                error.localizedDescription

            isShowingDeleteError = true
        }
    }

    private func sectionTitle(
        for date: Date
    ) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }

        return date.formatted(
            .dateTime
                .weekday(.wide)
                .month(.abbreviated)
                .day()
        )
    }
}

private struct ActivitySection: Identifiable {
    let date: Date
    let sessions: [FocusSession]

    var id: Date {
        date
    }
}

private struct ActivityRow: View {
    let session: FocusSession

    var body: some View {
        HStack(spacing: 14) {
            Image(
                systemName: session.isBreakSession
                    ? "cup.and.saucer.fill"
                    : "target"
            )
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 42, height: 42)
            .background(
                session.isBreakSession
                    ? AppTheme.coral
                    : AppTheme.indigo
            )
            .clipShape(Circle())

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(session.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 4
            ) {
                Text(
                    "\(session.durationMinutes) min"
                )
                .font(.subheadline.bold())

                Text(
                    session.startedAt,
                    format: .dateTime
                        .hour()
                        .minute()
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Image(
                systemName: session.isCompleted
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .foregroundStyle(
                session.isCompleted
                    ? Color.green
                    : Color.secondary
            )
        }
        .padding(.vertical, 6)
        .accessibilityElement(
            children: .combine
        )
    }
}

private enum ActivityFilter:
    String,
    CaseIterable,
    Identifiable {

    case all
    case focus
    case breakTime

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .all:
            return "All"

        case .focus:
            return "Focus"

        case .breakTime:
            return "Breaks"
        }
    }
}

private extension FocusSession {
    var isBreakSession: Bool {
        category.localizedCaseInsensitiveContains(
            "break"
        )
    }
}

#Preview {
    NavigationStack {
        ActivityView()
    }
    .modelContainer(
        for: FocusSession.self,
        inMemory: true
    )
}
