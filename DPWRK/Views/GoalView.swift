//
//  GoalView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct GoalView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var goalText: String = ""
    @State private var isEditing: Bool = false
    @State private var placeholder: String = "Write your focus goal here..."
    
    // Debouncer for auto-saving
    @State private var saveTask: Task<Void, Never>?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Set Your Focus Goal")
                .font(DPWRKStyle.Typography.heading2())
                .scaleEffect(y: 1.08)
                .padding(.bottom, DPWRKStyle.Layout.spacingSmall)
            
            Text("What do you want to accomplish during this session?")
                .font(DPWRKStyle.Typography.body())
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
                .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
            
            // Custom notepad-style text editor
            NotepadTextEditor(
                text: $goalText,
                placeholder: placeholder,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
            .onChange(of: goalText) { oldValue, newValue in
                // Auto-save with debounce
                saveTask?.cancel()
                saveTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
                    if !Task.isCancelled {
                        await MainActor.run {
                            sessionViewModel.saveGoal(newValue)
                        }
                    }
                }
            }
            
            // Encouraging message that appears when user is typing
            if isEditing {
                Text("✨ Clear goals lead to focused work!")
                    .font(DPWRKStyle.Typography.emphasis())
                    .foregroundColor(DPWRKStyle.Colors.accent)
                    .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isEditing)
            }
            
            Spacer()
            
            Button("Start Session") {
                // This will be implemented in a future task
            }
            .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(DPWRKStyle.Layout.padding)
        .navigationTitle("🎯 Focus")
        .background(DPWRKStyle.Colors.background)
        .onAppear {
            // Load the last saved goal when the view appears
            goalText = sessionViewModel.loadLastGoal()
            // Set a random encouraging placeholder
            placeholder = sessionViewModel.getRandomPlaceholder()
        }
    }
}

#Preview {
    GoalView()
        .environmentObject(SessionViewModel())
}