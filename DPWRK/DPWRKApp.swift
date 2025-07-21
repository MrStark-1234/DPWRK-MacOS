//
//  DPWRKApp.swift
//  DPWRK
//
//  Created by Johan Biju Paul on 18/07/25.
//

import SwiftUI

@main
struct DPWRKApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Set up any app initialization here
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Add custom menu commands here if needed
            SidebarCommands()
            
            // Custom commands for the app
            CommandGroup(replacing: .newItem) {
                Button("New Session") {
                    // This will be implemented in a future task
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

// AppDelegate to handle application lifecycle and window configuration
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure window appearance
        if let window = NSApplication.shared.windows.first {
            // Set window properties
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = NSColor.white
            
            // Set window size constraints
            window.minSize = NSSize(width: 800, height: 600)
            window.setContentSize(NSSize(width: 1000, height: 700))
            
            // Center the window on the screen
            window.center()
            
            // Add smooth animations for window resizing
            window.animationBehavior = .documentWindow
        }
    }
}
