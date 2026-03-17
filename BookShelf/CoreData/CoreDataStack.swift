import CoreData
import UIKit

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let model = CoreDataModelGenerator.generateModel()
        let container = NSPersistentContainer(name: "BookShelfModel", managedObjectModel: model)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                if let url = storeDescription.url {
                    do {
                        try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: storeDescription.type, options: nil)
                        container.loadPersistentStores { (storeDescription, error) in
                            if let error = error {
                                fatalError("Unresolved error \(error)")
                            }
                        }
                    } catch {
                        fatalError("Unresolved error \(error)")
                    }
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
            }
        }
    }
    
    func saveBackgroundContext(_ context: NSManagedObjectContext) async throws {
        try await context.perform {
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
