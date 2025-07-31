//
//  DurationSelectionView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct DurationSelectionView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @Binding var selectedDuration: TimeInterval
    @Binding var isPresented: Bool
    @State private var showCustomInput: Bool = false
    @State private var customDuration: String = ""
    @State private var customInputError: String? = nil
    let onComplete: () -> Void
    
    // Preset durations in minutes
    private let presetDurations: [Int] = [15, 25, 45, 60]
    
    var body: some View {
        VStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            // Header
            HStack {
                Text("Select Session Duration")
                    .font(DPWRKStyle.Typography.heading1())
                   
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
            
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
                    .frame(maxWidth: 200)
                }
                .buttonStyle(AnyButtonStyle(DPWRKStyle.SecondaryButtonStyle()))
                
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
                                }
                            } else {
                                customInputError = "Please enter a number between 5 and 180"
                            }
                        }
                        .buttonStyle(AnyButtonStyle(DPWRKStyle.PrimaryButtonStyle()))
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
            
            // Selected duration display
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
            

            
            // Continue button
            Button(action: {
                // Save the selected duration as the default
                let success = sessionViewModel.updateSessionDuration(selectedDuration)
                
                if success {
                    // Provide haptic feedback for successful selection
                    #if os(macOS)
                    NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
                    #endif
                    
                    // Close this view and proceed to the next step
                    isPresented = false
                    onComplete()
                }
            }) {
                HStack {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .frame(minWidth: 100)
            }
            .buttonStyle(AnyButtonStyle(DPWRKStyle.PrimaryButtonStyle()))
            .padding(.top, DPWRKStyle.Layout.spacingMedium)
        }
        .padding(DPWRKStyle.Layout.spacingMedium)
        .frame(width: 450)
        .background(DPWRKStyle.Colors.background)
        .cornerRadius(DPWRKStyle.Layout.cornerRadius)
        .shadow(color: DPWRKStyle.Colors.shadow, radius: 10, x: 0, y: 5)
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
            .frame(minWidth: 50, minHeight: 50)
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
    
    // Format duration as "X hours Y minutes"
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
    
    // Format time as "HH:MM:SS"
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    @State var isPresented = true
    @State var duration: TimeInterval = 25 * 60
    
    return DurationSelectionView(
        selectedDuration: $duration,
        isPresented: $isPresented,
        onComplete: {}
    )
    .environmentObject(SessionViewModel())
    .padding()
    .background(Color.gray.opacity(0.3))
}
