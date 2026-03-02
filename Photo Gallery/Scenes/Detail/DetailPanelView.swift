//
//  DetailPanelView.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 24.02.26.
//

import UIKit

final class DetailPanelView: UIView {

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

    private let grabberArea: CGFloat = Layout.grabberTopInset + Layout.grabberHeight + Layout.grabberBottomSpacing

    var panelHeightConstraint: NSLayoutConstraint!
    private var isExpanded = false
    private var contentStack: UIStackView!
    private var authorRow: UIStackView!
    private var panelScrollView: UIScrollView!
    private var needsInitialLayout = true

    private var parentBounds: CGRect {
        superview?.bounds ?? bounds
    }

    private var contentFittingSize: CGSize {
        let width = parentBounds.width - Layout.contentHorizontalInset * 2
        return CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
    }

    private var peekHeight: CGFloat {
        let bottomSafe = superview?.safeAreaInsets.bottom ?? safeAreaInsets.bottom
        let fittingSize = contentFittingSize
        let titleHeight = layoutHeight(for: titleLabel, fittingSize: fittingSize)
        let authorRowHeight = layoutHeight(for: authorRow, fittingSize: fittingSize)
        return grabberArea + titleHeight + Layout.contentSpacing + authorRowHeight + bottomSafe
    }

    private var expandedHeight: CGFloat {
        let bottomSafe = superview?.safeAreaInsets.bottom ?? safeAreaInsets.bottom
        let fittingSize = contentFittingSize
        let contentHeight = layoutHeight(for: contentStack, fittingSize: fittingSize)
        let totalNeeded = grabberArea + contentHeight + Layout.contentBottomInset + bottomSafe
        let maxHeight = parentBounds.height * Layout.maxExpandedHeightRatio
        return min(totalNeeded, maxHeight)
    }

    private func layoutHeight(for view: UIView, fittingSize: CGSize) -> CGFloat {
        view.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    // MARK: - UI Elements

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        if needsInitialLayout {
            needsInitialLayout = false
            panelHeightConstraint.constant = peekHeight
        }
    }

    // MARK: - Configuration

    func configure(title: String, authorName: String, description: String) {
        titleLabel.text = title
        authorLabel.text = authorName
        descriptionLabel.text = description
    }

    // MARK: - Setup

    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = Layout.panelCornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        addSubview(blurView)
        addSubview(grabberView)
        setupPanelScrollView()
        setupContentStack()
        panelHeightConstraint = heightAnchor.constraint(equalToConstant: Layout.initialPanelHeight)
        activateConstraints()
    }

    private func setupPanelScrollView() {
        panelScrollView = UIScrollView()
        panelScrollView.translatesAutoresizingMaskIntoConstraints = false
        panelScrollView.alwaysBounceVertical = true
        panelScrollView.showsVerticalScrollIndicator = false
        panelScrollView.isScrollEnabled = false
        addSubview(panelScrollView)
    }

    private func setupContentStack() {
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
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            grabberView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.grabberTopInset),
            grabberView.centerXAnchor.constraint(equalTo: centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: Layout.grabberWidth),
            grabberView.heightAnchor.constraint(equalToConstant: Layout.grabberHeight),

            panelScrollView.topAnchor.constraint(
                equalTo: grabberView.bottomAnchor,
                constant: Layout.grabberBottomSpacing
            ),
            panelScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            panelScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            panelScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: panelScrollView.topAnchor),
            contentStack.leadingAnchor.constraint(
                equalTo: panelScrollView.leadingAnchor,
                constant: Layout.contentHorizontalInset
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: panelScrollView.trailingAnchor,
                constant: -Layout.contentHorizontalInset
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: panelScrollView.bottomAnchor,
                constant: -Layout.contentBottomInset
            ),
            contentStack.widthAnchor.constraint(
                equalTo: panelScrollView.widthAnchor,
                constant: -Layout.contentHorizontalInset * 2
            )
        ])
    }

    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Gestures

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)

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

        let duration = Animation.duration
        let damping = Animation.springDamping
        let velocity = Animation.initialSpringVelocity
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: .curveEaseOut
        ) {
            self.layoutIfNeeded()
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
