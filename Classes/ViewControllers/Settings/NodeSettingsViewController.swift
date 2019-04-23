//
//  NodeSettingsViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol NodeSettingsViewControllerDelegate: class {
    func nodeSettingsViewControllerDidUpdateNode(_ nodeSettingsViewController: NodeSettingsViewController)
}

class NodeSettingsViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var nodeSettingsView = NodeSettingsView()
    
    var nodes: [Node] = []
    
    private let viewModel = NodeSettingsViewModel()
    
    weak var delegate: NodeSettingsViewControllerDelegate?
    
    private let mode: Mode
    
    private lazy var nodeManager: NodeManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = NodeManager(api: api)
        return manager
    }()
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
            self.open(.addNode, by: .push)
        }
        
        switch mode {
        case .checkHealth:
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                self.closeScreen(by: .dismiss, animated: true) {
                    self.delegate?.nodeSettingsViewControllerDidUpdateNode(self)
                }
            }
            
            leftBarButtonItems = [closeBarButtonItem]
        default:
            break
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
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Node.creationDate), ascending: true)
        
        Node.fetchAll(entity: Node.entityName, sortDescriptor: sortDescriptor) { response in
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
        return nodes.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ToggleCell.reusableIdentifier,
                for: indexPath) as? ToggleCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureDefaultNode(cell, enabled: session?.isDefaultNodeActive() ?? false, for: indexPath)
            
            cell.contextView.toggle.isEnabled = numberOfActiveNodes() > 0
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsToggleCell.reusableIdentifier,
                for: indexPath) as? SettingsToggleCell else {
                    fatalError("Index path is out of bounds")
            }
            
            cell.contextView.toggle.isEnabled = (session?.isDefaultNodeActive() ?? false) || numberOfActiveNodes() > 0
            
            if indexPath.item < nodes.count + 1 {
                let node = nodes[indexPath.row - 1]
                
                viewModel.configureToggle(cell, with: node, for: indexPath)
                
                viewModel.delegate = self
            }
            
            return cell
        }
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
        
        guard indexPath.item < nodes.count + 1 else {
            return
        }
        
        if indexPath.item == 0 {
            session?.setDefaultNodeActive(value)
        } else {
            let node = nodes[indexPath.item - 1]
            
            node.update(entity: Node.entityName, with: ["isActive": NSNumber(value: value)])
        }
        
        checkNodesHealth()
    }
    
    func nodeSettingsViewModelDidTapEdit(_ viewModel: NodeSettingsViewModel, atIndexPath indexPath: IndexPath) {
        guard indexPath.item < nodes.count + 1 else {
            return
        }
        
        if indexPath.item == 0 {
            return
        }
        
        let node = nodes[indexPath.item - 1]
        
        self.open(.editNode(node: node), by: .push)
    }
    
    fileprivate func updateNodes() {
        for cell in nodeSettingsView.collectionView.visibleCells {
            if let defaultNodeCell = cell as? ToggleCell {
                defaultNodeCell.contextView.toggle.isEnabled = numberOfActiveNodes() > 0
            } else if let nodeCell = cell as? SettingsToggleCell {
                nodeCell.contextView.toggle.isEnabled = (session?.isDefaultNodeActive() ?? false) || numberOfActiveNodes() > 1
            }
        }
    }
    
    fileprivate func checkNodesHealth() {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        self.view.isUserInteractionEnabled = false
        
        nodeManager?.checNodes { isHealthy in
            
            if isHealthy {
                SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                
                SVProgressHUD.dismiss(withDelay: 1.0) {
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                    
                    self.view.isUserInteractionEnabled = true
                    self.updateNodes()
                }
            } else {
                SVProgressHUD.dismiss {
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = false
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    
                    self.view.isUserInteractionEnabled = true
                    self.updateNodes()
                    
                    self.displaySimpleAlertWith(title: "title-error".localized, message: "node-settings-none-active-node-error-description".localized)
                }
            }
        }
    }
    
    fileprivate func numberOfActiveNodes() -> Int {
        return nodes.filter { node -> Bool in
            node.isActive
        }.count
    }
}

// MARK: Mode
extension NodeSettingsViewController {
    enum Mode {
        case initialize
        case checkHealth
    }
}
