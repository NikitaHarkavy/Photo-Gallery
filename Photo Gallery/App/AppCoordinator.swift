//
//  AppCoordinator.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

internal import CoreData
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
    private let coreDataStack: CoreDataStack
    private let favoritesStore: FavoritesStoreProtocol
    private let imageLoader: ImageLoaderProtocol

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.apiClient = APIClient()
        self.coreDataStack = CoreDataStack()
        self.favoritesStore = FavoritesStore(context: coreDataStack.container.viewContext)
        self.imageLoader = ImageLoader()
    }

    func start() {
        let viewModel = GalleryViewModel(
            apiClient: apiClient,
            favoritesStore: favoritesStore
        )

        let galleryVC = GalleryViewController(
            viewModel: viewModel,
            imageLoader: imageLoader
        )
        galleryVC.onPhotoSelected = { [weak self] photos, index in
            self?.showDetail(photos: photos, startingAt: index)
        }
        galleryVC.onFavoritesTapped = { [weak self] in
            self?.showFavorites()
        }

        navigationController.viewControllers = [galleryVC]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showFavorites() {
        let favoritesVM = FavoritesViewModel(favoritesStore: favoritesStore)
        let favoritesVC = FavoritesViewController(
            viewModel: favoritesVM,
            imageLoader: imageLoader
        )
        favoritesVC.onPhotoSelected = { [weak self] photos, index in
            self?.showDetail(photos: photos, startingAt: index)
        }
        navigationController.pushViewController(favoritesVC, animated: true)
    }

    private func showDetail(photos: [UnsplashPhoto], startingAt index: Int) {
        guard !photos.isEmpty else { return }

        let detailVM = DetailViewModel(
            photos: photos,
            initialIndex: index,
            favoritesStore: favoritesStore
        )
        let detailPageVC = DetailPageViewController(
            viewModel: detailVM,
            imageLoader: imageLoader
        )
        detailPageVC.hidesBottomBarWhenPushed = true

        navigationController.pushViewController(detailPageVC, animated: true)
        navigationController.setNavigationBarHidden(true, animated: true)
    }
}
