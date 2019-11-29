//
//  AssetAdditionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetAdditionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var assetInputView: SingleLineInputField = {
        let assetInputView = SingleLineInputField(displaysExplanationText: false)
        assetInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "asset-search-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))]
        )
        
        assetInputView.inputTextField.textColor = SharedColors.black
        assetInputView.inputTextField.tintColor = SharedColors.black
        assetInputView.nextButtonMode = .submit
        assetInputView.inputTextField.autocorrectionType = .no
        assetInputView.inputTextField.keyboardType = .numberPad
        return assetInputView
    }()
    
    private(set) lazy var assetsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(AssetSelectionCell.self, forCellWithReuseIdentifier: AssetSelectionCell.reusableIdentifier)
        
        return collectionView
    }()
    
    override func prepareLayout() {
        setupAssetInputViewLayout()
        setupAssetsCollectionViewLayout()
    }
}

extension AssetAdditionView {
    private func setupAssetInputViewLayout() {
        addSubview(assetInputView)
        
        assetInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(assetInputView.snp.bottom).offset(layout.current.collectionViewTopInset)
        }
    }
}

extension AssetAdditionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 15.0
        let topInset: CGFloat = 10.0
        let inputViewHeight: CGFloat = 50.0
        let collectionViewTopInset: CGFloat = 17.0
    }
}

extension AssetAdditionView {
    private enum Colors {
        static let placeholderColor = rgba(0.67, 0.67, 0.72, 0.3)
    }
}
