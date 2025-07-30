//
//  BlocklistItem.swift
//  DPWRK
//
//  Created on 30/07/25.
//

import Foundation

struct BlocklistItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: BlocklistType
    var isEnabled: Bool
    let bundleIdentifier: String?
    let iconPath: String?
    
    enum BlocklistType: String, Codable, CaseIterable {
        case application = "application"
        case website = "website"
    }
}

enum BlocklistMode: String, Codable, CaseIterable {
    case blacklist = "blacklist"
    case whitelist = "whitelist"
    
    var displayName: String {
        switch self {
        case .blacklist: return "Blacklist"
        case .whitelist: return "Whitelist"
        }
    }
}

struct MacOSApplication: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let iconPath: String?
    let category: String?
}