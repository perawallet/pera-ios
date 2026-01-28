// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MockCurrencyProvider.swift

@testable import pera_staging
@testable import pera_wallet_core

final class MockCurrencyProvider: CurrencyProvider {
    var primaryValue: pera_wallet_core.RemoteCurrencyValue?
    var secondaryValue: pera_wallet_core.RemoteCurrencyValue?
    
    var isExpired: Bool = false
    
    func refresh(on queue: DispatchQueue) {}
    
    func setAsPrimaryCurrency(_ currencyID: pera_wallet_core.CurrencyID) {}
    
    func addObserver(using handler: @escaping EventHandler) -> UUID { UUID() }
    
    func removeObserver(_ observer: UUID) {}
    
    init(
        fiatValue: RemoteCurrencyValue? = nil,
        algoValue: RemoteCurrencyValue? = nil
    ) {
        self.primaryValue = fiatValue
        self.secondaryValue = algoValue
    }
}
