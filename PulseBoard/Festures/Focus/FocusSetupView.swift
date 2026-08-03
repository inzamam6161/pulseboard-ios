//
//  FocusSetupView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftUI

struct FocusConfiguration: Hashable {
    let title: String
    let category: String
    let durationMinutes: Int
}

struct FocusSetupView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("focusDuration")
    private var defaultDuration = 25

    @State private var navigationPath: [FocusConfiguration] = []
    @State private var sessionTitle = ""
    @State private var selectedCategory = "Deep Work"
    @State private var selectedDuration = 25

    private let categories = [
        "Deep Work",
        "Development",
        "Design",
        "Research",
        "Planning"
    ]

    private let durations = [
        15,
        25,
        45,
        60
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    sessionForm
                    startButton
                }
                .padding(24)
            }
            .background(
                AppTheme.pageBackground.ignoresSafeArea()
            )
            .navigationTitle("New Focus Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(
                for: FocusConfiguration.self
            ) { configuration in
                FocusTimerView(
                    configuration: configuration
                ) {
                    dismiss()
                }
            }
            .onAppear {
                selectedDuration = defaultDuration
            }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(AppTheme.indigo)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 22,
                        style: .continuous
                    )
                )

            VStack(spacing: 6) {
                Text("Protect your focus")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.navy)

                Text(
                    "Choose one meaningful task and work without interruptions."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
        }
    }

    private var sessionForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("SESSION NAME")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(
                    "For example: Build dashboard UI",
                    text: $sessionTitle
                )
                .textInputAutocapitalization(.sentences)
                .padding(14)
                .background(
                    Color(uiColor: .tertiarySystemGroupedBackground)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("CATEGORY")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Picker(
                    "Category",
                    selection: $selectedCategory
                ) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(
                    Color(uiColor: .tertiarySystemGroupedBackground)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("DURATION")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(durations, id: \.self) { duration in
                        durationButton(duration)
                    }
                }
            }
        }
        .dashboardCard()
    }

    private func durationButton(
        _ duration: Int
    ) -> some View {
        Button {
            selectedDuration = duration
        } label: {
            Text("\(duration) min")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    selectedDuration == duration
                    ? Color.white
                    : AppTheme.navy
                )
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    selectedDuration == duration
                    ? AppTheme.indigo
                    : AppTheme.indigo.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
        }
        .buttonStyle(.plain)
    }

    private var startButton: some View {
        Button {
            let cleanedTitle = sessionTitle
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let configuration = FocusConfiguration(
                title: cleanedTitle.isEmpty
                    ? "\(selectedCategory) Session"
                    : cleanedTitle,
                category: selectedCategory,
                durationMinutes: selectedDuration
            )

            navigationPath.append(configuration)
        } label: {
            Label(
                "Start \(selectedDuration)-Minute Session",
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
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FocusSetupView()
}
