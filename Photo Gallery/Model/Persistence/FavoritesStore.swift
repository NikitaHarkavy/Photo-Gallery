//
//  FavoritesStore.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 23.02.26.
//

import Combine
internal import CoreData

struct FavoriteItem {
    let photoID: String
    let slug: String?
    let photoDescription: String?
    let altDescription: String?
    let thumbURL: String?
    let regularURL: String?
    let authorName: String?
    let authorUsername: String?
    let addedAt: Date?

    func toUnsplashPhoto() -> UnsplashPhoto {
        UnsplashPhoto(
            id: photoID,
            slug: slug,
            description: photoDescription,
            altDescription: altDescription,
            urls: PhotoURLs(raw: "", full: "", regular: regularURL ?? "", small: "", thumb: thumbURL ?? ""),
            user: PhotoUser(name: authorName ?? "", username: authorUsername ?? "")
        )
    }
}

protocol FavoritesStoreProtocol: AnyObject {
    var favoritesChanged: AnyPublisher<String, Never> { get }
    func isFavorite(id: String) -> Bool
    func toggleFavorite(photo: UnsplashPhoto)
    func allFavorites() -> [FavoriteItem]
}

final class FavoritesStore: FavoritesStoreProtocol {

    var favoritesChanged: AnyPublisher<String, Never> {
        favoritesChangedSubject.eraseToAnyPublisher()
    }

    private let favoritesChangedSubject = PassthroughSubject<String, Never>()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.context = context
    }

    func isFavorite(id: String) -> Bool {
        let request = NSFetchRequest<FavoritePhoto>(entityName: "FavoritePhoto")
        request.predicate = NSPredicate(format: "photoID == %@", id)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }

    func toggleFavorite(photo: UnsplashPhoto) {
        if let existing = fetchFavorite(id: photo.id) {
            context.delete(existing)
        } else {
            let entity = FavoritePhoto(context: context)
            entity.photoID = photo.id
            entity.slug = photo.slug
            entity.photoDescription = photo.description
            entity.altDescription = photo.altDescription
            entity.thumbURL = photo.urls.thumb
            entity.regularURL = photo.urls.regular
            entity.authorName = photo.user.name
            entity.authorUsername = photo.user.username
            entity.addedAt = Date()
        }

        try? context.save()

        favoritesChangedSubject.send(photo.id)
    }

    func allFavorites() -> [FavoriteItem] {
        let request = NSFetchRequest<FavoritePhoto>(entityName: "FavoritePhoto")
        request.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        let results = (try? context.fetch(request)) ?? []
        return results.map {
            FavoriteItem(
                photoID: $0.photoID,
                slug: $0.slug,
                photoDescription: $0.photoDescription,
                altDescription: $0.altDescription,
                thumbURL: $0.thumbURL,
                regularURL: $0.regularURL,
                authorName: $0.authorName,
                authorUsername: $0.authorUsername,
                addedAt: $0.addedAt
            )
        }
    }

    private func fetchFavorite(id: String) -> FavoritePhoto? {
        let request = NSFetchRequest<FavoritePhoto>(entityName: "FavoritePhoto")
        request.predicate = NSPredicate(format: "photoID == %@", id)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
