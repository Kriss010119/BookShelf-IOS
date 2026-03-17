//
//  ImagePickerModal.swift
//  BookShelf
//

import UIKit
import PhotosUI

protocol ImagePickerModalDelegate: AnyObject {
    func imagePickerModal(_ modal: ImagePickerModal, didSelectImage image: UIImage)
    func imagePickerModalDidCancel(_ modal: ImagePickerModal)
    func imagePickerModalDidRequestRemove(_ modal: ImagePickerModal)
}

final class ImagePickerModal: BaseModalViewController {
    
    // MARK: - Properties
    weak var delegate: ImagePickerModalDelegate?
    
    // MARK: - UI Elements
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.separator
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModal()
    }
    
    // MARK: - Setup
    private func setupModal() {
        titleLabel.text = "Выберите обложку"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        messageLabel.isHidden = true
        buttonStackView.isHidden = true
        containerView.addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            optionsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            addOption(title: "Сделать фото", action: #selector(cameraTapped))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            addOption(title: "Выбрать из галереи", action: #selector(galleryTapped))
        }
        
        addOption(title: "Загрузить по URL", action: #selector(urlTapped))
        
        let separator = UIView()
        separator.backgroundColor = .BookShelf.separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        optionsStackView.addArrangedSubview(separator)
        addOption(title: "Удалить обложку", action: #selector(removeTapped), isDestructive: true)
        let separator2 = UIView()
        separator2.backgroundColor = .BookShelf.separator
        separator2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        optionsStackView.addArrangedSubview(separator2)
    
        addOption(title: "Отмена", action: #selector(cancelTapped), isCancel: true)
    }
    
    private func addOption(title: String, action: Selector, isDestructive: Bool = false, isCancel: Bool = false) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: isCancel ? .semibold : .regular)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .center
        
        if isDestructive {
            button.setTitleColor(.BookShelf.error, for: .normal)
        } else if isCancel {
            button.setTitleColor(.BookShelf.primaryText, for: .normal)
        } else {
            button.setTitleColor(.BookShelf.buttonBackground, for: .normal)
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        optionsStackView.addArrangedSubview(button)
        if !isCancel {
            let divider = UIView()
            divider.backgroundColor = .BookShelf.separator.withAlphaComponent(0.5)
            divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            optionsStackView.addArrangedSubview(divider)
        }
    }
    
    // MARK: - Actions
    @objc private func cameraTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func galleryTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func urlTapped() {
        let alert = UIAlertController(title: "URL обложки", message: "Введите URL изображения", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "https://example.com/cover.jpg"
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .whileEditing
        }
        
        alert.addAction(UIAlertAction(title: "Загрузить", style: .default) { [weak self] _ in
            guard let urlString = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !urlString.isEmpty else { return }
            
            self?.loadImageFromURL(urlString)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func removeTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.imagePickerModalDidRequestRemove(self)
            self.onDismiss?()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.imagePickerModalDidCancel(self)
            self.onDismiss?()
        }
    }
    
    private func loadImageFromURL(_ urlString: String) {
        let loadingAlert = UIAlertController(title: "Загрузка...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        guard let url = URL(string: urlString) else {
            loadingAlert.dismiss(animated: true) { [weak self] in
                self?.showError("Неверный URL")
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        self?.showError("Ошибка загрузки: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = data, let image = UIImage(data: data) else {
                        self?.showError("Не удалось загрузить изображение")
                        return
                    }
                    
                    self?.dismiss(animated: true) {
                        self?.delegate?.imagePickerModal(self!, didSelectImage: image)
                        self?.onDismiss?()
                    }
                }
            }
        }.resume()
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

// MARK: - UIImagePickerControllerDelegate
extension ImagePickerModal: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            if let image = info[.originalImage] as? UIImage {
                self?.dismiss(animated: true) {
                    self?.delegate?.imagePickerModal(self!, didSelectImage: image)
                    self?.onDismiss?()
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ImagePickerModal: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError("Не удалось загрузить изображение: \(error.localizedDescription)")
                }
                return
            }
            
            if let image = object as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true) {
                        self?.delegate?.imagePickerModal(self!, didSelectImage: image)
                        self?.onDismiss?()
                    }
                }
            }
        }
    }
}
