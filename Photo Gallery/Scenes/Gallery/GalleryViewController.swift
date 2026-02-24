//
//  GalleryViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class GalleryViewController: UIViewController {

    var onPhotoSelected: ((Int) -> Void)?

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
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
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

    // MARK: - Setup

    private func setupUI() {
        title = "Gallery"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true

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
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let columns = environment.container.contentSize.width > 500 ? 3 : 2
            let spacing: CGFloat = 2

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .fractionalWidth(1.0 / CGFloat(columns))
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
                heightDimension: .fractionalWidth(1.0 / CGFloat(columns))
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            return NSCollectionLayoutSection(group: group)
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

        if offsetY > contentHeight - frameHeight * 2 {
            Task {
                await viewModel.loadNextPage()
            }
        }
    }
}
