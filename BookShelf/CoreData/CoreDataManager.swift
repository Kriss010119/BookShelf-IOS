import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let stack = CoreDataStack.shared
    
    // MARK: - Book Operations
    func addBook(_ bookDTO: BookDTO, to shelf: Shelf) async throws {
        _ = try await createBookWithImmediateUpdate(
            title: bookDTO.title,
            author: bookDTO.author,
            genre: bookDTO.genre ?? "Unknown",
            shelf: shelf,
            rating: bookDTO.rating ?? 0,
            pageCount: Int64(bookDTO.pageCount ?? 0),
            publicationYear: Int64(bookDTO.publishedYear ?? 0),
            coverImageURL: bookDTO.coverImageURL,
            startDate: nil,
            annotation: bookDTO.description
        )
    }
    
    func createBook(
        title: String,
        author: String,
        genre: String = "Unknown",
        shelf: Shelf? = nil,
        rating: Double = 0,
        pageCount: Int64 = 0,
        publicationYear: Int64 = 0,
        coverImageURL: String? = nil,
        startDate: Date? = nil,
        annotation: String? = nil
    ) async throws -> Book {
        let context = stack.backgroundContext
        
        return try await context.perform {
            let book = Book(context: context)
            book.id = UUID()
            book.title = title
            book.author = author
            book.genre = genre
            book.createdAt = Date()
            book.updatedAt = Date()
            book.isSynced = false
            book.syncVersion = 1
            book.rating = rating
            book.pageCount = pageCount
            book.publicationYear = publicationYear
            book.coverImageURL = coverImageURL
            book.startDate = startDate
            book.annotation = annotation
            
            if let shelf = shelf {
                if let shelfId = shelf.id {
                    let fetchRequest: NSFetchRequest<Shelf> = Shelf.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", shelfId as CVarArg)
                    fetchRequest.fetchLimit = 1
                    
                    if let shelfInContext = try context.fetch(fetchRequest).first {
                        book.shelf = shelfInContext
                    }
                }
            }
            
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
            return book
        }
    }
    
    func fetchBooks(in shelf: Shelf? = nil) async throws -> [Book] {
        let context = stack.viewContext
        
        return try await context.perform {
            let request = Book.fetchRequest()
            if let shelf = shelf {
                let shelfInContext = try context.existingObject(with: shelf.objectID) as? Shelf
                request.predicate = NSPredicate(format: "shelf == %@", shelfInContext!)
            }
            request.sortDescriptors = [
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
            return try context.fetch(request)
        }
    }
    
    func updateBook(
        _ book: Book,
        title: String? = nil,
        author: String? = nil,
        genre: String? = nil,
        shelf: Shelf? = nil,
        rating: Double? = nil,
        pageCount: Int64? = nil,
        publicationYear: Int64? = nil,
        coverImageURL: String? = nil,
        startDate: Date? = nil,
        annotation: String? = nil
    ) async throws {
        let context = stack.backgroundContext
        
        try await context.perform {
            let bookInContext = try context.existingObject(with: book.objectID) as? Book
            
            if let title = title { bookInContext?.title = title }
            if let author = author { bookInContext?.author = author }
            if let genre = genre { bookInContext?.genre = genre }
            if let rating = rating { bookInContext?.rating = rating }
            if let pageCount = pageCount { bookInContext?.pageCount = pageCount }
            if let publicationYear = publicationYear { bookInContext?.publicationYear = publicationYear }
            if let coverImageURL = coverImageURL { bookInContext?.coverImageURL = coverImageURL }
            if let startDate = startDate { bookInContext?.startDate = startDate }
            if let annotation = annotation { bookInContext?.annotation = annotation }
            
            bookInContext?.updatedAt = Date()
            
            if let shelf = shelf {
                if let shelfId = shelf.id {
                    let fetchRequest: NSFetchRequest<Shelf> = Shelf.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", shelfId as CVarArg)
                    fetchRequest.fetchLimit = 1
                    if let shelfInContext = try context.fetch(fetchRequest).first {
                        bookInContext?.shelf = shelfInContext
                    }
                }
            } else if shelf == nil {
                bookInContext?.shelf = nil
            }
            
            try context.save()
            
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
        }
    }
    
    func createBookWithImmediateUpdate(
        title: String,
        author: String,
        genre: String = "Unknown",
        shelf: Shelf? = nil,
        rating: Double = 0,
        pageCount: Int64 = 0,
        publicationYear: Int64 = 0,
        coverImageURL: String? = nil,
        startDate: Date? = nil,
        annotation: String? = nil
    ) async throws -> (book: Book, shelf: Shelf?) {
        let context = stack.backgroundContext
        
        return try await context.perform {
            let book = Book(context: context)
            book.id = UUID()
            book.title = title
            book.author = author
            book.genre = genre
            book.createdAt = Date()
            book.updatedAt = Date()
            book.isSynced = false
            book.syncVersion = 1
            book.rating = rating
            book.pageCount = pageCount
            book.publicationYear = publicationYear
            book.coverImageURL = coverImageURL
            book.startDate = startDate
            book.annotation = annotation
            
            var savedShelf: Shelf? = nil
            
            if let shelf = shelf {
                if let shelfId = shelf.id {
                    let fetchRequest: NSFetchRequest<Shelf> = Shelf.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", shelfId as CVarArg)
                    fetchRequest.fetchLimit = 1
                    
                    if let shelfInContext = try context.fetch(fetchRequest).first {
                        book.shelf = shelfInContext
                        savedShelf = shelfInContext
                    }
                }
            }
            
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
            return (book, savedShelf)
        }
    }
    
    func deleteBook(_ book: Book) async throws {
        let context = stack.backgroundContext
        try await context.perform {
            let object = try context.existingObject(with: book.objectID)
            context.delete(object)
            try context.save()
        }
    }
    
    // MARK: - Shelf Operations
    func createShelf(name: String) async throws -> Shelf {
        let context = stack.backgroundContext
        
        return try await context.perform {
            let shelf = Shelf(context: context)
            shelf.id = UUID()
            shelf.name = name
            shelf.creationDate = Date()
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
            return shelf
        }
    }
    
    func fetchShelves() async throws -> [Shelf] {
        let context = stack.viewContext
        return try await context.perform {
            let request = Shelf.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            return try context.fetch(request)
        }
    }
    
    func deleteShelf(_ shelf: Shelf) async throws {
        let context = stack.backgroundContext
        try await context.perform {
            let object = try context.existingObject(with: shelf.objectID)
            context.delete(object)
            try context.save()
        }
    }
    
    // MARK: - User Profile Operations
    func getOrCreateUserProfile() async throws -> UserProfile {
        let context = stack.viewContext
        return try await context.perform {
            let request = UserProfile.fetchRequest()
            request.fetchLimit = 1
            if let existingProfile = try context.fetch(request).first {
                return existingProfile
            } else {
                let profile = UserProfile(context: context)
                profile.id = UUID()
                profile.name = "Читатель"
                profile.email = nil
                profile.avatarData = nil
                try context.save()
                return profile
            }
        }
    }
    
    func updateUserProfile(name: String?, avatarData: Data?) async throws {
        let context = stack.backgroundContext
        
        try await context.perform {
            let request = UserProfile.fetchRequest()
            request.fetchLimit = 1
            let profiles = try context.fetch(request)
            guard let profile = profiles.first else {
                throw NSError(domain: "CoreDataManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
            }
            if let name = name { profile.name = name }
            if let avatarData = avatarData { profile.avatarData = avatarData }
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func fetchAllBooks() async throws -> [Book] {
        let context = stack.viewContext
        return try await context.perform {
            let request = Book.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "title", ascending: true)
            ]
            return try context.fetch(request)
        }
    }
    
    func countAllBooks() async throws -> Int {
        let context = stack.viewContext
        return try await context.perform {
            let request = Book.fetchRequest()
            return try context.count(for: request)
        }
    }
    
    func countBooks(in shelf: Shelf) async throws -> Int {
        let context = stack.viewContext
        return try await context.perform {
            let request = Book.fetchRequest()
            let shelfInContext = try context.existingObject(with: shelf.objectID) as? Shelf
            request.predicate = NSPredicate(format: "shelf == %@", shelfInContext!)
            return try context.count(for: request)
        }
    }
    
    // MARK: - Обновление полки
    func updateShelf(_ shelf: Shelf, newName: String) async throws {
        let context = stack.backgroundContext
        try await context.perform {
            let shelfInContext = try context.existingObject(with: shelf.objectID) as? Shelf
            shelfInContext?.name = newName
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
        }
    }
}

// MARK: - CoreDataManager Extension
extension CoreDataManager {
    func updateBook(
        _ book: Book,
        title: String? = nil,
        author: String? = nil,
        genre: String? = nil,
        shelf: Shelf? = nil,
        rating: Double? = nil,
        pageCount: Int64? = nil,
        publicationYear: Int64? = nil,
        coverImageURL: String? = nil,
        startDate: Date? = nil,
        annotation: String? = nil,
        ageLimit: String? = nil,
        externalLink: String? = nil,
        linkTitle: String? = nil,
        finishDate: Date? = nil,
        review: String? = nil
    ) async throws {
        let context = stack.backgroundContext
        try await context.perform {
            let bookInContext = try context.existingObject(with: book.objectID) as? Book
            if let title = title { bookInContext?.title = title }
            if let author = author { bookInContext?.author = author }
            if let genre = genre { bookInContext?.genre = genre }
            if let ageLimit = ageLimit { bookInContext?.ageLimit = ageLimit }
            if let rating = rating { bookInContext?.rating = rating }
            if let pageCount = pageCount { bookInContext?.pageCount = pageCount }
            if let publicationYear = publicationYear { bookInContext?.publicationYear = publicationYear }
            if let coverImageURL = coverImageURL { bookInContext?.coverImageURL = coverImageURL }
            if let startDate = startDate { bookInContext?.startDate = startDate }
            if let finishDate = finishDate { bookInContext?.finishDate = finishDate }
            if let annotation = annotation { bookInContext?.annotation = annotation }
            if let review = review { bookInContext?.review = review }
            if let externalLink = externalLink { bookInContext?.externalLink = externalLink }
            if let linkTitle = linkTitle { bookInContext?.linkTitle = linkTitle }
            
            bookInContext?.updatedAt = Date()
            bookInContext?.isSynced = false
            bookInContext?.syncVersion += 1
            
            if let shelf = shelf {
                if let shelfId = shelf.id {
                    let fetchRequest: NSFetchRequest<Shelf> = Shelf.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", shelfId as CVarArg)
                    fetchRequest.fetchLimit = 1
                    if let shelfInContext = try context.fetch(fetchRequest).first {
                        bookInContext?.shelf = shelfInContext
                    }
                }
            } else {
                bookInContext?.shelf = nil
            }
            
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
        }
    }
    
    func createBookWithImmediateUpdate(
        title: String,
        author: String,
        genre: String = "Unknown",
        shelf: Shelf? = nil,
        rating: Double = 0,
        pageCount: Int64 = 0,
        publicationYear: Int64 = 0,
        coverImageURL: String? = nil,
        startDate: Date? = nil,
        annotation: String? = nil,
        ageLimit: String? = nil,
        externalLink: String? = nil,
        linkTitle: String? = nil,
        finishDate: Date? = nil,
        review: String? = nil
    ) async throws -> (book: Book, shelf: Shelf?) {
        let context = stack.backgroundContext
        
        return try await context.perform {
            let book = Book(context: context)
            book.id = UUID()
            book.title = title
            book.author = author
            book.genre = genre
            book.ageLimit = ageLimit
            book.externalLink = externalLink
            book.linkTitle = linkTitle
            book.createdAt = Date()
            book.updatedAt = Date()
            book.isSynced = false
            book.syncVersion = 1
            book.rating = rating
            book.pageCount = pageCount
            book.publicationYear = publicationYear
            book.coverImageURL = coverImageURL
            book.startDate = startDate
            book.finishDate = finishDate
            book.annotation = annotation
            book.review = review
            
            var savedShelf: Shelf? = nil
            if let shelf = shelf {
                if let shelfId = shelf.id {
                    let fetchRequest: NSFetchRequest<Shelf> = Shelf.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", shelfId as CVarArg)
                    fetchRequest.fetchLimit = 1
                    if let shelfInContext = try context.fetch(fetchRequest).first {
                        book.shelf = shelfInContext
                        savedShelf = shelfInContext
                    }
                }
            }
            
            try context.save()
            if let parentContext = context.parent {
                try parentContext.performAndWait {
                    try parentContext.save()
                }
            }
            return (book, savedShelf)
        }
    }
}
