//
//  AssetAdditionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class AssetAdditionView: BaseView {
    
    weak var delegate: AssetAdditionViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var assetInputView: SingleLineInputField = {
        let assetInputView = SingleLineInputField(
            displaysExplanationText: false,
            displaysRightInputAccessoryButton: true,
            displaysLeftImageView: true
        )
        assetInputView.placeholderText = "asset-search-placeholder".localized
        assetInputView.leftImageView.image = img("icon-field-search")
        assetInputView.rightInputAccessoryButton.setImage(img("icon-field-close"), for: .normal)
        assetInputView.rightInputAccessoryButton.isHidden = true
        assetInputView.inputTextField.textColor = SharedColors.primaryText
        assetInputView.inputTextField.tintColor = SharedColors.primaryText
        assetInputView.inputTextField.returnKeyType = .done
        assetInputView.inputTextField.autocorrectionType = .no
        return assetInputView
    }()
    
    private lazy var segmentControlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.secondaryBackground
        return view
    }()
    
    private lazy var assetSegmentControl: BetterSegmentedControl = {
        let segments = [
            SegmentItem(text: "asset-verified-title".localized, image: img("icon-verified")),
            SegmentItem(text: "asset-all-title".localized)
        ]
        let control = BetterSegmentedControl(
            frame: .zero,
            segments: segments,
            index: 0,
            options: [
                .backgroundColor(SharedColors.gray100),
                .indicatorViewBackgroundColor(SharedColors.secondaryBackground),
                .cornerRadius(8.0),
                .indicatorViewInset(4.0)
            ]
        )
        return control
    }()
    
    private(set) lazy var assetsCollectionView: AssetsCollectionView = {
        let collectionView = AssetsCollectionView(containsPendingAssets: false)
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.contentInset = .zero
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    override func linkInteractors() {
        assetSegmentControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    override func prepareLayout() {
        setupAssetInputViewLayout()
        setupSegmentControlLayout()
        setupAssetsCollectionViewLayout()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        assetSegmentControl.setIndex(0)
    }
}

extension AssetAdditionView {
    @objc
    private func segmentedControlValueChanged(_ segmentedControl: BetterSegmentedControl) {
        switch segmentedControl.index {
        case 0:
            delegate?.assetAdditionViewDidTapVerifiedAssets(self)
        case 1:
            delegate?.assetAdditionViewDidTapAllAssets(self)
        default:
            return
        }
    }
}

extension AssetAdditionView {
    private func setupAssetInputViewLayout() {
        addSubview(assetInputView)
        
        assetInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
        
        assetInputView.rightInputAccessoryButton.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(3.0)
        }
    }
    
    private func setupSegmentControlLayout() {
        addSubview(segmentControlContainerView)
        
        segmentControlContainerView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(assetInputView.snp.bottom).offset(layout.current.topInset)
            maker.height.equalTo(layout.current.segmentControlContainerHeight)
        }
        
        segmentControlContainerView.addSubview(assetSegmentControl)
        
        assetSegmentControl.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            maker.top.equalToSuperview().inset(layout.current.segmentControlTopInset)
            maker.height.equalTo(layout.current.segmentControlHeight)
        }
    }

    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(segmentControlContainerView.snp.bottom)
        }
        
        assetsCollectionView.backgroundView = contentStateView
    }
}

extension AssetAdditionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 16.0
        let unverifiedAssetsButtonInset: CGFloat = 5.0
        let segmentControlHeight: CGFloat = 48.0
        let inputViewHeight: CGFloat = 50.0
        let collectionViewTopInset: CGFloat = 15.0
        let segmentControlContainerHeight = 72.0
        let segmentControlTopInset = 14.0
    }
}

extension AssetAdditionView {
    private enum Colors {
        static let placeholderColor = rgba(0.67, 0.67, 0.72, 0.3)
    }
}

protocol AssetAdditionViewDelegate: class {
    func assetAdditionViewDidTapVerifiedAssets(_ assetAdditionView: AssetAdditionView)
    func assetAdditionViewDidTapAllAssets(_ assetAdditionView: AssetAdditionView)
}
