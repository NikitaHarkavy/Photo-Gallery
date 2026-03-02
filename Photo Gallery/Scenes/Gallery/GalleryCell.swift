//
//  GalleryCell.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class GalleryCell: UICollectionViewCell {

    static let reuseIdentifier = "GalleryCell"

    private enum Layout {
        static let favoriteIconInset: CGFloat = 8
        static let favoriteIconWidth: CGFloat = 28
        static let favoriteIconHeight: CGFloat = 25
        static let shadowOpacity: Float = 0.6
        static let shadowOffsetHeight: CGFloat = 1
        static let shadowRadius: CGFloat = 2
    }

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
        imageView.layer.shadowOpacity = Layout.shadowOpacity
        imageView.layer.shadowOffset = CGSize(width: 0, height: Layout.shadowOffsetHeight)
        imageView.layer.shadowRadius = Layout.shadowRadius
        return imageView
    }()

    // MARK: - State

    private var displayedItemId: String?

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
        imageView.image = nil
        favoriteIcon.isHidden = true
        displayedItemId = nil
    }

    // MARK: - Configuration

    func configure(image: UIImage?, isFavorite: Bool, itemId: String) {
        displayedItemId = itemId
        imageView.image = image
        favoriteIcon.isHidden = !isFavorite
    }

    func updateImageIfMatching(_ image: UIImage?, itemId: String) {
        guard displayedItemId == itemId else { return }
        imageView.image = image
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

            favoriteIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.favoriteIconInset),
            favoriteIcon.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.favoriteIconInset
            ),
            favoriteIcon.widthAnchor.constraint(equalToConstant: Layout.favoriteIconWidth),
            favoriteIcon.heightAnchor.constraint(equalToConstant: Layout.favoriteIconHeight)
        ])
    }
}
