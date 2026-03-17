//
//  AchievementNotification.swift
//  BookShelf
//

import UIKit

final class AchievementNotificationManager {
    static let shared = AchievementNotificationManager()
    
    private var notificationWindow: UIWindow?
    private var currentNotification: AchievementNotificationView?
    private var notificationQueue: [Achievement] = []
    private var isShowing = false
    private var shownAchievements: Set<String> = []
    
    private init() {}
    
    func showAchievement(_ achievement: Achievement, in viewController: UIViewController? = nil) {
        let achievementId = "\(achievement.title)_\(achievement.description)"
        guard !shownAchievements.contains(achievementId) else {
            return
        }
        
        shownAchievements.insert(achievementId)
        notificationQueue.append(achievement)
        
        if !isShowing {
            showNextNotification(in: viewController)
        }
    }
    
    private func showNextNotification(in viewController: UIViewController? = nil) {
        guard !notificationQueue.isEmpty else {
            isShowing = false
            return
        }
        
        isShowing = true
        let achievement = notificationQueue.removeFirst()
        let notification = AchievementNotificationView(achievement: achievement)
        notification.alpha = 0
        notification.translatesAutoresizingMaskIntoConstraints = false
        
        if let viewController = viewController {
            viewController.view.addSubview(notification)
            
            NSLayoutConstraint.activate([
                notification.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 16),
                notification.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
                notification.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16)
            ])
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            let window = UIWindow(windowScene: windowScene)
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear
            window.isUserInteractionEnabled = false
            
            window.addSubview(notification)
            
            NSLayoutConstraint.activate([
                notification.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 16),
                notification.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
                notification.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16)
            ])
            
            window.isHidden = false
            self.notificationWindow = window
        }
        
        self.currentNotification = notification
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            notification.alpha = 1
            notification.transform = CGAffineTransform(translationX: 0, y: 10)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self, let notification = self.currentNotification else { return }
            UIView.animate(withDuration: 0.3, animations: {
                notification.alpha = 0
                notification.transform = CGAffineTransform(translationX: 0, y: -20)
            }) { _ in
                notification.removeFromSuperview()
                self.notificationWindow?.isHidden = true
                self.notificationWindow = nil
                self.currentNotification = nil
                self.showNextNotification(in: viewController)
            }
        }
    }
    
    func resetShownAchievements() {
        shownAchievements.removeAll()
    }
}

// MARK: - Notification View (убираем кружочки/конфетти)
final class AchievementNotificationView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.BookShelf.cardBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.BookShelf.primaryText
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.BookShelf.primaryText.withAlphaComponent(0.8)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "НОВОЕ ДОСТИЖЕНИЕ"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor.BookShelf.buttonText
        label.backgroundColor = UIColor.BookShelf.buttonBackground
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(achievement: Achievement) {
        super.init(frame: .zero)
        setupUI()
        configure(with: achievement)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            badgeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            badgeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            badgeLabel.widthAnchor.constraint(equalToConstant: 100),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: badgeLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .up
        addGestureRecognizer(swipeGesture)
    }
    
    private func configure(with achievement: Achievement) {
        titleLabel.text = achievement.title
        descriptionLabel.text = achievement.description
    }
    
    @objc private func handleSwipe() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -20)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
