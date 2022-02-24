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
    
    private lazy var dataController =  MoonpayTransactionDataController(
        sharedDataController: sharedDataController,
        accountAddress: moonpayParams.address
    )
    private let moonpayParams: MoonpayParams
    
    init(moonpayParams: MoonpayParams, configuration: ViewControllerConfiguration) {
        self.moonpayParams = moonpayParams
        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        dataController.delegate = self
        moonpayTransactionView.doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        view.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
        addMoonpayTransactionProcessView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.loadData()
    }
}

extension MoonpayTransactionViewController {
    private func addMoonpayTransactionProcessView() {
        moonpayTransactionView.customize(MoonpayTransactionViewTheme())
        
        view.addSubview(moonpayTransactionView)
        moonpayTransactionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc
    private func didTapDone() {
        dismissScreen()
    }
}

extension MoonpayTransactionViewController: MoonpayTransactionDataControllerDelegate {
    func moonpayTransactionDataControllerDidLoad(
        _ dataController: MoonpayTransactionDataController,
        account: Account
    ) {
        moonpayTransactionView.bindData(
            MoonpayTransactionViewModel(
                status: moonpayParams.transactionStatus,
                account: account
            )
        )
    }
}

extension MoonpayTransactionViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}
