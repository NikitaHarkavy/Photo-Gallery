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

        static let empty = DetailItem(
            id: "",
            title: "",
            description: "",
            regularURL: "",
            isFavorite: false,
            authorName: ""
        )
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
        guard (0..<photos.count).contains(index) else {
            return DetailItem.empty
        }
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
        guard (0..<photos.count).contains(index) else { return }
        let photo = photos[index]
        favoritesStore.toggleFavorite(photo: photo)
        onFavoriteToggled?()
    }

    func updateCurrentIndex(_ index: Int) {
        currentIndex = index
    }
}
