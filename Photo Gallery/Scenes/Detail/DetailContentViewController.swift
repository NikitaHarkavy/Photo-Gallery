//
//  DetailContentViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class DetailContentViewController: UIViewController {

    let index: Int

    private let item: DetailViewModel.DetailItem
    private let imageLoader: ImageLoaderProtocol
    private var imageLoadTask: Task<Void, Never>?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()

    private lazy var panelView: DetailPanelView = {
        let view = DetailPanelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        panelView.configure(title: item.title, authorName: item.authorName, description: item.description)
        loadImage()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(imageView)
        view.addSubview(panelView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelView.panelHeightConstraint
        ])
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
            await MainActor.run {
                self.imageView.image = image
            }
        }
    }
}
