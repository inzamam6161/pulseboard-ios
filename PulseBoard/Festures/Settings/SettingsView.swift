//
//  SettingsView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext)
    private var modelContext

    @AppStorage("profileName")
    private var profileName = "Inzamam"

    @AppStorage("focusDuration")
    private var focusDuration = 25

    @AppStorage("hapticsEnabled")
    private var hapticsEnabled = true

    @AppStorage("notificationsEnabled")
    private var notificationsEnabled = true

    @AppStorage("appearance")
    private var appearance =
        AppAppearance.system.rawValue

    @State private var isConfirmingSampleLoad = false
    @State private var isConfirmingDeletion = false

    @State private var resultTitle = ""
    @State private var resultMessage = ""
    @State private var isShowingResult = false

    var body: some View {
        Form {
            profileSection
            focusSection
            appearanceSection
            dataSection
            aboutSection
            preferenceResetSection
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Load Portfolio Data?",
            isPresented: $isConfirmingSampleLoad,
            titleVisibility: .visible
        ) {
            Button(
                "Replace with Sample Data",
                role: .destructive
            ) {
                loadSampleData()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                "Existing activity will be replaced with realistic demonstration sessions."
            )
        }
        .confirmationDialog(
            "Delete All Activity?",
            isPresented: $isConfirmingDeletion,
            titleVisibility: .visible
        ) {
            Button(
                "Delete All Activity",
                role: .destructive
            ) {
                deleteAllActivity()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                "This permanently removes every saved focus session."
            )
        }
        .alert(
            resultTitle,
            isPresented: $isShowingResult
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultMessage)
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            TextField(
                "Display name",
                text: $profileName
            )
            .textInputAutocapitalization(.words)

            LabeledContent(
                "Dashboard greeting",
                value: cleanedProfileName
            )
        }
    }

    private var focusSection: some View {
        Section("Focus") {
            Picker(
                "Default duration",
                selection: $focusDuration
            ) {
                Text("15 minutes").tag(15)
                Text("25 minutes").tag(25)
                Text("45 minutes").tag(45)
                Text("60 minutes").tag(60)
            }

            Toggle(
                "Haptic feedback",
                isOn: $hapticsEnabled
            )

            Toggle(
                "Notifications",
                isOn: $notificationsEnabled
            )
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker(
                "Theme",
                selection: $appearance
            ) {
                ForEach(AppAppearance.allCases) {
                    option in

                    Text(option.rawValue)
                        .tag(option.rawValue)
                }
            }
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                isConfirmingSampleLoad = true
            } label: {
                Label(
                    "Load Portfolio Sample Data",
                    systemImage: "sparkles"
                )
            }

            Button(
                role: .destructive
            ) {
                isConfirmingDeletion = true
            } label: {
                Label(
                    "Delete All Activity",
                    systemImage: "trash"
                )
            }
        } header: {
            Text("Data")
        } footer: {
            Text(
                "Sample data is useful when preparing App Store-style and GitHub screenshots."
            )
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent(
                "Application",
                value: "PulseBoard"
            )

            LabeledContent(
                "Version",
                value: "1.0.0"
            )

            LabeledContent(
                "Technology",
                value: "SwiftUI + SwiftData"
            )
        }
    }

    private var preferenceResetSection: some View {
        Section {
            Button(
                "Reset Preferences",
                role: .destructive
            ) {
                resetPreferences()
            }
        }
    }

    private var cleanedProfileName: String {
        let cleaned = profileName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        return cleaned.isEmpty
            ? "Inzamam"
            : cleaned
    }

    private func loadSampleData() {
        let service = SampleDataService(
            modelContext: modelContext
        )

        do {
            try service.replaceWithSampleData()

            showResult(
                title: "Sample Data Loaded",
                message: "Home, Insights and Activity now contain portfolio demonstration data."
            )
        } catch {
            showResult(
                title: "Data Loading Failed",
                message: error.localizedDescription
            )
        }
    }

    private func deleteAllActivity() {
        let service = SampleDataService(
            modelContext: modelContext
        )

        do {
            let deletedCount =
                try service.deleteAllSessions()

            showResult(
                title: "Activity Deleted",
                message: "\(deletedCount) saved sessions were removed."
            )
        } catch {
            showResult(
                title: "Deletion Failed",
                message: error.localizedDescription
            )
        }
    }

    private func resetPreferences() {
        profileName = "Inzamam"
        focusDuration = 25
        hapticsEnabled = true
        notificationsEnabled = true
        appearance = AppAppearance.system.rawValue

        showResult(
            title: "Preferences Reset",
            message: "Your settings were restored to their defaults."
        )
    }

    private func showResult(
        title: String,
        message: String
    ) {
        resultTitle = title
        resultMessage = message
        isShowingResult = true
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(
        for: FocusSession.self,
        inMemory: true
    )
}
