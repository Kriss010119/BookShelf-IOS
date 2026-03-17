import CoreData

@objc(Book)
public class Book: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var coverImageURL: String?
    @NSManaged public var pageCount: Int64
    @NSManaged public var rating: Double
    @NSManaged public var genre: String?
    @NSManaged public var ageLimit: String?
    @NSManaged public var externalLink: String?
    @NSManaged public var linkTitle: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var finishDate: Date?
    @NSManaged public var annotation: String?
    @NSManaged public var review: String?
    @NSManaged public var publicationYear: Int64
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncVersion: Int64
    @NSManaged public var shelf: Shelf?
}

// MARK: - Shelf Entity
@objc(Shelf)
public class Shelf: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shelf> {
        return NSFetchRequest<Shelf>(entityName: "Shelf")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var books: NSSet?
}

// MARK: - UserProfile Entity
@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var avatarData: Data?
    @NSManaged public var email: String?
}

// MARK: - Generated accessors for books
extension Shelf {
    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)
    
    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)
    
    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)
}
