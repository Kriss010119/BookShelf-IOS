//
//  SearchCategoriesViewModel.swift
//  BookShelf
//

import Foundation
import Combine

@MainActor
final class SearchCategoriesViewModel: ObservableObject {
    @Published var categories: [BookCategory] = BookCategory.categories
    @Published var categoryCounts: [String: Int] = [:]
    @Published var isLoading = false
    
    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func searchInCategory(_ category: BookCategory, query: String) async -> [BookDTO]? {
        do {
            let searchQuery = "\(query)+\(category.query)"
            return try await apiClient.searchBooks(query: searchQuery)
        } catch {
            print("Error searching in category: \(error)")
            return nil
        }
    }
}
