// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountServiceMock.swift

@testable import pera_staging
import Combine

final class AccountServiceMock: AccountsServiceable {
    
    // MARK: - AccountsServiceable
    
    var accounts: ReadOnlyPublisher<[PeraAccount]> { accountsPublisher.readOnlyPublisher() }
    var error: AnyPublisher<AccountsService.ServiceError, Never> { errorPublisher.eraseToAnyPublisher() }
    var network: CoreApiManager.BaseURL.Network = .testNet
    
    // MARK: - Properties
    
    var accountsPublisher = CurrentValueSubject<[PeraAccount], Never>([])
    var errorPublisher = PassthroughSubject<AccountsService.ServiceError, Never>()
}
