//
//  CircularProgressView.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 240) {
        self.progress = min(max(progress, 0), 1) // Ensure progress is between 0 and 1
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    DPWRKStyle.Colors.accent.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    DPWRKStyle.Colors.accent,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeInOut, value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        CircularProgressView(progress: 0.25)
        CircularProgressView(progress: 0.5)
        CircularProgressView(progress: 0.75)
        CircularProgressView(progress: 1.0)
    }
    .padding()
}