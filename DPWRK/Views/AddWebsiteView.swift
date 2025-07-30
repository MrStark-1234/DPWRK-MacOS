//
//  AddWebsiteView.swift
//  DPWRK
//
//  Created on 30/07/25.
//

import SwiftUI

struct AddWebsiteView: View {
    @ObservedObject var blocklistViewModel: BlocklistViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var websiteURL = ""
    @State private var validationError: String?
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: DPWRKStyle.Layout.spacingLarge) {
            // Header
            HStack {
                Text("Add Website")
                    .font(DPWRKStyle.Typography.heading2())
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                }
                .buttonStyle(.plain)
            }
            
            // Input section
            VStack(alignment: .leading, spacing: DPWRKStyle.Layout.spacingSmall) {
                Text("Website URL")
                    .font(DPWRKStyle.Typography.sessionBody())
                    .fontWeight(.medium)
                    .foregroundColor(DPWRKStyle.Colors.primaryText)
                
                TextField("Enter website URL (e.g., reddit.com)", text: $websiteURL)
                    .font(DPWRKStyle.Typography.sessionBody())
                    .padding()
                    .background(DPWRKStyle.Colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                            .stroke(
                                validationError != nil ? DPWRKStyle.Colors.warning : DPWRKStyle.Colors.border,
                                lineWidth: validationError != nil ? 2 : 1
                            )
                    )
                    .focused($isTextFieldFocused)
                    .onChange(of: websiteURL) { _, newValue in
                        validateURL(newValue)
                    }
                    .onSubmit {
                        if validationError == nil && !websiteURL.isEmpty {
                            addWebsite()
                        }
                    }
                
                if let error = validationError {
                    Text(error)
                        .font(DPWRKStyle.Typography.sessionCaption())
                        .foregroundColor(DPWRKStyle.Colors.warning)
                }
                
                // Helper text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tips:")
                        .font(DPWRKStyle.Typography.sessionCaption())
                        .fontWeight(.medium)
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                    
                    Text("• Enter just the domain (e.g., reddit.com)")
                        .font(DPWRKStyle.Typography.sessionCaption())
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                    
                    Text("• No need to include http:// or www.")
                        .font(DPWRKStyle.Typography.sessionCaption())
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                    
                    Text("• Subdomains will be blocked automatically")
                        .font(DPWRKStyle.Typography.sessionCaption())
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                }
                .padding(.top, DPWRKStyle.Layout.spacingSmall)
            }
            
            Spacer()
            
            // Buttons
            HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(DPWRKStyle.SecondaryButtonStyle())
                .frame(minWidth: 100)
                
                Button("Add to Blocklist") {
                    addWebsite()
                }
                .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
                .frame(minWidth: 120)
                .disabled(websiteURL.isEmpty || validationError != nil)
            }
        }
        .padding(DPWRKStyle.Layout.spacingLarge)
        .frame(width: 400, height: 300)
        .background(DPWRKStyle.Colors.background)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func validateURL(_ url: String) {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            validationError = nil
            return
        }
        
        // Basic URL validation
        let urlPattern = #"^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$"#
        let cleanedURL = cleanWebsiteURL(trimmed)
        
        if cleanedURL.isEmpty {
            validationError = "Please enter a valid website URL"
            return
        }
        
        if cleanedURL.range(of: urlPattern, options: .regularExpression) == nil {
            // Check if it contains at least one dot for domain validation
            if !cleanedURL.contains(".") {
                validationError = "Please enter a valid domain (e.g., example.com)"
                return
            }
        }
        
        // Check if website already exists
        if blocklistViewModel.blocklistItems.contains(where: { $0.name == cleanedURL && $0.type == .website }) {
            validationError = "This website is already in your blocklist"
            return
        }
        
        validationError = nil
    }
    
    private func cleanWebsiteURL(_ url: String) -> String {
        var cleaned = url.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Remove common prefixes
        let prefixes = ["https://", "http://", "www."]
        for prefix in prefixes {
            if cleaned.hasPrefix(prefix) {
                cleaned = String(cleaned.dropFirst(prefix.count))
            }
        }
        
        // Remove trailing slash and path
        if let slashIndex = cleaned.firstIndex(of: "/") {
            cleaned = String(cleaned[..<slashIndex])
        }
        
        return cleaned
    }
    
    private func addWebsite() {
        guard validationError == nil && !websiteURL.isEmpty else { return }
        
        blocklistViewModel.addWebsite(websiteURL)
        dismiss()
    }
}

#Preview {
    AddWebsiteView(blocklistViewModel: BlocklistViewModel())
}