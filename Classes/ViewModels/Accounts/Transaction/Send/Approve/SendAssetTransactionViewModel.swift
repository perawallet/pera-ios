//
//  SendAssetTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionViewModel {
    func configure(_ view: SendTransactionView, with assetTransactionSendDraft: AssetTransactionSendDraft) {
        if assetTransactionSendDraft.from.type == .ledger {
            view.setAccountImage(img("img-ledger-small"))
        } else if assetTransactionSendDraft.from.type == .rekeyed {
            view.setAccountImage(img("icon-account-type-rekeyed"))
        } else {
            view.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.setAccountName(assetTransactionSendDraft.from.name)
        
        if let amount = assetTransactionSendDraft.amount {
            view.setAmountInformationViewMode(
                .normal(amount: amount, isAlgos: false, fraction: assetTransactionSendDraft.assetDecimalFraction)
            )
        }
        
        if let note = assetTransactionSendDraft.note, !note.isEmpty {
            view.setTransactionNote(note)
        } else {
            view.removeTransactionNote()
        }
        
        setReceiver(in: view, with: assetTransactionSendDraft)
        view.setAssetNameAlignment(.right)
        
        if !assetTransactionSendDraft.isVerifiedAsset {
            view.removeVerifiedAsset()
        }
        
        guard let assetIndex = assetTransactionSendDraft.assetIndex,
            let assetDetail = assetTransactionSendDraft.from.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        
        view.setAssetId("\(assetDetail.id )")
        
        if assetDetail.hasBothDisplayName() || assetDetail.hasOnlyAssetName() {
            view.setAssetName(assetDetail.unitName)
            view.removeAssetUnitName()
            return
        }
        
        if assetDetail.hasOnlyUnitName() {
            view.setAssetName(assetDetail.unitName)
            view.removeAssetUnitName()
            return
        }
        
        if assetDetail.hasNoDisplayName() {
            view.setAssetName("title-unknown".localized)
            view.removeAssetUnitName()
            return
        }
    }
    
    private func setReceiver(in view: SendTransactionView, with assetTransactionSendDraft: AssetTransactionSendDraft) {
        guard let receiverAddress = assetTransactionSendDraft.toAccount else {
            return
        }
        
        Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", receiverAddress)) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact], !results.isEmpty else {
                    self.setReceiverWithAddress(receiverAddress, in: view)
                    return
                }
                
                view.setReceiverAsContact(results[0])
            default:
                self.setReceiverWithAddress(receiverAddress, in: view)
            }
        }
    }
    
    private func setReceiverWithAddress(_ address: String, in view: SendTransactionView) {
        if let shortAddressDisplay = address.shortAddressDisplay() {
            view.setReceiverName(shortAddressDisplay)
            view.removeReceiverImage()
        }
    }
}
