//
//  NodeSettingsViewModel.swift

import UIKit

class NodeSettingsViewModel {
    private(set) var nodeName: String?
    private(set) var backgroundImage: UIImage?
    private(set) var image: UIImage?

    init(node: AlgorandNode, activeNetwork: AlgorandAPI.BaseNetwork) {
        setNodeName(from: node)
        setBackgroundImage(from: node, activeNetwork: activeNetwork)
        setImage(from: node, activeNetwork: activeNetwork)
    }

    private func setNodeName(from node: AlgorandNode) {
        nodeName = node.name
    }

    private func setBackgroundImage(from node: AlgorandNode, activeNetwork: AlgorandAPI.BaseNetwork) {
        if node.network == activeNetwork {
            backgroundImage = img("bg-settings-node-selected")
        } else {
            backgroundImage = img("bg-settings-node-unselected")
        }
    }

    private func setImage(from node: AlgorandNode, activeNetwork: AlgorandAPI.BaseNetwork) {
        if node.network == activeNetwork {
            image = img("settings-node-active")
        } else {
            image = img("settings-node-inactive")
        }
    }
}
