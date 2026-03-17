//
//  AddBookViewController.swift
//  BookShelf
//

import UIKit
import CoreData
import Foundation

final class AddBookViewController: UIViewController {
    // MARK: - Properties
    private let book: BookDTO?
    private let existingBook: Book?
    private let coreDataManager = CoreDataManager.shared
    private var shelves: [Shelf] = []
    private var selectedCoverImage: UIImage?
    private var selectedCoverURL: String?
    private var isSaving = false
    private var isEditMode: Bool { return existingBook != nil }
    private var selectedShelfIndex: Int = 0
    private var selectedShelfID: NSManagedObjectID?
    
    // MARK: - UI Elements (оставляем без изменений)
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
    
    // MARK: - Header Section
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .BookShelf.primaryText
        label.text = "Новая книга"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.7)
        label.text = "Заполните информацию о книге"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Cover Section
    private let coverSectionCard: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .BookShelf.primaryBackground.withAlphaComponent(0.3)
        imageView.image = UIImage(systemName: "book.closed")
        imageView.tintColor = .BookShelf.primaryText.withAlphaComponent(0.3)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let coverOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let editIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil.circle.fill")
        imageView.tintColor = .BookShelf.buttonBackground
        imageView.backgroundColor = .BookShelf.cardBackground
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Form Sections (оставляем без изменений)
    private let formStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let basicInfoSection = FormSectionView(title: "Основная информация", icon: "book.fill")
    private let titleTextField = FormTextField(placeholder: "Название книги", isRequired: true)
    private let authorTextField = FormTextField(placeholder: "Автор", isRequired: true)
    private let genreTextField = FormTextField(placeholder: "Жанр")
    
    private let detailsSection = FormSectionView(title: "Детали", icon: "info.circle.fill")
    private let detailsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let publicationYearField = FormTextField(placeholder: "Год", keyboardType: .numberPad)
    private let pageCountField = FormTextField(placeholder: "Страниц", keyboardType: .numberPad)
    private let ageLimitField = FormTextField(placeholder: "Возраст")
    
    private let datesSection = FormSectionView(title: "Даты чтения", icon: "calendar")
    private let startDatePickerView = FormDatePicker(title: "Начало чтения")
    private let finishDatePickerView = FormDatePicker(title: "Окончание чтения")
    
    private let ratingSection = FormSectionView(title: "Оценка", icon: "star.fill")
    private let ratingControl: RatingControl = {
        let control = RatingControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let linkSection = FormSectionView(title: "Внешняя ссылка", icon: "link")
    private let linkTextField = FormTextField(placeholder: "URL")
    private let linkTitleField = FormTextField(placeholder: "Название ссылки")
    
    private let notesSection = FormSectionView(title: "Заметки", icon: "note.text")
    private let annotationTextView = ExpandingTextView(placeholder: "Аннотация")
    private let reviewTextView = ExpandingTextView(placeholder: "Рецензия или отзыв")
    
    private let shelfSection = FormSectionView(title: "Полка", icon: "books.vertical.fill")
    private let shelfPickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let shelfPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .clear
        return picker
    }()
    
    private let noShelvesLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет доступных полок. Создайте полку в библиотеке."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: ModernButton = {
        let button = ModernButton(title: "Сохранить книгу", style: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .BookShelf.buttonText
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    init(book: BookDTO? = nil, existingBook: Book? = nil) {
        self.book = book
        self.existingBook = existingBook
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        loadShelves()
        loadInitialData()
        
        if isEditMode {
            titleLabel.text = "Редактировать"
            subtitleLabel.text = "Измените информацию о книге"
        }
    }
    
    // MARK: - Setup UI (оставляем без изменений)
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        setupNavigationBar()
        setupScrollView()
        setupHeader()
        setupCoverSection()
        setupFormSections()
        setupSaveButton()
        setupLoadingOverlay()
        setupConstraints()
        setupActions()
        shelfPicker.delegate = self
        shelfPicker.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationController?.navigationBar.tintColor = .BookShelf.buttonBackground
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeader() {
        contentView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
    }
    
    private func setupCoverSection() {
        contentView.addSubview(coverSectionCard)
        coverSectionCard.addSubview(coverImageView)
        coverSectionCard.addSubview(coverOverlayView)
        coverSectionCard.addSubview(coverActivityIndicator)
        coverSectionCard.addSubview(editIconImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseCoverTapped))
        coverSectionCard.addGestureRecognizer(tapGesture)
    }
    
    private func setupFormSections() {
        contentView.addSubview(formStackView)
        
        basicInfoSection.contentView.addSubview(titleTextField)
        basicInfoSection.contentView.addSubview(authorTextField)
        basicInfoSection.contentView.addSubview(genreTextField)
        formStackView.addArrangedSubview(basicInfoSection)
        
        detailsSection.contentView.addSubview(detailsStackView)
        detailsStackView.addArrangedSubview(publicationYearField)
        detailsStackView.addArrangedSubview(pageCountField)
        detailsStackView.addArrangedSubview(ageLimitField)
        formStackView.addArrangedSubview(detailsSection)
        
        datesSection.contentView.addSubview(startDatePickerView)
        datesSection.contentView.addSubview(finishDatePickerView)
        formStackView.addArrangedSubview(datesSection)
        
        ratingSection.contentView.addSubview(ratingControl)
        formStackView.addArrangedSubview(ratingSection)
        
        linkSection.contentView.addSubview(linkTextField)
        linkSection.contentView.addSubview(linkTitleField)
        formStackView.addArrangedSubview(linkSection)
        
        notesSection.contentView.addSubview(annotationTextView)
        notesSection.contentView.addSubview(reviewTextView)
        formStackView.addArrangedSubview(notesSection)
        
        shelfSection.contentView.addSubview(shelfPickerContainer)
        shelfPickerContainer.addSubview(shelfPicker)
        shelfPickerContainer.addSubview(noShelvesLabel)
        formStackView.addArrangedSubview(shelfSection)
    }
    
    private func setupSaveButton() {
        contentView.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupLoadingOverlay() {
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            coverSectionCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            coverSectionCard.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverSectionCard.widthAnchor.constraint(equalToConstant: 200),
            coverSectionCard.heightAnchor.constraint(equalToConstant: 280),

            coverImageView.topAnchor.constraint(equalTo: coverSectionCard.topAnchor, constant: 12),
            coverImageView.leadingAnchor.constraint(equalTo: coverSectionCard.leadingAnchor, constant: 12),
            coverImageView.trailingAnchor.constraint(equalTo: coverSectionCard.trailingAnchor, constant: -12),
            coverImageView.bottomAnchor.constraint(equalTo: coverSectionCard.bottomAnchor, constant: -12),

            coverOverlayView.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            coverOverlayView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            coverOverlayView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            coverOverlayView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),

            coverActivityIndicator.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            coverActivityIndicator.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),

            editIconImageView.topAnchor.constraint(equalTo: coverSectionCard.topAnchor, constant: 8),
            editIconImageView.trailingAnchor.constraint(equalTo: coverSectionCard.trailingAnchor, constant: -8),
            editIconImageView.widthAnchor.constraint(equalToConstant: 30),
            editIconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            formStackView.topAnchor.constraint(equalTo: coverSectionCard.bottomAnchor, constant: 24),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            formStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: basicInfoSection.contentView.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: basicInfoSection.contentView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: basicInfoSection.contentView.trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            authorTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            authorTextField.leadingAnchor.constraint(equalTo: basicInfoSection.contentView.leadingAnchor),
            authorTextField.trailingAnchor.constraint(equalTo: basicInfoSection.contentView.trailingAnchor),
            authorTextField.heightAnchor.constraint(equalToConstant: 50),
            
            genreTextField.topAnchor.constraint(equalTo: authorTextField.bottomAnchor, constant: 12),
            genreTextField.leadingAnchor.constraint(equalTo: basicInfoSection.contentView.leadingAnchor),
            genreTextField.trailingAnchor.constraint(equalTo: basicInfoSection.contentView.trailingAnchor),
            genreTextField.heightAnchor.constraint(equalToConstant: 50),
            genreTextField.bottomAnchor.constraint(equalTo: basicInfoSection.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            detailsStackView.topAnchor.constraint(equalTo: detailsSection.contentView.topAnchor),
            detailsStackView.leadingAnchor.constraint(equalTo: detailsSection.contentView.leadingAnchor),
            detailsStackView.trailingAnchor.constraint(equalTo: detailsSection.contentView.trailingAnchor),
            detailsStackView.bottomAnchor.constraint(equalTo: detailsSection.contentView.bottomAnchor),
            detailsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            startDatePickerView.topAnchor.constraint(equalTo: datesSection.contentView.topAnchor),
            startDatePickerView.leadingAnchor.constraint(equalTo: datesSection.contentView.leadingAnchor),
            startDatePickerView.trailingAnchor.constraint(equalTo: datesSection.contentView.trailingAnchor),
            
            finishDatePickerView.topAnchor.constraint(equalTo: startDatePickerView.bottomAnchor, constant: 12),
            finishDatePickerView.leadingAnchor.constraint(equalTo: datesSection.contentView.leadingAnchor),
            finishDatePickerView.trailingAnchor.constraint(equalTo: datesSection.contentView.trailingAnchor),
            finishDatePickerView.bottomAnchor.constraint(equalTo: datesSection.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ratingControl.topAnchor.constraint(equalTo: ratingSection.contentView.topAnchor),
            ratingControl.leadingAnchor.constraint(equalTo: ratingSection.contentView.leadingAnchor),
            ratingControl.trailingAnchor.constraint(equalTo: ratingSection.contentView.trailingAnchor),
            ratingControl.bottomAnchor.constraint(equalTo: ratingSection.contentView.bottomAnchor),
            ratingControl.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            linkTextField.topAnchor.constraint(equalTo: linkSection.contentView.topAnchor),
            linkTextField.leadingAnchor.constraint(equalTo: linkSection.contentView.leadingAnchor),
            linkTextField.trailingAnchor.constraint(equalTo: linkSection.contentView.trailingAnchor),
            linkTextField.heightAnchor.constraint(equalToConstant: 50),
            
            linkTitleField.topAnchor.constraint(equalTo: linkTextField.bottomAnchor, constant: 12),
            linkTitleField.leadingAnchor.constraint(equalTo: linkSection.contentView.leadingAnchor),
            linkTitleField.trailingAnchor.constraint(equalTo: linkSection.contentView.trailingAnchor),
            linkTitleField.heightAnchor.constraint(equalToConstant: 50),
            linkTitleField.bottomAnchor.constraint(equalTo: linkSection.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            annotationTextView.topAnchor.constraint(equalTo: notesSection.contentView.topAnchor),
            annotationTextView.leadingAnchor.constraint(equalTo: notesSection.contentView.leadingAnchor),
            annotationTextView.trailingAnchor.constraint(equalTo: notesSection.contentView.trailingAnchor),
            
            reviewTextView.topAnchor.constraint(equalTo: annotationTextView.bottomAnchor, constant: 16),
            reviewTextView.leadingAnchor.constraint(equalTo: notesSection.contentView.leadingAnchor),
            reviewTextView.trailingAnchor.constraint(equalTo: notesSection.contentView.trailingAnchor),
            reviewTextView.bottomAnchor.constraint(equalTo: notesSection.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
           shelfPickerContainer.topAnchor.constraint(equalTo: shelfSection.contentView.topAnchor),
           shelfPickerContainer.leadingAnchor.constraint(equalTo: shelfSection.contentView.leadingAnchor),
           shelfPickerContainer.trailingAnchor.constraint(equalTo: shelfSection.contentView.trailingAnchor),
           shelfPickerContainer.bottomAnchor.constraint(equalTo: shelfSection.contentView.bottomAnchor),
           shelfPickerContainer.heightAnchor.constraint(equalToConstant: 120)
       ])
       
       NSLayoutConstraint.activate([
           shelfPicker.topAnchor.constraint(equalTo: shelfPickerContainer.topAnchor),
           shelfPicker.leadingAnchor.constraint(equalTo: shelfPickerContainer.leadingAnchor),
           shelfPicker.trailingAnchor.constraint(equalTo: shelfPickerContainer.trailingAnchor),
           shelfPicker.bottomAnchor.constraint(equalTo: shelfPickerContainer.bottomAnchor),
           
           noShelvesLabel.centerXAnchor.constraint(equalTo: shelfPickerContainer.centerXAnchor),
           noShelvesLabel.centerYAnchor.constraint(equalTo: shelfPickerContainer.centerYAnchor),
           noShelvesLabel.leadingAnchor.constraint(equalTo: shelfPickerContainer.leadingAnchor, constant: 16),
           noShelvesLabel.trailingAnchor.constraint(equalTo: shelfPickerContainer.trailingAnchor, constant: -16)
       ])
    
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 24),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            saveButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func chooseCoverTapped() {
        let modal = ImagePickerModal()
        modal.delegate = self
        modal.show(in: self)
    }
    
    @objc private func saveTapped() {
        guard validateInput() else { return }
        showLoading(true)
        Task { [weak self] in
            await self?.performSave()
        }
    }
    
    // MARK: - Helper Methods (оставляем без изменений)
    private func loadShelves() {
        Task {
            do {
                let shelves = try await coreDataManager.fetchShelves()
                await MainActor.run {
                    self.shelves = shelves
                    self.shelfPicker.reloadAllComponents()
                    self.noShelvesLabel.isHidden = !self.shelves.isEmpty
                    self.shelfPicker.isHidden = self.shelves.isEmpty
                    for (idx, shelf) in shelves.enumerated() {
                        print("   [\(idx)] \(shelf.name ?? "unnamed") - ID: \(shelf.objectID)")
                    }
                    if self.isEditMode, let selectedID = self.selectedShelfID {
                        if let index = shelves.firstIndex(where: { $0.objectID == selectedID }) {
                            self.shelfPicker.selectRow(index, inComponent: 0, animated: false)
                        }
                    }
                    else if !self.isEditMode && !shelves.isEmpty {
                        self.shelfPicker.selectRow(0, inComponent: 0, animated: false)
                    }
                }
            } catch {
                print("Error loading shelves: \(error)")
            }
        }
    }
    
    private func loadInitialData() {
        if isEditMode, let existingBook = existingBook {
            populateWithExistingBook(existingBook)
        } else if let book = book {
            populateWithBookDTO(book)
        }
    }
    
    private func populateWithExistingBook(_ book: Book) {
        titleTextField.text = book.title
        authorTextField.text = book.author
        genreTextField.text = book.genre
        ageLimitField.text = book.ageLimit
        publicationYearField.text = book.publicationYear > 0 ? "\(book.publicationYear)" : nil
        pageCountField.text = book.pageCount > 0 ? "\(book.pageCount)" : nil
        
        if let startDate = book.startDate {
            startDatePickerView.date = startDate
        }
        if let finishDate = book.finishDate {
            finishDatePickerView.date = finishDate
        }
        
        ratingControl.rating = Int(book.rating)
        linkTextField.text = book.externalLink
        linkTitleField.text = book.linkTitle
        
        if let annotation = book.annotation, !annotation.isEmpty {
            annotationTextView.text = annotation
            annotationTextView.textColor = .BookShelf.primaryText
        }
        if let review = book.review, !review.isEmpty {
            reviewTextView.text = review
            reviewTextView.textColor = .BookShelf.primaryText
        }
        if let coverURL = book.coverImageURL {
            selectedCoverURL = coverURL
            loadAndSetCover(from: coverURL)
        }
        if let shelf = book.shelf {
            self.selectedShelfID = shelf.objectID
        }
    }
    
    private func populateWithBookDTO(_ book: BookDTO) {
        titleTextField.text = book.title
        authorTextField.text = book.author
        genreTextField.text = book.genre
        if let year = book.publishedYear, year > 0 {
            publicationYearField.text = "\(year)"
        }
        if let pages = book.pageCount, pages > 0 {
            pageCountField.text = "\(pages)"
        }
        if let rating = book.rating {
            ratingControl.rating = Int(rating)
        }
        if let description = book.description, !description.isEmpty {
            annotationTextView.text = description
            annotationTextView.textColor = .BookShelf.primaryText
        }
        if let previewLink = book.previewLink {
            linkTextField.text = previewLink
            linkTitleField.text = "Google Books Preview"
        } else if let infoLink = book.infoLink {
            linkTextField.text = infoLink
            linkTitleField.text = "Google Books"
        }
        if let coverURL = book.coverImageURL {
            selectedCoverURL = coverURL
            loadAndSetCover(from: coverURL)
        }
    }
    
    private func loadAndSetCover(from urlString: String) {
        coverActivityIndicator.startAnimating()
        coverOverlayView.isHidden = false
        loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                self?.coverActivityIndicator.stopAnimating()
                self?.coverOverlayView.isHidden = true
                if let image = image {
                    self?.coverImageView.image = image
                    self?.coverImageView.contentMode = .scaleAspectFill
                    self?.selectedCoverImage = image
                    self?.selectedCoverURL = urlString
                } else {
                    self?.showError("Не удалось загрузить изображение")
                }
            }
        }
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
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } catch {
                    print("Failed to load image from file: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to load image: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    private func removeCover() {
        coverImageView.image = UIImage(systemName: "book.closed")
        coverImageView.tintColor = .BookShelf.primaryText.withAlphaComponent(0.3)
        coverImageView.contentMode = .scaleAspectFit
        selectedCoverImage = nil
        selectedCoverURL = nil
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = "cover_\(UUID().uuidString).jpg"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent(filename)
        do {
            try data.write(to: filePath)
            return filePath.absoluteString
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    private func validateInput() -> Bool {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showError("Введите название книги")
            return false
        }
        guard let author = authorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !author.isEmpty else {
            showError("Введите автора книги")
            return false
        }
        return true
    }
    
    private func performSave() async {
        let selectedShelfIndex = shelfPicker.selectedRow(inComponent: 0)
        let selectedShelf = shelves.isEmpty ? nil : shelves[selectedShelfIndex]
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let author = authorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let genre = genreTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let ageLimit = ageLimitField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let publicationYear = Int64(publicationYearField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0") ?? 0
        let pageCount = Int64(pageCountField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0") ?? 0
        let rating = Double(ratingControl.rating)
        let startDate = startDatePickerView.date
        let finishDate = finishDatePickerView.date
        let externalLink = linkTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let linkTitle = linkTitleField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let annotation = annotationTextView.textColor == .BookShelf.primaryText ? annotationTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        let review = reviewTextView.textColor == .BookShelf.primaryText ? reviewTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        var coverURL = selectedCoverURL
        
        if let image = selectedCoverImage, coverURL == nil {
            if let savedPath = saveImageToDocuments(image) {
                coverURL = savedPath
            }
        }
        
        do {
            if isEditMode, let existingBook = existingBook {
                try await coreDataManager.updateBook(
                    existingBook,
                    title: title,
                    author: author,
                    genre: genre,
                    shelf: selectedShelf,
                    rating: rating,
                    pageCount: pageCount,
                    publicationYear: publicationYear,
                    coverImageURL: coverURL,
                    startDate: startDate,
                    annotation: annotation,
                    ageLimit: ageLimit,
                    externalLink: externalLink,
                    linkTitle: linkTitle,
                    finishDate: finishDate,
                    review: review
                )
                await MainActor.run {
                    showLoading(false)
                    DataChangeManager.shared.notifyBookUpdated()
                    NotificationCenter.default.post(name: .bookDataChanged, object: nil)
                    showSuccessAndDismiss(message: "Книга успешно обновлена")
                }
            } else {
                let result = try await coreDataManager.createBookWithImmediateUpdate(
                    title: title,
                    author: author,
                    genre: genre ?? "Неизвестно",
                    shelf: selectedShelf,
                    rating: rating,
                    pageCount: pageCount,
                    publicationYear: publicationYear,
                    coverImageURL: coverURL,
                    startDate: startDate,
                    annotation: annotation,
                    ageLimit: ageLimit,
                    externalLink: externalLink,
                    linkTitle: linkTitle,
                    finishDate: finishDate,
                    review: review
                )
                await MainActor.run {
                    showLoading(false)
                    DataChangeManager.shared.notifyBookAdded()
                    NotificationCenter.default.post(
                        name: .bookDataChanged,
                        object: nil,
                        userInfo: ["book": result.book, "shelf": result.shelf as Any]
                    )
                    showSuccessAndDismiss(message: "Книга успешно добавлена в библиотеку")
                }
            }
        } catch {
            await MainActor.run {
                showLoading(false)
                isSaving = false
                showError("Не удалось сохранить книгу: \(error.localizedDescription)")
            }
        }
    }
    
    private func showLoading(_ show: Bool) {
        loadingOverlay.isHidden = !show
        show ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        saveButton.isEnabled = !show
        view.isUserInteractionEnabled = !show
    }
    
    private func showSuccessAndDismiss(message: String) {
        let alert = UIAlertController(
            title: "Успешно!",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
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

// MARK: - ImagePickerModalDelegate
extension AddBookViewController: ImagePickerModalDelegate {
    func imagePickerModal(_ modal: ImagePickerModal, didSelectImage image: UIImage) {
        coverImageView.image = image
        coverImageView.contentMode = .scaleAspectFill
        selectedCoverImage = image
        selectedCoverURL = nil
    }

    func imagePickerModalDidCancel(_ modal: ImagePickerModal) {}
    
    func imagePickerModalDidRequestRemove(_ modal: ImagePickerModal) {
        removeCover()
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension AddBookViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let count = shelves.isEmpty ? 1 : shelves.count
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if shelves.isEmpty {
            return "Нет полок"
        }
        return shelves[row].name ?? "Без названия"
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = shelves.isEmpty ? "Нет полок" : (shelves[row].name ?? "Без названия")
        return NSAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.BookShelf.primaryText]
        )
    }
}

extension AddBookViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
