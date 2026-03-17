//
//  ProfileViewModel.swift
//  BookShelf
//

import Foundation
import UIKit
import Combine

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isUnlocked: Bool
    let progress: Double?
}

struct ReadingStats {
    let totalBooks: Int
    let totalPages: Int
    let averageRating: Double
    let favoriteGenre: String
    let booksPerMonth: [(month: String, count: Int)]
    let booksPerYear: [(year: Int, count: Int)]
    let genresDistribution: [(genre: String, count: Int)]
    
    var totalBooksThisYear: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return booksPerYear.first { $0.year == currentYear }?.count ?? 0
    }
    
    var averagePagesPerBook: Int {
        guard totalBooks > 0 else { return 0 }
        return totalPages / totalBooks
    }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = "Читатель"
    @Published var avatarImage: UIImage? = UIImage(systemName: "person.circle.fill")
    @Published var achievements: [Achievement] = []
    @Published var stats: ReadingStats?
    @Published var isLoading = false

    // MARK: - Private Properties
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var previousStats: ReadingStats?
    
    // MARK: - Initialization
    init() {
        setupNotifications()
    }
    
    // MARK: - Notification Setup
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .bookDataChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("ProfileViewModel: Book data changed notification received")
                Task {
                    await self?.refreshStats()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadUserProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let profile = try await coreDataManager.getOrCreateUserProfile()
            userName = profile.name ?? "Читатель"
            
            if let avatarData = profile.avatarData {
                avatarImage = UIImage(data: avatarData)
            }
            await loadStats()
            await loadAchievements()
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
    
    func saveUserProfile() async {
        do {
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.8)
            try await coreDataManager.updateUserProfile(
                name: userName,
                avatarData: avatarData
            )
        } catch {
            print("Error saving user profile: \(error)")
        }
    }
    
    func refreshStats() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let allBooks = try await coreDataManager.fetchAllBooks()
            previousStats = stats
            let newStats = calculateStats(from: allBooks)
            await MainActor.run {
                self.stats = newStats
            }
            await checkForNewAchievements(oldStats: previousStats)
            await loadAchievements()
        } catch {
            print("Error loading stats: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func loadStats() async {
        do {
            let allBooks = try await coreDataManager.fetchAllBooks()
            stats = calculateStats(from: allBooks)
        } catch {
            print("Error loading stats: \(error)")
        }
    }
    
    private func calculateStats(from books: [Book]) -> ReadingStats {
        let totalBooks = books.count
        let totalPages = books.reduce(0) { $0 + Int($1.pageCount) }
        let averageRating = books.isEmpty ? 0 : books.reduce(0.0) { $0 + $1.rating } / Double(totalBooks)
        let genreCounts = Dictionary(grouping: books.compactMap { $0.genre }, by: { $0 }).mapValues { $0.count }
        let favoriteGenre = genreCounts.max(by: { $0.value < $1.value })?.key ?? "Не определен"
        let booksPerMonth = getBooksPerMonth(from: books)
        let booksPerYear = getBooksPerYear(from: books)
        let genresDistribution = getGenresDistribution(from: books)
        
        return ReadingStats(
            totalBooks: totalBooks,
            totalPages: totalPages,
            averageRating: averageRating,
            favoriteGenre: favoriteGenre,
            booksPerMonth: booksPerMonth,
            booksPerYear: booksPerYear,
            genresDistribution: genresDistribution
        )
    }
    
    private func getBooksPerYear(from books: [Book]) -> [(year: Int, count: Int)] {
        let calendar = Calendar.current
        return Dictionary(grouping: books.compactMap { $0.startDate }, by: { calendar.component(.year, from: $0) })
            .mapValues { $0.count }
            .filter { $0.key > 0 }
            .sorted { $0.key > $1.key }
            .prefix(5)
            .map { (year: $0.key, count: $0.value) }
    }
    
    private func getBooksPerMonth(from books: [Book]) -> [(month: String, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "MMM yyyy"
        var monthlyCounts: [(month: String, count: Int)] = []
        for i in (0..<6).reversed() {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let month = dateFormatter.string(from: date).capitalized
                let startOfMonth = calendar.startOfMonth(for: date)
                let endOfMonth = calendar.endOfMonth(for: date)
                
                let count = books.filter { book in
                    guard let startDate = book.startDate else { return false }
                    return startDate >= startOfMonth && startDate <= endOfMonth
                }.count
                
                monthlyCounts.append((month: month, count: count))
            }
        }
        return monthlyCounts
    }
    
    private func getGenresDistribution(from books: [Book]) -> [(genre: String, count: Int)] {
        return Dictionary(grouping: books.compactMap { $0.genre }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (genre: $0.key, count: $0.value) }
    }
    
    private func loadAchievements() async {
        guard let stats = stats else { return }
        var newAchievements: [Achievement] = []
    
        newAchievements.append(Achievement(
            title: "Первая книга",
            description: "Добавьте первую книгу в библиотеку",
            isUnlocked: stats.totalBooks >= 1,
            progress: stats.totalBooks >= 1 ? 1.0 : 0.0
        ))
        
        newAchievements.append(Achievement(
            title: "Начинающий читатель",
            description: "Прочитано 10 книг",
            isUnlocked: stats.totalBooks >= 10,
            progress: min(Double(stats.totalBooks) / 10.0, 1.0)
        ))
        
        newAchievements.append(Achievement(
            title: "Книжный червь",
            description: "Прочитано 50 книг",
            isUnlocked: stats.totalBooks >= 50,
            progress: min(Double(stats.totalBooks) / 50.0, 1.0)
        ))
        
        newAchievements.append(Achievement(
            title: "Эксперт",
            description: "Прочитано 100 книг",
            isUnlocked: stats.totalBooks >= 100,
            progress: min(Double(stats.totalBooks) / 100.0, 1.0)
        ))
        
        newAchievements.append(Achievement(
            title: "Тысяча страниц",
            description: "Прочитано 1000 страниц",
            isUnlocked: stats.totalPages >= 1000,
            progress: min(Double(stats.totalPages) / 1000.0, 1.0)
        ))
        
        newAchievements.append(Achievement(
            title: "Путешественник во времени",
            description: "Читайте книги из разных лет",
            isUnlocked: stats.booksPerYear.count >= 3,
            progress: min(Double(stats.booksPerYear.count) / 3.0, 1.0)
        ))
        
        achievements = newAchievements.sorted { !$0.isUnlocked && $1.isUnlocked }
    }
    
    // MARK: - Achievement Checking
    private func checkForNewAchievements(oldStats: ReadingStats?) async {
        guard let stats = stats, let oldStats = oldStats else { return }
        
        var newlyUnlockedAchievements: [Achievement] = []
        
        if oldStats.totalBooks < 1 && stats.totalBooks >= 1 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Первая книга",
                description: "Вы добавили свою первую книгу! Поздравляем!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if oldStats.totalBooks < 10 && stats.totalBooks >= 10 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Начинающий читатель",
                description: "Вы прочитали 10 книг! Отличный старт!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if oldStats.totalBooks < 50 && stats.totalBooks >= 50 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Книжный червь",
                description: "Вы прочитали 50 книг! Вы настоящий книголюб!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if oldStats.totalBooks < 100 && stats.totalBooks >= 100 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Эксперт",
                description: "Вы прочитали 100 книг! Фантастический результат!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if oldStats.totalPages < 1000 && stats.totalPages >= 1000 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Тысяча страниц",
                description: "Вы прочитали 1000 страниц!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if oldStats.totalPages < 5000 && stats.totalPages >= 5000 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Пятитысячник",
                description: "Вы прочитали 5000 страниц!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if oldStats.genresDistribution.count < 3 && stats.genresDistribution.count >= 3 {
            newlyUnlockedAchievements.append(Achievement(
                title: "Исследователь",
                description: "Вы попробовали 3 разных жанра!",
                isUnlocked: true,
                progress: 1.0
            ))
        }
        
        if !newlyUnlockedAchievements.isEmpty {
            await showAchievementNotifications(newlyUnlockedAchievements)
        }
    }
    
    @MainActor
    private func showAchievementNotifications(_ achievements: [Achievement]) {
        for achievement in achievements {
            AchievementNotificationManager.shared.showAchievement(achievement)
        }
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfMonth(for date: Date) -> Date {
        guard let startOfMonth = self.date(from: dateComponents([.year, .month], from: date)),
              let endOfMonth = self.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return date
        }
        return endOfMonth
    }
}
