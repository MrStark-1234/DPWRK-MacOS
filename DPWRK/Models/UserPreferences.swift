//
//  UserPreferences.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import Foundation

struct UserPreferences: Codable {
    var defaultDuration: TimeInterval
    var defaultBlockedApps: [String]
    var defaultBlockedWebsites: [String]
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var lastGoal: String
    
    init(
        defaultDuration: TimeInterval = 25 * 60, // Default 25 minutes
        defaultBlockedApps: [String] = [],
        defaultBlockedWebsites: [String] = [],
        notificationsEnabled: Bool = true,
        soundEnabled: Bool = true,
        lastGoal: String = ""
    ) {
        self.defaultDuration = defaultDuration
        self.defaultBlockedApps = defaultBlockedApps
        self.defaultBlockedWebsites = defaultBlockedWebsites
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        self.lastGoal = lastGoal
    }
    
    // Helper method to save preferences to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserPreferences")
        }
    }
    
    // Helper method to load preferences from UserDefaults
    static func load() -> UserPreferences {
        if let savedPreferences = UserDefaults.standard.data(forKey: "UserPreferences"),
           let decodedPreferences = try? JSONDecoder().decode(UserPreferences.self, from: savedPreferences) {
            return decodedPreferences
        }
        return UserPreferences() // Return default preferences if none saved
    }
}