//
//  CreateShelfViewController.swift
//  BookShelf
//
//  Created by Kriss Osina on 10.01.2026.
//

import UIKit

protocol CreateShelfViewControllerDelegate: AnyObject {
    func createShelfViewController(_ controller: CreateShelfViewController, didCreateShelfWithName name: String)
    func createShelfViewControllerDidCancel(_ controller: CreateShelfViewController)
}

class CreateShelfViewController: UIViewController {
    
    weak var delegate: CreateShelfViewControllerDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создать новую полку"
        label.font = Typography.title.font
        label.textColor = .BookShelf.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название полки"
        textField.font = Typography.body.font
        textField.textColor = .BookShelf.primaryText
        textField.backgroundColor = .BookShelf.primaryBackground
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let cancelButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.buttonStyle = .secondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            buttonStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
    }
    
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            delegate?.createShelfViewControllerDidCancel(self)
        }
    }
    
    @objc private func cancelTapped() {
        delegate?.createShelfViewControllerDidCancel(self)
    }
    
    @objc private func createTapped() {
        guard let shelfName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !shelfName.isEmpty else {
            showError(message: "Название полки не может быть пустым")
            return
        }
        
        if shelfName.count > 50 {
            showError(message: "Название полки слишком длинное")
            return
        }
        
        delegate?.createShelfViewController(self, didCreateShelfWithName: shelfName)
    }
    
    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        createButton.isEnabled = hasText
        createButton.alpha = hasText ? 1.0 : 0.5
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

extension CreateShelfViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createTapped()
        return true
    }
}
