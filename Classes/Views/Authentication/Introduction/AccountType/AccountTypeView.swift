//
//  AccountTypeView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountTypeView: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var typeImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
    }()
    
    private lazy var newLabelContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6.0
        view.backgroundColor = Colors.AccountTypeView.newLabelBackground
        return view
    }()
    
    private lazy var newLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .bold(size: 10.0)))
            .withText("title-new-uppercased".localized)
            .withTextColor(Colors.AccountTypeView.newLabelText)
            .withAlignment(.center)
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withAlignment(.left)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-introduction-arrow-right"))
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupNewLabelContainerLayout()
        setupNewLabelLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
        setupTypeImageViewLayout()
        setupArrowImageViewLayout()
    }
}

extension AccountTypeView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupNewLabelContainerLayout() {
        addSubview(newLabelContainer)
        
        newLabelContainer.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.newLabelHorizontalInset)
            make.centerY.equalTo(titleLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleInset)
        }
    }
    
    private func setupNewLabelLayout() {
        newLabelContainer.addSubview(newLabel)
        
        newLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(layout.current.newLabelVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.newLabelHorizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(layout.current.titleInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.minimumInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupTypeImageViewLayout() {
        addSubview(typeImageView)
        
        typeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.iconSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(typeImageView)
            make.size.equalTo(layout.current.iconSize)
        }
    }
}

extension AccountTypeView {
    func bind(_ viewModel: AccountTypeViewModel) {
        typeImageView.image = viewModel.typeImage
        titleLabel.text = viewModel.title
        newLabelContainer.isHidden = !viewModel.isNew
        newLabel.isHidden = !viewModel.isNew
        detailLabel.text = viewModel.detail
    }
}

extension Colors {
    fileprivate enum AccountTypeView {
        static let newLabelBackground = Colors.Main.primary600
        static let newLabelText = color("newLabelColor")
    }
}

extension AccountTypeView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let separatorHeight: CGFloat = 1.0
        let newLabelVerticalInset: CGFloat = 2.0
        let horizontalInset: CGFloat = 20.0
        let titleInset: CGFloat = 60.0
        let verticalInset: CGFloat = 20.0
        let newLabelHorizontalInset: CGFloat = 8.0
        let minimumInset: CGFloat = 4.0
    }
}
