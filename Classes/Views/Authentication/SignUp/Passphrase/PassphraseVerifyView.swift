//
//  PassPhraseVerifyView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseVerifyView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var questionTitleLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
    }()
    
    private(set) lazy var passphraseCollectionView: UICollectionView = {
        let collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 8.0
        collectionViewLayout.minimumInteritemSpacing = 8.0
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.register(
            PassphraseCollectionViewCell.self,
            forCellWithReuseIdentifier: PassphraseCollectionViewCell.reusableIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var wrongChoiceLabel: UILabel = {
        let label = UILabel()
            .withText("pass-phrase-verify-wrong-selection".localized)
            .withTextColor(Colors.Main.red600)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
            .withAlignment(.center)
        label.isHidden = true
        return label
    }()
    
    override func prepareLayout() {
        setuptQuestionTitleLabelLayout()
        setupCollectionViewLayout()
        setupWrongChoiceLabelLayout()
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.primary
    }
}

extension PassphraseVerifyView {
    private func setuptQuestionTitleLabelLayout() {
        addSubview(questionTitleLabel)
        
        questionTitleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(layout.current.titleTopInset)
            maker.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCollectionViewLayout() {
        addSubview(passphraseCollectionView)
        
        passphraseCollectionView.snp.makeConstraints { make in
            make.top.equalTo(questionTitleLabel.snp.bottom).offset(layout.current.listTopOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.greaterThanOrEqualTo(layout.current.listMinHeight)
        }
    }
    
    private func setupWrongChoiceLabelLayout() {
        addSubview(wrongChoiceLabel)
        
        wrongChoiceLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(passphraseCollectionView.snp.bottom).offset(layout.current.wrongChoiceLabelVerticalInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.wrongChoiceLabelVerticalInset)
        }
    }
}

extension PassphraseVerifyView {
    func setWrongChoiceLabelHidden(_ hidden: Bool) {
        wrongChoiceLabel.isHidden = hidden
    }
}

extension PassphraseVerifyView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 80.0
        let horizontalInset: CGFloat = 32.0
        let wrongChoiceLabelVerticalInset: CGFloat = 30.0
        let listTopOffset: CGFloat = 40.0
        let listMinHeight: CGFloat = 220.0
    }
}
