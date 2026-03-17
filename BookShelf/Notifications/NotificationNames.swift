//
//  NotificationNames.swift
//  BookShelf
//

import Foundation

extension Notification.Name {
    static let bookDataChanged = Notification.Name("bookDataChanged")
    static let bookAdded = Notification.Name("bookAdded")
    static let bookDeleted = Notification.Name("bookDeleted")
    static let bookUpdated = Notification.Name("bookUpdated")
    static let shelfChanged = Notification.Name("shelfChanged")
}
