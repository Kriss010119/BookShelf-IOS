//
//  CreateShelfModal.swift
//  BookShelf
//

import UIKit

protocol CreateShelfModalDelegate: AnyObject {
    func createShelfModal(_ modal: CreateShelfModal, didCreateShelfWithName name: String)
    func createShelfModalDidCancel(_ modal: CreateShelfModal)
}

final class CreateShelfModal: BaseModalViewController {
    
    // MARK: - Properties
    weak var delegate: CreateShelfModalDelegate?
    
    // MARK: - UI Elements
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название полки"
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .BookShelf.primaryText
        textField.backgroundColor = .BookShelf.primaryBackground
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.BookShelf.separator.cgColor
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private var createButton: UIButton!
    private var cancelButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModal()
        setupTextFieldObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupModal() {
        titleLabel.text = "Создать новую полку"
        messageLabel.text = "Введите название для новой полки"
        containerView.addSubview(textField)
        cancelButton = addButton(title: "Отмена", style: .secondary) { [weak self] in
            self?.cancelTapped()
        }
        createButton = addButton(title: "Создать", style: .primary) { [weak self] in
            self?.createTapped()
        }
        createButton.isEnabled = false
        createButton.alpha = 0.5
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        buttonStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20).isActive = true
        textField.delegate = self
    }
    
    private func setupTextFieldObserver() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        createButton.isEnabled = hasText
        createButton.alpha = hasText ? 1.0 : 0.5
    }
    
    private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.createShelfModalDidCancel(self)
            self.onDismiss?()
        }
    }
    
    private func createTapped() {
        guard let shelfName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !shelfName.isEmpty else {
            showError(message: "Название полки не может быть пустым")
            return
        }
        
        if shelfName.count > 50 {
            showError(message: "Название полки слишком длинное")
            return
        }
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.createShelfModal(self, didCreateShelfWithName: shelfName)
            self.onDismiss?()
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateShelfModal: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if createButton.isEnabled {
            createTapped()
        }
        return true
    }
}
