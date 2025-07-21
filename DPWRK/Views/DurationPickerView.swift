//
//  DurationPickerView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct DurationPickerView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @Binding var selectedDuration: TimeInterval
    @State private var customDuration: String = ""
    @State private var showCustomInput: Bool = false
    @State private var customInputError: String? = nil
    
    // Preset durations in minutes
    private let presetDurations: [Int] = [15, 25, 45, 60]
    
    var body: some View {
        VStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            Text("Select Session Duration")
                .font(DPWRKStyle.Typography.heading2())
                .scaleEffect(y: 1.08)
                .padding(.bottom, DPWRKStyle.Layout.spacingSmall)
            
            // Preset duration buttons
            HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
                ForEach(presetDurations, id: \.self) { minutes in
                    durationButton(minutes: minutes)
                }
            }
            .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
            
            // Custom duration button and input field
            VStack(spacing: DPWRKStyle.Layout.spacingSmall) {
                Button(action: {
                    withAnimation {
                        showCustomInput.toggle()
                        if !showCustomInput {
                            customInputError = nil
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Custom Duration")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(DPWRKStyle.SecondaryButtonStyle())
                
                if showCustomInput {
                    HStack {
                        TextField("5-180", text: $customDuration)
                            .frame(width: 100)
                            .onChange(of: customDuration) { _, newValue in
                                validateCustomDuration(newValue)
                            }
                        
                        Text("minutes")
                            .foregroundColor(DPWRKStyle.Colors.secondaryText)
                        
                        Button("Set") {
                            if let minutes = Int(customDuration), minutes >= 5 && minutes <= 180 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDuration = TimeInterval(minutes * 60)
                                    customInputError = nil
                                    
                                    // Save the selected duration as the default
                                    var preferences = sessionViewModel.userPreferences
                                    preferences.defaultDuration = selectedDuration
                                    sessionViewModel.updatePreferences(preferences: preferences)
                                    
                                    // Provide haptic feedback for successful selection
                                    #if os(macOS)
                                    NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
                                    #endif
                                }
                            } else {
                                customInputError = "Please enter a number between 5 and 180"
                            }
                        }
                        .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
                        .disabled(customInputError != nil)
                    }
                    
                    if let error = customInputError {
                        Text(error)
                            .font(DPWRKStyle.Typography.caption())
                            .foregroundColor(DPWRKStyle.Colors.warning)
                            .padding(.top, 4)
                    }
                }
            }
            
            // Selected duration display with enhanced visual feedback
            HStack {
                Text("Selected Duration:")
                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
                
                Text(formatDuration(selectedDuration))
                    .font(DPWRKStyle.Typography.bodyLarge())
                    .fontWeight(.bold)
                    .foregroundColor(DPWRKStyle.Colors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                            .fill(DPWRKStyle.Colors.accent.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                            .stroke(DPWRKStyle.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.top, DPWRKStyle.Layout.spacingMedium)
            .animation(.easeInOut(duration: 0.2), value: selectedDuration)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                .fill(DPWRKStyle.Colors.background)
                .shadow(color: DPWRKStyle.Colors.shadow, radius: 4)
        )
        .onAppear {
            // Initialize custom duration field with the current selected duration if it's not a preset
            if !presetDurations.contains(Int(selectedDuration / 60)) {
                customDuration = "\(Int(selectedDuration / 60))"
                showCustomInput = true
            }
        }
    }
    
    // Button for preset durations
    private func durationButton(minutes: Int) -> some View {
        let isSelected = Int(selectedDuration / 60) == minutes
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDuration = TimeInterval(minutes * 60)
                customInputError = nil
                showCustomInput = false
                
                // Save the selected duration as the default
                var preferences = sessionViewModel.userPreferences
                preferences.defaultDuration = selectedDuration
                sessionViewModel.updatePreferences(preferences: preferences)
            }
        }) {
            VStack {
                Text("\(minutes)")
                    .font(isSelected ? DPWRKStyle.Typography.bodyLarge() : DPWRKStyle.Typography.body())
                    .fontWeight(isSelected ? .bold : .regular)
                
                Text("min")
                    .font(DPWRKStyle.Typography.caption())
                    .foregroundColor(isSelected ? DPWRKStyle.Colors.accent : DPWRKStyle.Colors.secondaryText)
            }
            .frame(minWidth: 80, minHeight: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(isSelected ? AnyButtonStyle(DPWRKStyle.PrimaryButtonStyle()) : AnyButtonStyle(DPWRKStyle.SecondaryButtonStyle()))
        .background(
            isSelected ? 
                RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                .fill(DPWRKStyle.Colors.accent.opacity(0.1))
                .shadow(color: DPWRKStyle.Colors.accent.opacity(0.3), radius: 4)
                : nil
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
    
    // Validate custom duration input
    private func validateCustomDuration(_ input: String) {
        if input.isEmpty {
            customInputError = nil
            return
        }
        
        if let minutes = Int(input) {
            if minutes < 5 {
                customInputError = "Duration must be at least 5 minutes"
            } else if minutes > 180 {
                customInputError = "Duration must be at most 180 minutes"
            } else {
                customInputError = nil
            }
        } else {
            customInputError = "Please enter a valid number"
        }
    }
    
    // Format duration as "HH:MM:SS"
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d hour%@ %d minute%@", 
                         hours, hours == 1 ? "" : "s",
                         minutes, minutes == 1 ? "" : "s")
        } else {
            return String(format: "%d minute%@", minutes, minutes == 1 ? "" : "s")
        }
    }
}

#Preview {
    @State var duration: TimeInterval = 25 * 60
    
    return DurationPickerView(selectedDuration: $duration)
        .environmentObject(SessionViewModel())
        .padding()
        .frame(width: 600)
}
