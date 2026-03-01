//
//  DetailViewModel.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import Foundation

final class DetailViewModel {

    struct DetailItem {
        let id: String
        let title: String
        let description: String
        let regularURL: String
        let isFavorite: Bool
        let authorName: String
    }

    private let photos: [UnsplashPhoto]
    private let favoritesStore: FavoritesStoreProtocol

    private(set) var currentIndex: Int

    var numberOfPhotos: Int { photos.count }

    var onFavoriteToggled: (() -> Void)?

    init(
        photos: [UnsplashPhoto],
        initialIndex: Int,
        favoritesStore: FavoritesStoreProtocol
    ) {
        self.photos = photos
        self.currentIndex = initialIndex
        self.favoritesStore = favoritesStore
    }

    // MARK: - Public Methods

    func item(at index: Int) -> DetailItem {
        let photo = photos[index]
        return DetailItem(
            id: photo.id,
            title: photo.displayTitle,
            description: photo.displayDescription,
            regularURL: photo.urls.regular,
            isFavorite: favoritesStore.isFavorite(id: photo.id),
            authorName: photo.user.name
        )
    }

    func toggleFavorite(at index: Int) {
        let photo = photos[index]
        favoritesStore.toggleFavorite(photo: photo)
        onFavoriteToggled?()
    }

    func updateCurrentIndex(_ index: Int) {
        currentIndex = index
    }
}
