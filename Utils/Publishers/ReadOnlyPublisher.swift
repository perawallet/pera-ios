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

//   ReadOnlyPublisher.swift

import Combine

final class ReadOnlyPublisher<Output> {
    
    // MARK: - Properties
    
    var value: Output { currentValuePublisher.value }
    var publisher: AnyPublisher<Output, Never> { currentValuePublisher.eraseToAnyPublisher() }
    
    private let currentValuePublisher: CurrentValueSubject<Output, Never>
    
    // MARK: - Initialisers
    
    init(currentValuePublisher: CurrentValueSubject<Output, Never>) {
        self.currentValuePublisher = currentValuePublisher
    }
}
