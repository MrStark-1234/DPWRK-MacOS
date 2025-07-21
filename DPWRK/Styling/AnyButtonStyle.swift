//
//  AnyButtonStyle.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

/// A type-erased button style that can be used to wrap different button styles
/// in a ternary operator or other situations where Swift requires consistent types.
struct AnyButtonStyle: ButtonStyle {
    private let makeBody: (ButtonStyle.Configuration) -> AnyView
    
    init<S: ButtonStyle>(_ style: S) {
        makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        makeBody(configuration)
    }
}