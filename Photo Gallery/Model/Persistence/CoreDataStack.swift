//
//  CoreDataStack.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 01.03.26.
//

internal import CoreData

final class CoreDataStack {

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.createModel()
        container = NSPersistentContainer(name: "PhotoGallery", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "FavoritePhoto"
        entity.managedObjectClassName = NSStringFromClass(FavoritePhoto.self)

        let photoIDAttr = NSAttributeDescription()
        photoIDAttr.name = "photoID"
        photoIDAttr.attributeType = .stringAttributeType

        let slugAttr = NSAttributeDescription()
        slugAttr.name = "slug"
        slugAttr.attributeType = .stringAttributeType
        slugAttr.isOptional = true

        let photoDescriptionAttr = NSAttributeDescription()
        photoDescriptionAttr.name = "photoDescription"
        photoDescriptionAttr.attributeType = .stringAttributeType
        photoDescriptionAttr.isOptional = true

        let altDescriptionAttr = NSAttributeDescription()
        altDescriptionAttr.name = "altDescription"
        altDescriptionAttr.attributeType = .stringAttributeType
        altDescriptionAttr.isOptional = true

        let thumbURLAttr = NSAttributeDescription()
        thumbURLAttr.name = "thumbURL"
        thumbURLAttr.attributeType = .stringAttributeType
        thumbURLAttr.isOptional = true

        let regularURLAttr = NSAttributeDescription()
        regularURLAttr.name = "regularURL"
        regularURLAttr.attributeType = .stringAttributeType
        regularURLAttr.isOptional = true

        let authorNameAttr = NSAttributeDescription()
        authorNameAttr.name = "authorName"
        authorNameAttr.attributeType = .stringAttributeType
        authorNameAttr.isOptional = true

        let authorUsernameAttr = NSAttributeDescription()
        authorUsernameAttr.name = "authorUsername"
        authorUsernameAttr.attributeType = .stringAttributeType
        authorUsernameAttr.isOptional = true

        let addedAtAttr = NSAttributeDescription()
        addedAtAttr.name = "addedAt"
        addedAtAttr.attributeType = .dateAttributeType
        addedAtAttr.isOptional = true

        entity.properties = [
            photoIDAttr, slugAttr, photoDescriptionAttr, altDescriptionAttr,
            thumbURLAttr, regularURLAttr, authorNameAttr, authorUsernameAttr, addedAtAttr
        ]
        entity.uniquenessConstraints = [["photoID"]]

        model.entities = [entity]
        return model
    }
}
