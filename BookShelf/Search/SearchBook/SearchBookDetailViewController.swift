//
//  SearchBookDetailViewController.swift
//  BookShelf
//

import UIKit

final class SearchBookDetailViewController: UIViewController {
    
    private let book: SearchBook
    private let viewModel: SearchViewModel
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .BookShelf.primaryBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let coverActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .BookShelf.primaryText
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .BookShelf.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func createInfoCard(icon: String, value: String, title: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .BookShelf.cardBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.BookShelf.separator.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .BookShelf.buttonBackground
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = .BookShelf.primaryText
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.6)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconImageView)
        card.addSubview(valueLabel)
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iconImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    private let ratingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Рейтинг"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingStarsView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let ratingValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .BookShelf.primaryText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let externalLinkContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let externalLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.BookShelf.buttonBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .BookShelf.cardBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.BookShelf.buttonBackground.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let ageLimitBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .BookShelf.buttonText
        label.backgroundColor = .BookShelf.buttonBackground
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .BookShelf.primaryText
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let addToLibraryButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Добавить в библиотеку", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(book: SearchBook, viewModel: SearchViewModel) {
        self.book = book
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
        configureWithBook()
        loadCoverImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        title = "О книге"
        navigationController?.navigationBar.tintColor = .BookShelf.buttonBackground
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.BookShelf.primaryText,
            .font: Typography.title.font
        ]
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(coverContainerView)
        coverContainerView.addSubview(coverImageView)
        coverContainerView.addSubview(coverActivityIndicator)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(ageLimitBadge)
        contentView.addSubview(infoStackView)
        contentView.addSubview(ratingContainerView)
        
        ratingContainerView.addSubview(ratingTitleLabel)
        ratingContainerView.addSubview(ratingStarsView)
        ratingContainerView.addSubview(ratingValueLabel)
        
        contentView.addSubview(externalLinkContainerView)
        externalLinkContainerView.addSubview(externalLinkButton)
        
        contentView.addSubview(descriptionContainerView)
        descriptionContainerView.addSubview(descriptionTitleLabel)
        descriptionContainerView.addSubview(descriptionTextView)
        
        contentView.addSubview(addToLibraryButton)
        setupConstraints()
        addToLibraryButton.addTarget(self, action: #selector(addToLibraryTapped), for: .touchUpInside)
        externalLinkButton.addTarget(self, action: #selector(openExternalLink), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            coverContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            coverContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverContainerView.widthAnchor.constraint(equalToConstant: 180),
            coverContainerView.heightAnchor.constraint(equalToConstant: 250),
            
            coverImageView.topAnchor.constraint(equalTo: coverContainerView.topAnchor, constant: 8),
            coverImageView.leadingAnchor.constraint(equalTo: coverContainerView.leadingAnchor, constant: 8),
            coverImageView.trailingAnchor.constraint(equalTo: coverContainerView.trailingAnchor, constant: -8),
            coverImageView.bottomAnchor.constraint(equalTo: coverContainerView.bottomAnchor, constant: -8),
            
            coverActivityIndicator.centerXAnchor.constraint(equalTo: coverContainerView.centerXAnchor),
            coverActivityIndicator.centerYAnchor.constraint(equalTo: coverContainerView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: coverContainerView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ageLimitBadge.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 12),
            ageLimitBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ageLimitBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            ageLimitBadge.heightAnchor.constraint(equalToConstant: 32),
            
            infoStackView.topAnchor.constraint(equalTo: ageLimitBadge.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoStackView.heightAnchor.constraint(equalToConstant: 90),
            
            ratingContainerView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 16),
            ratingContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingTitleLabel.topAnchor.constraint(equalTo: ratingContainerView.topAnchor, constant: 16),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 16),
            
            ratingValueLabel.centerYAnchor.constraint(equalTo: ratingTitleLabel.centerYAnchor),
            ratingValueLabel.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -16),
            
            ratingStarsView.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 12),
            ratingStarsView.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 16),
            ratingStarsView.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -16),
            ratingStarsView.heightAnchor.constraint(equalToConstant: 30),
            ratingStarsView.bottomAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: -16),
            
            externalLinkContainerView.topAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: 16),
            externalLinkContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            externalLinkContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            externalLinkButton.topAnchor.constraint(equalTo: externalLinkContainerView.topAnchor, constant: 16),
            externalLinkButton.leadingAnchor.constraint(equalTo: externalLinkContainerView.leadingAnchor, constant: 16),
            externalLinkButton.trailingAnchor.constraint(equalTo: externalLinkContainerView.trailingAnchor, constant: -16),
            externalLinkButton.bottomAnchor.constraint(equalTo: externalLinkContainerView.bottomAnchor, constant: -16),
            
            descriptionContainerView.topAnchor.constraint(equalTo: externalLinkContainerView.bottomAnchor, constant: 16),
            descriptionContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 16),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: -16),
            
            addToLibraryButton.topAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: 24),
            addToLibraryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addToLibraryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            addToLibraryButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    // MARK: - Configuration
    private func configureWithBook() {
        titleLabel.text = book.title
        authorLabel.text = book.author
        ageLimitBadge.isHidden = true
        setupInfoCards()
        
        if let rating = book.rating, rating > 0 {
            setupRatingStars()
            ratingValueLabel.text = String(format: "%.1f", rating)
        } else {
            ratingContainerView.isHidden = true
        }
        
        if let link = book.previewLink ?? book.infoLink, !link.isEmpty {
            let linkTitle = book.previewLink != nil ? "Предпросмотр на Google Books" : "Подробнее на Google Books"
            externalLinkButton.setTitle("📎 \(linkTitle)", for: .normal)
            externalLinkContainerView.isHidden = false
        } else {
            externalLinkContainerView.isHidden = true
        }
        
        if let description = book.description, !description.isEmpty {
            descriptionTextView.text = description
        } else {
            descriptionTextView.text = "Описание отсутствует"
            descriptionTextView.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        }
    }
    
    private func setupInfoCards() {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let year = book.publishedYear, year > 0 {
            let yearCard = createInfoCard(
                icon: "calendar",
                value: "\(year)",
                title: "Год"
            )
            infoStackView.addArrangedSubview(yearCard)
        }
        
        if let pages = book.pageCount, pages > 0 {
            let pagesCard = createInfoCard(
                icon: "book.pages",
                value: "\(pages)",
                title: "Страниц"
            )
            infoStackView.addArrangedSubview(pagesCard)
        }
        
        if let genre = book.genre, !genre.isEmpty {
            let genreCard = createInfoCard(
                icon: "tag",
                value: genre,
                title: "Жанр"
            )
            infoStackView.addArrangedSubview(genreCard)
        }
    }
    
    private func setupRatingStars() {
        ratingStarsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let rating = Int(book.rating ?? 0)
        
        for i in 1...5 {
            let starLabel = UILabel()
            starLabel.font = .systemFont(ofSize: 24)
            starLabel.textAlignment = .center
            
            if i <= rating {
                starLabel.text = "★"
                starLabel.textColor = .BookShelf.primaryText
            } else {
                starLabel.text = "☆"
                starLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.3)
            }
            
            ratingStarsView.addArrangedSubview(starLabel)
        }
    }
    
    private func loadCoverImage() {
        guard let coverURL = book.coverImageURL else {
            showPlaceholderCover()
            return
        }
        
        coverActivityIndicator.startAnimating()
        
        Task { [weak self] in
            let image = await self?.viewModel.loadImage(from: coverURL)
            
            await MainActor.run {
                self?.coverActivityIndicator.stopAnimating()
                
                if let image = image {
                    self?.coverImageView.image = image
                    self?.coverImageView.contentMode = .scaleAspectFill
                } else {
                    self?.showPlaceholderCover()
                }
            }
        }
    }
    
    private func showPlaceholderCover() {
        coverImageView.image = UIImage(systemName: "book.closed")
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.tintColor = .BookShelf.primaryText
        coverImageView.backgroundColor = .clear
    }
    
    // MARK: - Actions
    @objc private func addToLibraryTapped() {
        showAddToLibraryOptions()
    }
    
    @objc private func openExternalLink() {
        guard let urlString = book.previewLink ?? book.infoLink,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            showError("Не удалось открыть ссылку")
            return
        }
        UIApplication.shared.open(url)
    }
    
    private func showAddToLibraryOptions() {
        let alert = UIAlertController(
            title: "Добавить книгу в библиотеку",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Ввести вручную", style: .default) { [weak self] _ in
            self?.openManualAdd()
        })
        
        alert.addAction(UIAlertAction(title: "Выбрать полку", style: .default) { [weak self] _ in
            self?.showShelfPicker()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = addToLibraryButton
            popoverController.sourceRect = addToLibraryButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func openManualAdd() {
        let bookDTO = book.toBookDTO()
        let vc = AddBookViewController(book: bookDTO)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func showShelfPicker() {
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
                            self.showCreateShelfDialog()
                        })
                    } else {
                        for shelf in shelves {
                            let action = UIAlertAction(title: shelf.name, style: .default) { _ in
                                self.addBookToShelf(shelf)
                            }
                            alert.addAction(action)
                        }
                    }
                    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                    if let popoverController = alert.popoverPresentationController {
                        popoverController.sourceView = self.addToLibraryButton
                        popoverController.sourceRect = self.addToLibraryButton.bounds
                    }
                    self.present(alert, animated: true)
                }
            } catch {
                print("Error fetching shelves: \(error)")
            }
        }
    }
    
    private func showCreateShelfDialog() {
        let alert = UIAlertController(
            title: "Создать новую полку",
            message: "Введите название полки",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Название полки"
        }
        alert.addAction(UIAlertAction(title: "Создать", style: .default) { [weak self] _ in
            guard let shelfName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !shelfName.isEmpty else { return }
            Task {
                do {
                    let shelf = try await CoreDataManager.shared.createShelf(name: shelfName)
                    await MainActor.run {
                        self?.addBookToShelf(shelf)
                    }
                } catch {
                    print("Error creating shelf: \(error)")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addBookToShelf(_ shelf: Shelf) {
        let loadingAlert = UIAlertController(title: "Добавление...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        let bookDTO = book.toBookDTO()
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
