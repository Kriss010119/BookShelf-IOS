//
//  RenameShelfModal.swift
//  BookShelf
//

import UIKit

protocol RenameShelfModalDelegate: AnyObject {
    func renameShelfModal(_ modal: RenameShelfModal, didRenameShelfTo newName: String)
    func renameShelfModalDidCancel(_ modal: RenameShelfModal)
}

final class RenameShelfModal: BaseModalViewController {
    
    // MARK: - Properties
    weak var delegate: RenameShelfModalDelegate?
    let currentName: String
    
    // MARK: - UI Elements
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Новое название полки"
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
    
    private var saveButton: UIButton!
    private var cancelButton: UIButton!
    
    // MARK: - Init
    init(currentName: String) {
        self.currentName = currentName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        titleLabel.text = "Переименовать полку"
        messageLabel.text = "Введите новое название для полки"
        containerView.addSubview(textField)
        cancelButton = addButton(title: "Отмена", style: .secondary) { [weak self] in
            self?.cancelTapped()
        }
        saveButton = addButton(title: "Сохранить", style: .primary) { [weak self] in
            self?.saveTapped()
        }
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(saveButton)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        buttonStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20).isActive = true
        textField.text = currentName
        textField.delegate = self
        updateSaveButtonState()
    }
    
    private func setupTextFieldObserver() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isDifferent = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != currentName
        saveButton.isEnabled = hasText && isDifferent
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.renameShelfModalDidCancel(self)
            self.onDismiss?()
        }
    }
    
    private func saveTapped() {
        guard let newName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty else { return }
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.renameShelfModal(self, didRenameShelfTo: newName)
            self.onDismiss?()
        }
    }
}

// MARK: - UITextFieldDelegate
extension RenameShelfModal: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if saveButton.isEnabled {
            saveTapped()
        }
        return true
    }
}
