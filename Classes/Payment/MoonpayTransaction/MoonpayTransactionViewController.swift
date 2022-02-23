// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MoonpayTransactionViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit

final class MoonpayTransactionViewController: BaseViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var moonpayTransactionView = MoonpayTransactionView()
    
    override func prepareLayout() {
        super.prepareLayout()
        view.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
        addMoonpayTransactionProcessView()
    }
}

extension MoonpayTransactionViewController {
    private func addMoonpayTransactionProcessView() {
        view.addSubview(moonpayTransactionView)
        moonpayTransactionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension MoonpayTransactionViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}
