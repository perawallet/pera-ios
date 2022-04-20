// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CurrencySelectionAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class CurrencySelectionAPIDataController: CurrencySelectionDataController {
    var eventHandler: ((CurrencySelectionDataControllerEvent) -> Void)?
    
    private var currencies = [Currency]()
    private var searchResults = [Currency]()
    
    private var lastSnapshot: Snapshot?
    
    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)
    
    private let api: ALGAPI
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.CurrencySelectionDataController")
    
    init(
        _ api: ALGAPI
    ) {
        self.api = api
    }
}

extension CurrencySelectionAPIDataController {
    func load() {
        currencies.removeAll()
        searchResults.removeAll()
        
        api.getCurrencies { response in
            switch response {
            case let .success(currencyList):
                self.currencies.append(contentsOf: currencyList.items)
                self.searchResults = self.currencies
                self.deliverContentSnapshot()
            case .failure:
                self.deliverEmptyContentSnapshot()
            }
        }
    }
        
    func search(for query: String) {
        searchThrottler.performNext {
            [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.searchResults = self.currencies.filter { currency in
                self.isCurrencyContainsID(currency, query: query) ||
                self.isCurrencyContainsName(currency, query: query)
            }
            
            self.deliverContentSnapshot()
        }
    }
    
    private func isCurrencyContainsID(_ currency: Currency, query: String) -> Bool {
        return currency.id.localizedCaseInsensitiveContains(query)
    }
    
    private func isCurrencyContainsName(_ currency: Currency, query: String) -> Bool {
        return currency.name.someString.localizedCaseInsensitiveContains(query)
    }
    
    func resetSearch() {
        searchResults.removeAll()
        searchResults = currencies
        deliverContentSnapshot()
    }
}

extension CurrencySelectionAPIDataController {
    private func deliverContentSnapshot() {
        guard !self.currencies.isEmpty else {
            deliverNoContentSnapshot()
            return
        }
        
        guard !self.searchResults.isEmpty else {
            deliverEmptyContentSnapshot()
            return
        }
        
        deliverSnapshot {
            [weak self] in
            
            guard let self = self else {
                return Snapshot()
            }
            
            var snapshot = Snapshot()
            
            var currencyItems: [CurrencySelectionItem] = []
            
            self.searchResults.forEach { currency in
                let viewModel: SingleSelectionViewModel
                let isSelected = self.api.session.preferredCurrency == currency.id
                viewModel = SingleSelectionViewModel(
                    title: currency.id,
                    isSelected: isSelected
                )
                
                currencyItems.append(.currency(viewModel))
            }
            
            snapshot.appendSections([.currencies])
            snapshot.appendItems(
                currencyItems,
                toSection: .currencies
            )
            
            snapshot.reloadItems(currencyItems)
            return snapshot
        }
    }
    
    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.noContent])
            snapshot.appendItems(
                [.noContent],
                toSection: .noContent
            )
            return snapshot
        }
    }
    
    private func deliverEmptyContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty],
                toSection: .empty
            )
            return snapshot
        }
    }
    
    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            
            guard let self = self else {
                return
            }
            
            let newSnapshot = snapshot()
            
            self.lastSnapshot = newSnapshot
            self.publish(.didUpdate(newSnapshot))
        }
    }
}

extension CurrencySelectionAPIDataController {
    private func publish(
        _ event: CurrencySelectionDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.eventHandler?(event)
        }
    }
}
