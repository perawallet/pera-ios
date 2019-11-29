//
//  AssetSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSelectionView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var codeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withTextColor(SharedColors.purple)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var indexLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupCodeLabelLayout()
        setupNameLabelLayout()
        setupIndexLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension AssetSelectionView {
    private func setupCodeLabelLayout() {
        addSubview(codeLabel)
        
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        codeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        codeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(codeLabel.snp.trailing).offset(layout.current.nameLabelInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupIndexLabelLayout() {
        addSubview(indexLabel)
        
        indexLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        indexLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        indexLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension AssetSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let nameLabelInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 25.0
    }
}

extension AssetSelectionView {
    private enum Colors {
        static let separatorColor = rgb(0.91, 0.91, 0.92)
    }
}
