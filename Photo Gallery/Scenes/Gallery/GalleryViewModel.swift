//
//  GalleryViewModel.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import Combine
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

    private enum Constants {
        static let photosPerPage = 30
    }

    private var currentPage = 1
    private let perPage = Constants.photosPerPage
    private var hasMorePages = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(apiClient: APIClientProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.apiClient = apiClient
        self.favoritesStore = favoritesStore

        favoritesStore.favoritesChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoID in
                self?.handleFavoriteChanged(photoID: photoID)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func loadPhotos() {
        loadTask?.cancel()
        loadTask = Task { await performLoadPhotos() }
    }

    func loadNextPage() {
        guard loadNextPageTask == nil else { return }
        loadNextPageTask = Task { await performLoadNextPage() }
    }

    // MARK: - Private Task Management

    private var loadTask: Task<Void, Never>?
    private var loadNextPageTask: Task<Void, Never>?

    private func performLoadPhotos() async {
        defer {
            if !Task.isCancelled {
                loadTask = nil
            }
        }
        switch state {
        case .idle, .error:
            photos = []
            currentPage = 1
            hasMorePages = false
            state = .loading
            await MainActor.run { onStateChanged?() }
            await fetchPhotos(page: 1)
        default:
            break
        }
    }

    private func performLoadNextPage() async {
        guard !isLoadingNextPage, hasMorePages, !photos.isEmpty else {
            loadNextPageTask = nil
            return
        }
        isLoadingNextPage = true
        await MainActor.run { onStateChanged?() }
        await fetchPhotos(page: currentPage)
        loadNextPageTask = nil
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
            await MainActor.run {
                photos.append(contentsOf: newPhotos)
                currentPage = page + 1
                hasMorePages = newPhotos.count == perPage
                isLoadingNextPage = false
                state = .loaded(items)
                onStateChanged?()
            }
        } catch {
            await MainActor.run {
                if photos.isEmpty {
                    state = .error(error.localizedDescription)
                }
                isLoadingNextPage = false
                onStateChanged?()
            }
        }
    }

    private func handleFavoriteChanged(photoID: String) {
        if let index = photos.firstIndex(where: { $0.id == photoID }) {
            state = .loaded(items)
            onItemUpdated?(index)
        }
    }
}
