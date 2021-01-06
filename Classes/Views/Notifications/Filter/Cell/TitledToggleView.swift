//
//  TitledToggleView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class TitledToggleView: BaseView {

    weak var delegate: TitledToggleViewDelegate?

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("notification-filter-show-title".localized)
    }()
    
    private lazy var toggleView = Toggle()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        toggleView.addTarget(self, action: #selector(notifyDelegateToToggleValueChanged), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupToggleViewLayout()
        setupTitleLabelLayout()
    }
}

extension TitledToggleView {
    @objc
    private func notifyDelegateToToggleValueChanged() {
        delegate?.titledToggleView(self, didChangeToggleValue: toggleView.isOn)
    }
}

extension TitledToggleView {
    private func setupToggleViewLayout() {
        addSubview(toggleView)

        toggleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(toggleView.snp.leading).offset(-layout.current.horizontalInset)
        }
    }
}

extension TitledToggleView {
    func bind(_ viewModel: TitledToggleViewModel) {
        titleLabel.text = viewModel.title
        toggleView.setOn(viewModel.isSelected, animated: true)
    }
}

extension TitledToggleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

protocol TitledToggleViewDelegate: class {
    func titledToggleView(_ titledToggleView: TitledToggleView, didChangeToggleValue value: Bool)
}
