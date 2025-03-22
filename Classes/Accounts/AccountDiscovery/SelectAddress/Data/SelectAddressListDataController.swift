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

//   SelectAddressListDataController.swift

import Foundation
import OrderedCollections

struct RecoveredAddress {
    let address: String
    let accountIndex: UInt32
    let addressIndex: UInt32
    let mainCurrency: Double
    let secondaryCurrency: Double
    let alreadyImported: Bool
}

final class SelectAddressListDataController {
    typealias Index = Int

    private let addressesDictonary: OrderedDictionary<Index, RecoveredAddress>
    private lazy var selectedAddressesDictonary: OrderedDictionary<Index, RecoveredAddress> = [:]
    
    init(recoveredAddresses: [RecoveredAddress]) {
        self.addressesDictonary = OrderedDictionary(uniqueKeysWithValues: recoveredAddresses.enumerated().map{ ($0.offset, $0.element) })
    }
}

extension SelectAddressListDataController {
    func isAddressSelected(at index: Index) -> Bool {
        return selectedAddressesDictonary[index] != nil
    }

    var isFinishActionEnabled: Bool {
        return !selectedAddressesDictonary.isEmpty
    }
    
    func getAddress(at index: Index) -> RecoveredAddress? {
        return addressesDictonary[index]
    }
    
    var addresses: [RecoveredAddress] {
        return addressesDictonary.values.elements
    }

    var selectedAddresses: [RecoveredAddress] {
        return selectedAddressesDictonary.values.elements
    }
    
    var isAllAddressesSelected: Bool {
        return addressesDictonary.count == selectedAddressesDictonary.count
    }
}

extension SelectAddressListDataController {
    var headerItemState: SelectAddressListHeaderItemState {
        if selectedAddressesDictonary.isEmpty {
            return .selectAll
        }

        if addressesDictonary.values.count == selectedAddressesDictonary.values.count {
            return .unselectAll
        }

        return .partialSelection
    }
    
    var headerTitle: String {
        addressesDictonary.count == 1 ? "address-count".localized : "address-count-plural".localized(params: addressesDictonary.count)
    }
    
    var descriptionText: String {
        addressesDictonary.count == 1 ? "select-address-description".localized : "select-address-description-plural".localized(params: addressesDictonary.count)
    }
}

extension SelectAddressListDataController {
    func updateSelectionWithItem(at index: Index) {
        if isAddressSelected(at: index) {
            unselectAddressItem(at: index)
        } else {
            selectAddressItem(at: index)
        }
    }
    
    func selectAddressItem(at index: Index) {
        guard
            let selectedAddress = addressesDictonary[index],
            !selectedAddress.alreadyImported
        else {
            return
        }

        selectedAddressesDictonary[index] = selectedAddress
    }

    func unselectAddressItem(at index: Index ) {
        selectedAddressesDictonary[index] = nil
    }

    func selectAllAddressItems() {
        selectedAddressesDictonary = addressesDictonary.filter { $0.value.alreadyImported == false}
    }

    func unselectAllAddressItems() {
        selectedAddressesDictonary = [:]
    }
}
