//
//  DetailPageViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class DetailPageViewController: UIPageViewController {

    private enum Layout {
        static let backButtonCornerRadius: CGFloat = 22
        static let backButtonTopInset: CGFloat = 8
        static let backButtonLeadingInset: CGFloat = 16
        static let backButtonSize: CGFloat = 44
        static let backIconPointSize: CGFloat = 18
        static let favoriteTopInset: CGFloat = 16
        static let favoriteTrailingInset: CGFloat = 20
        static let favoriteIconPointSize: CGFloat = 24
    }

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

    private let favoriteIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = true
        return icon
    }()

    private let backContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = Layout.backButtonCornerRadius
        container.clipsToBounds = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blur)

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Layout.backIconPointSize, weight: .semibold))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: container.topAnchor),
            blur.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        view.backgroundColor = .black

        let initialVC = makeDetailContentVC(at: viewModel.currentIndex)
        setViewControllers([initialVC], direction: .forward, animated: false)

        setupBackButton()
        setupFavoriteButton()
        updateFavoriteIcon()
    }

    private func setupBackButton() {
        view.addSubview(backContainer)

        let tap = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        backContainer.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            backContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.backButtonTopInset),
            backContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.backButtonLeadingInset),
            backContainer.widthAnchor.constraint(equalToConstant: Layout.backButtonSize),
            backContainer.heightAnchor.constraint(equalToConstant: Layout.backButtonSize)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupFavoriteButton() {
        view.addSubview(favoriteIcon)

        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteTapped))
        favoriteIcon.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            favoriteIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.favoriteTopInset),
            favoriteIcon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.favoriteTrailingInset)
        ])
    }

    private func updateFavoriteIcon() {
        let item = viewModel.item(at: viewModel.currentIndex)
        let config = UIImage.SymbolConfiguration(pointSize: Layout.favoriteIconPointSize, weight: .medium)
        let imageName = item.isFavorite ? "heart.fill" : "heart"
        favoriteIcon.image = UIImage(systemName: imageName, withConfiguration: config)
        favoriteIcon.tintColor = item.isFavorite ? .systemRed : .white
    }

    @objc private func favoriteTapped() {
        viewModel.toggleFavorite(at: viewModel.currentIndex)
        updateFavoriteIcon()
    }

    private func makeDetailContentVC(at index: Int) -> DetailContentViewController {
        let item = viewModel.item(at: index)
        return DetailContentViewController(
            item: item,
            index: index,
            imageLoader: imageLoader
        )
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
        updateFavoriteIcon()
    }
}
