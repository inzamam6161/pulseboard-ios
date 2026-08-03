//
//  RootTabView.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftData
import SwiftUI

struct RootTabView: View {
    @AppStorage("appearance")
    private var appearance =
        AppAppearance.system.rawValue

    @State private var selectedTab =
        AppTab.home

    private var preferredAppearance: ColorScheme? {
        AppAppearance(
            rawValue: appearance
        )?.colorScheme
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(
                    "Home",
                    systemImage: "house.fill"
                )
            }
            .tag(AppTab.home)

            NavigationStack {
                InsightsView()
            }
            .tabItem {
                Label(
                    "Insights",
                    systemImage: "chart.xyaxis.line"
                )
            }
            .tag(AppTab.insights)

            NavigationStack {
                ActivityView()
            }
            .tabItem {
                Label(
                    "Activity",
                    systemImage: "clock.fill"
                )
            }
            .tag(AppTab.activity)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    "Settings",
                    systemImage: "gearshape.fill"
                )
            }
            .tag(AppTab.settings)
        }
        .tint(AppTheme.indigo)
        .preferredColorScheme(
            preferredAppearance
        )
    }
}

private enum AppTab: Hashable {
    case home
    case insights
    case activity
    case settings
}

#Preview {
    RootTabView()
        .modelContainer(
            for: FocusSession.self,
            inMemory: true
        )
}
