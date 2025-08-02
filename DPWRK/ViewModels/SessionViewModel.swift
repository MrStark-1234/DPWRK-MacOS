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
    private var backgroundTaskIdentifier: NSBackgroundActivityScheduler?
    private var sessionStartTime: Date?
    
    init() {
        // Load user preferences from UserDefaults
        self.userPreferences = UserPreferences.load()
        
        // Set up notification observers for system events
        setupNotificationObservers()
        
        // Request notification permissions
        requestNotificationPermissions()
        
        // Restore timer state if app was closed during active session
        restoreTimerState()
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
        
        // App becoming inactive (background)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: NSApplication.willResignActiveNotification,
            object: nil
        )
        
        // App becoming active (foreground)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        #endif
    }
    
    #if os(macOS)
    // Handle system sleep
    @objc private func handleSleepNotification() {
        // Timer continues running even during sleep
        // We'll sync the time when the system wakes up
    }
    
    // Handle system wake
    @objc private func handleWakeNotification() {
        // Sync timer with actual elapsed time
        syncTimerWithRealTime()
    }
    
    // Handle app going to background
    @objc private func handleAppWillResignActive() {
        // Timer continues running in background
        // No action needed as we use real-time calculation
    }
    
    // Handle app coming to foreground
    @objc private func handleAppDidBecomeActive() {
        // Sync timer with actual elapsed time
        syncTimerWithRealTime()
    }
    
    // Sync timer with real elapsed time
    private func syncTimerWithRealTime() {
        guard let startTime = sessionStartTime, isTimerActive else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let newTimeRemaining = max(0, originalDuration - elapsedTime)
        
        DispatchQueue.main.async {
            self.timeRemaining = newTimeRemaining
            self.progress = newTimeRemaining / self.originalDuration
            
            if newTimeRemaining <= 0 && !self.isTimerComplete {
                self.timerCompleted()
            }
        }
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
        sessionStartTime = Date()
        
        // Save timer state to UserDefaults for persistence
        saveTimerState()
        
        // Schedule completion notification
        scheduleCompletionNotification()
        
        // Set up background activity to keep timer running
        #if os(macOS)
        setupBackgroundActivity()
        #endif
        
        // Create a timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isTimerActive else { return }
            
            // Use real-time calculation to ensure accuracy
            if let startTime = self.sessionStartTime {
                let elapsedTime = Date().timeIntervalSince(startTime)
                let newTimeRemaining = max(0, self.originalDuration - elapsedTime)
                
                self.timeRemaining = newTimeRemaining
                self.progress = newTimeRemaining / self.originalDuration
                
                // Update persistent state
                self.saveTimerState()
                
                // Provide haptic feedback at certain intervals
                let remainingMinutes = Int(newTimeRemaining / 60)
                let remainingSeconds = Int(newTimeRemaining.truncatingRemainder(dividingBy: 60))
                
                if (remainingMinutes == 1 && remainingSeconds == 0) || 
                   (remainingMinutes == 0 && (remainingSeconds == 30 || remainingSeconds == 10)) {
                    self.provideHapticFeedback()
                }
                
                if newTimeRemaining <= 0 {
                    self.timerCompleted()
                }
            }
        }
        
        // Make sure the timer runs even when scrolling and in background
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    #if os(macOS)
    // Set up background activity to keep timer running
    private func setupBackgroundActivity() {
        backgroundTaskIdentifier = NSBackgroundActivityScheduler(identifier: "com.dpwrk.timer")
        backgroundTaskIdentifier?.repeats = false
        backgroundTaskIdentifier?.qualityOfService = .userInitiated
        backgroundTaskIdentifier?.schedule { (completion) in
            // This keeps the app active in background for timer functionality
            DispatchQueue.main.asyncAfter(deadline: .now() + self.originalDuration) {
                completion(.finished)
            }
        }
    }
    #endif
    
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
        sessionStartTime = nil
        
        // Clear persistent timer state
        clearTimerState()
        
        // Cancel any scheduled notifications
        cancelCompletionNotification()
        
        #if os(macOS)
        // Cancel background activity
        backgroundTaskIdentifier?.invalidate()
        backgroundTaskIdentifier = nil
        #endif
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
    
    // MARK: - Persistent Timer State
    
    // Save timer state to UserDefaults
    private func saveTimerState() {
        guard let startTime = sessionStartTime else { return }
        
        UserDefaults.standard.set(startTime, forKey: "TimerStartTime")
        UserDefaults.standard.set(originalDuration, forKey: "TimerOriginalDuration")
        UserDefaults.standard.set(isTimerActive, forKey: "TimerIsActive")
        UserDefaults.standard.set(currentSession?.goal ?? "", forKey: "TimerSessionGoal")
    }
    
    // Restore timer state from UserDefaults
    private func restoreTimerState() {
        guard let startTime = UserDefaults.standard.object(forKey: "TimerStartTime") as? Date,
              UserDefaults.standard.bool(forKey: "TimerIsActive") else {
            return
        }
        
        let savedDuration = UserDefaults.standard.double(forKey: "TimerOriginalDuration")
        let savedGoal = UserDefaults.standard.string(forKey: "TimerSessionGoal") ?? ""
        
        // Calculate elapsed time since app was closed
        let elapsedTime = Date().timeIntervalSince(startTime)
        let newTimeRemaining = max(0, savedDuration - elapsedTime)
        
        if newTimeRemaining > 0 {
            // Timer is still running, restore state
            sessionStartTime = startTime
            originalDuration = savedDuration
            timeRemaining = newTimeRemaining
            progress = newTimeRemaining / originalDuration
            isTimerActive = true
            isTimerComplete = false
            
            // Recreate session
            currentSession = FocusSession(
                goal: savedGoal,
                duration: savedDuration,
                blockedApps: userPreferences.defaultBlockedApps,
                blockedWebsites: userPreferences.defaultBlockedWebsites
            )
            
            // Restart the timer
            startInternalTimer()
        } else {
            // Timer has completed while app was closed
            timerCompleted()
        }
    }
    
    // Clear persistent timer state
    private func clearTimerState() {
        UserDefaults.standard.removeObject(forKey: "TimerStartTime")
        UserDefaults.standard.removeObject(forKey: "TimerOriginalDuration")
        UserDefaults.standard.removeObject(forKey: "TimerIsActive")
        UserDefaults.standard.removeObject(forKey: "TimerSessionGoal")
    }
    
    // Start internal timer without resetting state (for restoration)
    private func startInternalTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isTimerActive else { return }
            
            if let startTime = self.sessionStartTime {
                let elapsedTime = Date().timeIntervalSince(startTime)
                let newTimeRemaining = max(0, self.originalDuration - elapsedTime)
                
                self.timeRemaining = newTimeRemaining
                self.progress = newTimeRemaining / self.originalDuration
                
                // Update persistent state
                self.saveTimerState()
                
                // Provide haptic feedback at certain intervals
                let remainingMinutes = Int(newTimeRemaining / 60)
                let remainingSeconds = Int(newTimeRemaining.truncatingRemainder(dividingBy: 60))
                
                if (remainingMinutes == 1 && remainingSeconds == 0) || 
                   (remainingMinutes == 0 && (remainingSeconds == 30 || remainingSeconds == 10)) {
                    self.provideHapticFeedback()
                }
                
                if newTimeRemaining <= 0 {
                    self.timerCompleted()
                }
            }
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    // MARK: - Notification Handling
    
    // Request notification permissions
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // Schedule completion notification
    private func scheduleCompletionNotification() {
        guard let startTime = sessionStartTime else { return }
        
        let center = UNUserNotificationCenter.current()
        
        // Cancel any existing notifications
        center.removeAllPendingNotificationRequests()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Session Complete! 🎉"
        content.body = "Great job! Your focus session is complete."
        content.sound = UNNotificationSound.default
        
        // Schedule notification for when timer completes
        let completionTime = startTime.addingTimeInterval(originalDuration)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: completionTime),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "timer-completion",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    // Cancel completion notification
    private func cancelCompletionNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
}
