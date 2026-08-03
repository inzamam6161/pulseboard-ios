//
//  PulseBoardApp.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import SwiftData
import SwiftUI

@main
struct PulseBoardApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: FocusSession.self)
    }
}
