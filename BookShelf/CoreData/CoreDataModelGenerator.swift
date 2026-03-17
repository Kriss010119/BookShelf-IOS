//
//  CoreDataModelGenerator.swift
//  BookShelf
//

import CoreData

class CoreDataModelGenerator {
    
    static func generateModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // MARK: - Book Entity
        let bookEntity = NSEntityDescription()
        bookEntity.name = "Book"
        bookEntity.managedObjectClassName = "Book"
        
        var bookProperties: [NSPropertyDescription] = []
        
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        bookProperties.append(idAttribute)
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false
        bookProperties.append(titleAttribute)
        
        let authorAttribute = NSAttributeDescription()
        authorAttribute.name = "author"
        authorAttribute.attributeType = .stringAttributeType
        authorAttribute.isOptional = false
        bookProperties.append(authorAttribute)
        
        let coverImageURLAttribute = NSAttributeDescription()
        coverImageURLAttribute.name = "coverImageURL"
        coverImageURLAttribute.attributeType = .stringAttributeType
        coverImageURLAttribute.isOptional = true
        bookProperties.append(coverImageURLAttribute)
        
        let pageCountAttribute = NSAttributeDescription()
        pageCountAttribute.name = "pageCount"
        pageCountAttribute.attributeType = .integer64AttributeType
        pageCountAttribute.isOptional = true
        bookProperties.append(pageCountAttribute)
        
        let ratingAttribute = NSAttributeDescription()
        ratingAttribute.name = "rating"
        ratingAttribute.attributeType = .doubleAttributeType
        ratingAttribute.isOptional = true
        bookProperties.append(ratingAttribute)
        
        let genreAttribute = NSAttributeDescription()
        genreAttribute.name = "genre"
        genreAttribute.attributeType = .stringAttributeType
        genreAttribute.isOptional = true
        bookProperties.append(genreAttribute)
        
        let ageLimitAttribute = NSAttributeDescription()
        ageLimitAttribute.name = "ageLimit"
        ageLimitAttribute.attributeType = .stringAttributeType
        ageLimitAttribute.isOptional = true
        bookProperties.append(ageLimitAttribute)
        
        let externalLinkAttribute = NSAttributeDescription()
        externalLinkAttribute.name = "externalLink"
        externalLinkAttribute.attributeType = .stringAttributeType
        externalLinkAttribute.isOptional = true
        bookProperties.append(externalLinkAttribute)
        
        let linkTitleAttribute = NSAttributeDescription()
        linkTitleAttribute.name = "linkTitle"
        linkTitleAttribute.attributeType = .stringAttributeType
        linkTitleAttribute.isOptional = true
        bookProperties.append(linkTitleAttribute)
        
        let publicationYearAttribute = NSAttributeDescription()
        publicationYearAttribute.name = "publicationYear"
        publicationYearAttribute.attributeType = .integer64AttributeType
        publicationYearAttribute.isOptional = true
        bookProperties.append(publicationYearAttribute)
        
        let startDateAttribute = NSAttributeDescription()
        startDateAttribute.name = "startDate"
        startDateAttribute.attributeType = .dateAttributeType
        startDateAttribute.isOptional = true
        bookProperties.append(startDateAttribute)
        
        let finishDateAttribute = NSAttributeDescription()
        finishDateAttribute.name = "finishDate"
        finishDateAttribute.attributeType = .dateAttributeType
        finishDateAttribute.isOptional = true
        bookProperties.append(finishDateAttribute)
        
        let annotationAttribute = NSAttributeDescription()
        annotationAttribute.name = "annotation"
        annotationAttribute.attributeType = .stringAttributeType
        annotationAttribute.isOptional = true
        bookProperties.append(annotationAttribute)
        
        let reviewAttribute = NSAttributeDescription()
        reviewAttribute.name = "review"
        reviewAttribute.attributeType = .stringAttributeType
        reviewAttribute.isOptional = true
        bookProperties.append(reviewAttribute)
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false
        bookProperties.append(createdAtAttribute)
        
        let updatedAtAttribute = NSAttributeDescription()
        updatedAtAttribute.name = "updatedAt"
        updatedAtAttribute.attributeType = .dateAttributeType
        updatedAtAttribute.isOptional = false
        bookProperties.append(updatedAtAttribute)
        
        let isSyncedAttribute = NSAttributeDescription()
        isSyncedAttribute.name = "isSynced"
        isSyncedAttribute.attributeType = .booleanAttributeType
        isSyncedAttribute.isOptional = true
        bookProperties.append(isSyncedAttribute)
        
        let syncVersionAttribute = NSAttributeDescription()
        syncVersionAttribute.name = "syncVersion"
        syncVersionAttribute.attributeType = .integer64AttributeType
        syncVersionAttribute.isOptional = true
        bookProperties.append(syncVersionAttribute)
        
        // MARK: - Shelf Entity
        let shelfEntity = NSEntityDescription()
        shelfEntity.name = "Shelf"
        shelfEntity.managedObjectClassName = "Shelf"
        
        var shelfProperties: [NSPropertyDescription] = []
        
        let shelfIdAttribute = NSAttributeDescription()
        shelfIdAttribute.name = "id"
        shelfIdAttribute.attributeType = .UUIDAttributeType
        shelfIdAttribute.isOptional = false
        shelfProperties.append(shelfIdAttribute)
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        shelfProperties.append(nameAttribute)
        
        let creationDateAttribute = NSAttributeDescription()
        creationDateAttribute.name = "creationDate"
        creationDateAttribute.attributeType = .dateAttributeType
        creationDateAttribute.isOptional = false
        shelfProperties.append(creationDateAttribute)
        
        // MARK: - UserProfile Entity
        let userProfileEntity = NSEntityDescription()
        userProfileEntity.name = "UserProfile"
        userProfileEntity.managedObjectClassName = "UserProfile"
        
        var userProfileProperties: [NSPropertyDescription] = []
        
        let userIdAttribute = NSAttributeDescription()
        userIdAttribute.name = "id"
        userIdAttribute.attributeType = .UUIDAttributeType
        userIdAttribute.isOptional = false
        userProfileProperties.append(userIdAttribute)
        
        let userNameAttribute = NSAttributeDescription()
        userNameAttribute.name = "name"
        userNameAttribute.attributeType = .stringAttributeType
        userNameAttribute.isOptional = false
        userProfileProperties.append(userNameAttribute)
        
        let avatarDataAttribute = NSAttributeDescription()
        avatarDataAttribute.name = "avatarData"
        avatarDataAttribute.attributeType = .binaryDataAttributeType
        avatarDataAttribute.isOptional = true
        userProfileProperties.append(avatarDataAttribute)
        
        let emailAttribute = NSAttributeDescription()
        emailAttribute.name = "email"
        emailAttribute.attributeType = .stringAttributeType
        emailAttribute.isOptional = true
        userProfileProperties.append(emailAttribute)
        
        // MARK: - Relationships
        let bookToShelfRelationship = NSRelationshipDescription()
        bookToShelfRelationship.name = "shelf"
        bookToShelfRelationship.destinationEntity = shelfEntity
        bookToShelfRelationship.minCount = 0
        bookToShelfRelationship.maxCount = 1
        bookToShelfRelationship.deleteRule = .nullifyDeleteRule
        bookToShelfRelationship.isOptional = true
        
        let shelfToBookRelationship = NSRelationshipDescription()
        shelfToBookRelationship.name = "books"
        shelfToBookRelationship.destinationEntity = bookEntity
        shelfToBookRelationship.minCount = 0
        shelfToBookRelationship.maxCount = 0
        shelfToBookRelationship.deleteRule = .cascadeDeleteRule
        shelfToBookRelationship.isOptional = true
        shelfToBookRelationship.isOrdered = false
        
        bookToShelfRelationship.inverseRelationship = shelfToBookRelationship
        shelfToBookRelationship.inverseRelationship = bookToShelfRelationship
        
        bookProperties.append(bookToShelfRelationship)
        shelfProperties.append(shelfToBookRelationship)
        
        bookEntity.properties = bookProperties
        shelfEntity.properties = shelfProperties
        userProfileEntity.properties = userProfileProperties
        
        model.entities = [bookEntity, shelfEntity, userProfileEntity]
        return model
    }
}
