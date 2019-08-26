//
//  FeedbackSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol FeedbackSelectionViewDelegate: class {
    func feedbackSelectionViewDidSelected(_ feedbackSelectionView: FeedbackSelectionView)
}

class FeedbackSelectionView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let labelInset: CGFloat = 13.0
        let horizontalInset: CGFloat = 25.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.94, 0.94, 0.94)
    }
    
    weak var delegate: FeedbackSelectionViewDelegate?
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToFeedbackSelectionViewTapped)
    )
    
    // MARK: Components
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private lazy var leftIconView = UIImageView(image: img("icon-feedback"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.purple)
            .withLine(.single)
            .withText("feedback-title".localized)
            .withAlignment(.left)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
    }()
    
    private lazy var rightIconView: UIImageView = {
        let imageView = UIImageView(image: img("icon-arrow", isTemplate: true))
        imageView.tintColor = SharedColors.purple
        return imageView
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupSeparatorViewLayout()
        setupLeftIconViewLayout()
        setupTitleLabelLayout()
        setupRightIconViewLayout()
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupLeftIconViewLayout() {
        addSubview(leftIconView)
        
        leftIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(leftIconView.snp.trailing).offset(layout.current.labelInset)
        }
    }
    
    private func setupRightIconViewLayout() {
        addSubview(rightIconView)
        
        rightIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToFeedbackSelectionViewTapped() {
        delegate?.feedbackSelectionViewDidSelected(self)
    }
}
