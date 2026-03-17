//
//  ProfileViewController.swift
//  BookShelf
//

import UIKit
import Combine
import Foundation

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .BookShelf.buttonText
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.backgroundColor = .BookShelf.buttonBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let editAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        button.tintColor = .BookShelf.buttonText
        button.backgroundColor = .BookShelf.buttonBackground
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.title.font
        label.textColor = .BookShelf.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Достижения", "Статистика"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .BookShelf.buttonBackground
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.BookShelf.buttonText,
            .font: Typography.caption.font
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.BookShelf.primaryText,
            .font: Typography.caption.font
        ], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let achievementsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: AchievementCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let statisticsView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .BookShelf.buttonBackground
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
        loadData()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .BookShelf.primaryBackground
        title = "Профиль"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(containerView)
        
        headerView.addSubview(avatarImageView)
        headerView.addSubview(editAvatarButton)
        headerView.addSubview(nameLabel)
        
        containerView.addSubview(achievementsCollectionView)
        containerView.addSubview(statisticsView)
        statisticsView.addSubview(statsCollectionView)
        
        view.addSubview(loadingIndicator)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        achievementsCollectionView.refreshControl = refreshControl
        statsCollectionView.refreshControl = refreshControl
        achievementsCollectionView.delegate = self
        achievementsCollectionView.dataSource = self
        statsCollectionView.delegate = self
        statsCollectionView.dataSource = self
        statsCollectionView.register(StatCardCell.self, forCellWithReuseIdentifier: StatCardCell.reuseIdentifier)
        statsCollectionView.register(BarChartCell.self, forCellWithReuseIdentifier: BarChartCell.reuseIdentifier)
        statsCollectionView.register(PieChartCell.self, forCellWithReuseIdentifier: PieChartCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            editAvatarButton.widthAnchor.constraint(equalToConstant: 30),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 500),
            
            achievementsCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            achievementsCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            achievementsCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            achievementsCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            statisticsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            statisticsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            statisticsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            statisticsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            statsCollectionView.topAnchor.constraint(equalTo: statisticsView.topAnchor),
            statsCollectionView.leadingAnchor.constraint(equalTo: statisticsView.leadingAnchor),
            statsCollectionView.trailingAnchor.constraint(equalTo: statisticsView.trailingAnchor),
            statsCollectionView.bottomAnchor.constraint(equalTo: statisticsView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$userName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameLabel.text = name
            }
            .store(in: &cancellables)
        
        viewModel.$avatarImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.avatarImageView.image = image
            }
            .store(in: &cancellables)
        
        viewModel.$achievements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.achievementsCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$stats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.statsCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        editAvatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        
        segmentedControl.addAction(
            UIAction { [weak self] _ in
                self?.segmentedControlChanged()
            },
            for: .valueChanged
        )
    }
    
    private func loadData() {
        Task {
            await viewModel.loadUserProfile()
        }
    }
    
    @objc private func refreshData() {
        Task {
            await viewModel.refreshStats()
        }
    }
    
    private func segmentedControlChanged() {
        let index = segmentedControl.selectedSegmentIndex
        
        achievementsCollectionView.isHidden = index != 0
        statisticsView.isHidden = index != 1
    }
    
    @objc private func avatarTapped() {
        let modal = ImagePickerModal()
        modal.delegate = self
        modal.show(in: self)
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
extension ProfileViewController: ImagePickerModalDelegate {
    func imagePickerModal(_ modal: ImagePickerModal, didSelectImage image: UIImage) {
        viewModel.avatarImage = image
        Task {
            await viewModel.saveUserProfile()
        }
    }
    
    func imagePickerModalDidCancel(_ modal: ImagePickerModal) {}
    
    func imagePickerModalDidRequestRemove(_ modal: ImagePickerModal) {
        viewModel.avatarImage = UIImage(systemName: "person.circle.fill")
        Task {
            await viewModel.saveUserProfile()
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == achievementsCollectionView {
            return viewModel.achievements.count
        } else {
            guard viewModel.stats != nil else { return 0 }
            return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == achievementsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AchievementCell.reuseIdentifier, for: indexPath) as! AchievementCell
            let achievement = viewModel.achievements[indexPath.item]
            cell.configure(with: achievement)
            return cell
        } else {
            guard let stats = viewModel.stats else {
                return UICollectionViewCell()
            }
            
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCardCell.reuseIdentifier, for: indexPath) as! StatCardCell
                cell.configure(icon: "books.vertical.fill", value: "\(stats.totalBooks)", title: "Всего книг")
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCardCell.reuseIdentifier, for: indexPath) as! StatCardCell
                cell.configure(icon: "book.pages.fill", value: "\(stats.totalPages)", title: "Прочитано страниц")
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCardCell.reuseIdentifier, for: indexPath) as! StatCardCell
                let avgPages = stats.averagePagesPerBook
                cell.configure(icon: "chart.bar.fill", value: "\(avgPages)", title: "Среднее стр/кн")
                return cell
            case 3:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCardCell.reuseIdentifier, for: indexPath) as! StatCardCell
                cell.configure(icon: "star.fill", value: String(format: "%.1f", stats.averageRating), title: "Средний рейтинг")
                return cell
            case 4:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BarChartCell.reuseIdentifier, for: indexPath) as! BarChartCell
                cell.configure(title: "Книги по месяцам", data: stats.booksPerMonth.map { ($0.month, $0.count) })
                return cell
            case 5:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PieChartCell.reuseIdentifier, for: indexPath) as! PieChartCell
                cell.configure(title: "Любимые жанры", data: stats.genresDistribution)
                return cell
            default:
                return UICollectionViewCell()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        
        if collectionView == achievementsCollectionView {
            return CGSize(width: (width - 12) / 2, height: 160)
        } else {
            switch indexPath.item {
            case 0...3:
                return CGSize(width: (width - 12) / 2, height: 100)
            case 4:
                return CGSize(width: width, height: 280)
            case 5:
                return CGSize(width: width, height: 320)
            default:
                return .zero
            }
        }
    }
}
