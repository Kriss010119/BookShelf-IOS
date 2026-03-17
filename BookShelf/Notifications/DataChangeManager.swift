//
//  DataChangeManager.swift
//  BookShelf
//

import Foundation
import Combine

@MainActor
final class DataChangeManager: ObservableObject {
    static let shared = DataChangeManager()
    
    @Published var lastChangeTimestamp = Date()
    @Published var lastChangeType: ChangeType = .unknown
    
    enum ChangeType: String {
        case bookAdded = "bookAdded"
        case bookDeleted = "bookDeleted"
        case bookUpdated = "bookUpdated"
        case shelfChanged = "shelfChanged"
        case unknown = "unknown"
    }
    
    private init() {}
    
    func notifyBookAdded() {
        lastChangeTimestamp = Date()
        lastChangeType = .bookAdded
        NotificationCenter.default.post(name: .bookDataChanged, object: nil)
        NotificationCenter.default.post(name: .bookAdded, object: nil)
    }
    
    func notifyBookDeleted() {
        lastChangeTimestamp = Date()
        lastChangeType = .bookDeleted
        NotificationCenter.default.post(name: .bookDataChanged, object: nil)
        NotificationCenter.default.post(name: .bookDeleted, object: nil)
    }
    
    func notifyBookUpdated() {
        lastChangeTimestamp = Date()
        lastChangeType = .bookUpdated
        NotificationCenter.default.post(name: .bookDataChanged, object: nil)
        NotificationCenter.default.post(name: .bookUpdated, object: nil)
    }
    
    func notifyShelfChanged() {
        lastChangeTimestamp = Date()
        lastChangeType = .shelfChanged
        NotificationCenter.default.post(name: .bookDataChanged, object: nil)
        NotificationCenter.default.post(name: .shelfChanged, object: nil)
    }
}
