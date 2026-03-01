//
//  FavoritesViewModel.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 01.03.26.
//

import Combine
import Foundation

final class FavoritesViewModel {

    struct FavoritesItem {
        let id: String
        let thumbURL: String?
    }

    private(set) var items: [FavoritesItem] = []
    private(set) var photos: [UnsplashPhoto] = []

    var onItemsChanged: (() -> Void)?

    private let favoritesStore: FavoritesStoreProtocol
    private var cancellables = Set<AnyCancellable>()

    init(favoritesStore: FavoritesStoreProtocol) {
        self.favoritesStore = favoritesStore

        favoritesStore.favoritesChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reload()
            }
            .store(in: &cancellables)
    }

    func reload() {
        let favorites = favoritesStore.allFavorites()
        items = favorites.map { FavoritesItem(id: $0.photoID, thumbURL: $0.thumbURL) }
        photos = favorites.map { $0.toUnsplashPhoto() }
        onItemsChanged?()
    }
}
