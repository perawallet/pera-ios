//
//  ToggleTitleView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class ToggleTitleView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("notification-filter-show-for".localized)
    }()

    override func prepareLayout() {
        setupTitleLabelLayout()
    }
}

extension ToggleTitleView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
}

extension ToggleTitleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 26.0
    }
}
