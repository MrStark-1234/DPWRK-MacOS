//
//  InsightsView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        VStack(spacing: DPWRKStyle.Layout.spacingLarge) {
            Text("📊 Insights")
                .font(DPWRKStyle.Typography.heading1())
                .scaleEffect(y: 1.08)
            
            Text("Your productivity insights will appear here")
                .font(DPWRKStyle.Typography.body())
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Complete focus sessions to see your progress!")
                .font(DPWRKStyle.Typography.emphasis())
                .foregroundColor(DPWRKStyle.Colors.accent)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding(DPWRKStyle.Layout.padding)
        .background(DPWRKStyle.Colors.background)
        .navigationTitle("📊 Insights")
    }
}

#Preview {
    InsightsView()
        .environmentObject(SessionViewModel())
}