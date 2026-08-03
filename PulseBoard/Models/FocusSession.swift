//
//  FocusSession.swift
//  PulseBoard
//
//  Created by Inzamamul Haque on 02/08/26.
//
import SwiftData
import Foundation

@Model
final class FocusSession {
    var id: UUID
    var title: String
    var category: String
    var startedAt: Date
    var durationMinutes: Int
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        startedAt: Date = .now,
        durationMinutes: Int,
        isCompleted: Bool = true
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.startedAt = startedAt
        self.durationMinutes = durationMinutes
        self.isCompleted = isCompleted
    }
}
