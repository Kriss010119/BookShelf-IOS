//
//  LibraryViewModel.swift
//  BookShelf
//

import Foundation
import Combine

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var totalShelvesCount: Int = 0
    @Published var totalBooksCount: Int = 0

    func loadLibrary() async {
        await loadShelves()
        await updateCounts()
    }

    private func updateCounts() async {
        totalShelvesCount = shelves.count
        do {
            totalBooksCount = try await coreDataManager.countAllBooks()
        } catch {
            print("Error counting books:", error)
        }
    }
    
    @Published private(set) var shelves: [Shelf] = []
    @Published var isLoading: Bool = false
    
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        Task {
            await loadShelves()
        }
    }
    
    func loadShelves() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            shelves = try await coreDataManager.fetchShelves()
            await updateCounts()
        } catch {
            print("Error loading shelves:", error)
            shelves = []
        }
    }
    
    func createShelf(name: String) {
        Task {
            do {
                try await coreDataManager.createShelf(name: name)
                await loadShelves()
            } catch {
                print("Error creating shelf:", error)
            }
        }
    }
    
    func deleteShelf(_ shelf: Shelf) {
        Task {
            do {
                try await coreDataManager.deleteShelf(shelf)
                await loadShelves()
            } catch {
                print("Error deleting shelf:", error)
            }
        }
    }
    
    func addBook(_ bookDTO: BookDTO, to shelf: Shelf) {
        Task {
            do {
                try await coreDataManager.addBook(bookDTO, to: shelf)
            } catch {
                print("Error adding book:", error)
            }
        }
    }
}
