//
//  BookDetailViewController.swift
//  BookShelf
//
//  Created by Kriss Osina on 06.02.2026.
//

import UIKit

final class BookDetailViewController: UIViewController {
    
    private let book: Book
    weak var delegate: ShelfDetailViewController?
    private var isEditingMode = false
    
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
    
    // MARK: - Title Section
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
    
    // MARK: - Info Cards
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
    
    // MARK: - Rating Section
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
        label.text = "Моя оценка"
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
    
    // MARK: - Dates Section
    private let datesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let datesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Даты чтения"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startDateIcon = UIImageView(image: UIImage(systemName: "calendar"))
    private let finishDateIcon = UIImageView(image: UIImage(systemName: "calendar.badge.checkmark"))
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let finishDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - External Link Section
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
    
    // MARK: - Age
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
    
    // MARK: - Annotation Section
    private let annotationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let annotationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Аннотация"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let annotationTextView: UITextView = {
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
    
    // MARK: - Review Section
    private let reviewContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Моя рецензия"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reviewTextView: UITextView = {
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
    
    // MARK: - Edit Button
    private let editButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Редактировать", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(book: Book) {
        self.book = book
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
        
        contentView.addSubview(datesContainerView)
        datesContainerView.addSubview(datesTitleLabel)
        
        setupDateRow(icon: startDateIcon, label: startDateLabel, in: datesContainerView, topAnchor: datesTitleLabel.bottomAnchor, constant: 12)
        setupDateRow(icon: finishDateIcon, label: finishDateLabel, in: datesContainerView, topAnchor: startDateLabel.bottomAnchor, constant: 8)
        
        contentView.addSubview(externalLinkContainerView)
        externalLinkContainerView.addSubview(externalLinkButton)
        
        contentView.addSubview(annotationContainerView)
        annotationContainerView.addSubview(annotationTitleLabel)
        annotationContainerView.addSubview(annotationTextView)
        
        contentView.addSubview(reviewContainerView)
        reviewContainerView.addSubview(reviewTitleLabel)
        reviewContainerView.addSubview(reviewTextView)
        
        contentView.addSubview(editButton)
        [startDateIcon, finishDateIcon].forEach {
            $0.tintColor = .BookShelf.buttonBackground
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        setupConstraints()
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        externalLinkButton.addTarget(self, action: #selector(openExternalLink), for: .touchUpInside)
    }
    
    private func setupDateRow(icon: UIImageView, label: UILabel, in container: UIView, topAnchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        container.addSubview(icon)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: constant),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
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
            ageLimitBadge.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            ageLimitBadge.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
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
            
            datesContainerView.topAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: 16),
            datesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            datesTitleLabel.topAnchor.constraint(equalTo: datesContainerView.topAnchor, constant: 16),
            datesTitleLabel.leadingAnchor.constraint(equalTo: datesContainerView.leadingAnchor, constant: 16),
            datesTitleLabel.trailingAnchor.constraint(equalTo: datesContainerView.trailingAnchor, constant: -16),
            
            startDateIcon.leadingAnchor.constraint(equalTo: datesContainerView.leadingAnchor, constant: 16),
            startDateIcon.topAnchor.constraint(equalTo: datesTitleLabel.bottomAnchor, constant: 12),
            startDateIcon.widthAnchor.constraint(equalToConstant: 20),
            startDateIcon.heightAnchor.constraint(equalToConstant: 20),
            
            startDateLabel.leadingAnchor.constraint(equalTo: startDateIcon.trailingAnchor, constant: 12),
            startDateLabel.centerYAnchor.constraint(equalTo: startDateIcon.centerYAnchor),
            startDateLabel.trailingAnchor.constraint(equalTo: datesContainerView.trailingAnchor, constant: -16),
            
            finishDateIcon.leadingAnchor.constraint(equalTo: datesContainerView.leadingAnchor, constant: 16),
            finishDateIcon.topAnchor.constraint(equalTo: startDateIcon.bottomAnchor, constant: 12),
            finishDateIcon.widthAnchor.constraint(equalToConstant: 20),
            finishDateIcon.heightAnchor.constraint(equalToConstant: 20),
            
            finishDateLabel.leadingAnchor.constraint(equalTo: finishDateIcon.trailingAnchor, constant: 12),
            finishDateLabel.centerYAnchor.constraint(equalTo: finishDateIcon.centerYAnchor),
            finishDateLabel.trailingAnchor.constraint(equalTo: datesContainerView.trailingAnchor, constant: -16),
            finishDateLabel.bottomAnchor.constraint(equalTo: datesContainerView.bottomAnchor, constant: -16),
            
            externalLinkContainerView.topAnchor.constraint(equalTo: datesContainerView.bottomAnchor, constant: 16),
            externalLinkContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            externalLinkContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            externalLinkButton.topAnchor.constraint(equalTo: externalLinkContainerView.topAnchor, constant: 16),
            externalLinkButton.leadingAnchor.constraint(equalTo: externalLinkContainerView.leadingAnchor, constant: 16),
            externalLinkButton.trailingAnchor.constraint(equalTo: externalLinkContainerView.trailingAnchor, constant: -16),
            externalLinkButton.bottomAnchor.constraint(equalTo: externalLinkContainerView.bottomAnchor, constant: -16),
            
            annotationContainerView.topAnchor.constraint(equalTo: externalLinkContainerView.bottomAnchor, constant: 16),
            annotationContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            annotationContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            annotationTitleLabel.topAnchor.constraint(equalTo: annotationContainerView.topAnchor, constant: 16),
            annotationTitleLabel.leadingAnchor.constraint(equalTo: annotationContainerView.leadingAnchor, constant: 16),
            annotationTitleLabel.trailingAnchor.constraint(equalTo: annotationContainerView.trailingAnchor, constant: -16),
            
            annotationTextView.topAnchor.constraint(equalTo: annotationTitleLabel.bottomAnchor, constant: 8),
            annotationTextView.leadingAnchor.constraint(equalTo: annotationContainerView.leadingAnchor, constant: 16),
            annotationTextView.trailingAnchor.constraint(equalTo: annotationContainerView.trailingAnchor, constant: -16),
            annotationTextView.bottomAnchor.constraint(equalTo: annotationContainerView.bottomAnchor, constant: -16),
            
            reviewContainerView.topAnchor.constraint(equalTo: annotationContainerView.bottomAnchor, constant: 16),
            reviewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reviewTitleLabel.topAnchor.constraint(equalTo: reviewContainerView.topAnchor, constant: 16),
            reviewTitleLabel.leadingAnchor.constraint(equalTo: reviewContainerView.leadingAnchor, constant: 16),
            reviewTitleLabel.trailingAnchor.constraint(equalTo: reviewContainerView.trailingAnchor, constant: -16),
            
            reviewTextView.topAnchor.constraint(equalTo: reviewTitleLabel.bottomAnchor, constant: 8),
            reviewTextView.leadingAnchor.constraint(equalTo: reviewContainerView.leadingAnchor, constant: 16),
            reviewTextView.trailingAnchor.constraint(equalTo: reviewContainerView.trailingAnchor, constant: -16),
            reviewTextView.bottomAnchor.constraint(equalTo: reviewContainerView.bottomAnchor, constant: -16),
            
            editButton.topAnchor.constraint(equalTo: reviewContainerView.bottomAnchor, constant: 24),
            editButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            editButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Configuration
    private func configureWithBook() {
        titleLabel.text = book.title
        authorLabel.text = book.author
        
        if let ageLimit = book.ageLimit, !ageLimit.isEmpty {
            ageLimitBadge.text = ageLimit
            ageLimitBadge.isHidden = false
        }
        
        setupInfoCards()
        setupRatingStars()
        ratingValueLabel.text = String(format: "%.1f", book.rating)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        
        if let startDate = book.startDate {
            startDateLabel.text = formatter.string(from: startDate)
        } else {
            startDateLabel.text = "Не указано"
            startDateLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        }
        
        if let finishDate = book.finishDate {
            finishDateLabel.text = formatter.string(from: finishDate)
        } else {
            finishDateLabel.text = "Не указано"
            finishDateLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        }
        
        if let link = book.externalLink, !link.isEmpty,
           let linkTitle = book.linkTitle, !linkTitle.isEmpty {
            externalLinkButton.setTitle("📎 \(linkTitle)", for: .normal)
            externalLinkContainerView.isHidden = false
        }
        
        if let annotation = book.annotation, !annotation.isEmpty {
            annotationTextView.text = annotation
        } else {
            annotationTextView.text = "Аннотация отсутствует"
            annotationTextView.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        }
        
        if let review = book.review, !review.isEmpty {
            reviewTextView.text = review
        } else {
            reviewTextView.text = "Рецензия отсутствует"
            reviewTextView.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        }
    }
    
    private func setupInfoCards() {
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if book.publicationYear > 0 {
            let yearCard = createInfoCard(
                icon: "calendar",
                value: "\(book.publicationYear)",
                title: "Год"
            )
            infoStackView.addArrangedSubview(yearCard)
        }
        if book.pageCount > 0 {
            let pagesCard = createInfoCard(
                icon: "book.pages",
                value: "\(book.pageCount)",
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
        let rating = Int(book.rating)
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
        loadImage(from: coverURL) { [weak self] image in
            DispatchQueue.main.async {
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
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if urlString.hasPrefix("asset://") {
            let assetName = String(urlString.dropFirst("asset://".count))
            let image = UIImage(named: assetName)
            completion(image)
            return
        }
        
        if urlString.hasPrefix("file://") {
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                completion(image)
            } catch {
                print("Failed to load image from file: \(error)")
                completion(nil)
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to load image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            completion(image)
        }.resume()
    }
    
    // MARK: - Actions
    @objc private func editTapped() {
        let addBookVC = AddBookViewController(existingBook: book)
        let navController = UINavigationController(rootViewController: addBookVC)
        present(navController, animated: true)
    }
    
    @objc private func openExternalLink() {
        guard let urlString = book.externalLink,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            showError("Не удалось открыть ссылку")
            return
        }
        
        UIApplication.shared.open(url)
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

