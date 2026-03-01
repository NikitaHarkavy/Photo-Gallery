//
//  GalleryViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class GalleryViewController: UIViewController {

    private enum Layout {
        static let errorLabelFontSize: CGFloat = 16
        static let retryButtonFontSize: CGFloat = 17
        static let errorLabelCenterYOffset: CGFloat = -20
        static let errorLabelHorizontalInset: CGFloat = 32
        static let retryButtonTopSpacing: CGFloat = 16
        static let targetCellWidth: CGFloat = 190
        static let minimumColumns = 2
        static let gridSpacing: CGFloat = 2
        static let paginationThresholdMultiplier: CGFloat = 2
    }

    var onPhotoSelected: ((Int) -> Void)?
    var onFavoritesTapped: (() -> Void)?

    private let viewModel: GalleryViewModel
    private let imageLoader: ImageLoaderProtocol

    // MARK: - UI Elements

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: Layout.errorLabelFontSize)
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(L10n.Action.retry, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Layout.retryButtonFontSize, weight: .semibold)
        button.isHidden = true
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(viewModel: GalleryViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()

        Task {
            await viewModel.loadPhotos()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupUI() {
        title = L10n.Gallery.title
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart.fill"),
            style: .plain,
            target: self,
            action: #selector(favoritesTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed

        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Layout.errorLabelCenterYOffset),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.errorLabelHorizontalInset),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.errorLabelHorizontalInset),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: Layout.retryButtonTopSpacing),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let width = environment.container.contentSize.width
            let columns = max(Layout.minimumColumns, Int(width / Layout.targetCellWidth))
            let spacing = Layout.gridSpacing
            let fraction = 1.0 / CGFloat(columns)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fraction),
                heightDimension: .fractionalWidth(fraction)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: spacing / 2,
                leading: spacing / 2,
                bottom: spacing / 2,
                trailing: spacing / 2
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(fraction)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsetsReference = .none
            return section
        }
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            self?.updateUI()
        }
        viewModel.onItemUpdated = { [weak self] index in
            self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    private func updateUI() {
        switch viewModel.state {
        case .idle:
            break

        case .loading:
            activityIndicator.startAnimating()
            collectionView.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true

        case .loaded:
            activityIndicator.stopAnimating()
            collectionView.isHidden = false
            errorLabel.isHidden = true
            retryButton.isHidden = true
            collectionView.reloadData()

        case .error(let message):
            activityIndicator.stopAnimating()
            collectionView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = message
            retryButton.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func retryTapped() {
        Task {
            await viewModel.loadPhotos()
        }
    }

    @objc private func favoritesTapped() {
        onFavoritesTapped?()
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryCell.reuseIdentifier,
            for: indexPath
        ) as? GalleryCell else {
            return UICollectionViewCell()
        }

        let item = viewModel.items[indexPath.item]
        cell.configure(with: item, imageLoader: imageLoader)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        onPhotoSelected?(indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        guard contentHeight > 0 else { return }

        if offsetY > contentHeight - frameHeight * Layout.paginationThresholdMultiplier {
            Task {
                await viewModel.loadNextPage()
            }
        }
    }
}
