//
//  ShelfDetailViewController.swift
//  BookShelf
//

import UIKit
import Combine
import Foundation

final class ShelfDetailViewController: UIViewController {
    private let shelf: Shelf
    private let viewModel: LibraryViewModel
    private var books: [Book] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let booksCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        let imageView = UIImageView(image: UIImage(systemName: "book"))
        imageView.tintColor = .BookShelf.primaryText.withAlphaComponent(0.2)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет книг"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.4)
        label.textAlignment = .center
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
    
    // MARK: - Initialization
    init(shelf: Shelf, viewModel: LibraryViewModel) {
        self.shelf = shelf
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
        loadBooks()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookDataChanged),
            name: .bookDataChanged,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        view.addSubview(booksCountLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(activityIndicator)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
        NSLayoutConstraint.activate([
            booksCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            booksCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: booksCountLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            emptyStateView.widthAnchor.constraint(equalToConstant: 120),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 50),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 50),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 12),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = shelf.safeName
        
        navigationController?.navigationBar.tintColor = .BookShelf.buttonBackground
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.BookShelf.primaryText,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(menuButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = menuButton
    }
    
    // MARK: - Data Loading
    @objc private func handleBookDataChanged() {
        loadBooks()
    }
    
    private func loadBooks() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let fetchedBooks = try await CoreDataManager.shared.fetchBooks(in: shelf)
                await MainActor.run {
                    self.books = fetchedBooks
                    self.updateBooksCount()
                    self.emptyStateView.isHidden = !fetchedBooks.isEmpty
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("Error loading books: \(error)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showAlert("Ошибка", "Не удалось загрузить книги")
                }
            }
        }
    }
    
    private func updateBooksCount() {
        let count = books.count
        let word = getRussianWordForm(count: count, one: "книга", two: "книги", many: "книг")
        booksCountLabel.text = "\(count) \(word)"
    }
    
    private func getRussianWordForm(count: Int, one: String, two: String, many: String) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod100 >= 11 && mod100 <= 19 {
            return many
        }
        switch mod10 {
            case 1: return one
            case 2, 3, 4: return two
            default: return many
        }
    }
    
    // MARK: - Actions
    @objc private func menuButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Добавить книгу", style: .default) { [weak self] _ in
            self?.showAddBookOptions()
        })
        
        alert.addAction(UIAlertAction(title: "Переименовать полку", style: .default) { [weak self] _ in
            self?.showRenameDialog()
        })
        
        alert.addAction(UIAlertAction(title: "Удалить полку", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func showAddBookOptions() {
        let modal = AddBookOptionsModal(shelfName: shelf.safeName)
        modal.delegate = self
        modal.show(in: self)
    }
    
    private func showRenameDialog() {
        let modal = RenameShelfModal(currentName: shelf.safeName)
        modal.delegate = self
        modal.show(in: self)
    }
    
    private func showDeleteConfirmation() {
        let bookCount = books.count
        let additionalInfo = bookCount > 0
            ? "На этой полке \(bookCount) \(getRussianWordForm(count: bookCount, one: "книга", two: "книги", many: "книг")). Они также будут удалены."
            : nil
        
        let modal = DeleteConfirmationModal(
            itemType: .shelf,
            itemName: shelf.safeName,
            additionalInfo: additionalInfo
        )
        modal.delegate = self
        modal.show(in: self)
    }
    
    private func openManualAdd() {
        let emptyBook = BookDTO(
            id: UUID().uuidString,
            title: "",
            author: "",
            genre: nil,
            publishedYear: nil,
            description: nil,
            coverImageURL: nil,
            pageCount: nil,
            rating: nil,
            previewLink: nil,
            infoLink: nil
        )
        let vc = AddBookViewController(book: emptyBook)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func openSearch() {
        tabBarController?.selectedIndex = 1
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func openExternalLink(_ urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            showAlert("Ошибка", "Не удалось открыть ссылку")
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: - Модальные окна
extension ShelfDetailViewController: AddBookOptionsModalDelegate {
    func addBookOptionsModalDidSelectManual(_ modal: AddBookOptionsModal) {
        openManualAdd()
    }
    
    func addBookOptionsModalDidSelectSearch(_ modal: AddBookOptionsModal) {
        openSearch()
    }
    
    func addBookOptionsModalDidCancel(_ modal: AddBookOptionsModal) {}
}

extension ShelfDetailViewController: RenameShelfModalDelegate {
    
    func renameShelfModal(_ modal: RenameShelfModal, didRenameShelfTo newName: String) {
        Task {
            do {
                try await CoreDataManager.shared.updateShelf(shelf, newName: newName)
                await MainActor.run {
                    title = newName
                    DataChangeManager.shared.notifyShelfChanged()
                }
            } catch {
                showAlert("Ошибка", "Не удалось переименовать полку")
            }
        }
    }
    
    func renameShelfModalDidCancel(_ modal: RenameShelfModal) {}
}

extension ShelfDetailViewController: DeleteConfirmationModalDelegate {
    
    func deleteConfirmationModalDidConfirm(_ modal: DeleteConfirmationModal) {
        Task {
            do {
                try await CoreDataManager.shared.deleteShelf(shelf)
                await MainActor.run {
                    DataChangeManager.shared.notifyShelfChanged()
                    navigationController?.popViewController(animated: true)
                }
            } catch {
                showAlert("Ошибка", "Не удалось удалить полку")
            }
        }
    }
    
    func deleteConfirmationModalDidCancel(_ modal: DeleteConfirmationModal) {}
}

// MARK: - UITableView DataSource & Delegate
extension ShelfDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookShelfCell.reuseIdentifier, for: indexPath) as! BookShelfCell
        let book = books[indexPath.row]
        cell.configure(with: book)
        cell.onExternalLinkTapped = { [weak self] url in
            self?.openExternalLink(url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let book = books[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.deleteBook(at: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .BookShelf.error
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func deleteBook(at indexPath: IndexPath) {
        let book = books[indexPath.row]
        
        let modal = DeleteConfirmationModal(
            itemType: .book,
            itemName: book.title ?? "Без названия"
        )
        modal.delegate = self
        modal.onDismiss = { [weak self] in}
        modal.show(in: self)
    }
}

// MARK: - Дополнительный делегат для удаления
extension ShelfDetailViewController {
    func deleteConfirmationModalDidConfirmForBook(_ modal: DeleteConfirmationModal) {
        Task {
            do {
                if let book = books.first(where: { $0.title == modal.itemName }) {
                    try await CoreDataManager.shared.deleteBook(book)
                    await MainActor.run {
                        if let index = books.firstIndex(where: { $0.id == book.id }) {
                            books.remove(at: index)
                            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            updateBooksCount()
                            emptyStateView.isHidden = !books.isEmpty
                            DataChangeManager.shared.notifyBookDeleted()
                        }
                    }
                }
            } catch {
                showAlert("Ошибка", "Не удалось удалить книгу")
            }
        }
    }
}
