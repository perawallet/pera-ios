//
//  MyBidsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MyBidsView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 15.0
        let potentialAlgosViewTopInset: CGFloat = 10.0
        let potentialAlgosViewHeight: CGFloat = 50.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var totalPotentialAlgosDisplayView: PotentialAlgosDisplayView = {
        let view = PotentialAlgosDisplayView(mode: .total)
        return view
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTotalPotentialAlgosDisplayViewLayout()
    }
    
    private func setupTotalPotentialAlgosDisplayViewLayout() {
        addSubview(totalPotentialAlgosDisplayView)
        
        totalPotentialAlgosDisplayView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.potentialAlgosViewHeight)
        }
    }
}
