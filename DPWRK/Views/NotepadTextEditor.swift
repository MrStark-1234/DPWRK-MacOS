//
//  NotepadTextEditor.swift
//  DPWRK
//
//  Created on 18/07/25.
//

import SwiftUI

struct NotepadTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var onEditingChanged: ((Bool) -> Void)?
    
    @State private var isFocused: Bool = false
    @FocusState private var textFieldFocus: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Text editor with Georgia font styling
            TextEditor(text: $text)
                .font(DPWRKStyle.Typography.bodyLarge())
                .lineSpacing(8) // Add proper line spacing
                .focused($textFieldFocus)
                .scrollContentBackground(.hidden)
                .background(DPWRKStyle.Colors.background)
                .padding(DPWRKStyle.Layout.spacingMedium)
                .onChange(of: textFieldFocus) { oldValue, newValue in
                    isFocused = newValue
                    onEditingChanged?(newValue)
                }
            
            // Placeholder text that shows when the text is empty and not focused
            if text.isEmpty {
                Text(placeholder)
                    .font(DPWRKStyle.Typography.bodyLarge())
                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
                    .padding(DPWRKStyle.Layout.spacingMedium + 5) // Match TextEditor padding
                    .opacity(textFieldFocus ? 0.5 : 0.8)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: 200)
        .background(DPWRKStyle.Colors.background)
        .overlay(
            RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                .stroke(isFocused ? DPWRKStyle.Colors.accent : DPWRKStyle.Colors.border, lineWidth: isFocused ? 2 : 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        
        var body: some View {
            NotepadTextEditor(
                text: $text,
                placeholder: "What do you want to accomplish during this session?"
            )
            .padding()
        }
    }
    
    return PreviewWrapper()
}