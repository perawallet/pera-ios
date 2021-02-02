//
//  DeepLinkParser.swift

import UIKit

struct DeepLinkParser {
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    var expectedScreen: Screen? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let accountAddress = urlComponents.host,
            accountAddress.isValidatedAddress(),
            let qrText = url.buildQRText() else {
            return nil
        }
        
        switch qrText.mode {
        case .address:
            return .addContact(mode: .new(address: accountAddress, name: qrText.label))
        case .algosRequest:
            if let amount = qrText.amount {
                return .sendAlgosTransactionPreview(
                    account: nil,
                    receiver: .address(address: accountAddress, amount: "\(amount)"),
                    isSenderEditable: false
                )
            }
        case .assetRequest:
            guard let assetId = qrText.asset,
                let userAccounts = UIApplication.shared.appConfiguration?.session.accounts else {
                return nil
            }
            
            var requestedAssetDetail: AssetDetail?
            
            for account in userAccounts {
                for assetDetail in account.assetDetails where assetDetail.id == assetId {
                    requestedAssetDetail = assetDetail
                }
            }
            
            guard let assetDetail = requestedAssetDetail else {
                let assetAlertDraft = AssetAlertDraft(
                    account: nil,
                    assetIndex: assetId,
                    assetDetail: nil,
                    title: "asset-support-title".localized,
                    detail: "asset-support-error".localized,
                    actionTitle: "title-ok".localized
                )
                
                return .assetSupport(assetAlertDraft: assetAlertDraft)
            }
                
            if let amount = qrText.amount {
                return .sendAssetTransactionPreview(
                    account: nil,
                    receiver: .address(address: accountAddress, amount: "\(amount)"),
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false
                )
            }
        case .mnemonic:
            return nil
        }
        
        return nil
    }
}
