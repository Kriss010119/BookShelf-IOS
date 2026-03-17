//
//  MainTabBarController.swift
//  BookShelf
//

import UIKit

final class MainTabBarController: UITabBarController {
    private let container = AppContainer.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureTabBarAppearance()
    }
    
    private func setupTabs() {
        let libraryVC = LibraryViewController(viewModel: container.libraryViewModel)
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        libraryNav.tabBarItem = UITabBarItem(
            title: "Библиотека",
            image: UIImage(systemName: "books.vertical"),
            tag: 0
        )
        let categoriesVM = SearchCategoriesViewModel(apiClient: .shared)
        let categoriesVC = SearchCategoriesViewController(viewModel: categoriesVM)
        let searchNav = UINavigationController(rootViewController: categoriesVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "Поиск",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: nil
        )
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        viewControllers = [libraryNav, searchNav, profileNav]
    }
    
    private func configureTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .BookShelf.buttonBackground
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .BookShelf.primaryBackground
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .BookShelf.secondaryBackground
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.BookShelf.primaryBackground
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.BookShelf.secondaryBackground
        ]
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        tabBar.isTranslucent = false
    }
}
