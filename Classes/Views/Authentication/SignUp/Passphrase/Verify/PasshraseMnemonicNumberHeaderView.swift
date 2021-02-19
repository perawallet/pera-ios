//
//  PasshraseMnemonicNumberHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.02.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class PasshraseMnemonicNumberHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.secondary)
            .withAlignment(.left)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
    }
}

extension PasshraseMnemonicNumberHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview()
        }
    }
}

extension PasshraseMnemonicNumberHeaderView {
    func bind(_ viewModel: PasshraseMnemonicNumberHeaderViewModel) {
        titleLabel.text = viewModel.number
    }
}

extension PasshraseMnemonicNumberHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
    }
}
