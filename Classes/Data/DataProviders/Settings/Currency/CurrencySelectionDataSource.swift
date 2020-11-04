//
//  CurrencySelectionDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import Magpie

class CurrencySelectionDataSource: NSObject {
    
    private let api: AlgorandAPI
    private var currencies = [Currency]()
    
    weak var delegate: CurrencySelectionDataSourceDelegate?

    init(api: AlgorandAPI) {
        self.api = api
        super.init()
    }
}

extension CurrencySelectionDataSource {
    func loadData(withRefresh refresh: Bool = true) {
        api.getCurrencies { response in
            if refresh {
                self.currencies.removeAll()
            }
            
            switch response {
            case let .success(currencies):
                self.currencies = currencies
                self.delegate?.currencySelectionDataSourceDidFetchCurrencies(self)
            case .failure:
                self.delegate?.currencySelectionDataSourceDidFailToFetch(self)
            }
        }
    }
}

extension CurrencySelectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let currency = currencies[safe: indexPath.item],
           let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SingleSelectionCell.reusableIdentifier,
                for: indexPath
            ) as? SingleSelectionCell {
                let isSelected = api.session.preferredCurrency == currency.id
                cell.contextView.bind(SingleSelectionViewModel(title: currency.name, isSelected: isSelected))
                return cell
        }
    
        fatalError("Index path is out of bounds")
    }
}

extension CurrencySelectionDataSource {
    var isEmpty: Bool {
        return currencies.isEmpty
    }
    
    func currency(at index: Int) -> Currency? {
        return currencies[safe: index]
    }
}

protocol CurrencySelectionDataSourceDelegate: class {
    func currencySelectionDataSourceDidFetchCurrencies(_ currencySelectionDataSource: CurrencySelectionDataSource)
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource)
}
