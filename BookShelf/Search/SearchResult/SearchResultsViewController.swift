//
//  SearchResultsViewController.swift
//  BookShelf
//

import UIKit
import Combine
import Foundation

final class SearchResultsViewController: UIViewController {
    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let filtersScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let filtersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BookShelfCell.self, forCellReuseIdentifier: BookShelfCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 140
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
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
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Начните поиск, выбрав жанр или введя запрос"
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.6)
        label.font = Typography.body.font
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Найти", for: .normal)
        button.buttonStyle = .primary
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupFilters()
        setupSearchButton()
    }
    
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        title = "Поиск книг"
        
        view.addSubview(filtersScrollView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)
        view.addSubview(searchButton)
        
        filtersScrollView.addSubview(filtersStackView)
        
        NSLayoutConstraint.activate([
            filtersScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filtersScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filtersScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filtersScrollView.heightAnchor.constraint(equalToConstant: 40),
            
            filtersStackView.topAnchor.constraint(equalTo: filtersScrollView.topAnchor),
            filtersStackView.leadingAnchor.constraint(equalTo: filtersScrollView.leadingAnchor),
            filtersStackView.trailingAnchor.constraint(equalTo: filtersScrollView.trailingAnchor),
            filtersStackView.bottomAnchor.constraint(equalTo: filtersScrollView.bottomAnchor),
            filtersStackView.heightAnchor.constraint(equalTo: filtersScrollView.heightAnchor),
            
            tableView.topAnchor.constraint(equalTo: filtersScrollView.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            searchButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
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
                    self?.emptyStateLabel.isHidden = true
                    self?.searchButton.isHidden = true
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
        
        viewModel.$selectedGenre
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateFiltersAppearance()
            }
            .store(in: &cancellables)
        
        viewModel.$searchQuery
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                self?.updateSearchButtonVisibility()
            }
            .store(in: &cancellables)
    }
    
    private func setupFilters() {
        let genres = ["Все", "Фантастика", "Детектив", "Роман", "История", "Поэзия", "Наука"]
        
        for genre in genres {
            let button = PrimaryButton(type: .system)
            button.setTitle(genre, for: .normal)
            button.buttonStyle = .outline
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.addAction(
                UIAction { [weak self] _ in
                    self?.viewModel.selectedGenre = (genre == "Все") ? nil : genre
                },
                for: .touchUpInside
            )
            filtersStackView.addArrangedSubview(button)
        }
    }
    
    private func setupSearchButton() {
        searchButton.addAction(
            UIAction { [weak self] _ in
                Task {
                    await self?.viewModel.performSearch()
                }
            },
            for: .touchUpInside
        )
    }
    
    private func updateFiltersAppearance() {
        for case let button as PrimaryButton in filtersStackView.arrangedSubviews {
            let title = button.title(for: .normal) ?? ""
            let isSelected = title == viewModel.selectedGenre ||
                           (viewModel.selectedGenre == nil && title == "Все")
            
            button.buttonStyle = isSelected ? .primary : .outline
        }
    }
    
    private func updateEmptyState() {
        if viewModel.searchResults.isEmpty {
            if viewModel.searchQuery.isEmpty && viewModel.selectedGenre == nil {
                emptyStateLabel.text = "Начните поиск, выбрав жанр или введя запрос"
            } else {
                emptyStateLabel.text = "Ничего не найдено\nПопробуйте изменить параметры поиска"
            }
            emptyStateLabel.isHidden = false
        } else {
            emptyStateLabel.isHidden = true
        }
        
        updateSearchButtonVisibility()
    }
    
    private func updateSearchButtonVisibility() {
        let hasQuery = !viewModel.searchQuery.isEmpty
        let hasGenre = viewModel.selectedGenre != nil
        let hasNoResults = viewModel.searchResults.isEmpty
        
        searchButton.isHidden = !(hasQuery || hasGenre) || !hasNoResults
    }
}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            linkTitle: searchBook.previewLink != nil ? "Ссылка" : "Подробнее",
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
        showBookPreview(searchBook)
    }
    
    private func showBookPreview(_ searchBook: SearchBook) {
        let bookDTO = searchBook.toBookDTO()
        let addBookVC = AddBookViewController(book: bookDTO)
        let navController = UINavigationController(rootViewController: addBookVC)
        navController.navigationBar.tintColor = .BookShelf.buttonBackground
        present(navController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addAction = UIContextualAction(style: .normal, title: "Добавить") { [weak self] _, _, completion in
            self?.showAddToLibrarySheet(at: indexPath)
            completion(true)
        }
        addAction.backgroundColor = .BookShelf.success
        return UISwipeActionsConfiguration(actions: [addAction])
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
    
    private func openExternalLink(_ urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            showError("Не удалось открыть ссылку")
            return
        }
        UIApplication.shared.open(url)
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
                        self.showError("Не удалось добавить книгу: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
