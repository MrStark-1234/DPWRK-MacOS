//
//  SessionNotesView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct SessionNotesView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var sessionGoal: String
    @Binding var isPresented: Bool
    let onStart: () -> Void
    
    init(isPresented: Binding<Bool>, onStart: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onStart = onStart
        self._sessionGoal = State(initialValue: SessionViewModel().loadLastGoal())
    }
    
    var body: some View {
        VStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            // Header
            HStack {
                Text("Session Notes")
                    .font(DPWRKStyle.Typography.heading2())
                    .scaleEffect(y: 1.08)
                
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
            .padding(.bottom, DPWRKStyle.Layout.spacingSmall)
            
            // Session goal input
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your goal for this session?")
                    .font(DPWRKStyle.Typography.bodyLarge())
                    .foregroundColor(DPWRKStyle.Colors.primaryText)
                
                TextEditor(text: $sessionGoal)
                    .font(DPWRKStyle.Typography.body())
                    .padding()
                    .frame(height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                            .stroke(DPWRKStyle.Colors.border, lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if sessionGoal.isEmpty {
                                Text(sessionViewModel.getRandomPlaceholder())
                                    .font(DPWRKStyle.Typography.body())
                                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
                                    .padding()
                                    .allowsHitTesting(false)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                    )
            }
            
            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Text("Tips for a productive session:")
                    .font(DPWRKStyle.Typography.bodyLarge())
                    .foregroundColor(DPWRKStyle.Colors.primaryText)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DPWRKStyle.Colors.success)
                    
                    Text("Set a clear, specific goal for this session")
                        .font(DPWRKStyle.Typography.body())
                        .foregroundColor(DPWRKStyle.Colors.primaryText)
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DPWRKStyle.Colors.success)
                    
                    Text("Remove distractions from your environment")
                        .font(DPWRKStyle.Typography.body())
                        .foregroundColor(DPWRKStyle.Colors.primaryText)
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DPWRKStyle.Colors.success)
                    
                    Text("Take a short break after your session")
                        .font(DPWRKStyle.Typography.body())
                        .foregroundColor(DPWRKStyle.Colors.primaryText)
                }
            }
            .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
            
            // Action buttons
            HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(minWidth: 80)
                }
                .buttonStyle(DPWRKStyle.SecondaryButtonStyle())
                
                Button(action: {
                    // Save the goal
                    sessionViewModel.saveGoal(sessionGoal)
                    
                    // Close the sheet and start the session
                    isPresented = false
                    onStart()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Session")
                    }
                    .frame(minWidth: 120)
                }
                .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
            }
            .padding(.top, DPWRKStyle.Layout.spacingMedium)
        }
        .padding(DPWRKStyle.Layout.spacingMedium)
        .frame(width: 450)
        .background(DPWRKStyle.Colors.background)
        .cornerRadius(DPWRKStyle.Layout.cornerRadius)
        .shadow(color: DPWRKStyle.Colors.shadow, radius: 10, x: 0, y: 5)
        .onAppear {
            // Load the last saved goal when the view appears
            sessionGoal = sessionViewModel.loadLastGoal()
        }
    }
}

#Preview {
    @State var isPresented = true
    
    return SessionNotesView(isPresented: $isPresented, onStart: {})
        .environmentObject(SessionViewModel())
        .padding()
        .background(Color.gray.opacity(0.3))
}