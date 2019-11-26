//
//  AssetDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDisplayView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.size
    }
    
    private(set) lazy var assetNameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var assetCodeLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .bold(size: 40.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.separatorColor.cgColor
    }
}

extension AssetDisplayView {
    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.nameVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.nameVerticalInset)
        }
    }
    
    private func setupAssetCodeLabelLayout() {
        addSubview(assetCodeLabel)
        
        assetCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.codeVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.codeVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension AssetDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let size = CGSize(width: 225.0, height: 116.0)
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 20.0
        let nameVerticalInset: CGFloat = 8.0
        let codeVerticalInset: CGFloat = 15.0
    }
}

extension AssetDisplayView {
    private enum Colors {
        static let separatorColor = rgb(0.91, 0.91, 0.92)
    }
}
