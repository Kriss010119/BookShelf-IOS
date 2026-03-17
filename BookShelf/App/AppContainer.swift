//
//  AppContainer.swift
//  BookShelf
//
//  Created by Kriss Osina on 08.02.2026.
//

import Foundation

@MainActor
final class AppContainer {
    
    static let shared = AppContainer()
    
    let coreDataManager: CoreDataManager
    let apiClient: APIClient
    let libraryViewModel: LibraryViewModel
    
    private init() {
        self.coreDataManager = CoreDataManager.shared
        self.apiClient = APIClient.shared
        self.libraryViewModel = LibraryViewModel(coreDataManager: coreDataManager)
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(apiClient: apiClient)
    }
}
