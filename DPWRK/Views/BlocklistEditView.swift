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
    @State private var showingAddWebsite = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            // Tab Selection
            tabSelector
            
            // Content
            Group {
                if selectedTab == 0 {
                    applicationsSection
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    websitesSection
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .background(DPWRKStyle.Colors.background)
        .sheet(isPresented: $showingAddWebsite) {
            AddWebsiteView(blocklistViewModel: blocklistViewModel)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text("Edit Blocklist")
                .font(DPWRKStyle.Typography.heading1())
                .fontWeight(.semibold)
            
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
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Applications", index: 0)
            tabButton(title: "Websites", index: 1)
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.top, DPWRKStyle.Layout.spacingMedium)
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(DPWRKStyle.Typography.sessionBody())
                    .fontWeight(selectedTab == index ? .semibold : .regular)
                    .foregroundColor(selectedTab == index ? DPWRKStyle.Colors.accent : DPWRKStyle.Colors.secondaryText)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(selectedTab == index ? DPWRKStyle.Colors.accent : Color.clear)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Applications Section
    
    private var applicationsSection: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
                
                TextField("Search applications...", text: $blocklistViewModel.searchText)
                    .font(DPWRKStyle.Typography.sessionBody())
            }
            .padding()
            .background(DPWRKStyle.Colors.background)
            .overlay(
                RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                    .stroke(DPWRKStyle.Colors.border, lineWidth: 1)
            )
            .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
            .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
            
            // Applications list
            if blocklistViewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Scanning applications...")
                        .font(DPWRKStyle.Typography.sessionBody())
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                        .padding(.top, DPWRKStyle.Layout.spacingSmall)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(blocklistViewModel.filteredApplications) { app in
                            applicationRow(app)
                        }
                    }
                }
            }
        }
    }
    
    private func applicationRow(_ app: MacOSApplication) -> some View {
        HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            // App icon
            if let iconPath = app.iconPath,
               let image = NSImage(contentsOfFile: iconPath) {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "app.fill")
                    .frame(width: 16, height: 16)
                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
            }
            
            // App name
            Text(app.name)
                .font(DPWRKStyle.Typography.sessionBody())
                .foregroundColor(DPWRKStyle.Colors.primaryText)
            
            Spacer()
            
            // Checkbox
            Button(action: {
                if blocklistViewModel.isApplicationBlocked(app) {
                    if let item = blocklistViewModel.blockedApplications.first(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
                        blocklistViewModel.removeItem(item)
                    }
                } else {
                    blocklistViewModel.addApplication(app)
                }
            }) {
                Image(systemName: blocklistViewModel.isApplicationBlocked(app) ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(blocklistViewModel.isApplicationBlocked(app) ? DPWRKStyle.Colors.accent : DPWRKStyle.Colors.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.vertical, DPWRKStyle.Layout.spacingSmall)
        .contentShape(Rectangle())
        .onTapGesture {
            if blocklistViewModel.isApplicationBlocked(app) {
                if let item = blocklistViewModel.blockedApplications.first(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
                    blocklistViewModel.removeItem(item)
                }
            } else {
                blocklistViewModel.addApplication(app)
            }
        }
    }
    
    // MARK: - Websites Section
    
    private var websitesSection: some View {
        VStack(spacing: 0) {
            // Add website button
            HStack {
                Button(action: {
                    showingAddWebsite = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Website")
                    }
                }
                .buttonStyle(DPWRKStyle.PrimaryButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
            .padding(.vertical, DPWRKStyle.Layout.spacingMedium)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DPWRKStyle.Colors.secondaryText)
                
                TextField("Search websites...", text: $blocklistViewModel.websiteSearchText)
                    .font(DPWRKStyle.Typography.sessionBody())
            }
            .padding()
            .background(DPWRKStyle.Colors.background)
            .overlay(
                RoundedRectangle(cornerRadius: DPWRKStyle.Layout.cornerRadius)
                    .stroke(DPWRKStyle.Colors.border, lineWidth: 1)
            )
            .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
            .padding(.bottom, DPWRKStyle.Layout.spacingMedium)
            
            // Websites list
            if blocklistViewModel.filteredWebsites.isEmpty {
                VStack {
                    Image(systemName: "globe.badge.chevron.backward")
                        .font(.system(size: 48))
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                    
                    Text("No websites blocked")
                        .font(DPWRKStyle.Typography.sessionBodyLarge())
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                        .padding(.top, DPWRKStyle.Layout.spacingSmall)
                    
                    Text("Add websites to block during focus sessions")
                        .font(DPWRKStyle.Typography.sessionBody())
                        .foregroundColor(DPWRKStyle.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(blocklistViewModel.filteredWebsites) { website in
                            websiteRow(website)
                        }
                    }
                }
            }
        }
    }
    
    private func websiteRow(_ website: BlocklistItem) -> some View {
        HStack(spacing: DPWRKStyle.Layout.spacingMedium) {
            // Website icon
            Image(systemName: "globe")
                .frame(width: 16, height: 16)
                .foregroundColor(DPWRKStyle.Colors.secondaryText)
            
            // Website URL
            Text(website.name)
                .font(DPWRKStyle.Typography.sessionBody())
                .foregroundColor(DPWRKStyle.Colors.primaryText)
            
            Spacer()
            
            // Toggle switch
            Toggle("", isOn: Binding(
                get: { website.isEnabled },
                set: { _ in blocklistViewModel.toggleItem(website) }
            ))
            .toggleStyle(SwitchToggleStyle())
            .scaleEffect(0.8)
            
            // Delete button
            Button(action: {
                blocklistViewModel.removeItem(website)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(DPWRKStyle.Colors.warning)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DPWRKStyle.Layout.spacingLarge)
        .padding(.vertical, DPWRKStyle.Layout.spacingSmall)
    }
}

#Preview {
    @State var isPresented = true
    
    return BlocklistEditView(isPresented: $isPresented)
        .frame(width: 600, height: 500)
}