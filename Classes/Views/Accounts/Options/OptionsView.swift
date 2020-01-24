//
//  OptionsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol OptionsViewDelegate: class {
    func optionsViewDidTapDismissButton(_ optionsView: OptionsView)
}

class OptionsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: OptionsViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withAttributedText("options-title".localized.attributed([.letterSpacing(1.10), .textColor(SharedColors.darkGray)]))
            .withFont(UIFont.font(.avenir, withWeight: .bold(size: 11.0)))
    }()
    
    private lazy var dismissButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-close"))
    }()
    
    private(set) lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        collectionView.register(OptionsCell.self, forCellWithReuseIdentifier: OptionsCell.reusableIdentifier)
        return collectionView
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        dismissButton.addTarget(self, action: #selector(notifyDelegateToDismissButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDismissButtonLayout()
        setupOptionsCollectionViewLayout()
    }
    
    @objc
    private func notifyDelegateToDismissButtonTapped() {
        delegate?.optionsViewDidTapDismissButton(self)
    }
}

extension OptionsView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupDismissButtonLayout() {
        addSubview(dismissButton)
        
        dismissButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(layout.current.dismissButtonInset)
        }
    }
    
    private func setupOptionsCollectionViewLayout() {
        addSubview(optionsCollectionView)
        
        optionsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.collectionViewTopInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension OptionsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelTopInset: CGFloat = 30.0
        let collectionViewTopInset: CGFloat = 25.0
        let dismissButtonInset: CGFloat = 15.0
    }
}
