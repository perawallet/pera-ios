//
//  PlaceBidViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PlaceBidViewController: BaseViewController {
    
    // MARK: Components
    
    private(set) lazy var placeBidView: PlaceBidView = {
        let view = PlaceBidView()
        return view
    }()
    
    // MARK: Setup
    
    override func linkInteractors() {
        placeBidView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupPlaceBidViewLayout()
    }
    
    private func setupPlaceBidViewLayout() {
        view.addSubview(placeBidView)
        
        placeBidView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: PlaceBidViewDelegate

extension PlaceBidViewController: PlaceBidViewDelegate {
    
    func placeBidViewDidTapPlaceBidButton(_ placeBidView: PlaceBidView) {
        
    }
}
