//
//  TestNetTitleView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TestNetTitleView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
    }()
    
    private lazy var testNetLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 10.0)))
            .withTextColor(Colors.ButtonText.primary)
            .withAlignment(.center)
            .withText("title-testnet".localized)
        label.backgroundColor = Colors.General.testNetBanner
        label.layer.cornerRadius = 12.0
        label.layer.masksToBounds = true
        return label
    }()
    
    override func prepareLayout() {
        setupTestNetLabelLayout()
        setupTitleLabelLayout()
    }
}

extension TestNetTitleView {
    private func setupTestNetLabelLayout() {
        addSubview(testNetLabel)
        
        testNetLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.size.equalTo(layout.current.testNetLabelSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(testNetLabel.snp.leading).offset(layout.current.titleOffset)
            make.centerY.equalTo(testNetLabel)
        }
    }
}

extension TestNetTitleView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension TestNetTitleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleOffset: CGFloat = -8.0
        let testNetLabelSize = CGSize(width: 63.0, height: 24.0)
    }
}

class AssetDetailTitleView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withAlignment(.center)
        label.alpha = 0.0
        return label
    }()
    
    init(title: String?) {
        super.init(frame: .zero)
        titleLabel.text = title
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
    }
}

extension AssetDetailTitleView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.trailing.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension AssetDetailTitleView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String) {
        detailLabel.text = detail
    }
}

extension AssetDetailTitleView {
    func animateUp(with offset: CGFloat) {
        let scrollOfset = offset >= 1.0 ? 0.0 : layout.current.verticalInset - (offset * layout.current.verticalInset)
        animate(with: scrollOfset, shouldDisplayDetail: true)
    }
    
    func animateDown(with offset: CGFloat) {
        let scrollOfset = offset >= 1.0 ? layout.current.verticalInset : offset * layout.current.verticalInset
        animate(with: scrollOfset, shouldDisplayDetail: false)
    }
    
    private func animate(with offset: CGFloat, shouldDisplayDetail isDisplaying: Bool) {
        titleLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(offset)
        }
        
        detailLabel.snp.updateConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(offset)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.detailLabel.alpha = isDisplaying ? 1.0 : 0.0
            self.layoutIfNeeded()
        }
    }
}

extension AssetDetailTitleView {
    func bind(_ viewModel: AssetDetailTitleViewModel) {
        detailLabel.text = viewModel.detail
    }
}

extension AssetDetailTitleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 10.0
    }
}
