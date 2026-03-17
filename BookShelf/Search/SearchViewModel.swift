//
//  SearchViewModel.swift
//  BookShelf
//

import Foundation
import Combine
import UIKit

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchBook] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var searchQuery = ""
    @Published var selectedGenre: String?
    @Published var isEmptyState = true
    @Published var hasMoreResults = true
    @Published var totalResults = 0
    
    private var currentPage = 0
    private let resultsPerPage = 20
    private var currentSearchTask: Task<Void, Never>?
    private var currentQuery = ""
    private var currentGenre: String?
    private let imageCache = NSCache<NSString, UIImage>()
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func performSearch() async {
        currentQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        currentGenre = selectedGenre
        
        guard !currentQuery.isEmpty else {
            searchResults = []
            isEmptyState = true
            hasMoreResults = false
            return
        }
        
        currentSearchTask?.cancel()
        currentPage = 0
        hasMoreResults = true
        currentSearchTask = Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try Task.checkCancellation()
                let (results, total) = try await apiClient.searchBooks(
                    query: currentQuery,
                    genre: currentGenre,
                    startIndex: 0,
                    maxResults: resultsPerPage
                )
                try Task.checkCancellation()
                searchResults = results.map { SearchBook(from: $0) }
                totalResults = total
                isEmptyState = results.isEmpty
                hasMoreResults = results.count == resultsPerPage && total > resultsPerPage
                currentPage = results.isEmpty ? 0 : 1
                await preloadCovers(for: results)
            } catch {
                searchResults = []
                isEmptyState = true
                hasMoreResults = false
            }
        }
        await currentSearchTask?.value
    }
    
    func loadNextPage() async {
        guard !isLoadingMore && hasMoreResults && !currentQuery.isEmpty else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let nextPage = currentPage
            let (newResults, total) = try await apiClient.searchBooks(
                query: currentQuery,
                genre: currentGenre,
                startIndex: nextPage * resultsPerPage,
                maxResults: resultsPerPage
            )
            let newSearchBooks = newResults.map { SearchBook(from: $0) }
            let existingIDs = Set(searchResults.map { $0.id })
            let uniqueNewResults = newSearchBooks.filter { !existingIDs.contains($0.id) }
            searchResults.append(contentsOf: uniqueNewResults)
            let totalLoaded = (currentPage + 1) * resultsPerPage
            hasMoreResults = totalLoaded < total && !newResults.isEmpty
            currentPage += 1
            await preloadCovers(for: newResults)
            
        } catch {
            print("Ошибка загрузки следующей страницы: \(error)")
        }
    }
    
    func resetSearch() {
        searchResults = []
        currentQuery = ""
        currentGenre = nil
        currentPage = 0
        hasMoreResults = false
        isEmptyState = true
        totalResults = 0
        searchQuery = ""
        selectedGenre = nil
    }
    
    func shouldLoadMore(after item: SearchBook) -> Bool {
        guard hasMoreResults && !isLoadingMore else { return false }
        if let index = searchResults.firstIndex(where: { $0.id == item.id }) {
            return index >= searchResults.count - 5
        }
        return false
    }
    
    // MARK: - Image Loading
    func loadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        do {
            let data = try await apiClient.loadImage(from: urlString)
            guard let image = UIImage(data: data) else { return nil }
            imageCache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
    
    private func preloadCovers(for books: [BookDTO]) async {
        await withTaskGroup(of: Void.self) { group in
            for book in books.prefix(10) {
                guard let coverURL = book.coverImageURL else { continue }
                group.addTask {
                    _ = await self.loadImage(from: coverURL)
                }
            }
        }
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
    }
}
