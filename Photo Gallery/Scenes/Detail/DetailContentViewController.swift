//
//  DetailContentViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class DetailContentViewController: UIViewController {

    let index: Int

    var onFavoriteTapped: ((Int) -> Void)?

    private let item: DetailViewModel.DetailItem
    private let imageLoader: ImageLoaderProtocol
    private var imageLoadTask: Task<Void, Never>?

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        return button
    }()

    // MARK: - Init

    init(item: DetailViewModel.DetailItem, index: Int, imageLoader: ImageLoaderProtocol) {
        self.item = item
        self.index = index
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imageLoadTask?.cancel()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
        loadImage()
    }

    // MARK: - Public

    func updateFavoriteState(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        let color: UIColor = isFavorite ? .systemRed : .label
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = color
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(imageView)

        let textContainer = UIStackView()
        textContainer.axis = .vertical
        textContainer.spacing = 8
        textContainer.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textContainer.isLayoutMarginsRelativeArrangement = true

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, favoriteButton])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8

        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        textContainer.addArrangedSubview(titleRow)
        textContainer.addArrangedSubview(authorLabel)
        textContainer.addArrangedSubview(descriptionLabel)

        contentStack.addArrangedSubview(textContainer)

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75),

            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func configureContent() {
        titleLabel.text = item.title
        authorLabel.text = "by \(item.authorName)"
        descriptionLabel.text = item.description
        updateFavoriteState(isFavorite: item.isFavorite)
    }

    private func loadImage() {
        if let cached = imageLoader.cachedImage(for: item.regularURL) {
            imageView.image = cached
            return
        }

        imageLoadTask = Task { [weak self] in
            guard let self else { return }
            let image = await self.imageLoader.loadImage(from: self.item.regularURL)
            guard !Task.isCancelled else { return }
            self.imageView.image = image
        }
    }

    // MARK: - Actions

    @objc private func favoriteTapped() {
        onFavoriteTapped?(index)
    }
}
