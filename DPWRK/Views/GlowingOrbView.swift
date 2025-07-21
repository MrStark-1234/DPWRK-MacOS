//
//  GlowingOrbView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct GlowingOrbView: View {
    let progress: Double // 0.0 to 1.0
    let isActive: Bool
    let isPaused: Bool
    
    @State private var pulseAnimation: Bool = false
    @State private var rotationAnimation: Double = 0
    
    var body: some View {
        // Pre-calculate all values to avoid complex expressions
        let baseSize: CGFloat = 80
        let maxSize: CGFloat = 200
        let currentSize = baseSize + (maxSize - baseSize) * progress
        let orbSize = isPaused ? currentSize * 0.8 : currentSize
        
        let baseOpacity: Double = 0.3
        let maxOpacity: Double = 1.0
        let currentOpacity = baseOpacity + (maxOpacity - baseOpacity) * progress
        let orbOpacity = isPaused ? currentOpacity * 0.6 : currentOpacity
        
        let baseGlow: CGFloat = 10
        let maxGlow: CGFloat = 50
        let currentGlow = baseGlow + (maxGlow - baseGlow) * progress
        let glowRadius = isPaused ? currentGlow * 0.5 : currentGlow
        
        // Simple color selection
        let orbColor: Color = {
            if isPaused {
                return Color.orange
            } else if progress < 0.3 {
                return Color.blue
            } else if progress < 0.7 {
                return Color.cyan
            } else {
                return Color.yellow
            }
        }()
        
        ZStack {
            // Simple main orb
            Circle()
                .fill(orbColor)
                .frame(width: orbSize, height: orbSize)
                .shadow(color: orbColor, radius: glowRadius)
                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                .opacity(orbOpacity)
            
            // Inner highlight
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: orbSize * 0.6, height: orbSize * 0.6)
                .offset(x: -orbSize * 0.1, y: -orbSize * 0.1)
                .opacity(orbOpacity)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimations()
            } else {
                stopAnimations()
            }
        }
        .onChange(of: isPaused) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.3)) {
                    pulseAnimation = false
                }
            } else if isActive {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
    }
    
    private func stopAnimations() {
        withAnimation(.easeOut(duration: 0.5)) {
            pulseAnimation = false
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        GlowingOrbView(progress: 0.1, isActive: true, isPaused: false)
        GlowingOrbView(progress: 0.5, isActive: true, isPaused: false)
        GlowingOrbView(progress: 0.9, isActive: true, isPaused: false)
        GlowingOrbView(progress: 0.7, isActive: true, isPaused: true)
    }
    .padding()
    .background(Color.black)
}