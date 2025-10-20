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

//   CreateJointAccountEditAccountModel.swift

import Combine

final class CreateJointAccountEditAccountViewModel: ObservableObject {
    
    enum ErrorMessage: Error {
        case unableToCreateContact
    }
    
    @Published var name: String = ""
    @Published fileprivate(set) var updatedModel: AddedAccountData?
    @Published fileprivate(set) var errorMessage: ErrorMessage?
    @Published private(set) var image: ImageType
    @Published private(set) var address: String
    
    fileprivate init(image: ImageType, address: String) {
        self.image = image
        self.address = address
    }
}

protocol CreateJointAccountEditAccountModelable {
    var viewModel: CreateJointAccountEditAccountViewModel { get }
    func createContact()
}

final class CreateJointAccountEditAccountModel: CreateJointAccountEditAccountModelable {
    
    // MARK: - Properties - CreateJointAccountEditAccountModelable
    
    let viewModel: CreateJointAccountEditAccountViewModel
    
    // MARK: - Initialisers
    
    init(image: ImageType, address: String) {
        viewModel = CreateJointAccountEditAccountViewModel(image: image, address: address)
    }
    
    // MARK: - Actions - CreateJointAccountEditAccountModelable
    
    func createContact() {
        do {
            let _ = try ContactsManager.createContact(name: viewModel.name, address: viewModel.address)
            let title = !viewModel.name.isEmpty ? viewModel.name : viewModel.address.shortAddressDisplay
            let subtitle = !viewModel.name.isEmpty ? viewModel.address.shortAddressDisplay : nil
            viewModel.updatedModel = AddedAccountData(address: viewModel.address, image: .placeholderIconData, title: title, subtitle: subtitle, isStoredLocally: false)
        } catch {
            viewModel.errorMessage = .unableToCreateContact
        }
    }
}
