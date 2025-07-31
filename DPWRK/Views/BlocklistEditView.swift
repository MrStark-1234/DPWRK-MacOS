//
//  BlocklistEditView.swift
//  DPWRK
//
//  Created on 30/07/25.
//

import SwiftUI

struct BlocklistEditView: View {
    @StateObject private var blocklistViewModel = BlocklistViewModel()
    @Binding var isPresented: Bool
    @State private var selectedMode: BlocklistMode = .blacklist
    @State private var showingAddToBlocked = false
    @State private var showingAddToAllowed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            // Mode Toggle
            modeToggle
            
            // Dual-List Panels
            dualListPanels
            
            // Action Buttons
            actionButtons
        }
        .background(DPWRKStyle.Colors.background)
        .onAppear {
            selectedMode = blocklistViewModel.currentMode
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text("Blocklist")
                .font(DPWRKStyle.Typography.heading1())
                .fontWeight(.light)
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
        .background(DPWRKStyle.Colors.background)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(DPWRKStyle.Colors.border),
            alignment: .bottom
        )
    }
    
    // MARK: - Mode Toggle
    
    private var modeToggle: some View {
        HStack {
            ForEach(BlocklistMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.displayName)
                        .font(DPWRKStyle.Typography.button())
                        .fontWeight(.medium)
                        .foregroundColor(selectedMode == mode ? .white : Color(hex: "4F46E5"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedMode == mode ? Color(hex: "4F46E5") : Color(hex: "F9FAFB"))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
    }
    
    // MARK: - Dual-List Panels
    
    private var dualListPanels: some View {
        HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            // Blocked Sites Panel
            websitePanel(
                title: "Blocked Sites",
                websites: blocklistViewModel.filteredBlockedWebsites,
                isActive: selectedMode == .blacklist,
                onAdd: { showingAddToBlocked = true },
                onRemove: { item in blocklistViewModel.removeItem(item, from: .blacklist) },
                onToggle: { item in blocklistViewModel.toggleItem(item, in: .blacklist) }
            )
            .sheet(isPresented: $showingAddToBlocked) {
                AddWebsiteToListView(
                    listType: .blacklist,
                    onAdd: { url in blocklistViewModel.addWebsite(url, to: .blacklist) }
                )
            }
            
            // Allowed Sites Panel
            websitePanel(
                title: "Allowed Sites",
                websites: blocklistViewModel.filteredAllowedWebsites,
                isActive: selectedMode == .whitelist,
                onAdd: { showingAddToAllowed = true },
                onRemove: { item in blocklistViewModel.removeItem(item, from: .whitelist) },
                onToggle: { item in blocklistViewModel.toggleItem(item, in: .whitelist) }
            )
            .sheet(isPresented: $showingAddToAllowed) {
                AddWebsiteToListView(
                    listType: .whitelist,
                    onAdd: { url in blocklistViewModel.addWebsite(url, to: .whitelist) }
                )
            }
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
    }
    
    // MARK: - Website Panel
    
    private func websitePanel(
        title: String,
        websites: [BlocklistItem],
        isActive: Bool,
        onAdd: @escaping () -> Void,
        onRemove: @escaping (BlocklistItem) -> Void,
        onToggle: @escaping (BlocklistItem) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DPWRKStyle.Layout.spacingMedium) {
            // Panel Title
            Text(title)
                .font(DPWRKStyle.Typography.button())
                .fontWeight(.semibold)
                .foregroundColor(DPWRKStyle.Colors.primaryText)
            
            // Website List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(websites) { website in
                        websiteRow(
                            website: website,
                            isActive: isActive,
                            onRemove: { onRemove(website) },
                            onToggle: { onToggle(website) }
                        )
                    }
                    
                    if websites.isEmpty {
                        emptyStateView(for: title)
                    }
                }
            }
            .frame(minHeight: 200)
            
            // Add Website Button
            Button(action: onAdd) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                    Text("Add Website")
                        .font(DPWRKStyle.Typography.button())
                }
                .foregroundColor(isActive ? Color(hex: "4F46E5") : DPWRKStyle.Colors.secondaryText)
            }
            .buttonStyle(.plain)
            .disabled(!isActive)
        }
        .padding(DPWRKStyle.Layout.spacingMedium)
        .background(Color(hex: "F9FAFB"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
        .cornerRadius(12)
        .opacity(isActive ? 1.0 : 0.5)
        .disabled(!isActive)
    }
    
    // MARK: - Website Row
    
    private func websiteRow(
        website: BlocklistItem,
        isActive: Bool,
        onRemove: @escaping () -> Void,
        onToggle: @escaping () -> Void
    ) -> some View {
        HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            // Website icon
            Image(systemName: "globe")
                .frame(width: 16, height: 16)
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
            
            // Website URL
            Text(website.name)
                .font(DPWRKStyle.Typography.button())
                .foregroundColor(DPWRKStyle.Colors.primaryText)
            
            Spacer()
            
            // Toggle switch
            Toggle("", isOn: Binding(
                get: { website.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle())
            .scaleEffect(0.8)
            .disabled(!isActive)
            
            // Delete button
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(isActive ? DPWRKStyle.Colors.warning : DPWRKStyle.Colors.secondaryText)
            }
            .buttonStyle(.plain)
            .disabled(!isActive)
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingSmall)
        .padding(.vertical, DPWRKStyle.Layout.spacingSmall)
        .frame(height: 48)
        .contentShape(Rectangle())
    }
    
    // MARK: - Empty State
    
    private func emptyStateView(for title: String) -> some View {
        VStack(spacing: DPWRKStyle.Layout.spacingSmall) {
            Image(systemName: title.contains("Blocked") ? "shield.slash" : "shield.checkered")
                .font(.system(size: 32))
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
            
            Text("No websites \(title.contains("Blocked") ? "blocked" : "allowed")")
                .font(DPWRKStyle.Typography.button())
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
        }
        .padding(.vertical, DPWRKStyle.Layout.spacingLarge)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            Button("Cancel") {
                isPresented = false
            }
            .buttonStyle(DPWRKStyle.SecondaryButtonStyle())
            .frame(minWidth: 100)
            
            Button("Save") {
                blocklistViewModel.currentMode = selectedMode
                blocklistViewModel.saveMode()
                isPresented = false
            }
            .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
            .frame(minWidth: 100)
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    return BlocklistEditView(isPresented: $isPresented)
        .frame(width: 700, height: 600)
}
