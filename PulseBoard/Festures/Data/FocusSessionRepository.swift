//
//  FocusSessionRepository.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//

import Foundation
import SwiftData

@MainActor
struct FocusSessionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveSession(
        title: String,
        category: String,
        startedAt: Date,
        durationMinutes: Int
    ) throws {
        let session = FocusSession(
            title: title,
            category: category,
            startedAt: startedAt,
            durationMinutes: durationMinutes,
            isCompleted: true
        )

        modelContext.insert(session)
        try modelContext.save()
    }

    func deleteSession(
        _ session: FocusSession
    ) throws {
        modelContext.delete(session)
        try modelContext.save()
    }
}
