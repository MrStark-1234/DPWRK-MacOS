//
//  FocusSession.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import Foundation

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let goal: String
    let duration: TimeInterval
    let startTime: Date
    let endTime: Date?
    let reflection: String?
    let blockedApps: [String]
    let blockedWebsites: [String]
    let completed: Bool
    
    init(
        id: UUID = UUID(),
        goal: String = "",
        duration: TimeInterval = 25 * 60, // Default 25 minutes
        startTime: Date = Date(),
        endTime: Date? = nil,
        reflection: String? = nil,
        blockedApps: [String] = [],
        blockedWebsites: [String] = [],
        completed: Bool = false
    ) {
        self.id = id
        self.goal = goal
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.reflection = reflection
        self.blockedApps = blockedApps
        self.blockedWebsites = blockedWebsites
        self.completed = completed
    }
}