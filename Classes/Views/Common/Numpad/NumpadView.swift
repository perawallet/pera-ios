//
//  NumpadView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum NumpadValue {
    case number(String?)
    case delete
}

protocol NumpadTypeable where Self: UIView {
    
    var value: NumpadValue { get set }
}

protocol NumpadViewDelegate: class {
    
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadValue)
}

class NumpadView: BaseView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: layout.current.width, height: layout.current.height)
    }
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let width: CGFloat = UIScreen.main.bounds.width - 26.0
        let height: CGFloat = 267.0 * verticalScale
        let horizontalInset: CGFloat = 13.0
        let bottomInset: CGFloat = 4.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private var numpadViewLayoutBuilder: NumpadViewLayoutBuilder
    private var numpadViewDataSource: NumpadViewDataSource
    
    // MARK: Components
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        
        collectionView.register(NumpadNumericCell.self, forCellWithReuseIdentifier: NumpadNumericCell.reusableIdentifier)
        collectionView.register(NumpadDeleteCell.self, forCellWithReuseIdentifier: NumpadDeleteCell.reusableIdentifier)
        return collectionView
    }()
    
    weak var delegate: NumpadViewDelegate?
    
    override init(frame: CGRect) {
        numpadViewLayoutBuilder = NumpadViewLayoutBuilder()
        numpadViewDataSource = NumpadViewDataSource()
        
        super.init(frame: frame)
    }
    
    // MARK: Configuration
    
    override func configureAppearance() {
        backgroundColor = SharedColors.warmWhite
        
        collectionView.backgroundColor = SharedColors.warmWhite
        collectionView.contentInset = UIEdgeInsets(
            top: 0.0,
            left: layout.current.horizontalInset,
            bottom: layout.current.bottomInset,
            right: layout.current.horizontalInset
        )
    }
    
    override func linkInteractors() {
        collectionView.delegate = numpadViewLayoutBuilder
        collectionView.dataSource = numpadViewDataSource
        
        numpadViewLayoutBuilder.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NumpadView: NumpadViewLayoutBuilderDelegate {
    
    func numpadViewLayoutBuilder(_ layoutBuilder: NumpadViewLayoutBuilder, didSelect value: NumpadValue) {
        delegate?.numpadView(self, didSelect: value)
    }
}
