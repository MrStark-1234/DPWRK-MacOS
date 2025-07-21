//
//  SessionViewModel.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications

class SessionViewModel: ObservableObject {
    @Published var currentSession: FocusSession?
    @Published var userPreferences: UserPreferences
    @Published var timeRemaining: TimeInterval = 0
    @Published var progress: Double = 1.0
    @Published var isTimerActive: Bool = false
    @Published var isTimerComplete: Bool = false
    
    private var timer: Timer?
    private var originalDuration: TimeInterval = 0
    
    init() {
        // Load user preferences from UserDefaults
        self.userPreferences = UserPreferences.load()
        
        // Set up notification observers for system events
        setupNotificationObservers()
    }
    
    deinit {
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
    }
    
    // Set up notification observers for system events
    private func setupNotificationObservers() {
        #if os(macOS)
        // Sleep notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSleepNotification),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        // Wake notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWakeNotification),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        #endif
    }
    
    #if os(macOS)
    // Handle system sleep
    @objc private func handleSleepNotification() {
        if isTimerActive {
            pauseTimer()
        }
    }
    
    // Handle system wake
    @objc private func handleWakeNotification() {
        // Don't automatically resume - let the user decide
    }
    #endif
    
    // MARK: - Session Management
    
    // Create a new session
    func createSession(goal: String, duration: TimeInterval) -> FocusSession {
        // Save the goal to user preferences
        saveGoal(goal)
        
        let session = FocusSession(
            goal: goal,
            duration: duration,
            blockedApps: userPreferences.defaultBlockedApps,
            blockedWebsites: userPreferences.defaultBlockedWebsites
        )
        return session
    }
    
    // Start a session
    func startSession(session: FocusSession) {
        currentSession = session
        startTimer(duration: session.duration)
    }
    
    // End a session
    func endSession(reflection: String? = nil, completed: Bool = true) {
        guard var session = currentSession else { return }
        
        // In a real implementation, we would create a new session with updated values
        // For now, we'll just clear the current session
        stopTimer()
        currentSession = nil
    }
    
    // MARK: - Timer Logic
    
    // Start the timer with the specified duration
    func startTimer(duration: TimeInterval) {
        stopTimer() // Stop any existing timer
        
        timeRemaining = duration
        originalDuration = duration
        progress = 1.0
        isTimerActive = true
        isTimerComplete = false
        
        // Create a timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isTimerActive else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1.0
                self.progress = self.timeRemaining / self.originalDuration
                
                // Provide haptic feedback at certain intervals
                if self.timeRemaining == 60 || self.timeRemaining == 30 || self.timeRemaining == 10 {
                    self.provideHapticFeedback()
                }
            } else {
                self.timerCompleted()
            }
        }
        
        // Make sure the timer runs even when scrolling
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    // Pause the timer
    func pauseTimer() {
        isTimerActive = false
    }
    
    // Resume the timer
    func resumeTimer() {
        isTimerActive = true
    }
    
    // Stop the timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        timeRemaining = originalDuration
        progress = 1.0
    }
    
    // Timer completed
    private func timerCompleted() {
        isTimerActive = false
        isTimerComplete = true
        progress = 0.0
        timeRemaining = 0
        
        // Provide completion feedback
        provideHapticFeedback()
        provideHapticFeedback() // Double feedback for emphasis
        
        // Update the session as completed
        if var session = currentSession {
            let completedSession = FocusSession(
                id: session.id,
                goal: session.goal,
                duration: originalDuration,
                startTime: session.startTime,
                endTime: Date(),
                reflection: nil,
                blockedApps: session.blockedApps,
                blockedWebsites: session.blockedWebsites,
                completed: true
            )
            currentSession = completedSession
        }
        
        // Invalidate the timer after completion
        timer?.invalidate()
        timer = nil
        
        // In a real implementation, we would show a completion notification
        // and transition to the reflection view
        #if os(macOS)
        // Use modern notification API
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = "Great job! Your session is complete."
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request)
        #endif
    }
    
    // Provide haptic feedback
    private func provideHapticFeedback() {
        #if os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
        #endif
    }
    
    // MARK: - Preferences Management
    
    // Update user preferences
    func updatePreferences(preferences: UserPreferences) {
        userPreferences = preferences
        userPreferences.save()
    }
    
    // Update and save session duration
    func updateSessionDuration(_ duration: TimeInterval) -> Bool {
        // Validate duration is within acceptable range (5-180 minutes)
        let minutes = duration / 60
        if minutes >= 5 && minutes <= 180 {
            userPreferences.defaultDuration = duration
            userPreferences.save()
            return true
        }
        return false
    }
    
    // Get formatted duration string
    func formattedDuration(_ duration: TimeInterval? = nil) -> String {
        let durationToFormat = duration ?? userPreferences.defaultDuration
        let hours = Int(durationToFormat) / 3600
        let minutes = (Int(durationToFormat) % 3600) / 60
        let seconds = Int(durationToFormat) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Goal Management
    
    // Save goal text to UserDefaults
    func saveGoal(_ goal: String) {
        userPreferences.lastGoal = goal
        userPreferences.save()
    }
    
    // Load the last saved goal from UserDefaults
    func loadLastGoal() -> String {
        return userPreferences.lastGoal
    }
    
    // Get a random encouraging placeholder text
    func getRandomPlaceholder() -> String {
        let placeholders = [
            "Write your goal here...",
            "What's your main objective for this session?",
            "What would make this session successful?",
            "What's the one thing you want to accomplish?",
            "Set a clear intention for your work..."
        ]
        return placeholders.randomElement() ?? placeholders[0]
    }
}
