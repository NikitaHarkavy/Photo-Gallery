//
//  DetailContentViewController.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class DetailContentViewController: UIViewController {

    private enum Layout {
        static let contentHorizontalInset: CGFloat = 20
        static let contentBottomInset: CGFloat = 20
        static let panelCornerRadius: CGFloat = 20
        static let grabberTopInset: CGFloat = 10
        static let grabberWidth: CGFloat = 40
        static let grabberHeight: CGFloat = 5
        static let grabberBottomSpacing: CGFloat = 12
        static let grabberCornerRadius: CGFloat = 2.5
        static let grabberAlpha: CGFloat = 0.4
        static let contentSpacing: CGFloat = 8
        static let initialPanelHeight: CGFloat = 80
        static let maxExpandedHeightRatio: CGFloat = 0.85
        static let panVelocityThreshold: CGFloat = 300
    }

    private enum Typography {
        static let hintFontSize: CGFloat = 13
        static let titleFontSize: CGFloat = 22
        static let authorFontSize: CGFloat = 15
        static let descriptionFontSize: CGFloat = 16
        static let authorAlpha: CGFloat = 0.7
        static let descriptionAlpha: CGFloat = 0.85
    }

    private enum Animation {
        static let duration: TimeInterval = 0.4
        static let springDamping: CGFloat = 0.85
        static let initialSpringVelocity: CGFloat = 0.5
    }

    let index: Int

    private let item: DetailViewModel.DetailItem
    private let imageLoader: ImageLoaderProtocol
    private var imageLoadTask: Task<Void, Never>?

    private var panelHeightConstraint: NSLayoutConstraint!
    private var isExpanded = false
    private var contentStack: UIStackView!
    private var authorRow: UIStackView!
    private var panelScrollView: UIScrollView!
    private var needsInitialLayout = true

    private let grabberArea: CGFloat = Layout.grabberTopInset + Layout.grabberHeight + Layout.grabberBottomSpacing

    private var peekHeight: CGFloat {
        let bottomSafe = view.safeAreaInsets.bottom
        let contentWidth = view.bounds.width - Layout.contentHorizontalInset * 2
        let fittingSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let titleHeight = titleLabel.systemLayoutSizeFitting(fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel).height
        let authorRowHeight = authorRow.systemLayoutSizeFitting(fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel).height
        return grabberArea + titleHeight + Layout.contentSpacing + authorRowHeight + bottomSafe
    }

    private var expandedHeight: CGFloat {
        let bottomSafe = view.safeAreaInsets.bottom
        let contentWidth = view.bounds.width - Layout.contentHorizontalInset * 2
        let fittingSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let contentHeight = contentStack.systemLayoutSizeFitting(fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel).height
        let totalNeeded = grabberArea + contentHeight + Layout.contentBottomInset + bottomSafe
        return min(totalNeeded, view.bounds.height * Layout.maxExpandedHeightRatio)
    }

    // MARK: - UI Elements

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()

    private let panelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.panelCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    private let grabberView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(Layout.grabberAlpha)
        view.layer.cornerRadius = Layout.grabberCornerRadius
        view.alpha = 0
        return view
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Typography.hintFontSize, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(Layout.grabberAlpha)
        label.text = L10n.Detail.moreHint
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Typography.titleFontSize, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Typography.authorFontSize, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(Typography.authorAlpha)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Typography.descriptionFontSize)
        label.textColor = UIColor.white.withAlphaComponent(Typography.descriptionAlpha)
        label.numberOfLines = 0
        return label
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
        setupGestures()
        configureContent()
        loadImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsInitialLayout {
            needsInitialLayout = false
            panelHeightConstraint.constant = peekHeight
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(imageView)
        view.addSubview(panelContainer)

        panelContainer.addSubview(blurView)
        panelContainer.addSubview(grabberView)

        panelScrollView = UIScrollView()
        panelScrollView.translatesAutoresizingMaskIntoConstraints = false
        panelScrollView.alwaysBounceVertical = true
        panelScrollView.showsVerticalScrollIndicator = false
        panelScrollView.isScrollEnabled = false
        panelContainer.addSubview(panelScrollView)

        contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = Layout.contentSpacing
        panelScrollView.addSubview(contentStack)

        let authorSpacer = UIView()
        authorRow = UIStackView(arrangedSubviews: [authorLabel, hintLabel, authorSpacer])
        authorRow.axis = .horizontal
        authorRow.alignment = .center
        authorRow.spacing = Layout.contentSpacing

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(authorRow)
        contentStack.addArrangedSubview(descriptionLabel)

        panelHeightConstraint = panelContainer.heightAnchor.constraint(equalToConstant: Layout.initialPanelHeight)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            panelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelHeightConstraint,

            blurView.topAnchor.constraint(equalTo: panelContainer.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: panelContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: panelContainer.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: panelContainer.bottomAnchor),

            grabberView.topAnchor.constraint(equalTo: panelContainer.topAnchor, constant: Layout.grabberTopInset),
            grabberView.centerXAnchor.constraint(equalTo: panelContainer.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: Layout.grabberWidth),
            grabberView.heightAnchor.constraint(equalToConstant: Layout.grabberHeight),

            panelScrollView.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: Layout.grabberBottomSpacing),
            panelScrollView.leadingAnchor.constraint(equalTo: panelContainer.leadingAnchor),
            panelScrollView.trailingAnchor.constraint(equalTo: panelContainer.trailingAnchor),
            panelScrollView.bottomAnchor.constraint(equalTo: panelContainer.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: panelScrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: panelScrollView.leadingAnchor, constant: Layout.contentHorizontalInset),
            contentStack.trailingAnchor.constraint(equalTo: panelScrollView.trailingAnchor, constant: -Layout.contentHorizontalInset),
            contentStack.bottomAnchor.constraint(equalTo: panelScrollView.bottomAnchor, constant: -Layout.contentBottomInset),
            contentStack.widthAnchor.constraint(equalTo: panelScrollView.widthAnchor, constant: -Layout.contentHorizontalInset * 2)
        ])
    }

    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panelContainer.addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        panelContainer.addGestureRecognizer(tap)
    }

    private func configureContent() {
        titleLabel.text = item.title
        authorLabel.text = item.authorName
        descriptionLabel.text = item.description
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

    // MARK: - Gestures

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            let currentHeight = isExpanded ? expandedHeight : peekHeight
            var newHeight = currentHeight - translation.y
            newHeight = max(peekHeight, min(expandedHeight, newHeight))
            panelHeightConstraint.constant = newHeight
            updateBlurAlpha()

        case .ended, .cancelled:
            let shouldExpand: Bool
            if velocity.y < -Layout.panVelocityThreshold {
                shouldExpand = true
            } else if velocity.y > Layout.panVelocityThreshold {
                shouldExpand = false
            } else {
                let midpoint = (peekHeight + expandedHeight) / 2
                shouldExpand = panelHeightConstraint.constant > midpoint
            }
            animatePanel(expanded: shouldExpand)

        default:
            break
        }
    }

    @objc private func handleTap() {
        animatePanel(expanded: !isExpanded)
    }

    private func animatePanel(expanded: Bool) {
        isExpanded = expanded
        panelHeightConstraint.constant = expanded ? expandedHeight : peekHeight

        if !expanded {
            panelScrollView.isScrollEnabled = false
            panelScrollView.setContentOffset(.zero, animated: false)
        }

        UIView.animate(
            withDuration: Animation.duration,
            delay: 0,
            usingSpringWithDamping: Animation.springDamping,
            initialSpringVelocity: Animation.initialSpringVelocity,
            options: .curveEaseOut
        ) {
            self.view.layoutIfNeeded()
            self.updateBlurAlpha()
        } completion: { _ in
            if expanded {
                self.panelScrollView.isScrollEnabled = true
            }
        }
    }

    private func updateBlurAlpha() {
        let peek = peekHeight
        let expanded = expandedHeight
        guard expanded > peek else {
            blurView.alpha = 0
            grabberView.alpha = 0
            hintLabel.alpha = 1
            return
        }
        let progress = (panelHeightConstraint.constant - peek) / (expanded - peek)
        let clamped = max(0, min(1, progress))
        blurView.alpha = clamped
        grabberView.alpha = clamped
        hintLabel.alpha = 1 - clamped
    }

}
