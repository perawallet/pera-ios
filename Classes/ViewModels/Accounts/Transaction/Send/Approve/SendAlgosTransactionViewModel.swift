//
//  SendAlgosTransactionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionViewModel {
    func configure(_ view: SendTransactionView, with algosTransactionSendDraft: AlgosTransactionSendDraft) {
        view.setButtonTitle("send-algos-title".localized)
        
        if algosTransactionSendDraft.from.type == .ledger {
            view.setAccountImage(img("icon-account-type-ledger"))
        } else {
            view.setAccountImage(img("icon-account-type-standard"))
        }
        
        view.removeAssetUnitName()
        view.removeAssetId()
        view.setAssetNameAlignment(.right)
        view.setAccountName(algosTransactionSendDraft.from.name)
        
        if let amount = algosTransactionSendDraft.amount {
            view.setAmountInformationViewMode(.normal(amount: amount))
        }
        
        if let note = algosTransactionSendDraft.note, !note.isEmpty {
            view.setTransactionNote(note)
        } else {
            view.removeTransactionNote()
        }
        
        setReceiver(in: view, with: algosTransactionSendDraft)
        view.setAssetName("asset-algos-title".localized)
    }
    
    private func setReceiver(in view: SendTransactionView, with algosTransactionSendDraft: AlgosTransactionSendDraft) {
        guard let receiverAddress = algosTransactionSendDraft.toAccount else {
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
