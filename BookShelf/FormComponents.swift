//
//  FormComponents.swift
//  BookShelf
//

import UIKit

final class FormSectionView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .BookShelf.primaryText
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(title: String, icon: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

final class FormTextField: UITextField {
    
    init(placeholder: String, isRequired: Bool = false, keyboardType: UIKeyboardType = .default) {
        super.init(frame: .zero)
        self.placeholder = placeholder + (isRequired ? " *" : "")
        self.keyboardType = keyboardType
        self.font = .systemFont(ofSize: 16)
        self.textColor = .BookShelf.primaryText
        self.backgroundColor = .BookShelf.cardBackground
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.BookShelf.separator.cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        leftView = paddingView
        leftViewMode = .always
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FormDatePicker: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .BookShelf.primaryText.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .BookShelf.primaryText
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    var date: Date {
        get { return datePicker.date }
        set { datePicker.date = newValue }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }
}

final class RatingControl: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var starButtons: [UIButton] = []
    
    var rating: Int = 0 {
        didSet {
            updateStars()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .BookShelf.primaryText
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            button.tag = i
            stackView.addArrangedSubview(button)
            starButtons.append(button)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        rating = sender.tag
    }
    
    private func updateStars() {
        for (index, button) in starButtons.enumerated() {
            let imageName = index < rating ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
}

final class ExpandingTextView: UITextView {
    private var heightConstraint: NSLayoutConstraint?
    private var placeholderText: String
    private var placeholderLabel: UILabel?
    init(placeholder: String) {
        self.placeholderText = placeholder
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        font = .systemFont(ofSize: 16)
        textColor = .BookShelf.primaryText
        backgroundColor = .BookShelf.cardBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.BookShelf.separator.cgColor
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        isScrollEnabled = false
        delegate = self
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.font = font
        placeholderLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        self.placeholderLabel = placeholderLabel
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel?.isHidden = !text.isEmpty
    }
    
    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        let fittingSize = sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: max(100, fittingSize.height))
    }
}

extension ExpandingTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        invalidateIntrinsicContentSize()
        UIView.animate(withDuration: 0.1) {
            self.invalidateIntrinsicContentSize()
        }
    }
}

final class ModernButton: UIButton {
    enum Style {
        case primary
        case secondary
        var backgroundColor: UIColor {
            switch self {
            case .primary: return .BookShelf.buttonBackground
            case .secondary: return .clear
            }
        }
        var titleColor: UIColor {
            switch self {
            case .primary: return .BookShelf.buttonText
            case .secondary: return .BookShelf.buttonBackground
            }
        }
        var borderWidth: CGFloat {
            switch self {
            case .primary: return 0
            case .secondary: return 2
            }
        }
        var borderColor: UIColor {
            switch self {
            case .primary: return .clear
            case .secondary: return .BookShelf.buttonBackground
            }
        }
    }
    
    private var style: Style = .primary {
        didSet {
            updateAppearance()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted ?
                    CGAffineTransform(scaleX: 0.97, y: 0.97) :
                    .identity
                self.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }
    
    init(title: String, style: Style = .primary) {
        super.init(frame: .zero)
        self.style = style
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAppearance() {
        backgroundColor = style.backgroundColor
        setTitleColor(style.titleColor, for: .normal)
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
    }
}
