//
//  AppCoordinator.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

final class AppCoordinator {

    private let window: UIWindow
    private let navigationController: UINavigationController
    private let apiClient: APIClientProtocol
    private let favoritesStore: FavoritesStoreProtocol
    private let imageLoader: ImageLoaderProtocol

    private var galleryViewModel: GalleryViewModel?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.apiClient = APIClient()
        self.favoritesStore = FavoritesStore()
        self.imageLoader = ImageLoader.shared
    }

    func start() {
        let viewModel = GalleryViewModel(
            apiClient: apiClient,
            favoritesStore: favoritesStore
        )
        galleryViewModel = viewModel

        let galleryVC = GalleryViewController(
            viewModel: viewModel,
            imageLoader: imageLoader
        )
        galleryVC.onPhotoSelected = { [weak self] index in
            self?.showDetail(startingAt: index)
        }

        navigationController.viewControllers = [galleryVC]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showDetail(startingAt index: Int) {
        guard let photos = galleryViewModel?.photos, !photos.isEmpty else { return }

        let detailVM = DetailViewModel(
            photos: photos,
            initialIndex: index,
            favoritesStore: favoritesStore
        )
        let detailPageVC = DetailPageViewController(
            viewModel: detailVM,
            imageLoader: imageLoader
        )

        navigationController.pushViewController(detailPageVC, animated: true)
    }
}
