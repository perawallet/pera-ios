//
//  ContactInfoView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactInfoView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewHeight: CGFloat = 333.0
        let bottomInset: CGFloat = 20.0
        let topInset: CGFloat = 24.0
        let transactionLabelVerticalInset: CGFloat = 34.0
        let transactionLabelHorizontalInset: CGFloat = 25.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
    }
    
    // MARK: Components
    
    private(set) lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(isEditable: false)
        return view
    }()
    
    private lazy var transactionTitleLabel: UILabel = {
        UILabel()
            .withText("contacts-transactions-title".localized)
            .withTextColor(SharedColors.darkGray)
            .withAlignment(.left)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
    }()
    
    // Transactions list
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupTransactionsLabelLayout()
    }
    
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(layout.current.topInset)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupTransactionsLabelLayout() {
        addSubview(transactionTitleLabel)
        
        transactionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.transactionLabelVerticalInset)
            make.leading.equalToSuperview().inset(layout.current.transactionLabelHorizontalInset)
        }
    }
}
