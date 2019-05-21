//
//  AuthManager.swift
//  algorand
//
//  Created by Omer Emre Aslan on 21.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import AuthenticationServices
import SafariServices

class AuthManager: NSObject {
    
    private lazy var url: String = {
        let clientId = "7fb1221754c8aa17172fdef40d76f4478b1edbba3349f3641928e89349459efe"
        return "https://coinlist.co/oauth/authorize?client_id=\(clientId)&redirect_uri=https://www.algorand.com"
    }()
    
    @available(iOS 12.0, *)
    fileprivate lazy var webAuthenticationSession: ASWebAuthenticationSession? = {
        guard let url = URL(string: self.url) else {
            return nil
        }
        
        let handler: ASWebAuthenticationSession.CompletionHandler = { successUrl, error in
            self.processAuthentication(url: successUrl, error: error)
        }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: handler)
        
        return session
    }()
    
    fileprivate lazy var safariAuthenticationSession: SFAuthenticationSession? = {
        guard let url = URL(string: self.url) else {
            return nil
        }
        
        let authenticationSession = SFAuthenticationSession(url: url, callbackURLScheme: nil) { successUrl, error in
            self.processAuthentication(url: successUrl, error: error)
        }
        
        return authenticationSession
    }()
    
    func authorize() {
        if #available(iOS 12.0, *) {
            webAuthenticationSession?.start()
        } else {
            
            safariAuthenticationSession?.start()
        }
    }
    
    func processAuthentication(url: URL?, error: Error?) {
        
    }
}
