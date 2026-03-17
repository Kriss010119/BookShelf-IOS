//
//  SearchBooksViewController.swift
//  BookShelf
//

import UIKit
import Combine
import Foundation

final class SearchBooksViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookShelfCell.self, forCellReuseIdentifier: BookShelfCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .BookShelf.primaryText.withAlphaComponent(0.2)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Начните поиск книг"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.4)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите название книги или автора в поиске"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.3)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .BookShelf.primaryText
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .BookShelf.buttonBackground
        indicator.center = CGPoint(x: view.center.x, y: 30)
        indicator.startAnimating()
        view.addSubview(indicator)
        return view
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Поиск книг по названию, автору..."
        controller.searchBar.autocapitalizationType = .none
        controller.searchBar.searchTextField.backgroundColor = .BookShelf.cardBackground
        return controller
    }()
    
    // MARK: - Init
    init(viewModel: SearchViewModel) {
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
        setupBindings()
        setupSearch()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(activityIndicator)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 12),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    private func setupBindings() {
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.tableView.reloadData()
                self?.updateEmptyState()
                self?.tableView.tableFooterView = nil
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingMore in
                self?.tableView.tableFooterView = isLoadingMore ? self?.loadingFooterView : nil
            }
            .store(in: &cancellables)
        
        viewModel.$searchQuery
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                if query.isEmpty && self?.viewModel.searchResults.isEmpty == true {
                    self?.emptyStateLabel.text = "Начните поиск книг"
                    self?.emptyStateSubLabel.text = "Введите название книги или автора в поиске"
                    self?.emptyStateImageView.image = UIImage(systemName: "magnifyingglass")
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        if viewModel.searchResults.isEmpty && !viewModel.isLoading {
            if viewModel.searchQuery.isEmpty {
                emptyStateLabel.text = "Начните поиск книг"
                emptyStateSubLabel.text = "Введите название книги или автора в поиске"
                emptyStateImageView.image = UIImage(systemName: "magnifyingglass")
            } else {
                emptyStateLabel.text = "Ничего не найдено"
                emptyStateSubLabel.text = "Попробуйте изменить поисковый запрос"
                emptyStateImageView.image = UIImage(systemName: "book.closed")
            }
            emptyStateView.isHidden = false
        } else {
            emptyStateView.isHidden = true
        }
    }
    
    private func openExternalLink(_ urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            showAlert("Ошибка", "Не удалось открыть ссылку")
            return
        }
        UIApplication.shared.open(url)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAddToLibrarySheet(at indexPath: IndexPath) {
        let searchBook = viewModel.searchResults[indexPath.row]
        let bookDTO = searchBook.toBookDTO()
        
        let alert = UIAlertController(
            title: "Добавить книгу",
            message: "Выберите действие",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Ввести вручную", style: .default) { [weak self] _ in
            self?.openManualAdd(with: bookDTO)
        })
        
        alert.addAction(UIAlertAction(title: "Выбрать полку", style: .default) { [weak self] _ in
            self?.showShelfPicker(for: bookDTO)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            let cell = tableView.cellForRow(at: indexPath)
            popoverController.sourceView = cell
            popoverController.sourceRect = cell?.bounds ?? CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        present(alert, animated: true)
    }
    
    private func openManualAdd(with bookDTO: BookDTO) {
        let vc = AddBookViewController(book: bookDTO)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func showShelfPicker(for bookDTO: BookDTO) {
        let alert = UIAlertController(
            title: "Выберите полку",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let shelves = try await CoreDataManager.shared.fetchShelves()
                
                await MainActor.run {
                    if shelves.isEmpty {
                        alert.message = "У вас нет полок. Создайте полку в библиотеке."
                        alert.addAction(UIAlertAction(title: "Создать полку", style: .default) { _ in
                            self.showCreateShelfDialog(for: bookDTO)
                        })
                    } else {
                        for shelf in shelves {
                            let action = UIAlertAction(title: shelf.name, style: .default) { _ in
                                self.addBookToShelf(bookDTO, shelf: shelf)
                            }
                            alert.addAction(action)
                        }
                    }
                    
                    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                    
                    if let popoverController = alert.popoverPresentationController {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    }
                    
                    self.present(alert, animated: true)
                }
            } catch {
                print("Error fetching shelves: \(error)")
            }
        }
    }
    
    private func showCreateShelfDialog(for bookDTO: BookDTO) {
        let alert = UIAlertController(
            title: "Создать новую полку",
            message: "Введите название полки",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Название полки"
        }
        
        alert.addAction(UIAlertAction(title: "Создать", style: .default) { [weak self] _ in
            guard let shelfName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !shelfName.isEmpty else { return }
            
            Task {
                do {
                    let shelf = try await CoreDataManager.shared.createShelf(name: shelfName)
                    await MainActor.run {
                        self?.addBookToShelf(bookDTO, shelf: shelf)
                    }
                } catch {
                    print("Error creating shelf: \(error)")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addBookToShelf(_ bookDTO: BookDTO, shelf: Shelf) {
        let loadingAlert = UIAlertController(title: "Добавление...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                _ = try await CoreDataManager.shared.createBookWithImmediateUpdate(
                    title: bookDTO.title,
                    author: bookDTO.author,
                    genre: bookDTO.genre ?? "Неизвестно",
                    shelf: shelf,
                    rating: bookDTO.rating ?? 0,
                    pageCount: Int64(bookDTO.pageCount ?? 0),
                    publicationYear: Int64(bookDTO.publishedYear ?? 0),
                    coverImageURL: bookDTO.coverImageURL,
                    startDate: Date(),
                    annotation: bookDTO.description,
                    externalLink: bookDTO.previewLink ?? bookDTO.infoLink,
                    linkTitle: bookDTO.previewLink != nil ? "Google Books Preview" : "Google Books"
                )
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        DataChangeManager.shared.notifyBookAdded()
                        
                        let successAlert = UIAlertController(
                            title: "Успешно!",
                            message: "Книга добавлена на полку \"\(shelf.name ?? "")\"",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(successAlert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert("Ошибка", "Не удалось добавить книгу: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension SearchBooksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookShelfCell.reuseIdentifier, for: indexPath) as! BookShelfCell
        let searchBook = viewModel.searchResults[indexPath.row]
        configureCell(cell, with: searchBook)
        if viewModel.shouldLoadMore(after: searchBook) {
            Task {
                await viewModel.loadNextPage()
            }
        }
        return cell
    }
    
    private func configureCell(_ cell: BookShelfCell, with searchBook: SearchBook) {
        var metadata: [String] = []
        if let year = searchBook.publishedYear, year > 0 {
            metadata.append("\(year)")
        }
        if let pages = searchBook.pageCount, pages > 0 {
            metadata.append("\(pages) стр.")
        }
        if let genre = searchBook.genre, !genre.isEmpty {
            metadata.append(genre)
        }
        if let rating = searchBook.rating, rating > 0 {
            metadata.append(String(format: "%.1f ★", rating))
        }
        let metadataString = metadata.joined(separator: " • ")
        
        cell.configureWithSearchData(
            title: searchBook.title,
            author: searchBook.author,
            description: searchBook.description,
            coverURL: searchBook.coverImageURL,
            externalLink: searchBook.previewLink ?? searchBook.infoLink,
            linkTitle: searchBook.previewLink != nil ? "Предпросмотр" : "Подробнее",
            metadata: metadataString.isEmpty ? nil : metadataString,
            viewModel: viewModel
        )
        
        cell.onExternalLinkTapped = { [weak self] url in
            self?.openExternalLink(url)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let searchBook = viewModel.searchResults[indexPath.row]
        
        let detailVC = SearchBookDetailViewController(book: searchBook, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addAction = UIContextualAction(style: .normal, title: "Добавить") { [weak self] _, _, completion in
            self?.showAddToLibrarySheet(at: indexPath)
            completion(true)
        }
        addAction.backgroundColor = .BookShelf.success
        
        return UISwipeActionsConfiguration(actions: [addAction])
    }
}

// MARK: - UISearchBarDelegate
extension SearchBooksViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else { return }
        
        viewModel.searchQuery = query
        Task {
            await viewModel.performSearch()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.resetSearch()
        }
    }
}
