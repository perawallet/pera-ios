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
    
    private let api: API
    private var currencies = [String]()
    private var lastRequest: EndpointOperatable?
    
    private let paginationRequestThreshold = 3
    private var paginationCursor: String?
    var hasNext: Bool {
        return paginationCursor != nil
    }
    
    weak var delegate: CurrencySelectionDataSourceDelegate?

    init(api: API) {
        self.api = api
        super.init()
    }
}

extension CurrencySelectionDataSource {
    func loadData(withRefresh refresh: Bool = true, isPaginated: Bool = false) {
        
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
                cell.contextView.bind(SingleSelectionViewModel())
                return cell
        }
    
        fatalError("Index path is out of bounds")
    }
}

extension CurrencySelectionDataSource {
    var isEmpty: Bool {
        return currencies.isEmpty
    }
    
    func currency(at index: Int) -> String? {
        return currencies[safe: index]
    }
    
    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        return index == currencies.count - paginationRequestThreshold && hasNext
    }
    
    func clear() {
        lastRequest?.cancel()
        lastRequest = nil
        currencies.removeAll()
        paginationCursor = nil
    }
}

protocol CurrencySelectionDataSourceDelegate: class {
    func currencySelectionDataSourceDidFetchCurrencies(_ currencySelectionDataSource: CurrencySelectionDataSource)
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource)
}
