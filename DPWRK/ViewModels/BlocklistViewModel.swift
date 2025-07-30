//
//  BlocklistViewModel.swift
//  DPWRK
//
//  Created on 30/07/25.
//

import Foundation
import AppKit

@MainActor
class BlocklistViewModel: ObservableObject {
    @Published var blocklistItems: [BlocklistItem] = []
    @Published var availableApplications: [MacOSApplication] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var websiteSearchText = ""
    
    private let userDefaults = UserDefaults.standard
    private let blocklistKey = "dpwrk_blocklist"
    
    init() {
        loadBlocklist()
        scanApplications()
    }
    
    // MARK: - Blocklist Management
    
    func loadBlocklist() {
        if let data = userDefaults.data(forKey: blocklistKey),
           let items = try? JSONDecoder().decode([BlocklistItem].self, from: data) {
            blocklistItems = items
        }
    }
    
    func saveBlocklist() {
        if let data = try? JSONEncoder().encode(blocklistItems) {
            userDefaults.set(data, forKey: blocklistKey)
        }
    }
    
    func addWebsite(_ url: String) {
        let cleanedURL = cleanWebsiteURL(url)
        guard !cleanedURL.isEmpty else { return }
        
        // Check if website already exists
        if !blocklistItems.contains(where: { $0.name == cleanedURL && $0.type == .website }) {
            let item = BlocklistItem(
                name: cleanedURL,
                type: .website,
                isEnabled: true,
                bundleIdentifier: nil,
                iconPath: nil
            )
            blocklistItems.append(item)
            saveBlocklist()
        }
    }
    
    func removeItem(_ item: BlocklistItem) {
        blocklistItems.removeAll { $0.id == item.id }
        saveBlocklist()
    }
    
    func toggleItem(_ item: BlocklistItem) {
        if let index = blocklistItems.firstIndex(where: { $0.id == item.id }) {
            blocklistItems[index].isEnabled.toggle()
            saveBlocklist()
        }
    }
    
    func addApplication(_ app: MacOSApplication) {
        // Check if application already exists
        if !blocklistItems.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            let item = BlocklistItem(
                name: app.name,
                type: .application,
                isEnabled: true,
                bundleIdentifier: app.bundleIdentifier,
                iconPath: app.iconPath
            )
            blocklistItems.append(item)
            saveBlocklist()
        }
    }
    
    func isApplicationBlocked(_ app: MacOSApplication) -> Bool {
        return blocklistItems.contains { item in
            item.bundleIdentifier == app.bundleIdentifier && item.type == .application
        }
    }
    
    // MARK: - Application Scanning
    
    func scanApplications() {
        isLoading = true
        
        Task {
            let apps = await scanMacOSApplications()
            await MainActor.run {
                self.availableApplications = apps
                self.isLoading = false
            }
        }
    }
    
    private func scanMacOSApplications() async -> [MacOSApplication] {
        var applications: [MacOSApplication] = []
        
        let applicationsPaths = [
            "/Applications",
            "/System/Applications",
            "~/Applications".expandingTildeInPath
        ]
        
        for path in applicationsPaths {
            let url = URL(fileURLWithPath: path)
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.isApplicationKey],
                    options: [.skipsHiddenFiles]
                )
                
                for appURL in contents {
                    if appURL.pathExtension == "app" {
                        if let app = createMacOSApplication(from: appURL) {
                            applications.append(app)
                        }
                    }
                }
            } catch {
                print("Error scanning \(path): \(error)")
            }
        }
        
        return applications.sorted { $0.name < $1.name }
    }
    
    private func createMacOSApplication(from url: URL) -> MacOSApplication? {
        guard let bundle = Bundle(url: url) else { return nil }
        
        let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                   bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                   url.deletingPathExtension().lastPathComponent
        
        let bundleIdentifier = bundle.bundleIdentifier ?? url.lastPathComponent
        
        // Get app icon path
        var iconPath: String?
        if let iconFile = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String {
            iconPath = bundle.path(forResource: iconFile, ofType: nil)
        }
        
        return MacOSApplication(
            name: name,
            bundleIdentifier: bundleIdentifier,
            iconPath: iconPath,
            category: nil // Could be enhanced with app categories
        )
    }
    
    // MARK: - Filtering
    
    var filteredApplications: [MacOSApplication] {
        if searchText.isEmpty {
            return availableApplications
        }
        return availableApplications.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredWebsites: [BlocklistItem] {
        let websites = blocklistItems.filter { $0.type == .website }
        if websiteSearchText.isEmpty {
            return websites
        }
        return websites.filter { item in
            item.name.localizedCaseInsensitiveContains(websiteSearchText)
        }
    }
    
    var blockedApplications: [BlocklistItem] {
        return blocklistItems.filter { $0.type == .application }
    }
    
    // MARK: - URL Cleaning
    
    private func cleanWebsiteURL(_ url: String) -> String {
        var cleaned = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove common prefixes
        let prefixes = ["https://", "http://", "www."]
        for prefix in prefixes {
            if cleaned.lowercased().hasPrefix(prefix) {
                cleaned = String(cleaned.dropFirst(prefix.count))
            }
        }
        
        // Remove trailing slash
        if cleaned.hasSuffix("/") {
            cleaned = String(cleaned.dropLast())
        }
        
        return cleaned
    }
}

extension String {
    var expandingTildeInPath: String {
        return NSString(string: self).expandingTildeInPath
    }
}