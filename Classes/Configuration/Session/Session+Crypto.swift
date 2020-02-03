//
//  Session+Crypto.swift
//  algorand
//
//  Created by Omer Emre Aslan on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Session {
    func mnemonics(forAccount account: String) -> [String] {
        guard let privateKey = privateData(for: account) else {
            return []
        }
        
        var error: NSError?
        let mnemonics = algorandSDK.mnemonicFrom(privateKey, error: &error)
        
        guard error == nil else {
            return []
        }
        
        return mnemonics.components(separatedBy: " ")
    }
    
    func privateKey(forMnemonics mnemonics: String) -> Data? {
        var error: NSError?
        let data = algorandSDK.privateKeyFrom(mnemonics, error: &error)
        
        guard let privateKey = data,
            error == nil else {
            return nil
        }
        
        return privateKey
    }
    
    func address(for account: String) -> String? {
        guard let privateKey = privateData(for: account) else {
            return nil
        }
        
        return address(fromPrivateKey: privateKey)
    }
    
    func address(fromPrivateKey privateKey: Data) -> String? {
        var error: NSError?
        let address = algorandSDK.addressFrom(privateKey, error: &error)
        
        guard error == nil else {
            return nil
        }
        
        return address
    }
    
    func generatePrivateKey() -> Data? {
        return algorandSDK.generatePrivateKey()
    }
}
