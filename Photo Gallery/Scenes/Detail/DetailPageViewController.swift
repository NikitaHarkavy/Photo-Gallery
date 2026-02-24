//
//  DetailPageViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class DetailPageViewController: UIPageViewController {

    private let viewModel: DetailViewModel
    private let imageLoader: ImageLoaderProtocol

    init(viewModel: DetailViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        view.backgroundColor = .systemBackground

        let initialVC = makeDetailContentVC(at: viewModel.currentIndex)
        setViewControllers([initialVC], direction: .forward, animated: false)

        updateTitle(for: viewModel.currentIndex)
    }

    private func makeDetailContentVC(at index: Int) -> DetailContentViewController {
        let item = viewModel.item(at: index)
        let contentVC = DetailContentViewController(
            item: item,
            index: index,
            imageLoader: imageLoader
        )
        contentVC.onFavoriteTapped = { [weak self] tappedIndex in
            self?.viewModel.toggleFavorite(at: tappedIndex)

            if let currentVC = self?.viewControllers?.first as? DetailContentViewController {
                let updatedItem = self?.viewModel.item(at: tappedIndex)
                if let updatedItem {
                    currentVC.updateFavoriteState(isFavorite: updatedItem.isFavorite)
                }
            }
        }
        return contentVC
    }

    private func updateTitle(for index: Int) {
        title = "\(index + 1) / \(viewModel.numberOfPhotos)"
    }
}

extension DetailPageViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let detailVC = viewController as? DetailContentViewController else { return nil }
        let previousIndex = detailVC.index - 1
        guard previousIndex >= 0 else { return nil }
        return makeDetailContentVC(at: previousIndex)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let detailVC = viewController as? DetailContentViewController else { return nil }
        let nextIndex = detailVC.index + 1
        guard nextIndex < viewModel.numberOfPhotos else { return nil }
        return makeDetailContentVC(at: nextIndex)
    }
}

extension DetailPageViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = viewControllers?.first as? DetailContentViewController else {
            return
        }
        viewModel.updateCurrentIndex(currentVC.index)
        updateTitle(for: currentVC.index)
    }
}
