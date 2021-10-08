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
//  LedgerAccountDetailView.swift

import UIKit
import Macaroon

final class LedgerAccountDetailView: View {
    private lazy var ledgerAccountTitleLabel = UILabel()
    private lazy var ledgerAccountInfo = AccountPreviewView()
    private lazy var assetTitleLabel = UILabel()
    private lazy var assetStackView = UIStackView()
    private lazy var signedByTitleLabel = UILabel()
    private lazy var rekeyedAccountsStackView = UIStackView()

    func customize(_ theme: LedgerAccountDetailViewTheme) {
        addTitleLabel(theme)
        addLedgerAccountInfo(theme)
        addAssetTitleLabel(theme)
        addAssetStackView(theme)
        addSignedByTitleLabel(theme)
        addRekeyedAccountsStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension LedgerAccountDetailView {
    private func addTitleLabel(_ theme: LedgerAccountDetailViewTheme) {
        ledgerAccountTitleLabel.customizeAppearance(theme.ledgerAccountTitle)

        addSubview(ledgerAccountTitleLabel)
        ledgerAccountTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addLedgerAccountInfo(_ theme: LedgerAccountDetailViewTheme) {
        addSubview(ledgerAccountInfo)
        ledgerAccountInfo.customize(AccountPreviewViewTheme())

        ledgerAccountInfo.snp.makeConstraints {
            $0.top.equalTo(ledgerAccountTitleLabel.snp.bottom).offset(theme.stackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAssetTitleLabel(_ theme: LedgerAccountDetailViewTheme) {
        assetTitleLabel.customizeAppearance(theme.assetsTitle)

        addSubview(assetTitleLabel)
        assetTitleLabel.snp.makeConstraints {
            $0.top.equalTo(ledgerAccountInfo.snp.bottom).offset(theme.titleTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addAssetStackView(_ theme: LedgerAccountDetailViewTheme) {
        assetStackView.distribution = .fillProportionally
        assetStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        assetStackView.axis = .vertical

        addSubview(assetStackView)
        assetStackView.snp.makeConstraints {
            $0.top.equalTo(assetTitleLabel.snp.bottom).offset(theme.stackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addSignedByTitleLabel(_ theme: LedgerAccountDetailViewTheme) {
        signedByTitleLabel.customizeAppearance(theme.signedByTitle)

        addSubview(signedByTitleLabel)
        signedByTitleLabel.snp.makeConstraints {
            $0.top.equalTo(assetStackView.snp.bottom).offset(theme.titleTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addRekeyedAccountsStackView(_ theme: LedgerAccountDetailViewTheme) {
        rekeyedAccountsStackView.distribution = .fillProportionally
        rekeyedAccountsStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rekeyedAccountsStackView.axis = .vertical

        addSubview(rekeyedAccountsStackView)
        rekeyedAccountsStackView.snp.makeConstraints {
            $0.top.equalTo(signedByTitleLabel.snp.bottom).offset(theme.stackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension LedgerAccountDetailView: ViewModelBindable {
    func bindData(_ viewModel: LedgerAccountDetailViewModel?) {
        guard let viewModel = viewModel else { return }

        setAssetViews(viewModel.account)
        
        if let rekeyedAccounts = viewModel.rekeyedAccounts {
            signedByTitleLabel.text = viewModel.subtitle
            setRekeyedAccountViews(from: viewModel.account, and: rekeyedAccounts)
        }
    }
}

extension LedgerAccountDetailView {
    private func setRekeyedAccountViews(from account: Account, and rekeyedAccounts: [Account]) {
        if account.isRekeyed() {
            let accountPreviewView = AccountPreviewView()
            accountPreviewView.customize(AccountPreviewViewTheme())
            let accountNameViewModel = AuthAccountNameViewModel(account)
            accountPreviewView.bindData(
                AccountPreviewViewModel(
                    AccountPreviewModel(
                        accountType: account.type,
                        accountImageType: .orange,
                        accountName: accountNameViewModel.address
                    )
                )
            )
            rekeyedAccountsStackView.addArrangedSubview(accountPreviewView)
        } else {
            guard !rekeyedAccounts.isEmpty else { return }

            rekeyedAccounts.forEach { rekeyedAccount in
                let accountPreviewView = AccountPreviewView()
                accountPreviewView.customize(AccountPreviewViewTheme())
                let accountNameViewModel = AccountNameViewModel(account: rekeyedAccount)
                accountPreviewView.bindData(
                    AccountPreviewViewModel(
                        AccountPreviewModel(
                            accountType: rekeyedAccount.type,
                            accountImageType: .orange,
                            accountName: accountNameViewModel.name
                        )
                    )
                )
                rekeyedAccountsStackView.addArrangedSubview(accountPreviewView)
            }
        }
    }
}

extension LedgerAccountDetailView {
    private func setAssetViews(_ account: Account) {
        bindLedgerInfoAccountNameView(account)
        addAlgoView(account)
        addAssetViews(account)
    }

    private func bindLedgerInfoAccountNameView(_ account: Account) {
        let accountNameViewModel = AccountNameViewModel(account: account)
        ledgerAccountInfo.bindData(
            AccountPreviewViewModel(
                AccountPreviewModel(
                    accountType: account.type,
                    accountImageType: .orange,
                    accountName: accountNameViewModel.name,
                    assetsAndNFTs: "1 asset",
                    assetValue: "6.06 ALGO",
                    secondaryAssetValue: "$16,000.09")
            )
        )
    }

    private func addAlgoView(_ account: Account) {
        let assetView = AssetPreviewView()
        assetView.customize(AssetPreviewViewTheme())
        assetView.bindData(AlgoAssetViewModel(account: account))

        assetStackView.addArrangedSubview(assetView)
    }

    private func addAssetViews(_ account: Account) {
        for (index, assetDetail) in account.assetDetails.enumerated() {
            guard let asset = account.assets?[safe: index] else { continue }

            let assetView = AssetPreviewView()
            assetView.customize(AssetPreviewViewTheme())
            assetView.bindData(AssetViewModel(assetDetail: assetDetail, asset: asset))

            assetStackView.addArrangedSubview(assetView)
        }
    }
}
