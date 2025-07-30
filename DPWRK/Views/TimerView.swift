//
//  TimerView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var selectedDuration: TimeInterval
    @State private var isTimerActive: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var progress: Double = 0
    @State private var isSetupMode: Bool = true
    @State private var showDurationSelection: Bool = false
    @State private var showSessionNotes: Bool = false
    @State private var showingBlocklistEdit = false
    
    // Animation properties (kept for completion animation)
    @State private var timerScale: CGFloat = 1.0
    
    init() {
        // Initialize with the default duration from UserPreferences
        // This will be loaded when the view is created
        _selectedDuration = State(initialValue: UserPreferences.load().defaultDuration)
        _timeRemaining = State(initialValue: UserPreferences.load().defaultDuration)
    }
    

    var body: some View {
        ScrollView {
            VStack(spacing: DPWRKStyle.Layout.spacingLarge) {
                if isSetupMode {
                    // SETUP MODE
                    Text("⏱️ Session Setup")
                        .font(DPWRKStyle.Typography.heading1())
                        .scaleEffect(y: 1.08)
                        .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
                    
                    // Simple timer display
                    timerDisplayView(time: selectedDuration, progress: 1.0)
                    
                    // Button row
                    HStack(spacing: 8) {
                        Button(action: {
                            // Show duration selection popup
                            showDurationSelection = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Session")
                            }
                            .frame(minWidth: 140)
                        }
                        .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
                        
                        Button("Edit Blocklist") {
                            showingBlocklistEdit = true
                        }
                        .buttonStyle(BlocklistButtonStyle())
                        .frame(height: 48)
                    }
                    .padding(.top, DPWRKStyle.Layout.spacingLarge)
                    
                } else {
                    // ACTIVE TIMER MODE
                    Text("⏱️ Session")
                        .font(DPWRKStyle.Typography.heading1())
                        .scaleEffect(y: 1.08)
                        .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
                    
                    // Session status indicator
                    if !isTimerActive && !isSetupMode {
                        Text("⏸️ Paused")
                            .font(DPWRKStyle.Typography.bodyLarge())
                            .foregroundColor(DPWRKStyle.Colors.warning)
                            .padding(.horizontal, DPWRKStyle.Layout.spacingMedium)
                            .padding(.vertical, DPWRKStyle.Layout.spacingSmall)
                            .background(
                                RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                                    .fill(DPWRKStyle.Colors.warning.opacity(0.1))
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Active timer display
                    timerDisplayView(time: timeRemaining, progress: progress)
                    
                    // Timer controls
                    HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
                        // Pause/Resume button
                        Button(action: {
                            toggleTimer()
                        }) {
                            HStack {
                                Image(systemName: isTimerActive ? "pause.fill" : "play.fill")
                                Text(isTimerActive ? "Pause" : "Resume")
                            }
                            .frame(minWidth: 90)
                        }
                        .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
                        
                        // Stop button
                        Button(action: {
                            resetTimer()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop")
                            }
                            .frame(minWidth: 90)
                        }
                        .buttonStyle(DPWRKStyle.SecondaryButtonStyle())
                    }
                    .padding(.top, DPWRKStyle.Layout.spacingLarge)
                }
                
                Spacer()
            }
            .padding(DPWRKStyle.Layout.padding)
        }
        .background(DPWRKStyle.Colors.background)
        .navigationTitle("⏱️ Timer")
        .onAppear {
            // Update the selected duration from user preferences when the view appears
            selectedDuration = sessionViewModel.userPreferences.defaultDuration
            timeRemaining = selectedDuration
        }
        .onChange(of: selectedDuration) { _, newValue in
            timeRemaining = newValue
        }
        // Duration selection sheet
        .sheet(isPresented: $showDurationSelection) {
            DurationSelectionView(
                selectedDuration: $selectedDuration,
                isPresented: $showDurationSelection,
                onComplete: {
                    // When duration selection is complete, show session notes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSessionNotes = true
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // Session notes sheet
        .sheet(isPresented: $showSessionNotes) {
            SessionNotesView(isPresented: $showSessionNotes, onStart: {
                startTimer()
            })
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingBlocklistEdit) {
            BlocklistEditView(isPresented: $showingBlocklistEdit)
                .frame(minWidth: 600, minHeight: 500)
        }

    }
    
    // MARK: - Timer Display View
    
    private func timerDisplayView(time: TimeInterval, progress: Double) -> some View {
        VStack(spacing: DPWRKStyle.Layout.spacingLarge) {
            // Glowing orb that evolves with progress
            GlowingOrbView(
                progress: isSetupMode ? 0.1 : (1.0 - progress), // Inverted progress so orb grows as time passes
                isActive: isTimerActive,
                isPaused: !isTimerActive && !isSetupMode
            )
            .frame(height: 250)
            
            // Simple timer text below the orb (no animations)
            Text(formatTime(time))
                .font(DPWRKStyle.Typography.timerDisplay())
                .foregroundColor(DPWRKStyle.Colors.primaryText)
                .monospacedDigit()
        }
        .padding(.vertical, DPWRKStyle.Layout.spacingLarge)
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        isSetupMode = false
        
        // Create a session and start the timer in the view model
        let goal = sessionViewModel.loadLastGoal()
        let session = sessionViewModel.createSession(goal: goal, duration: selectedDuration)
        sessionViewModel.startSession(session: session)
        
        // Update local state
        isTimerActive = true
        timeRemaining = selectedDuration
        progress = 1.0
        
        // Create a small "start" animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            timerScale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                timerScale = 1.0
            }
        }
        
        // Set up a timer to update the UI
        let updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // Update from view model
            self.timeRemaining = self.sessionViewModel.timeRemaining
            self.progress = self.sessionViewModel.progress
            self.isTimerActive = self.sessionViewModel.isTimerActive
            
            // Check if timer completed
            if self.sessionViewModel.isTimerComplete {
                self.showTimerCompletion()
                timer.invalidate()
            }
        }
        
        // Make sure the timer runs even when scrolling
        RunLoop.current.add(updateTimer, forMode: .common)
    }
    
    private func toggleTimer() {
        if isTimerActive {
            sessionViewModel.pauseTimer()
        } else {
            sessionViewModel.resumeTimer()
        }
        
        isTimerActive.toggle()
        
        // Create a small "tap" animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            timerScale = 0.98
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                timerScale = 1.0
            }
        }
    }
    
    private func resetTimer() {
        sessionViewModel.stopTimer()
        isTimerActive = false
        isSetupMode = true
        timeRemaining = selectedDuration
        progress = 1.0
    }
    
    private func showTimerCompletion() {
        // Create a completion animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            timerScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                timerScale = 1.0
            }
        }
        
        // Show completion message
        let completionView = VStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            Text("🎉 Session Complete!")
                .font(DPWRKStyle.Typography.heading2())
                .scaleEffect(y: 1.08)
                .foregroundColor(DPWRKStyle.Colors.success)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                        .fill(DPWRKStyle.Colors.success.opacity(0.1))
                )
            
            Text("Great job on your session!")
                .font(DPWRKStyle.Typography.bodyLarge())
                .foregroundColor(DPWRKStyle.Colors.primaryText)
                .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
            
            Button(action: {
                resetTimer()
            }) {
                Text("Return to Timer Setup")
                    .frame(minWidth: 140)
            }
            .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                .fill(DPWRKStyle.Colors.background)
                .shadow(color: DPWRKStyle.Colors.shadow, radius: 10, x: 0, y: 5)
        )
        .transition(.scale.combined(with: .opacity))
        
        // In a real implementation, we would transition to the reflection view
        // For now, we'll just show a completion message and reset the timer after a delay
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            // We would insert the completion view here in a real implementation
        }
        
        // Reset the timer after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            resetTimer()
        }
    }
    
    // Format time as "HH:MM:SS"
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// Custom button style for Edit Blocklist button
struct BlocklistButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .font(DPWRKStyle.Typography.sessionBody())
            .foregroundColor(Color(hex: "4F46E5"))
            .background(DPWRKStyle.Colors.background)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "4F46E5"), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    TimerView()
        .environmentObject(SessionViewModel())
}