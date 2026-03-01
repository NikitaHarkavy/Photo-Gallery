//
//  MockFavoritesStore.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

import Combine
@testable import Photo_Gallery

@MainActor
final class MockFavoritesStore: FavoritesStoreProtocol {

    var favoritesChanged: AnyPublisher<String, Never> {
        favoritesChangedSubject.eraseToAnyPublisher()
    }

    private let favoritesChangedSubject = PassthroughSubject<String, Never>()
    private var favorites: [String: UnsplashPhoto] = [:]
    private(set) var toggleCallCount = 0
    private(set) var lastToggledID: String?

    func isFavorite(id: String) -> Bool {
        favorites.keys.contains(id)
    }

    func toggleFavorite(photo: UnsplashPhoto) {
        toggleCallCount += 1
        lastToggledID = photo.id
        if favorites.keys.contains(photo.id) {
            favorites.removeValue(forKey: photo.id)
        } else {
            favorites[photo.id] = photo
        }
        favoritesChangedSubject.send(photo.id)
    }

    func allFavorites() -> [FavoriteItem] {
        favorites.values.map {
            FavoriteItem(
                photoID: $0.id,
                slug: $0.slug,
                photoDescription: $0.description,
                altDescription: $0.altDescription,
                thumbURL: $0.urls.thumb,
                regularURL: $0.urls.regular,
                authorName: $0.user.name,
                authorUsername: $0.user.username,
                addedAt: nil
            )
        }
    }
}
