//
//  DeepLinkParser.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
            break
        case .assetRequest:
            break
        case .mnemonic:
            return nil
        }
        
        return nil
    }
}
