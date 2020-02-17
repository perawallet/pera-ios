//
//  URL+Link.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
    
    func buildQRText() -> QRText? {
        guard let address = host else {
            return nil
        }
        
        guard let queryParameters = queryParameters else {
            if AlgorandSDK().isValidAddress(address) {
                return QRText(mode: .address, address: address)
            }
            return nil
        }
        
        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue],
            let asset = queryParameters[QRText.CodingKeys.asset.rawValue] {
            return QRText(mode: .assetRequest, address: address, amount: Int64(amount), asset: Int64(asset))
        }
        
        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue] {
            return QRText(mode: .algosRequest, address: address, amount: Int64(amount))
        }
        
        if let label = queryParameters[QRText.CodingKeys.label.rawValue] {
            return QRText(mode: .address, address: address, label: label)
        }
        
        return nil
    }
}
