//
//  DeleteConfirmationModal.swift
//  BookShelf
//

import UIKit

protocol DeleteConfirmationModalDelegate: AnyObject {
    func deleteConfirmationModalDidConfirm(_ modal: DeleteConfirmationModal)
    func deleteConfirmationModalDidCancel(_ modal: DeleteConfirmationModal)
}

final class DeleteConfirmationModal: BaseModalViewController {
    
    // MARK: - Properties
    weak var delegate: DeleteConfirmationModalDelegate?
    let itemType: DeleteItemType
    let itemName: String
    let additionalInfo: String?
    
    enum DeleteItemType {
        case shelf
        case book
        
        var title: String {
            switch self {
            case .shelf: return "Удалить полку"
            case .book:  return "Удалить книгу"
            }
        }
        
        var confirmButtonTitle: String {
            return "Удалить"
        }
        
        var icon: String {
            switch self {
            case .shelf: return "books.vertical"
            case .book:  return "book"
            }
        }
    }
    
    // MARK: - Init
    init(itemType: DeleteItemType, itemName: String, additionalInfo: String? = nil) {
        self.itemType = itemType
        self.itemName = itemName
        self.additionalInfo = additionalInfo
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
        titleLabel.text = itemType.title
        
        var message = "Вы уверены, что хотите удалить "
        switch itemType {
        case .shelf:
            message += "полку \"\(itemName)\"?"
            if let info = additionalInfo {
                message += "\n\n\(info)"
            }
        case .book:
            message += "книгу \"\(itemName)\"?"
        }
        
        messageLabel.text = message
        
        let cancelButton = addButton(title: "Отмена", style: .secondary) { [weak self] in
            self?.cancelTapped()
        }
        let deleteButton = addButton(title: itemType.confirmButtonTitle, style: .destructive) { [weak self] in
            self?.deleteTapped()
        }
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(deleteButton)
    }
    
    // MARK: - Actions
    private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.deleteConfirmationModalDidCancel(self)
            self.onDismiss?()
        }
    }
    
    private func deleteTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.deleteConfirmationModalDidConfirm(self)
            self.onDismiss?()
        }
    }
}
