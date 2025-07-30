//
//  DPWRKStyle.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

/// A centralized styling system for the DPWRK app
/// This file contains all typography, colors, and styling constants
/// to ensure consistency throughout the application
struct DPWRKStyle {
    
    // MARK: - Typography
    
    struct Typography {
        /// Font sizes used throughout the app
        struct FontSize {
            static let small: CGFloat = 12
            static let body: CGFloat = 14
            static let bodyLarge: CGFloat = 16
            static let title: CGFloat = 20
            static let largeTitle: CGFloat = 24
            static let timer: CGFloat = 48
        }
        
        /// Font families used in the app
        struct FontFamily {
            static let bodoni = "Bodoni 72"
            static let bodoniItalic = "Bodoni 72-Italic"
            static let bodoniBold = "Bodoni 72-Bold"
            static let bodoniBoldItalic = "Bodoni 72-BoldItalic"
            static let didot = "Didot"
            static let didotItalic = "Didot-Italic"
            static let didotBold = "Didot-Bold"
            static let didotBoldItalic = "Didot-BoldItalic"
            static let spaceMono = "Space Mono"
            static let sfPro = "SF Pro"
        }
        
        /// Reusable text styles for consistent typography
        static func heading1() -> Font {
            Font.custom(FontFamily.bodoni, size: FontSize.largeTitle)
        }
        
        static func heading2() -> Font {
            Font.custom(FontFamily.bodoni, size: FontSize.title)
        }
        
        static func heading3() -> Font {
            Font.custom(FontFamily.bodoni, size: FontSize.bodyLarge)
        }
        
        static func body() -> Font {
            Font.custom(FontFamily.didot, size: FontSize.body)
        }
        
        static func bodyLarge() -> Font {
            Font.custom(FontFamily.didot, size: FontSize.bodyLarge)
        }
        
        static func caption() -> Font {
            Font.custom(FontFamily.didot, size: FontSize.small)
        }
        
        static func emphasis() -> Font {
            Font.custom(FontFamily.didotItalic, size: FontSize.body)
        }
        
        // Bodoni variants for session setup and specific content
        static func sessionBody() -> Font {
            Font.custom(FontFamily.bodoni, size: FontSize.body)
        }
        
        static func sessionBodyLarge() -> Font {
            Font.custom(FontFamily.bodoni, size: FontSize.bodyLarge)
        }
        
        static func sessionCaption() -> Font {
            Font.custom(FontFamily.bodoni, size: FontSize.small)
        }
        
        static func sessionEmphasis() -> Font {
            Font.custom(FontFamily.bodoniItalic, size: FontSize.body)
        }
        
        static func timerDisplay() -> Font {
            Font.custom(FontFamily.spaceMono, size: FontSize.timer)
        }
        
        static func button() -> Font {
            Font.custom(FontFamily.sfPro, size: FontSize.body)
        }
    }
    
    // MARK: - Colors
    
    struct Colors {
        /// Primary colors
        static let background = Color.white
        static let primaryText = Color(hex: "1C1C1E") // Rich Black
        static let secondaryText = Color(hex: "8E8E93") // Medium Gray
        
        /// Accent colors
        static let accent = Color.blue // macOS system blue
        static let success = Color(hex: "34C759") // Forest Green
        static let warning = Color(hex: "FF9500") // Amber
        
        /// UI element colors
        static let border = Color.gray.opacity(0.3)
        static let shadow = Color.black.opacity(0.1)
    }
    
    // MARK: - Layout Constants
    
    struct Layout {
        /// Standard spacing values
        static let spacingSmall: CGFloat = 8
        static let spacingMedium: CGFloat = 16
        static let spacingLarge: CGFloat = 24
        
        /// Standard corner radius
        static let cornerRadius: CGFloat = 8
        
        /// Standard padding
        static let padding: EdgeInsets = EdgeInsets(
            top: spacingMedium,
            leading: spacingMedium,
            bottom: spacingMedium,
            trailing: spacingMedium
        )
    }
    
    // MARK: - View Modifiers
    
    /// Card style for content containers
    struct CardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(Layout.padding)
                .background(Colors.background)
                .cornerRadius(Layout.cornerRadius)
                .shadow(color: Colors.shadow, radius: 4, x: 0, y: 2)
        }
    }
    
    /// Text input field style
    struct TextInputStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .font(Typography.body())
                .background(Colors.background)
                .cornerRadius(Layout.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .stroke(Colors.border, lineWidth: 1)
                )
        }
    }
    
    /// Primary button style
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .font(Typography.button())
                .foregroundColor(.white)
                .background(Colors.accent)
                .cornerRadius(Layout.cornerRadius)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    /// Secondary button style
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .font(Typography.button())
                .foregroundColor(Colors.accent)
                .background(Colors.background)
                .cornerRadius(Layout.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .stroke(Colors.accent, lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}

// MARK: - View Extension for Modifiers

extension View {
    func cardStyle() -> some View {
        modifier(DPWRKStyle.CardStyle())
    }
    
    func textInputStyle() -> some View {
        modifier(DPWRKStyle.TextInputStyle())
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


extension DPWRKStyle {
    /// Custom tab view style for smooth transitions
    struct TabTransitionModifier: ViewModifier {
        let tabIndex: Int
        
        func body(content: Content) -> some View {
            content
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                .id("tab-\(tabIndex)")
        }
    }
}

extension View {
    func tabTransition(index: Int) -> some View {
        modifier(DPWRKStyle.TabTransitionModifier(tabIndex: index))
    }
}
