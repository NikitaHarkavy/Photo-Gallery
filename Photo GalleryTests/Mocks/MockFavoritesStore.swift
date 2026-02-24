//
//  MockFavoritesStore.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

@testable import Photo_Gallery

@MainActor
final class MockFavoritesStore: FavoritesStoreProtocol {

    private var favorites: Set<String> = []
    private(set) var toggleCallCount = 0
    private(set) var lastToggledID: String?

    func isFavorite(id: String) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(id: String) {
        toggleCallCount += 1
        lastToggledID = id
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
    }
}
