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

    private(set) var items: [HDWalletItemViewModel] = []
    private var hdWallets: [HDWalletInfoViewModel] = []
    
    init(configuration: ViewControllerConfiguration) {
        parseHDWallets(configuration: configuration)
    }
    
    private func parseHDWallets(configuration: ViewControllerConfiguration) {
        let hdWalletsList = configuration.session?.authenticatedUser?.hdWallets ?? []
        hdWallets = hdWalletsList.sorted { $0.walletOrderNumber < $1.walletOrderNumber }

        Task {
            var newItems = [HDWalletItemViewModel]()
            for wallet in hdWallets {
                let viewModel = await makeHDWalletViewModel(name: wallet.walletName, walletID: wallet.walletId, configuration: configuration)
                newItems.append(viewModel)
            }
            items = newItems
            eventHandler?(.didFinishFastLookup)
        }
    }

    private func makeHDWalletViewModel(name: String, walletID: String, configuration: ViewControllerConfiguration) async -> HDWalletItemViewModel {

        let addresses = configuration.session?.authenticatedUser?.accounts(withWalletId: walletID).map(\.address) ?? []
        
        let accountsCount = configuration.session?.authenticatedUser?.addresses(forWalletId: walletID) ?? 0
        let currencyValues = await calculateCurrencyValues(addresses: addresses, configuration: configuration)

        return HDWalletItemViewModel(
            walletName: name,
            accountsCount: accountsCount,
            mainCurrency: currencyValues.main,
            secondaryCurrency: currencyValues.secondary,
            currencyFormatter: CurrencyFormatter(),
            currencyProvider: configuration.sharedDataController.currency
        )
    }

    private func calculateCurrencyValues(addresses: [String], configuration: ViewControllerConfiguration) async -> (main: Double, secondary: Double) {

        guard let api = configuration.api else { return (0.0, 0.0) }

        var mainCurrency = 0.0
        var secondaryCurrency = 0.0

        await withTaskGroup(of: AccountFastLookup?.self) { group in
            for address in addresses {
                group.addTask {
                    await configuration.hdWalletService.fastLookupAccount(address: address, api: api)
                }
            }

            for await lookupInfo in group {
                guard let lookupInfo, lookupInfo.accountExists else { continue }
                mainCurrency += Double(lookupInfo.algoValue) ?? 0.0
                secondaryCurrency += Double(lookupInfo.usdValue) ?? 0.0
            }
        }

        return (mainCurrency, secondaryCurrency)
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
