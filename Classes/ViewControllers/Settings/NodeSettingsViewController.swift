//
//  NodeSettingsViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NodeSettingsViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var nodeSettingsView = NodeSettingsView()
    
    var nodes: [Node] = []
    
    private let viewModel = NodeSettingsViewModel()
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
            self.open(.addNode, by: .push)
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func linkInteractors() {
        nodeSettingsView.collectionView.delegate = self
        nodeSettingsView.collectionView.dataSource = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "node-settings-title".localized
        
        fetchNodes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchNodes()
    }
    
    private func fetchNodes() {
        Node.fetchAll(entity: Node.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Node] else {
                    return
                }
                
                self.nodes = results
            default:
                break
            }
            
            self.nodeSettingsView.collectionView.reloadData()
        }
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(nodeSettingsView)
        
        nodeSettingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: UICollectionViewDataSource

extension NodeSettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsToggleCell.reusableIdentifier,
            for: indexPath) as? SettingsToggleCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < nodes.count {
            let node = nodes[indexPath.row]
            
            let enabled = session?.authenticatedUser?.defaultNode == node.address
            
            viewModel.configureToggle(cell, enabled: enabled, with: node, for: indexPath)
            
            viewModel.delegate = self
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension NodeSettingsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 90.0)
    }
}

// MARK: NodeSettingsViewModelDelegate

extension NodeSettingsViewController: NodeSettingsViewModelDelegate {
    func nodeSettingsViewModel(_ viewModel: NodeSettingsViewModel,
                               didToggleValue value: Bool,
                               atIndexPath indexPath: IndexPath) {
        
        guard indexPath.item < nodes.count else {
            return
        }
        
        let node = nodes[indexPath.item]
        
        session?.authenticatedUser?.setDefaultNode(value ? node : nil)
    }
}
