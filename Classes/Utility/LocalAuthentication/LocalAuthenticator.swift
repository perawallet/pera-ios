//
//  LocalAuthenticator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import LocalAuthentication

class LocalAuthenticator {

    private var context = LAContext()
    
    var authenticationError: NSError?

    var isLocalAuthenticationAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
    }
    
    var localAuthenticationStatus: Status = .none {
        didSet {
            if localAuthenticationStatus == oldValue {
                return
            }
            
            self.save(localAuthenticationStatus.rawValue, for: StorableKeys.localAuthenticationStatus.rawValue, to: .defaults)
        }
    }
    
    var localAuthenticationType: Type {
        if !isLocalAuthenticationAvailable {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        }
    }
    
    func authenticate(then handler: @escaping (_ error: Error?) -> Void) {
        if !isLocalAuthenticationAvailable {
            return
        }
        
        let reasonMessage: String
        
        if localAuthenticationType == .faceID {
            reasonMessage = "local-authentication-reason-face-id-title".localized
        } else {
            reasonMessage = "local-authentication-reason-touch-id-title".localized
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonMessage) { success, error in
            if success {
                DispatchQueue.main.async {
                    handler(nil)
                }
            } else {
                DispatchQueue.main.async {
                    handler(error)
                }
            }
        }
    }

    func reset() {
        context = LAContext()
    }
}

extension LocalAuthenticator {
    
    enum `Type` {
        case none
        case touchID
        case faceID
    }
}

extension LocalAuthenticator: Storable {
    
    enum Status: String {
        case allowed = "enabled"
        case notAllowed = "disabled"
        case none = "none"
    }
    
    typealias Object = String
}
