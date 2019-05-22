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

protocol AuthManagerDelegate: class {
    func authManager(_ authManager: AuthManager, didCaptureToken token: String?, withError error: Error?)
}

class AuthManager: NSObject {
    private let callbackUrlScheme = "algorand://coinlist/oauth"
    
    private lazy var oauthUrl: String = {
        let host = Environment.current.coinlistHost
        let clientId = Environment.current.coinlistClientId
        return "\(host)/oauth/authorize?client_id=\(clientId)&redirect_uri=\(callbackUrlScheme)"
    }()
    
    @available(iOS 12.0, *)
    fileprivate lazy var webAuthenticationSession: ASWebAuthenticationSession? = {
        guard let authUrl = URL(string: oauthUrl) else {
            return nil
        }
        
        let handler: ASWebAuthenticationSession.CompletionHandler = { successUrl, error in
            self.processAuthentication(url: successUrl, error: error)
        }
        
        let session = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: callbackUrlScheme, completionHandler: handler)
        
        return session
    }()
    
    fileprivate lazy var safariAuthenticationSession: SFAuthenticationSession? = {
        guard let authUrl = URL(string: oauthUrl) else {
            return nil
        }
        
        let handler: SFAuthenticationSession.CompletionHandler = { successUrl, error in
            self.processAuthentication(url: successUrl, error: error)
        }
        
        let session = SFAuthenticationSession(url: authUrl, callbackURLScheme: callbackUrlScheme, completionHandler: handler)
        
        return session
    }()
    
    weak var delegate: AuthManagerDelegate?
    
    func authorize() {
        if #available(iOS 12.0, *) {
            webAuthenticationSession?.start()
        } else {
            safariAuthenticationSession?.start()
        }
    }
    
    func processAuthentication(url: URL?, error: Error?) {
        guard error == nil, let successURL = url else {
            delegate?.authManager(self, didCaptureToken: nil, withError: error)
            return
        }
        
        let oauthToken = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.first { $0.name == "code" }
        
        delegate?.authManager(self, didCaptureToken: oauthToken?.value, withError: nil)
    }
}
