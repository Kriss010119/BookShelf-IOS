//
//  AddBookOptionsModal.swift
//  BookShelf
//

import UIKit

protocol AddBookOptionsModalDelegate: AnyObject {
    func addBookOptionsModalDidSelectManual(_ modal: AddBookOptionsModal)
    func addBookOptionsModalDidSelectSearch(_ modal: AddBookOptionsModal)
    func addBookOptionsModalDidCancel(_ modal: AddBookOptionsModal)
}

final class AddBookOptionsModal: BaseModalViewController {
    
    // MARK: - Properties
    weak var delegate: AddBookOptionsModalDelegate?
    private let shelfName: String?
    
    // MARK: - UI Elements
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    init(shelfName: String? = nil) {
        self.shelfName = shelfName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModal()
    }
    
    // MARK: - Setup
    private func setupModal() {
        titleLabel.text = "Добавить книгу"
        
        if let shelfName = shelfName {
            messageLabel.text = "Выберите способ добавления книги на полку \"\(shelfName)\""
        } else {
            messageLabel.text = "Выберите способ добавления книги"
        }
        
        buttonStackView.isHidden = true
        containerView.addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            optionsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
        
        let manualOption = createOption(
            icon: "",
            title: "Ввести вручную",
            tag: 0
        ) { [weak self] in
            self?.selectManual()
        }
        
        let searchOption = createOption(
            icon: "",
            title: "Найти через поиск",
            tag: 1
        ) { [weak self] in
            self?.selectSearch()
        }
        
        optionsStackView.addArrangedSubview(manualOption)
        optionsStackView.addArrangedSubview(searchOption)
    }
    
    private func createOption(icon: String, title: String, tag: Int, action: @escaping () -> Void) -> UIView {
        let container = UIView()
        container.backgroundColor = .BookShelf.primaryBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.BookShelf.separator.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .BookShelf.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = tag
        return container
    }
    
    @objc private func optionTapped(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            container.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            container.backgroundColor = .BookShelf.separator
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                container.transform = .identity
                container.backgroundColor = .BookShelf.primaryBackground
            }
        }
        
        if container.tag == 0 {
            selectManual()
        } else {
            selectSearch()
        }
    }
    
    // MARK: - Actions
    private func selectManual() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.addBookOptionsModalDidSelectManual(self)
            self.onDismiss?()
        }
    }
    
    private func selectSearch() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.addBookOptionsModalDidSelectSearch(self)
            self.onDismiss?()
        }
    }
}
