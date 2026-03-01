//
//  FavoritesViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 01.03.26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private enum Layout {
        static let emptyLabelFontSize: CGFloat = 18
        static let targetCellWidth: CGFloat = 190
        static let minimumColumns = 2
        static let gridSpacing: CGFloat = 2
    }

    var onPhotoSelected: ((Int) -> Void)?

    private let viewModel: FavoritesViewModel
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

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Favorites.empty
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: Layout.emptyLabelFontSize, weight: .medium)
        label.isHidden = true
        return label
    }()

    // MARK: - Init

    init(viewModel: FavoritesViewModel, imageLoader: ImageLoaderProtocol) {
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
        viewModel.reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupUI() {
        title = L10n.Favorites.title
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        viewModel.onItemsChanged = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.emptyLabel.isHidden = !self.viewModel.items.isEmpty
            self.collectionView.isHidden = self.viewModel.items.isEmpty
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesViewController: UICollectionViewDataSource {

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
        let galleryItem = GalleryViewModel.GalleryItem(
            id: item.id,
            thumbURL: item.thumbURL ?? "",
            isFavorite: true
        )
        cell.configure(with: galleryItem, imageLoader: imageLoader)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        onPhotoSelected?(indexPath.item)
    }
}
