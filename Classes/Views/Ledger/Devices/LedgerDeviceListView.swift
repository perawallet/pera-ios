//
//  LedgerDeviceListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerDeviceListView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerDeviceListViewDelegate?
    
    private(set) lazy var devicesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 7.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.warmWhite
        collectionView.contentInset = layout.current.listContentInset
        collectionView.register(LedgerDeviceCell.self, forCellWithReuseIdentifier: LedgerDeviceCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var troubleshootButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-purple-light"))
            .withTitle("ledger-device-list-troubleshoot".localized)
            .withTitleColor(SharedColors.purple)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
    }()

    override func setListeners() {
        troubleshootButton.addTarget(self, action: #selector(notifyDelegateToOpenTrobuleshooting), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTroubleshootButtonLayout()
        setupDevicesCollectionViewLayout()
    }
}

extension LedgerDeviceListView {
    @objc
    func notifyDelegateToOpenTrobuleshooting() {
        delegate?.ledgerDeviceListViewDidTapTroubleshootButton(self)
    }
}

extension LedgerDeviceListView {
    private func setupTroubleshootButtonLayout() {
        addSubview(troubleshootButton)
        
        troubleshootButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    private func setupDevicesCollectionViewLayout() {
        addSubview(devicesCollectionView)
        
        devicesCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(troubleshootButton.snp.top).offset(layout.current.listBottomInset)
        }
    }
}

extension LedgerDeviceListView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonBottomInset: CGFloat = 60.0
        let listContentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        let listBottomInset: CGFloat = -30.0
    }
}

protocol LedgerDeviceListViewDelegate: class {
    func ledgerDeviceListViewDidTapTroubleshootButton(_ ledgerDeviceListView: LedgerDeviceListView)
}
