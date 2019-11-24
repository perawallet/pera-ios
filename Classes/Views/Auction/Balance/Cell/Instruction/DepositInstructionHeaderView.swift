//
//  DepositInstructionHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol DepositInstructionHeaderViewDelegate: class {
    
    func depositInstructionHeaderViewDidTapRemoveButton(_ depositInstructionHeaderView: DepositInstructionHeaderView)
}

class DepositInstructionHeaderView: UICollectionReusableView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let height: CGFloat = 65.0
        let bottomInset: CGFloat = 10.0
        let labelOffset: CGFloat = 6.0
        let horizontalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: DepositInstructionHeaderViewDelegate?
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: layout.current.height)
    }
    
    // MARK: Components
    
    private lazy var imageView = UIImageView(image: img("deposit-instruction-icon"))
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.blue)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
    }()
    
    private(set) lazy var removeButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.darkGray)
            .withTitle("title-remove-lowercased".localized)
            .withAlignment(.right)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        prepareLayout()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setupView() {
        backgroundColor = SharedColors.warmWhite
        removeButton.addTarget(self, action: #selector(notifyDelegateToRemoveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    private func prepareLayout() {
        setupImageViewLayout()
        setupRemoveButtonLayout()
        setupTitleLabelLayout()
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    private func setupRemoveButtonLayout() {
        addSubview(removeButton)
        
        removeButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelOffset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToRemoveButtonTapped() {
        delegate?.depositInstructionHeaderViewDidTapRemoveButton(self)
    }
}
