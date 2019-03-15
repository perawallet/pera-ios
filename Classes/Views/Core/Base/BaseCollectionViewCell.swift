//
//  BaseCollectionViewCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseCollectionViewCell<T: UIView>: UICollectionViewCell {
    
    typealias ContextView = T
    
    private(set) lazy var contextView = ContextView()

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
    }
    
    func prepareLayout() {
        setupContextViewLayout()
    }
    
    private func setupContextViewLayout() {
        contentView.addSubview(contextView)
        
        contextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }

    static func getContext() -> ContextView.Type {
        return ContextView.self
    }
}
