//
//  OptionsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class OptionsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: OptionsViewDelegate?
    
    private(set) lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8.0
        flowLayout.minimumInteritemSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.contentInset = .zero
        collectionView.register(OptionsCell.self, forCellWithReuseIdentifier: OptionsCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.gray100
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-cancel".localized)
            .withTitleColor(SharedColors.gray500)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupCancelButtonLayout()
        setupOptionsCollectionViewLayout()
    }
}

extension OptionsView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.optionsViewDidTapCancelButton(self)
    }
}

extension OptionsView {
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    private func setupOptionsCollectionViewLayout() {
        addSubview(optionsCollectionView)
        
        optionsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(cancelButton.snp.top).offset(layout.current.bottomInset)
        }
    }
}

extension OptionsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonTopInset: CGFloat = 22.0
        let buttonBottomInset: CGFloat = 20.0
        let defaultInset: CGFloat = 20.0
        let topInset: CGFloat = 10.0
        let bottomInset: CGFloat = -20.0
    }
}

protocol OptionsViewDelegate: class {
    func optionsViewDidTapCancelButton(_ optionsView: OptionsView)
}
