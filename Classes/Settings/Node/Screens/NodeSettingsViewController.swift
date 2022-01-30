// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  NodeSettingsViewController.swift

import UIKit

final class NodeSettingsViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var nodeSettingsView = SingleSelectionListView()
    
    private let nodes = [mainNetNode, testNetNode]
        
    private lazy var lastActiveNetwork: ALGAPI.Network = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return api.network
    }()
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api, bannerController: bannerController)
    }()
    
    override func linkInteractors() {
        nodeSettingsView.linkInteractors()
        nodeSettingsView.setDataSource(self)
        nodeSettingsView.setListDelegate(self)
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "node-settings-title".localized
    }
    
    override func prepareLayout() {
        addNodeSettingsView()
    }
}

extension NodeSettingsViewController {
    private func addNodeSettingsView() {
        view.addSubview(nodeSettingsView)
        
        nodeSettingsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NodeSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SingleSelectionCell.self, at: indexPath)
        
        if let algorandNode = nodes[safe: indexPath.item] {
            let isActiveNetwork = algorandNode.network == lastActiveNetwork
            cell.bindData(SingleSelectionViewModel(title: algorandNode.name, isSelected: isActiveNetwork))
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension NodeSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeNode(at: indexPath)
    }
}

extension NodeSettingsViewController {
    private func changeNode(at indexPath: IndexPath) {
        loadingController?.startLoadingWithMessage("title-loading".localized)
        
        sharedDataController.cancel()
        
        let selectedNode = nodes[indexPath.item]
        
        if pushNotificationController.token == nil {
            switchNetwork(for: selectedNode)
        } else {
            pushNotificationController.sendDeviceDetails { isCompleted in
                if isCompleted {
                    self.switchNetwork(for: selectedNode)
                } else {
                    self.loadingController?.stopLoadingAfter(seconds: 1, on: .main) {
                        self.nodeSettingsView.reloadData()
                    }
                }
            }
        }
    }
    
    private func switchNetwork(for selectedNode: AlgorandNode) {
        session?.authenticatedUser?.setDefaultNode(selectedNode)
        lastActiveNetwork = selectedNode.network
        
        DispatchQueue.main.async {
//            UIApplication.shared.rootViewController()?.setNetwork(to: selectedNode.network)
            UIApplication.shared.rootViewController()?.addBanner()
        }
        
        self.loadingController?.stopLoadingAfter(seconds: 2, on: .main) {
            self.sharedDataController.startPolling()
            self.nodeSettingsView.reloadData()
        }
    }
}

let mainNetNode = AlgorandNode(
    algodAddress: Environment.current.mainNetAlgodHost,
    indexerAddress: Environment.current.mainNetAlgodHost,
    algodToken: Environment.current.algodToken,
    indexerToken: Environment.current.indexerToken,
    name: "node-settings-default-node-name".localized,
    network: .mainnet
)

let testNetNode = AlgorandNode(
    algodAddress: Environment.current.testNetAlgodHost,
    indexerAddress: Environment.current.testNetIndexerHost,
    algodToken: Environment.current.algodToken,
    indexerToken: Environment.current.indexerToken,
    name: "node-settings-default-test-node-name".localized,
    network: .testnet
)
