//
//  FavoritesStoreTests.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

import Foundation
@testable import Photo_Gallery
import Testing

@Suite("FavoritesStore")
@MainActor
struct FavoritesStoreTests {

    private let store: FavoritesStore

    init() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        store = FavoritesStore(defaults: defaults)
    }

    @Test("Photo is not favorite by default")
    func initiallyNotFavorite() {
        #expect(!store.isFavorite(id: "photo-1"))
    }

    @Test("Toggle adds photo to favorites")
    func toggleAdds() {
        store.toggleFavorite(id: "photo-1")
        #expect(store.isFavorite(id: "photo-1"))
    }

    @Test("Toggle twice removes photo from favorites")
    func toggleTwiceRemoves() {
        store.toggleFavorite(id: "photo-1")
        store.toggleFavorite(id: "photo-1")
        #expect(!store.isFavorite(id: "photo-1"))
    }

    @Test("Favorites persist across store instances")
    func persistence() {
        let suiteName = UUID().uuidString
        let sharedDefaults = UserDefaults(suiteName: suiteName)!

        let first = FavoritesStore(defaults: sharedDefaults)
        first.toggleFavorite(id: "photo-1")

        let second = FavoritesStore(defaults: sharedDefaults)
        #expect(second.isFavorite(id: "photo-1"))
    }
}
