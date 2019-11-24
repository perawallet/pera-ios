//
//  AssetAdditionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetAdditionViewControllerDelegate: class {
    func assetAdditionViewController(_ assetAdditionViewController: AssetAdditionViewController, didAdd assetDetail: AssetDetail)
}

class AssetAdditionViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetAdditionViewControllerDelegate?
    
    private var account: Account
    private var assetResults = [AssetDetail]()
    private lazy var assetAdditionView = AssetAdditionView()
    
    private let viewModel = AssetAdditionViewModel()
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func setListeners() {
        assetAdditionView.assetInputView.delegate = self
        assetAdditionView.assetsCollectionView.delegate = self
        assetAdditionView.assetsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupAssetAdditionViewLayout()
    }
}

extension AssetAdditionViewController {
    private func setupAssetAdditionViewLayout() {
        view.addSubview(assetAdditionView)
        
        assetAdditionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetAdditionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetSelectionCell.reusableIdentifier,
            for: indexPath) as? AssetSelectionCell else {
                fatalError("Index path is out of bounds")
        }
        
        let assetDetail = assetResults[indexPath.item]
        viewModel.configure(cell, with: assetDetail)
        
        return cell
    }
}

extension AssetAdditionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetDetail = assetResults[indexPath.item]
        
        let controller = open(
            .assetActionConfirmation(assetDetail: assetDetail),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            )
        ) as? AssetActionConfirmationViewController
        
        controller?.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: layout.current.cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: layout.current.topInset, left: 0.0, bottom: 0.0, right: 0.0)
    }
}

extension AssetAdditionViewController: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        
    }
}

extension AssetAdditionViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        delegate?.assetAdditionViewController(self, didAdd: assetDetail)
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 50.0
        let topInset: CGFloat = 2.0
    }
}
