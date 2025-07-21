//
//  ContentView.swift
//  DPWRK
//
//  Created by Johan Biju Paul on 18/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionViewModel = SessionViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TimerView()
                    .tabTransition(index: 0)
            }
            .tag(0)
            .tabItem {
                Image(systemName: "timer")
                Text("⏱️ Timer")
            }
            
            NavigationStack {
                InsightsView()
                    .tabTransition(index: 1)
            }
            .tag(1)
            .tabItem {
                Image(systemName: "chart.bar")
                Text("📊 Insights")
            }
            
            NavigationStack {
                SettingsView()
                    .tabTransition(index: 2)
            }
            .tag(2)
            .tabItem {
                Image(systemName: "gear")
                Text("⚙️ Settings")
            }
        }
        .environmentObject(sessionViewModel)
        .font(DPWRKStyle.Typography.body())
        .foregroundColor(DPWRKStyle.Colors.primaryText)
        .background(DPWRKStyle.Colors.background)
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Set the appearance for macOS
            NSWindow.allowsAutomaticWindowTabbing = false
            
            // Apply custom tab bar appearance
            let appearance = NSAppearance(named: .aqua)
            NSApp.appearance = appearance
        }
    }
}

#Preview {
    ContentView()
}
