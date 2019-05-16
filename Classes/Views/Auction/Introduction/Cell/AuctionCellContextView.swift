//
//  AuctionCellContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionCellContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let viewWidth: CGFloat = UIScreen.main.bounds.width / 2
        let leadingInset: CGFloat = 30.0
        let trailingInset: CGFloat = 25.0
        let separatorInset: CGFloat = 20.0
        let verticalInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()

    private(set) lazy var dateView: DetailedInformationView = {
        let dateView = DetailedInformationView()
        dateView.backgroundColor = .white
        dateView.explanationLabel.text = "auction-date-title".localized
        dateView.detailLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0))
        return dateView
    }()
    
    private(set) lazy var soldAlgosView: DetailedInformationView = {
        let soldAlgosView = DetailedInformationView(mode: .algos)
        soldAlgosView.backgroundColor = .white
        soldAlgosView.explanationLabel.text = "auction-algos-sold-title".localized
        soldAlgosView.algosAmountView.amountLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0))
        return soldAlgosView
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupDateViewLayout()
        setupSoldAlgosViewLayout()
    }
    
    private func setupDateViewLayout() {
        addSubview(dateView)
        
        dateView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(layout.current.viewWidth)
        }
        
        adjustDateViewLayout()
    }
    
    private func adjustDateViewLayout() {
        dateView.explanationLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
        }
        
        dateView.detailLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.top.equalTo(dateView.explanationLabel.snp.bottom).offset(layout.current.verticalInset)
        }
        
        dateView.separatorView.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.separatorInset)
        }
    }
    
    private func setupSoldAlgosViewLayout() {
        addSubview(soldAlgosView)
        
        soldAlgosView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(layout.current.viewWidth)
        }
        
        adjustSoldAlgosViewLayout()
    }
    
    private func adjustSoldAlgosViewLayout() {
        soldAlgosView.explanationLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.trailingInset)
        }
        
        soldAlgosView.algosAmountView.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.trailingInset)
            make.top.equalTo(dateView.explanationLabel.snp.bottom).offset(layout.current.verticalInset)
        }
        
        soldAlgosView.separatorView.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.separatorInset)
        }
    }
}
