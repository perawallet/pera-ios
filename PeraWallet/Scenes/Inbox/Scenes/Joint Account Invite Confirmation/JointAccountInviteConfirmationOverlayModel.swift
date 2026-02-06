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

//   JointAccountInviteConfirmationOverlayModel.swift

import Combine

protocol JointAccountInviteConfirmationOverlayModelable {
    var viewModel: JointAccountInviteConfirmationOverlayViewModel { get }
}

final class JointAccountInviteConfirmationOverlayViewModel: ObservableObject {
    
    struct AccountModel: Identifiable {
        let id: String
        let image: ImageType
        let title: String
        let subtitle: String?
    }
    
    @Published fileprivate(set) var subtitle: String = ""
    @Published fileprivate(set) var addressCount: Int = 0
    @Published fileprivate(set) var threshold: Int = 0
    @Published fileprivate(set) var accountModels: [AccountModel] = []
}

final class JointAccountInviteConfirmationOverlayModel: JointAccountInviteConfirmationOverlayModelable {
    
    // MARK: - Properties - JointAccountInviteConfirmationOverlayModelable
    
    var viewModel: JointAccountInviteConfirmationOverlayViewModel = JointAccountInviteConfirmationOverlayViewModel()
    
    // MARK: - Initializers
    
    init(subtitle: String, threshold: Int, accountModels: [JointAccountInviteConfirmationOverlayViewModel.AccountModel]) {
        viewModel.subtitle = subtitle
        viewModel.addressCount = accountModels.count
        viewModel.threshold = threshold
        viewModel.accountModels = accountModels
    }
}
