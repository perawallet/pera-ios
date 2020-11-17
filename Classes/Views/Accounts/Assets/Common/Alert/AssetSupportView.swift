//
//  AssetSupportView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSupportView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetSupportViewDelegate?
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
        
    }()
    
    private(set) lazy var assetDisplayView = AssetDisplayView()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var okButton = MainButton(title: "title-ok".localized)
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        okButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAssetDisplayViewLayout()
        setupDetailLabelLayout()
        setupOKButtonLayout()
    }
}

extension AssetSupportView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.assetSupportViewDidTapOKButton(self)
    }
}

extension AssetSupportView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.titleLabelHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
        }
    }

    private func setupAssetDisplayViewLayout() {
        addSubview(assetDisplayView)
        
        assetDisplayView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.displayViewTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.displayViewHorizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(assetDisplayView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupOKButtonLayout() {
        addSubview(okButton)
        
        okButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.displayViewTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension AssetSupportView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 35.0
        let titleLabelTopInset: CGFloat = 16.0
        let titleLabelHorizontalInset: CGFloat = 40.0
        let displayViewTopInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 30.0
        let displayViewHorizontalInset: CGFloat = 32.0
    }
}

protocol AssetSupportViewDelegate: class {
    func assetSupportViewDidTapOKButton(_ assetSupportView: AssetSupportView)
}
