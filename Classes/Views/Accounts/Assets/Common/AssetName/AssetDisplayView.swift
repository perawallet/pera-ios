//
//  AssetDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDisplayView: BaseView {
    
    private lazy var assetNameLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var separatorView = UIView()
    
    private lazy var assetCodeLabel: UILabel = {
        UILabel()
    }()
    
    override func configureAppearance() {
        
    }
}

extension AssetDisplayView {
    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { _ in
            
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupAssetCodeLabelLayout() {
        addSubview(assetCodeLabel)
        
        assetCodeLabel.snp.makeConstraints { _ in
            
        }
    }
}

extension AssetDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
}
