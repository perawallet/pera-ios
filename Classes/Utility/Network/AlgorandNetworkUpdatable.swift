//
//  AlgorandNetworkUpdatable.swift

import UIKit

protocol AlgorandNetworkUpdatable {
    var appConfiguration: AppConfiguration { get }
    func initializeNetwork()
    func setNetworkFromTarget()
    func setNetwork(to network: AlgorandAPI.BaseNetwork)
}

extension AlgorandNetworkUpdatable where Self: UIViewController {
    func initializeNetwork() {
        if let authenticatedUser = appConfiguration.session.authenticatedUser {
            if let preferredAlgorandNetwork = authenticatedUser.preferredAlgorandNetwork() {
                setNetwork(to: preferredAlgorandNetwork)
            } else {
                setNetworkFromTarget()
            }
        } else {
            setNetworkFromTarget()
        }
    }

    func setNetworkFromTarget() {
        if Environment.current.isTestNet {
            setNetwork(to: .testnet)
        } else {
            setNetwork(to: .mainnet)
        }
    }

    func setNetwork(to network: AlgorandAPI.BaseNetwork) {
        appConfiguration.api.cancelEndpoints()
        appConfiguration.api.setupEnvironment(for: network)
    }
}
