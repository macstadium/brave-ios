// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import BraveUI

/// Displays a group of feed items under a title, and optionally a brand under
/// the feeds.
class FeedGroupView: UIView {
    /// The user has tapped the feed that exists at a specific index
    var tappedFeedAtIndex: ((Int) -> Void)?
    /// The title label appearing above the list of feeds
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 21, weight: .bold)
        $0.appearanceTextColor = .white
    }
    /// The buttons that contain each feed view
    private let buttons: [SpringButton]
    /// The feeds that are displayed within the list
    let feedViews: [FeedItemView]
    /// The brand image at the bottom of each card.
    ///
    /// Set `isHidden` to true if you want to hide the brand image for a given
    /// card
    let groupBrandImageView = UIImageView().then {
        $0.contentMode = .left
        $0.snp.makeConstraints {
            $0.height.equalTo(20)
        }
    }
    /// The blurred background view
    private let backgroundView = CardBackgroundView()
    /// Create a card that contains a list of feeds within it
    /// - parameters:
    ///     - axis: Controls whether or not feeds are distributed horizontally
    ///             or vertically
    ///     - feedLayout: Controls how each individual feed item is laid out
    ///     - numberOfFeeds: The number of feeds views to create and to the list
    ///     - transformItems: A block to transform the group item views to
    ///       another view in case it needs to be altered, padded, etc.
    init(axis: NSLayoutConstraint.Axis,
         feedLayout: FeedItemView.Layout,
         numberOfFeeds: Int = 3,
         transformItems: (([UIView]) -> [UIView])? = nil) {
        feedViews = (0..<numberOfFeeds).map { _ in
            FeedItemView(layout: feedLayout)
        }
        buttons = feedViews.map {
            let button = SpringButton()
            button.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            return button
        }
        
        super.init(frame: .zero)
        
        buttons.forEach {
            $0.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)
        }
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 20
        }
        stackView.addStackViewItems(
            .view(titleLabel),
            .view(UIStackView().then {
                $0.spacing = 16
                $0.axis = axis
                if axis == .horizontal {
                    $0.distribution = .fillEqually
                }
                let transform: ([UIView]) -> [UIView] = transformItems ?? { views in views }
                let groupViews = transform(buttons)
                groupViews.forEach($0.addArrangedSubview)
            }),
            .view(groupBrandImageView)
        )
        
        addSubview(backgroundView)
        addSubview(stackView)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func tappedButton(_ sender: SpringButton) {
        if let index = buttons.firstIndex(where: { sender === $0 }) {
            tappedFeedAtIndex?(index)
        }
    }
}