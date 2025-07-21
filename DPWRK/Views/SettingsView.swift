//
//  SettingsView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        VStack(spacing: DPWRKStyle.Layout.spacingLarge) {
            Text("⚙️ Settings")
                .font(DPWRKStyle.Typography.heading1())
                .scaleEffect(y: 1.08)
            
            Text("App preferences and settings will be implemented in a future task")
                .font(DPWRKStyle.Typography.body())
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding(DPWRKStyle.Layout.padding)
        .background(DPWRKStyle.Colors.background)
        .navigationTitle("⚙️ Settings")
    }
}

#Preview {
    SettingsView()
        .environmentObject(SessionViewModel())
}