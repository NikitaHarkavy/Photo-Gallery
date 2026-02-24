//
//  GalleryCell.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class GalleryCell: UICollectionViewCell {

    static let reuseIdentifier = "GalleryCell"

    // MARK: - UI Elements

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    private let favoriteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        imageView.isHidden = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.6
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shadowRadius = 2
        return imageView
    }()

    // MARK: - State

    private var imageLoadTask: Task<Void, Never>?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = nil
        favoriteIcon.isHidden = true
    }

    // MARK: - Configuration

    func configure(with item: GalleryViewModel.GalleryItem, imageLoader: ImageLoaderProtocol) {
        favoriteIcon.isHidden = !item.isFavorite

        imageLoadTask?.cancel()

        if let cached = imageLoader.cachedImage(for: item.thumbURL) {
            imageView.image = cached
        } else {
            imageLoadTask = Task { [weak self] in
                let image = await imageLoader.loadImage(from: item.thumbURL)
                guard !Task.isCancelled else { return }
                self?.imageView.image = image
            }
        }
    }

    // MARK: - Layout

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteIcon)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            favoriteIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            favoriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
