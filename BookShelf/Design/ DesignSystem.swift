import UIKit

// MARK: - Colors
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    struct BookShelf {
        static let primaryBackground = UIColor(hex: "B3977E")
        static let secondaryBackground = UIColor(hex: "E5D5C5")
        static let primaryText = UIColor(hex: "5D4037")
        static let buttonBackground = UIColor(hex: "5D4037")
        static let buttonBackgroundPressed = UIColor(hex: "473029")
        static let buttonBorder = UIColor(hex: "38251F")
        static let buttonText = UIColor(hex: "F4DFC3")
        static let cardBackground = UIColor(hex: "F4DFC3")
        static let cardText = UIColor(hex: "5D4037")
        static let separator = UIColor(hex: "5D4037").withAlphaComponent(0.2)
        static let success = UIColor(hex: "4CAF50")
        static let warning = UIColor(hex: "FF9800")
        static let error = UIColor(hex: "F44336")
        static let accent = UIColor(hex: "F4DFC3")
        
    }
}


// MARK: - Typography
enum Typography {
    case largeTitle, title, body, caption, button, small
    
    var font: UIFont {
        switch self {
        case .largeTitle:
            return .systemFont(ofSize: 34, weight: .bold)
        case .title:
            return .systemFont(ofSize: 28, weight: .semibold)
        case .body:
            return .systemFont(ofSize: 17, weight: .regular)
        case .caption:
            return .systemFont(ofSize: 13, weight: .medium)
        case .button:
            return .systemFont(ofSize: 17, weight: .semibold)
        case .small:
            return .systemFont(ofSize: 11, weight: .regular)
        }
    }
}

// MARK: - Reusable Components
class PrimaryButton: UIButton {
    enum ButtonStyle {
        case primary, secondary, outline
    }
    
    var buttonStyle: ButtonStyle = .primary {
        didSet {
            updateAppearance()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = Typography.button.font
        layer.cornerRadius = 10
        clipsToBounds = true
        let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint
        updateAppearance()
    }
    
    private func updateAppearance() {
        switch buttonStyle {
        case .primary:
            backgroundColor = .BookShelf.buttonBackground
            setTitleColor(.BookShelf.buttonText, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.BookShelf.buttonBorder.cgColor
        case .secondary:
            backgroundColor = .BookShelf.cardBackground
            setTitleColor(.BookShelf.cardText, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.BookShelf.cardText.withAlphaComponent(0.3).cgColor
        case .outline:
            backgroundColor = .clear
            setTitleColor(.BookShelf.buttonBackground, for: .normal)
            layer.borderWidth = 2
            layer.borderColor = UIColor.BookShelf.buttonBackground.cgColor
        }
    }
    
    private func updateBackgroundColor() {
        guard buttonStyle == .primary else { return }
        
        UIView.animate(withDuration: 0.1) {
            self.backgroundColor = self.isHighlighted ?
                .BookShelf.buttonBackgroundPressed :
                .BookShelf.buttonBackground
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        invalidateIntrinsicContentSize()
    }
}

class BookCard: UIView {
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
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .BookShelf.primaryBackground
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .BookShelf.buttonText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        placeholderView.addSubview(placeholderLabel)
        addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1.5),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            authorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            placeholderView.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
        ])
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title ?? "Без названия"
        authorLabel.text = book.author ?? "Неизвестный автор"
        
        if let coverURL = book.coverImageURL, let url = URL(string: coverURL) {
            placeholderView.isHidden = true
            loadImage(from: url)
        } else {
            placeholderView.isHidden = false
            let title = book.title ?? "БН"
            placeholderLabel.text = String(title.prefix(2)).uppercased()
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.coverImageView.image = image
                }
            }
        }.resume()
    }
}

// MARK: - Simple Components for Testing
class SimpleTitleLabel: UILabel {
    init(text: String = "") {
        super.init(frame: .zero)
        self.text = text
        self.font = Typography.title.font
        self.textColor = .BookShelf.primaryText
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SimpleBodyLabel: UILabel {
    init(text: String = "") {
        super.init(frame: .zero)
        self.text = text
        self.font = Typography.body.font
        self.textColor = .BookShelf.primaryText.withAlphaComponent(0.8)
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

