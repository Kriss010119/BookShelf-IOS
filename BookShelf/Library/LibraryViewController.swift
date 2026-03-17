//
//  LibraryViewController.swift
//  BookShelf
//
//  Created by Kriss Osina on 10.01.2026.
//

import UIKit
import Combine
import CoreData
import Foundation

// MARK: - Shelf Extension
extension Shelf {
    var safeName: String {
        if self.responds(to: Selector(("name"))) {
            return self.value(forKey: "name") as? String ?? "Без названия"
        }
        return "Без названия"
    }
}

extension Shelf {
    /// Получение книг через прямой запрос к Core Data
    var booksArray: [Book] {
        guard let managedObjectContext = self.managedObjectContext else {
            print("⚠️ Shelf.booksArray: managedObjectContext is nil")
            return []
        }
        
        do {
            let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "shelf = %@", self)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            print("🔍 Fetching books for shelf: \(self.name ?? "unnamed")")
            
            let books = try managedObjectContext.fetch(fetchRequest)
            print("✅ Found \(books.count) books")
            
            return books
            
        } catch {
            print("❌ Error fetching books: \(error)")
            
            do {
                let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "shelf.objectID == %@", self.objectID)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
                let books = try managedObjectContext.fetch(fetchRequest)
                print("✅ Alternative fetch found \(books.count) books")
                return books
            } catch {
                print("❌ Alternative fetch also failed: \(error)")
                return []
            }
        }
    }
}











//
//  LibraryViewController.swift
//  BookShelf
//

import UIKit
import Combine
import CoreData

final class LibraryViewController: UIViewController {

    private let viewModel: LibraryViewModel
    private var cancellables = Set<AnyCancellable>()
    private var selectedShelfForBook: Shelf?
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let headerView = UIView()
    private let appImageView = UIImageView()
    private let welcomeLabel = UILabel()
    private let sloganLabel = UILabel()
    private let statsContainer = UIView()
    private let totalShelvesLabel = UILabel()
    private let totalBooksLabel = UILabel()
    private let createShelfButton = UIButton(type: .system)
    private let addBookButton = UIButton(type: .system)
    private let divider = UIView()
    private let shelvesStack = UIStackView()
    
    // MARK: - Constants
    private let bookViewWidth: CGFloat = 85
    private let bookCoverHeight: CGFloat = 130

    // MARK: - Initializer
    init(viewModel: LibraryViewModel) {
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
        setupNotifications()
        Task { await viewModel.loadLibrary() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await viewModel.loadLibrary() }
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookDataChanged),
            name: .bookDataChanged,
            object: nil
        )
    }
    
    @objc private func handleBookDataChanged() {
        Task { await viewModel.loadLibrary() }
    }
}

// MARK: - Setup UI
private extension LibraryViewController {
    func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        setupScroll()
        setupHeader()
        setupStats()
        setupDivider()
        setupShelvesSection()
    }

    func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupHeader() {
        headerView.backgroundColor = .BookShelf.buttonBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        appImageView.image = UIImage(named: "Logo")
        appImageView.contentMode = .scaleAspectFill
        appImageView.clipsToBounds = true
        appImageView.layer.cornerRadius = 38.5
        appImageView.layer.borderWidth = 5
        appImageView.layer.borderColor = UIColor.BookShelf.buttonBorder.cgColor
        appImageView.translatesAutoresizingMaskIntoConstraints = false

        welcomeLabel.text = "Welcome to Bookshelf"
        welcomeLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        welcomeLabel.textColor = .BookShelf.buttonText

        sloganLabel.text = "Место, где живут книги"
        sloganLabel.font = .systemFont(ofSize: 14)
        sloganLabel.textColor = .BookShelf.buttonText

        let textStack = UIStackView(arrangedSubviews: [welcomeLabel, sloganLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let headerStack = UIStackView(arrangedSubviews: [appImageView, textStack])
        headerStack.spacing = 16
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(headerStack)
        contentStack.addArrangedSubview(headerView)

        NSLayoutConstraint.activate([
            appImageView.widthAnchor.constraint(equalToConstant: 77),
            appImageView.heightAnchor.constraint(equalToConstant: 77),
            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    func setupStats() {
        statsContainer.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let mainStack = UIStackView()
        mainStack.axis = .horizontal
        mainStack.alignment = .top
        mainStack.distribution = .equalSpacing
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.spacing = 8

        statsStack.addArrangedSubview(makeStatRow(title: "Всего полок:", valueLabel: totalShelvesLabel))
        statsStack.addArrangedSubview(makeStatRow(title: "Всего книг:", valueLabel: totalBooksLabel))

        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 8

        createShelfButton.setTitle("Создать полку", for: .normal)
        createShelfButton.backgroundColor = .BookShelf.buttonBackground
        createShelfButton.setTitleColor(.BookShelf.buttonText, for: .normal)
        createShelfButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        createShelfButton.layer.cornerRadius = 14
        createShelfButton.layer.borderWidth = 2
        createShelfButton.layer.borderColor = UIColor.BookShelf.buttonBorder.cgColor
        createShelfButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        createShelfButton.addTarget(self, action: #selector(createShelfTapped), for: .touchUpInside)

        addBookButton.setTitle("Добавить книгу", for: .normal)
        addBookButton.backgroundColor = .BookShelf.buttonBackground
        addBookButton.setTitleColor(.BookShelf.buttonText, for: .normal)
        addBookButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        addBookButton.layer.cornerRadius = 14
        addBookButton.layer.borderWidth = 2
        addBookButton.layer.borderColor = UIColor.BookShelf.buttonBorder.cgColor
        addBookButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        addBookButton.addTarget(self, action: #selector(addBookTapped), for: .touchUpInside)

        buttonsStack.addArrangedSubview(createShelfButton)
        buttonsStack.addArrangedSubview(addBookButton)
        buttonsStack.alignment = .trailing

        mainStack.addArrangedSubview(statsStack)
        mainStack.addArrangedSubview(buttonsStack)

        statsContainer.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: statsContainer.layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: statsContainer.layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: statsContainer.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor)
        ])

        contentStack.addArrangedSubview(statsContainer)
    }

    func makeStatRow(title: String, valueLabel: UILabel) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.8)

        valueLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        valueLabel.textColor = .BookShelf.primaryText
        valueLabel.text = "0"

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }

    func setupDivider() {
        divider.backgroundColor = .BookShelf.separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(divider)
    }

    func setupShelvesSection() {
        shelvesStack.axis = .vertical
        shelvesStack.spacing = 32
        shelvesStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
        shelvesStack.isLayoutMarginsRelativeArrangement = true
        contentStack.addArrangedSubview(shelvesStack)
    }

    func reloadShelves(_ shelves: [Shelf]) {
        shelvesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for shelf in shelves {
            shelvesStack.addArrangedSubview(createShelfBlock(for: shelf))
        }
    }

    func createShelfBlock(for shelf: Shelf) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.tag = shelf.hashValue

        let titleLabel = UILabel()
        titleLabel.text = shelf.safeName
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .BookShelf.primaryText

        let goLabel = UILabel()
        goLabel.text = "Перейти ->"
        goLabel.font = .systemFont(ofSize: 13)
        goLabel.textColor = .BookShelf.primaryText
        goLabel.isUserInteractionEnabled = true
        let goTap = UITapGestureRecognizer(target: self, action: #selector(goToShelfTapped(_:)))
        goLabel.addGestureRecognizer(goTap)
        goLabel.tag = shelf.hashValue

        let topRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), goLabel])
        topRow.axis = .horizontal

        let card = UIView()
        card.backgroundColor = .BookShelf.cardBackground
        card.layer.cornerRadius = 20
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 220).isActive = true

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .fill
        horizontalStack.distribution = .fill
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        let booksScroll = UIScrollView()
        booksScroll.showsHorizontalScrollIndicator = false
        booksScroll.translatesAutoresizingMaskIntoConstraints = false

        let booksStack = UIStackView()
        booksStack.axis = .horizontal
        booksStack.spacing = 12
        booksStack.alignment = .top
        booksStack.translatesAutoresizingMaskIntoConstraints = false

        let books = shelf.booksArray

        if books.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Нет книг"
            emptyLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.6)
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.textAlignment = .center
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
            booksStack.addArrangedSubview(emptyLabel)
        } else {
            books.forEach { book in
                let bookView = createBookView(book: book)
                let tap = BookTapGestureRecognizer(target: self, action: #selector(bookTapped(_:)))
                tap.bookID = book.objectID
                bookView.addGestureRecognizer(tap)
                booksStack.addArrangedSubview(bookView)
            }
        }

        booksScroll.addSubview(booksStack)

        NSLayoutConstraint.activate([
            booksStack.topAnchor.constraint(equalTo: booksScroll.topAnchor, constant: 16),
            booksStack.leadingAnchor.constraint(equalTo: booksScroll.leadingAnchor, constant: 16),
            booksStack.trailingAnchor.constraint(equalTo: booksScroll.trailingAnchor, constant: -16),
            booksStack.bottomAnchor.constraint(equalTo: booksScroll.bottomAnchor),
            booksStack.heightAnchor.constraint(equalTo: booksScroll.heightAnchor, constant: -16)
        ])

        let sidePanel = UIStackView()
        sidePanel.axis = .vertical
        sidePanel.alignment = .center
        sidePanel.distribution = .equalSpacing
        sidePanel.spacing = 16
        sidePanel.backgroundColor = .BookShelf.buttonBackground
        sidePanel.translatesAutoresizingMaskIntoConstraints = false
        sidePanel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sidePanel.tag = shelf.hashValue

        let addIcon = UIImageView(image: UIImage(systemName: "plus"))
        addIcon.tintColor = .BookShelf.buttonText
        addIcon.contentMode = .scaleAspectFit
        addIcon.translatesAutoresizingMaskIntoConstraints = false
        addIcon.isUserInteractionEnabled = true
        addIcon.tag = shelf.hashValue
        let addTap = UITapGestureRecognizer(target: self, action: #selector(addBookToShelfTapped(_:)))
        addIcon.addGestureRecognizer(addTap)
        
        let editIcon = UIImageView(image: UIImage(systemName: "pencil"))
        editIcon.tintColor = .BookShelf.buttonText
        editIcon.contentMode = .scaleAspectFit
        editIcon.translatesAutoresizingMaskIntoConstraints = false
        editIcon.isUserInteractionEnabled = true
        editIcon.tag = shelf.hashValue
        let editTap = UITapGestureRecognizer(target: self, action: #selector(editShelfTapped(_:)))
        editIcon.addGestureRecognizer(editTap)
        
        let deleteIcon = UIImageView(image: UIImage(systemName: "trash"))
        deleteIcon.tintColor = .BookShelf.buttonText
        deleteIcon.contentMode = .scaleAspectFit
        deleteIcon.translatesAutoresizingMaskIntoConstraints = false
        deleteIcon.isUserInteractionEnabled = true
        deleteIcon.tag = shelf.hashValue
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteShelfTapped(_:)))
        deleteIcon.addGestureRecognizer(deleteTap)

        NSLayoutConstraint.activate([
            addIcon.widthAnchor.constraint(equalToConstant: 20),
            addIcon.heightAnchor.constraint(equalToConstant: 20),
            editIcon.widthAnchor.constraint(equalToConstant: 20),
            editIcon.heightAnchor.constraint(equalToConstant: 20),
            deleteIcon.widthAnchor.constraint(equalToConstant: 20),
            deleteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])

        sidePanel.addArrangedSubview(addIcon)
        sidePanel.addArrangedSubview(editIcon)
        sidePanel.addArrangedSubview(deleteIcon)

        sidePanel.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        sidePanel.isLayoutMarginsRelativeArrangement = true

        horizontalStack.addArrangedSubview(booksScroll)
        horizontalStack.addArrangedSubview(sidePanel)

        card.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: card.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        container.addArrangedSubview(topRow)
        container.addArrangedSubview(card)

        return container
    }

    func createBookView(book: Book) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalToConstant: bookViewWidth).isActive = true
        container.isUserInteractionEnabled = true

        let coverContainer = UIView()
        coverContainer.translatesAutoresizingMaskIntoConstraints = false
        coverContainer.widthAnchor.constraint(equalToConstant: bookViewWidth).isActive = true
        coverContainer.heightAnchor.constraint(equalToConstant: bookCoverHeight).isActive = true
        
        let cover = UIView()
        cover.backgroundColor = UIColor.BookShelf.primaryText.withAlphaComponent(0.2)
        cover.layer.cornerRadius = 8
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false
        
        let coverImage = UIImageView()
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
        coverImage.layer.cornerRadius = 8
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        
        if let coverURL = book.coverImageURL {
            loadImage(from: coverURL, into: coverImage)
        } else {
            coverImage.image = UIImage(systemName: "book.closed")
            coverImage.tintColor = .BookShelf.primaryText
            coverImage.contentMode = .scaleAspectFit
        }
        
        cover.addSubview(coverImage)
        coverContainer.addSubview(cover)
        
        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            cover.leadingAnchor.constraint(equalTo: coverContainer.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: coverContainer.bottomAnchor),
            
            coverImage.topAnchor.constraint(equalTo: cover.topAnchor),
            coverImage.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            coverImage.bottomAnchor.constraint(equalTo: cover.bottomAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = book.title ?? "Без названия"
        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        titleLabel.textColor = .BookShelf.primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 32).isActive = true

        let authorLabel = UILabel()
        authorLabel.text = book.author ?? ""
        authorLabel.font = .systemFont(ofSize: 9, weight: .regular)
        authorLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.7)
        authorLabel.textAlignment = .center
        authorLabel.numberOfLines = 1
        authorLabel.lineBreakMode = .byTruncatingTail
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true

        container.addArrangedSubview(coverContainer)
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(authorLabel)

        container.setCustomSpacing(6, after: coverContainer)
        container.setCustomSpacing(2, after: titleLabel)

        return container
    }
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        if urlString.hasPrefix("asset://") {
            let assetName = String(urlString.dropFirst("asset://".count))
            imageView.image = UIImage(named: assetName)
        } else if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        }
    }
}

// MARK: - Bindings
private extension LibraryViewController {
    func setupBindings() {
        viewModel.$totalShelvesCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.totalShelvesLabel.text = "\(count)"
            }
            .store(in: &cancellables)

        viewModel.$totalBooksCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.totalBooksLabel.text = "\(count)"
            }
            .store(in: &cancellables)

        viewModel.$shelves
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shelves in
                self?.reloadShelves(shelves)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions
extension LibraryViewController {
    
    @objc func goToShelfTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        let shelf = viewModel.shelves.first { $0.hashValue == label.tag }
        guard let shelf = shelf else { return }
        
        let detailVC = ShelfDetailViewController(shelf: shelf, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    class BookTapGestureRecognizer: UITapGestureRecognizer {
        var bookID: NSManagedObjectID?
    }
    
    @objc func bookTapped(_ gesture: UITapGestureRecognizer) {
        guard let bookTap = gesture as? BookTapGestureRecognizer,
              let bookID = bookTap.bookID else { return }
        
        for shelf in viewModel.shelves {
            if let book = shelf.booksArray.first(where: { $0.objectID == bookID }) {
                showBookDetail(for: book)
                return
            }
        }
    }
    
    @objc func addBookToShelfTapped(_ gesture: UITapGestureRecognizer) {
        guard let icon = gesture.view else { return }
        let shelf = viewModel.shelves.first { $0.hashValue == icon.tag }
        guard let shelf = shelf else { return }
        
        showAddBookOptions(for: shelf, sourceView: icon)
    }
    
    @objc func editShelfTapped(_ gesture: UITapGestureRecognizer) {
        guard let icon = gesture.view else { return }
        let shelf = viewModel.shelves.first { $0.hashValue == icon.tag }
        guard let shelf = shelf else { return }
        
        showRenameShelfDialog(for: shelf)
    }
    
    @objc func deleteShelfTapped(_ gesture: UITapGestureRecognizer) {
        guard let icon = gesture.view else { return }
        let shelf = viewModel.shelves.first { $0.hashValue == icon.tag }
        guard let shelf = shelf else { return }
        
        showDeleteShelfConfirmation(for: shelf)
    }

    @objc func addBookTapped() {
        showAddBookOptions(for: nil, sourceView: addBookButton)
    }

    @objc func createShelfTapped() {
        let modal = CreateShelfModal()
        modal.delegate = self
        modal.show(in: self)
    }
    
    // MARK: - Navigation Methods
    
    private func showBookDetail(for book: Book) {
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func openManualAdd(for shelf: Shelf?) {
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

    func openSearchAdd(for shelf: Shelf?) {
        selectedShelfForBook = shelf
        tabBarController?.selectedIndex = 1
    }
}

// MARK: - Модальные окна
extension LibraryViewController: CreateShelfModalDelegate {
    
    func createShelfModal(_ modal: CreateShelfModal, didCreateShelfWithName name: String) {
        Task {
            await viewModel.createShelf(name: name)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func createShelfModalDidCancel(_ modal: CreateShelfModal) {
        // Ничего не делаем
    }
}

extension LibraryViewController: AddBookOptionsModalDelegate {
    
    func showAddBookOptions(for shelf: Shelf?, sourceView: UIView) {
        let modal = AddBookOptionsModal(shelfName: shelf?.safeName)
        modal.delegate = self
        modal.show(in: self)
        self.selectedShelfForBook = shelf
    }
    
    func addBookOptionsModalDidSelectManual(_ modal: AddBookOptionsModal) {
        openManualAdd(for: selectedShelfForBook)
    }
    
    func addBookOptionsModalDidSelectSearch(_ modal: AddBookOptionsModal) {
        openSearchAdd(for: selectedShelfForBook)
    }
    
    func addBookOptionsModalDidCancel(_ modal: AddBookOptionsModal) {
        selectedShelfForBook = nil
    }
}

extension LibraryViewController: DeleteConfirmationModalDelegate {
    
    func showDeleteShelfConfirmation(for shelf: Shelf) {
        let bookCount = shelf.books?.count ?? 0
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
    
    func deleteConfirmationModalDidConfirm(_ modal: DeleteConfirmationModal) {
            Task {
                do {
                    if let shelf = viewModel.shelves.first(where: { $0.safeName == modal.itemName }) {
                        try await CoreDataManager.shared.deleteShelf(shelf)
                        await viewModel.loadLibrary()
                        
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                } catch {
                    showError("Не удалось удалить полку")
                }
            }
        }
    
    func deleteConfirmationModalDidCancel(_ modal: DeleteConfirmationModal) {
        // Ничего не делаем
    }
}

extension LibraryViewController: RenameShelfModalDelegate {
    
    func showRenameShelfDialog(for shelf: Shelf) {
        let modal = RenameShelfModal(currentName: shelf.safeName)
        modal.delegate = self
        modal.show(in: self)
    }
    
    func renameShelfModal(_ modal: RenameShelfModal, didRenameShelfTo newName: String) {
            Task {
                do {
                    if let shelf = viewModel.shelves.first(where: { $0.safeName == modal.currentName }) {
                        try await CoreDataManager.shared.updateShelf(shelf, newName: newName)
                        await viewModel.loadLibrary()
                        
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                } catch {
                    showError("Не удалось переименовать полку")
                }
            }
        }
    
    func renameShelfModalDidCancel(_ modal: RenameShelfModal) {
        // Ничего не делаем
    }
}

// MARK: - Вспомогательные методы
extension LibraryViewController {
    
    func getRussianWordForm(count: Int, one: String, two: String, many: String) -> String {
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
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

