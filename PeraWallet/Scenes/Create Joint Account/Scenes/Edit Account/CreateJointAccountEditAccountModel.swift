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
    
    @Published var name: String
    @Published fileprivate(set) var updatedModel: AddedAccountData?
    @Published fileprivate(set) var errorMessage: ErrorMessage?
    @Published private(set) var image: ImageType
    @Published private(set) var address: String
    
    fileprivate init(name: String, image: ImageType, address: String) {
        self.name = name
        self.image = image
        self.address = address
    }
}

protocol CreateJointAccountEditAccountModelable {
    var viewModel: CreateJointAccountEditAccountViewModel { get }
    func updateContact()
}

final class CreateJointAccountEditAccountModel: CreateJointAccountEditAccountModelable {
    
    // MARK: - Properties - CreateJointAccountEditAccountModelable
    
    let viewModel: CreateJointAccountEditAccountViewModel
    
    // MARK: - Initialisers
    
    init(name: String, image: ImageType, address: String) {
        viewModel = CreateJointAccountEditAccountViewModel(name: name, image: image, address: address)
    }
    
    // MARK: - Actions - CreateJointAccountEditAccountModelable
    
    func updateContact() {
        do {
            try updateExistingContact()
        } catch .contactNotFound {
            createContact()
        } catch {
            viewModel.errorMessage = .unableToCreateContact
        }
    }
    
    // MARK: - Actions
    
    private func updateExistingContact() throws(ContactsManager.ContactsManagerError) {
        _ = try ContactsManager.updateContact(name: viewModel.name, address: viewModel.address)
        updateModel()
    }
    
    private func createContact() {
        do {
            _ = try ContactsManager.createContact(name: viewModel.name, address: viewModel.address)
            updateModel()
        } catch {
            viewModel.errorMessage = .unableToCreateContact
        }
    }
    
    private func updateModel() {
        let title = !viewModel.name.isEmpty ? viewModel.name : viewModel.address.shortAddressDisplay
        let subtitle = !viewModel.name.isEmpty ? viewModel.address.shortAddressDisplay : nil
        viewModel.updatedModel = AddedAccountData(address: viewModel.address, image: .placeholderUserIconData, title: title, subtitle: subtitle, isEditable: true, isUserAccount: false)
    }
}
