//
//  TransactionFilterViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionFilterViewController: BaseViewController {
    
    weak var delegate: TransactionFilterViewControllerDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var transactionFilterView = TransactionFilterView()
    
    private let viewModel = TransactionFilterViewModel()
    private var selectedOption: FilterOption
    private var filterOptions: [FilterOption] = [.allTime, .today, .yesterday, .lastWeek, .lastMonth, .customRange(from: nil, to: nil)]
    
    init(filterOption: FilterOption, configuration: ViewControllerConfiguration) {
        self.selectedOption = filterOption
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
        title = "transaction-filter-title-sort".localized
    }
    
    override func linkInteractors() {
        transactionFilterView.delegate = self
        transactionFilterView.filterOptionsCollectionView.delegate = self
        transactionFilterView.filterOptionsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupTransactionFilterViewLayout()
    }
}

extension TransactionFilterViewController {
    private func setupTransactionFilterViewLayout() {
        view.addSubview(transactionFilterView)
        
        transactionFilterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionFilterViewController: TransactionFilterViewDelegate {
    func transactionFilterViewDidDismissView(_ transactionFilterView: TransactionFilterView) {
        delegate?.transactionFilterViewController(self, didSelect: selectedOption)
        dismissScreen()
    }
}

extension TransactionFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TransactionFilterOptionCell.reusableIdentifier,
            for: indexPath
        ) as? TransactionFilterOptionCell else {
            fatalError("Index path is out of bounds")
        }
        
        let filterOption = filterOptions[indexPath.item]
        viewModel.configure(cell, with: filterOption, isSelected: filterOption == selectedOption)
        return cell
    }
}

extension TransactionFilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilterOption = filterOptions[indexPath.item]
        
        switch selectedFilterOption {
        case let .customRange(from, to):
            break
        default:
            self.selectedOption = selectedFilterOption
            delegate?.transactionFilterViewController(self, didSelect: selectedOption)
            dismissScreen()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }
}

extension TransactionFilterViewController {
    enum FilterOption: Equatable {
        case allTime
        case today
        case yesterday
        case lastWeek
        case lastMonth
        case customRange(from: Date?, to: Date?)
    }
}

extension TransactionFilterViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: 52.0)
    }
}

protocol TransactionFilterViewControllerDelegate: class {
    func transactionFilterViewController(
        _ transactionFilterViewController: TransactionFilterViewController,
        didSelect filterOption: TransactionFilterViewController.FilterOption
    )
}
