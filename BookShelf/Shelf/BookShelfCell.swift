//
//  BookShelfCell.swift
//  BookShelf
//

import UIKit

final class BookShelfCell: UITableViewCell {
    static let reuseIdentifier = "BookShelfCell"
    var onExternalLinkTapped: ((String) -> Void)?
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .BookShelf.primaryBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.7)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.6)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let linkButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(.BookShelf.buttonBackground, for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .BookShelf.buttonBackground
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var currentExternalLink: String?
    private var imageLoadTask: URLSessionDataTask?
    private weak var searchViewModel: SearchViewModel?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .default
        contentView.addSubview(containerView)
        containerView.addSubview(coverImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(linkButton)
        containerView.addSubview(metadataLabel)
        containerView.addSubview(activityIndicator)
        linkButton.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            coverImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            coverImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            linkButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2),
            linkButton.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            linkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            metadataLabel.topAnchor.constraint(equalTo: linkButton.bottomAnchor, constant: 4),
            metadataLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            metadataLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            metadataLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            activityIndicator.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration for Book (из библиотеки)
    func configure(with book: Book) {
        resetCell()
        titleLabel.text = book.title ?? "Без названия"
        authorLabel.text = book.author ?? "Неизвестный автор"
        
        if let annotation = book.annotation, !annotation.isEmpty {
            let firstLine = annotation.components(separatedBy: .newlines).first ?? ""
            descriptionLabel.text = firstLine.count > 180 ? String(firstLine.prefix(180)) + "..." : firstLine
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        if let link = book.externalLink, !link.isEmpty, let linkTitle = book.linkTitle, !linkTitle.isEmpty {
            currentExternalLink = link
            linkButton.setTitle(linkTitle, for: .normal)
            linkButton.isHidden = false
        } else {
            currentExternalLink = nil
            linkButton.isHidden = true
        }
        
        var metadata: [String] = []
        if book.publicationYear > 0 { metadata.append("\(book.publicationYear)") }
        if book.pageCount > 0 { metadata.append("\(book.pageCount) стр.") }
        if let genre = book.genre, !genre.isEmpty { metadata.append(genre) }
        if book.rating > 0 { metadata.append(String(format: "%.1f ★", book.rating)) }
        metadataLabel.text = metadata.joined(separator: " • ")
        loadCover(from: book.coverImageURL)
    }
    
    // MARK: - Configuration for SearchBook (из поиска)
    func configureWithSearchData(
        title: String,
        author: String,
        description: String? = nil,
        coverURL: String?,
        externalLink: String?,
        linkTitle: String?,
        metadata: String? = nil,
        viewModel: SearchViewModel? = nil
    ) {
        resetCell()
        self.searchViewModel = viewModel
        titleLabel.text = title
        authorLabel.text = author
        
        if let description = description, !description.isEmpty {
            let firstLine = description.components(separatedBy: .newlines).first ?? ""
            descriptionLabel.text = firstLine.count > 180 ? String(firstLine.prefix(180)) + "..." : firstLine
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        if let link = externalLink, !link.isEmpty, let linkTitle = linkTitle, !linkTitle.isEmpty {
            currentExternalLink = link
            linkButton.setTitle(linkTitle, for: .normal)
            linkButton.isHidden = false
        } else {
            currentExternalLink = nil
            linkButton.isHidden = true
        }
        
        if let metadata = metadata, !metadata.isEmpty {
            metadataLabel.text = metadata
        } else {
            metadataLabel.text = nil
        }
        
        if let coverURL = coverURL {
            loadCover(from: coverURL)
        } else {
            setPlaceholderCover()
        }
    }
    
    private func resetCell() {
        imageLoadTask?.cancel()
        imageLoadTask = nil
        coverImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = true
        linkButton.isHidden = true
        linkButton.setTitle(nil, for: .normal)
        currentExternalLink = nil
        metadataLabel.text = nil
        activityIndicator.stopAnimating()
    }
    
    private func loadCover(from urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            setPlaceholderCover()
            return
        }
        
        activityIndicator.startAnimating()
        coverImageView.isHidden = true
        
        if let searchViewModel = searchViewModel {
            Task { [weak self] in
                let image = await searchViewModel.loadImage(from: urlString)
                await MainActor.run {
                    self?.activityIndicator.stopAnimating()
                    if let image = image {
                        self?.coverImageView.image = image
                        self?.coverImageView.isHidden = false
                    } else {
                        self?.setPlaceholderCover()
                    }
                }
            }
            return
        }
        
        if urlString.hasPrefix("asset://") {
            let assetName = String(urlString.dropFirst("asset://".count))
            coverImageView.image = UIImage(named: assetName)
            coverImageView.isHidden = false
            activityIndicator.stopAnimating()
            return
        }
        
        if urlString.hasPrefix("file://"), let url = URL(string: urlString) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.coverImageView.image = image
                        self?.coverImageView.isHidden = false
                        self?.activityIndicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.setPlaceholderCover()
                    }
                }
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            setPlaceholderCover()
            return
        }
        
        imageLoadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let data = data, let image = UIImage(data: data) {
                    self?.coverImageView.image = image
                    self?.coverImageView.isHidden = false
                } else {
                    self?.setPlaceholderCover()
                }
            }
        }
        imageLoadTask?.resume()
    }
    
    private func setPlaceholderCover() {
        activityIndicator.stopAnimating()
        coverImageView.image = UIImage(systemName: "book")
        coverImageView.tintColor = .BookShelf.primaryText.withAlphaComponent(0.2)
        coverImageView.contentMode = .center
        coverImageView.backgroundColor = .BookShelf.cardBackground
        coverImageView.isHidden = false
    }
    
    @objc private func linkTapped() {
        guard let link = currentExternalLink else { return }
        onExternalLinkTapped?(link)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
}
