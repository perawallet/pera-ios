//
//  QRCreationDraft.swift

import Foundation

struct QRCreationDraft {
    let address: String
    let mnemonic: String?
    let mode: QRMode
    let isSelectable: Bool
    
    init(address: String, mode: QRMode, mnemonic: String? = nil) {
        self.address = address
        self.mode = mode
        self.mnemonic = mnemonic
        self.isSelectable = mode == .address
    }
}
