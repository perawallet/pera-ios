// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   HDWalletSetupDataController.swift

import UIKit

final class HDWalletSetupDataController {
    var eventHandler: ((Event) -> Void)?

    var items: [HDWalletItemViewModel] = []
    private var hdWallets: [HDWalletInfoViewModel] = []
    
    init(configuration: ViewControllerConfiguration) {
        parseHDWallets(configuration: configuration)
    }
    
    private func parseHDWallets(configuration: ViewControllerConfiguration) {
        if let hdWalletsList = configuration.session?.authenticatedUser?.hdWallets {
            hdWallets = hdWalletsList.sorted {
                return $0.walletOrderNumber < $1.walletOrderNumber
            }
            
            Task { @MainActor in
                for hdWallet in hdWallets {
                    
                    var mainCurrency = 0.0
                    var secondaryCurrency = 0.0
                    let addressesForHDWallet = configuration.session?.authenticatedUser?.accounts(withWalletId: hdWallet.walletId).map { $0.address } ?? []
                    
                    guard let api = configuration.api else {
                        items.append(HDWalletItemViewModel(
                            walletName: hdWallet.walletName,
                            accountsCount: configuration.session?.authenticatedUser?.addresses(forWalletId: hdWallet.walletId) ?? 0,
                            mainCurrency: mainCurrency,
                            secondaryCurrency: secondaryCurrency,
                            currencyFormatter: CurrencyFormatter(),
                            currencyProvider: configuration.sharedDataController.currency
                        ))
                        continue
                    }

                    await withTaskGroup(of: AccountFastLookup?.self) { group in
                        for address in addressesForHDWallet {
                            group.addTask {
                                await configuration.hdWalletService.fastLookupAccount(address: address, api: api)
                            }
                        }

                        for await lookupInfo in group {
                            if let lookupInfo, lookupInfo.accountExists {
                                mainCurrency += Double(lookupInfo.algoValue) ?? 0
                                secondaryCurrency += Double(lookupInfo.usdValue) ?? 0
                            }
                        }
                    }
                    
                    items.append(HDWalletItemViewModel(
                        walletName: hdWallet.walletName,
                        accountsCount: configuration.session?.authenticatedUser?.addresses(forWalletId: hdWallet.walletId) ?? 0,
                        mainCurrency: mainCurrency,
                        secondaryCurrency: secondaryCurrency,
                        currencyFormatter: CurrencyFormatter(),
                        currencyProvider: configuration.sharedDataController.currency
                    ))
                }
                eventHandler?(.didFinishFastLookup)
            }
        } else {
            hdWallets = []
            eventHandler?(.didFinishFastLookup)
        }
    }
}

extension HDWalletSetupDataController {    
    func itemInfo(at index: Int) -> HDWalletInfoViewModel {
        hdWallets[index]
    }
}

extension HDWalletSetupDataController {
    enum Event {
        case didFinishFastLookup
    }
}
