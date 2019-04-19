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
            let host = urlComponents.host else {
            return nil
        }
        
        let pathComponents = url.pathComponents
        
        guard let linkPath = DeepLinkParser.Path(rawValue: host) else {
            return nil
        }
        
        switch linkPath {
        case .sendAlgos:
            if pathComponents.count < 3 {
                return nil
            }
            
            let address = pathComponents[1]
            let amount = pathComponents[2]
            
            return .sendAlgos(receiver: .address(address: address, amount: amount))
        }
    }
}

extension DeepLinkParser {
    
    enum Path: String {
        case sendAlgos = "send-algos"
    }
}
