// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  PassphraseVerifyViewController.swift

import UIKit
import AVFoundation

final class PassphraseVerifyViewController: BaseScrollViewController {
    private lazy var passphraseVerifyView = PassphraseVerifyView()

    private lazy var layoutBuilder: PassphraseVerifyLayoutBuilder = {
        return PassphraseVerifyLayoutBuilder(dataSource: dataSource)
    }()

    private lazy var dataSource: PassphraseVerifyDataSource = {
        if let privateKey = session?.privateData(for: "temp") {
            return PassphraseVerifyDataSource(privateKey: privateKey)
        }
        fatalError("Private key should be set.")
    }()

    override func configureAppearance() {
        super.configureAppearance()
        setNavigationBarTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        passphraseVerifyView.setNextButtonEnabled(false)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        passphraseVerifyView.setDelegate(layoutBuilder)
        passphraseVerifyView.setDataSource(dataSource)
        passphraseVerifyView.delegate = self
        dataSource.delegate = self
    }

    override func setListeners() {
        passphraseVerifyView.setListeners()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        passphraseVerifyView.customize(PassphraseVerifyViewTheme())
        
        contentView.addSubview(passphraseVerifyView)
        passphraseVerifyView.pinToSuperview()
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyDataSourceDelegate {
    func passphraseVerifyDataSource(_ passphraseVerifyDataSource: PassphraseVerifyDataSource, isValidated: Bool) {
        passphraseVerifyView.setNextButtonEnabled(isValidated)

        if !isValidated {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "passphrase-verify-wrong-message".localized
            )
            dataSource.resetVerificationData()
            passphraseVerifyView.resetSelectionStatesAndReloadData()
        }
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyViewDelegate {
    func passphraseVerifyViewDidVerifyPassphrase(_ passphraseVerifyView: PassphraseVerifyView) {
        openValidatedBottomInformation()
    }

    private func openValidatedBottomInformation() {
        open(
            .tutorial(flow: .none, tutorial: .passphraseVerified, isActionable: false),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        )
    }
}
