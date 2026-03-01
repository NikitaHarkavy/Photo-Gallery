//
//  FavoritesStoreTests.swift
//  Photo GalleryTests
//
//  Created by Никита Горьковой on 24.02.26.
//

import CoreData
@testable import Photo_Gallery
import Testing

@Suite("FavoritesStore")
@MainActor
struct FavoritesStoreTests {

    private let store: FavoritesStore

    init() {
        let stack = CoreDataStack(inMemory: true)
        store = FavoritesStore(context: stack.container.viewContext)
    }

    @Test("Photo is not favorite by default")
    func initiallyNotFavorite() {
        #expect(!store.isFavorite(id: "photo-1"))
    }

    @Test("Toggle adds photo to favorites")
    func toggleAdds() {
        store.toggleFavorite(photo: TestData.makePhoto(id: "photo-1"))
        #expect(store.isFavorite(id: "photo-1"))
    }

    @Test("Toggle twice removes photo from favorites")
    func toggleTwiceRemoves() {
        let photo = TestData.makePhoto(id: "photo-1")
        store.toggleFavorite(photo: photo)
        store.toggleFavorite(photo: photo)
        #expect(!store.isFavorite(id: "photo-1"))
    }

    @Test("Favorites persist across store instances sharing same context")
    func persistence() {
        let stack = CoreDataStack(inMemory: true)

        let first = FavoritesStore(context: stack.container.viewContext)
        first.toggleFavorite(photo: TestData.makePhoto(id: "photo-1"))

        let second = FavoritesStore(context: stack.container.viewContext)
        #expect(second.isFavorite(id: "photo-1"))
    }
}
