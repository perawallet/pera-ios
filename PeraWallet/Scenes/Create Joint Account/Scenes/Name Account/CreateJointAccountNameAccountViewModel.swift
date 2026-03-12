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

//   CreateJointAccountNameAccountViewModel.swift

import Combine

@MainActor
protocol CreateJointAccountNameAccountViewModelWritable {
    func update(isValidName: Bool)
    func update(isWaitingForResponse: Bool)
    func update(action: CreateJointAccountNameAccountViewModel.Action?)
    func update(error: CreateJointAccountNameAccountViewModel.ErrorMessage?)
}

@MainActor
final class CreateJointAccountNameAccountViewModel: ObservableObject, CreateJointAccountNameAccountViewModelWritable {
    
    enum Action {
        case success
    }
    
    enum ErrorMessage: Error {
        case unableToCreateJointAccount(CoreApiManager.ApiError)
        case unabletoAcceptTransaction
    }
    
    @Published var name: String = ""
    @Published private(set) var isValidName: Bool = false
    @Published private(set) var isWaitingForResponse: Bool = false
    @Published private(set) var action: Action?
    @Published private(set) var error: ErrorMessage?

    // MARK: - Actions - CreateJointAccountNameAccountViewModelWritable
    
    func update(isValidName: Bool) {
        self.isValidName = isValidName
    }

    func update(isWaitingForResponse: Bool) {
        self.isWaitingForResponse = isWaitingForResponse
    }

    func update(action: Action?) {
        self.action = action
    }

    func update(error: ErrorMessage?) {
        self.error = error
    }
}
