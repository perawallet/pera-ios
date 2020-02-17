//
//  AssetAdditionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetAdditionViewDelegate: class {
    func assetAdditionViewDidTapButton(_ assetAdditionView: AssetAdditionView, didTapButtonFor status: AssetSearchStatus)
}

class AssetAdditionView: BaseView {
    
    weak var delegate: AssetAdditionViewDelegate?
    
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
        assetInputView.inputTextField.returnKeyType = .done
        assetInputView.inputTextField.autocorrectionType = .no
        return assetInputView
    }()
    
    private(set) lazy var verifiedAssetsButton: UIButton = {
        let button = UIButton(type: .custom)
            .withTitleColor(.white)
            .withTitle("asset-verified-title".localized)
            .withBackgroundColor(Colors.verifiedButtonColor)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 12.0)))
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    private(set) lazy var unverifiedAssetsButton: UIButton = {
        let button = UIButton(type: .custom)
            .withTitleColor(.white)
            .withTitle("asset-unverified-title".localized)
            .withBackgroundColor(SharedColors.purple.withAlphaComponent(0.3))
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 12.0)))
        button.layer.cornerRadius = 6.0
        return button
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
    
    private lazy var contentStateView = ContentStateView()
    
    override func linkInteractors() {
        verifiedAssetsButton.addTarget(self, action: #selector(notifyDelegateToVerifiedAssetsButtonTapped), for: .touchUpInside)
        unverifiedAssetsButton.addTarget(self, action: #selector(notifyDelegateToUnverifiedAssetsButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAssetInputViewLayout()
        setupVerifiedAssetsButtonLayout()
        setupUnverifiedAssetsButtonLayout()
        setupAssetsCollectionViewLayout()
    }
}

extension AssetAdditionView {
    @objc
    private func notifyDelegateToVerifiedAssetsButtonTapped() {
        delegate?.assetAdditionViewDidTapButton(self, didTapButtonFor: .verified)
    }
    
    @objc
    private func notifyDelegateToUnverifiedAssetsButtonTapped() {
        delegate?.assetAdditionViewDidTapButton(self, didTapButtonFor: .unverified)
    }
}

extension AssetAdditionView {
    private func setupAssetInputViewLayout() {
        addSubview(assetInputView)
        
        assetInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupVerifiedAssetsButtonLayout() {
        addSubview(verifiedAssetsButton)
        
        verifiedAssetsButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(assetInputView.snp.bottom).offset(layout.current.topInset)
            make.height.equalTo(layout.current.buttonHeight)
        }
    }
    
    private func setupUnverifiedAssetsButtonLayout() {
        addSubview(unverifiedAssetsButton)
        
        unverifiedAssetsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(verifiedAssetsButton)
            make.width.height.equalTo(verifiedAssetsButton)
            make.leading.equalTo(verifiedAssetsButton.snp.trailing).offset(layout.current.unverifiedAssetsButtonInset)
        }
    }

    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(verifiedAssetsButton.snp.bottom).offset(layout.current.collectionViewTopInset)
        }
        
        assetsCollectionView.backgroundView = contentStateView
    }
}

extension AssetAdditionView {
    func set(button: UIButton, selected isSelected: Bool) {
        if button == verifiedAssetsButton {
            button.backgroundColor = isSelected ? Colors.verifiedButtonColor : Colors.verifiedButtonColor.withAlphaComponent(0.3)
        } else {
            button.backgroundColor = isSelected ? SharedColors.purple : SharedColors.purple.withAlphaComponent(0.3)
        }
    }
}

extension AssetAdditionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 15.0
        let topInset: CGFloat = 10.0
        let unverifiedAssetsButtonInset: CGFloat = 5.0
        let buttonHeight: CGFloat = 40.0
        let inputViewHeight: CGFloat = 50.0
        let collectionViewTopInset: CGFloat = 15.0
    }
}

extension AssetAdditionView {
    private enum Colors {
        static let placeholderColor = rgba(0.67, 0.67, 0.72, 0.3)
        static let verifiedButtonColor = rgb(0.29, 0.42, 0.87)
    }
}
