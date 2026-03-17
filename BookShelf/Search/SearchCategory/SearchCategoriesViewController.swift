//
//  SearchCategoriesViewController.swift
//  BookShelf
//

import UIKit
import Combine
import Foundation

final class SearchCategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SearchCategoriesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Поиск книг по названию, автору..."
        controller.searchBar.autocapitalizationType = .none
        controller.searchBar.searchTextField.backgroundColor = .BookShelf.cardBackground
        return controller
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите категорию для поиска"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(BookCategoryCell.self, forCellWithReuseIdentifier: BookCategoryCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Init
    init(viewModel: SearchCategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearch()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        view.addSubview(subtitleLabel)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    private func showSearchResults(for query: String, title: String) {
        let searchVM = SearchViewModel(apiClient: .shared)
        searchVM.searchQuery = query
        let searchVC = SearchBooksViewController(viewModel: searchVM)
        searchVC.title = title
        navigationController?.pushViewController(searchVC, animated: true)
    }

    private func showSearchResults(for category: BookCategory) {
        let searchVM = SearchViewModel(apiClient: .shared)
        searchVM.searchQuery = category.query
        searchVM.selectedGenre = nil
        let searchVC = SearchBooksViewController(viewModel: searchVM)
        searchVC.title = category.name
        navigationController?.pushViewController(searchVC, animated: true)
        
        Task {
            await searchVM.performSearch()
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension SearchCategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCategoryCell.reuseIdentifier, for: indexPath) as! BookCategoryCell
        let category = viewModel.categories[indexPath.item]
        
        cell.configure(with: category)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: width / 2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.item]
        showSearchResults(for: category)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchCategoriesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else { return }
        
        showSearchResults(for: query, title: "Результаты поиска")
        searchBar.resignFirstResponder()
    }
}
