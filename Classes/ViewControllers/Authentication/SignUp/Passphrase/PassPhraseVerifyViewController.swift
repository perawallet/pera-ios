//
//  PassphraseVerifyViewController.swift

import UIKit

class PassphraseVerifyViewController: BaseScrollViewController {
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 358.0))
    )
    
    private lazy var layoutBuilder: PassphraseVerifyLayoutBuilder = {
        return PassphraseVerifyLayoutBuilder(dataSource: dataSource)
    }()

    private lazy var dataSource: PassphraseVerifyDataSource = {
        if let privateKey = session?.privateData(for: "temp") {
            return PassphraseVerifyDataSource(privateKey: privateKey)
        }
        fatalError("Private key should be set.")
    }()
    
    private lazy var passphraseVerifyView = PassphraseVerifyView()
    
    override func configureAppearance() {
        super.configureAppearance()
        setTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        passphraseVerifyView.setVerificationEnabled(false)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        passphraseVerifyView.setDelegate(layoutBuilder)
        passphraseVerifyView.setDataSource(dataSource)
        passphraseVerifyView.delegate = self
        dataSource.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupPassphraseViewLayout()
    }
}

extension PassphraseVerifyViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passphraseVerifyView)
        passphraseVerifyView.pinToSuperview()
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyDataSourceDelegate {
    func passphraseVerifyDataSource(_ passphraseVerifyDataSource: PassphraseVerifyDataSource, isValidated: Bool) {
        passphraseVerifyView.setVerificationEnabled(isValidated)
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyViewDelegate {
    func passphraseVerifyViewDidVerifyPassphrase(_ passphraseVerifyView: PassphraseVerifyView) {
        openValidatedBottomInformation()
    }

    private func openValidatedBottomInformation() {
        let configurator = BottomInformationBundle(
            title: "pass-phrase-verify-pop-up-title".localized,
            image: img("img-green-checkmark"),
            explanation: "pass-phrase-verify-pop-up-explanation".localized,
            actionTitle: "title-accept".localized,
            actionImage: img("bg-main-button")) {
                self.open(.accountNameSetup, by: .push)
        }

        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
}
