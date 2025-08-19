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

//   RekeySupportHandler.swift

enum RekeySupportHandler {
    
    // MARK: - Actions
    
    static func handle(walletConnectTransaction: WCTransaction, presenter: BaseViewController, onConfirm: @escaping () -> Void) {
        
        guard walletConnectTransaction.transactionDetail?.isRekeyTransaction == true else {
            onConfirm()
            return
        }
        
        guard PeraUserDefaults.isRekeySupported == true else {
            showBlockedTransactionOverlay(presenter: presenter)
            return
        }
        
        showWarningOverlay(presenter: presenter, onConfirm: onConfirm)
    }
    
    // MARK: - Navigation
    
    private static func showBlockedTransactionOverlay(presenter: BaseViewController) {
        showOverlay(presenter: presenter, variant: .accessBlocked) { [weak presenter] in
            _ = presenter?.open(.securitySettings, by: .present)
        }
    }
    
    private static func showWarningOverlay(presenter: BaseViewController, onConfirm: @escaping () -> Void) {
        showOverlay(presenter: presenter, variant: .warning, onPrimaryAction: onConfirm)
    }
    
    private static func showOverlay(presenter: BaseViewController, variant: RekeySupportOverlayView.Variant, onPrimaryAction: @escaping () -> Void) {
        let transitionToBottomSheet = BottomSheetTransition(presentingViewController: presenter)
        transitionToBottomSheet.perform(.rekeyTransactionOverlay(variant: variant, onPrimaryAction: onPrimaryAction), by: .presentWithoutNavigationController)
    }
}
