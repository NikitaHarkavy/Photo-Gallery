//
//  GalleryViewModel.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import Foundation

final class GalleryViewModel {

    struct GalleryItem {
        let id: String
        let thumbURL: String
        let isFavorite: Bool
    }

    private(set) var state: ViewState<[GalleryItem]> = .idle
    private(set) var isLoadingNextPage = false

    var onStateChanged: (() -> Void)?

    var onItemUpdated: ((Int) -> Void)?

    private(set) var photos: [UnsplashPhoto] = []

    private let apiClient: APIClientProtocol
    private let favoritesStore: FavoritesStoreProtocol

    private var currentPage = 1
    private let perPage = 30
    private var hasMorePages = false

    private var favoriteObserver: NSObjectProtocol?

    // MARK: - Init

    init(apiClient: APIClientProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.apiClient = apiClient
        self.favoritesStore = favoritesStore

        favoriteObserver = NotificationCenter.default.addObserver(
            forName: FavoritesStore.favoriteChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleFavoriteChanged(notification)
        }
    }

    deinit {
        if let observer = favoriteObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Public Methods

    func loadPhotos() async {
        switch state {
        case .idle, .error:
            photos = []
            currentPage = 1
            hasMorePages = false
            state = .loading
            onStateChanged?()
            await fetchPhotos(page: 1)
        default:
            break
        }
    }

    func loadNextPage() async {
        guard !isLoadingNextPage, hasMorePages, !photos.isEmpty else { return }
        isLoadingNextPage = true
        onStateChanged?()
        await fetchPhotos(page: currentPage)
    }

    var items: [GalleryItem] {
        photos.map { photo in
            GalleryItem(
                id: photo.id,
                thumbURL: photo.urls.thumb,
                isFavorite: favoritesStore.isFavorite(id: photo.id)
            )
        }
    }

    // MARK: - Private

    private func fetchPhotos(page: Int) async {
        do {
            let newPhotos: [UnsplashPhoto] = try await apiClient.request(
                UnsplashEndpoint.listPhotos(page: page, perPage: perPage)
            )
            photos.append(contentsOf: newPhotos)
            currentPage = page + 1
            hasMorePages = newPhotos.count == perPage
            isLoadingNextPage = false
            state = .loaded(items)
            onStateChanged?()
        } catch {
            if photos.isEmpty {
                state = .error(error.localizedDescription)
            }
            isLoadingNextPage = false
            onStateChanged?()
        }
    }

    private func handleFavoriteChanged(_ notification: Notification) {
        guard let photoID = notification.userInfo?[FavoritesStore.changedPhotoIDKey] as? String else {
            return
        }
        if let index = photos.firstIndex(where: { $0.id == photoID }) {
            state = .loaded(items)
            onItemUpdated?(index)
        }
    }
}
