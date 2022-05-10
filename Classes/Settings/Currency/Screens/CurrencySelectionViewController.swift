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

//
//  CurrencySelectionViewController.swift

import UIKit

final class CurrencySelectionViewController: BaseViewController {
    static var didChangePreferredCurrency: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.preferredCurrency.didChange")
    }
    
    private lazy var theme = Theme()
    private lazy var contextView = CurrencySelectionView()
    
    private lazy var listLayout = CurrencySelectionListLayout(dataSource)
    private lazy var dataSource = CurrencySelectionListDataSource(contextView.collectionView)
    private lazy var dataController: CurrencySelectionListAPIDataController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return CurrencySelectionListAPIDataController(api)
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController.eventHandler = {
            [weak self] event in
            
            guard let self = self else {
                return
            }
            
            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        
        dataController.load()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "settings-currency".localized
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func setListeners() {
        contextView.setDataSource(dataSource)
        contextView.setCollectionViewDelegate(listLayout)
        contextView.setSearchInputDelegate(self)
        setListLayoutListeners()
    }
    
    private func setListLayoutListeners() {
        listLayout.handlers.didTapReload = {
            [weak self] cell in
            
            let noContentCell = cell as! NoContentWithActionCell
            noContentCell.observe(event: .performPrimaryAction) {
                [weak self] in
                guard let self = self else {
                    return
                }
                
                self.dataController.load()
            }
        }
        listLayout.handlers.didSelectCurrency = {
            [weak self] indexPath in
            guard let self = self,
                  let selectedCurrency = self.dataController[indexPath.item] else {
                      return
                  }
            
            self.log(CurrencyChangeEvent(currencyId: selectedCurrency.id))
            
            self.sharedDataController.stopPolling()
            
            self.api?.session.preferredCurrency = selectedCurrency.id
            self.dataController.load()
            
            self.sharedDataController.resetPollingAfterPreferredCurrencyWasChanged()
            
            NotificationCenter.default.post(
                name: Self.didChangePreferredCurrency,
                object: self
            )
            
            
        }
    }
    
    override func prepareLayout() {
        contextView.customize(theme.contextViewTheme)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension CurrencySelectionViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }
        
        if query.isEmpty {
            dataController.resetSearch()
            return
        }
        
        dataController.search(for: query)
    }
    
    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
    
    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        dataController.resetSearch()
    }
}
