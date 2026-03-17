//
//  BookSearchCell.swift
//  BookShelf
//

import UIKit

final class BookSearchCell: UICollectionViewCell {
    static let reuseIdentifier = "BookSearchCell"
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .BookShelf.cardBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.caption.font
        label.textColor = .BookShelf.cardText
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .BookShelf.cardText.withAlphaComponent(0.7)
        label.numberOfLines = 1
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
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.primaryBackground
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .BookShelf.buttonText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    private weak var viewModel: SearchViewModel?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        placeholderView.addSubview(placeholderLabel)
        contentView.addSubview(placeholderView)
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1.5),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            placeholderView.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with book: SearchBook, viewModel: SearchViewModel) {
        self.viewModel = viewModel
        titleLabel.text = book.title
        authorLabel.text = book.author
        showPlaceholder(with: book.title)
        if let coverURL = book.coverImageURL {
            loadCover(from: coverURL)
        }
    }
    
    private func showPlaceholder(with title: String) {
        placeholderView.isHidden = false
        coverImageView.isHidden = true
        activityIndicator.stopAnimating()
        let letters = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(2)
            .uppercased()
        placeholderLabel.text = String(letters)
    }
    
    private func loadCover(from urlString: String) {
        guard let viewModel = viewModel else { return }
        activityIndicator.startAnimating()
        placeholderView.isHidden = true
        imageLoadTask?.cancel()
        imageLoadTask = Task { [weak self] in
            let image = await viewModel.loadImage(from: urlString)
            
            await MainActor.run {
                guard !Task.isCancelled else { return }
                self?.activityIndicator.stopAnimating()
                if let image = image {
                    self?.coverImageView.image = image
                    self?.coverImageView.isHidden = false
                    self?.placeholderView.isHidden = true
                } else {
                    self?.coverImageView.isHidden = true
                    self?.placeholderView.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        coverImageView.image = nil
        coverImageView.isHidden = true
        titleLabel.text = nil
        authorLabel.text = nil
        placeholderView.isHidden = true
        activityIndicator.stopAnimating()
    }
}
