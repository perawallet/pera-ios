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
    
    private lazy var nodeSettingsView = NodeSettingsView()
    
    var nodes: [Node] = []
    
    private let viewModel = NodeSettingsViewModel()
    
    weak var delegate: NodeSettingsViewControllerDelegate?
    
    private var canTapBarButton = true
    
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
    
    override func prepareLayout() {
        setupNodeSettingsViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchNodes()
        
        switch mode {
        case .checkHealth:
            self.displaySimpleAlertWith(title: "title-error".localized, message: "node-settings-health-problem-message".localized)
        default:
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = SharedColors.warmWhite
    }
    
    override func didTapBackBarButton() -> Bool {
        return canTapBarButton
    }
    
    override func didTapDismissBarButton() -> Bool {
        return canTapBarButton
    }
}

extension NodeSettingsViewController {
    private func setupNodeSettingsViewLayout() {
        view.addSubview(nodeSettingsView)
        
        nodeSettingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NodeSettingsViewController {
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
}

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
            
            if indexPath.item < nodes.count + 1 {
                let node = nodes[indexPath.item - 1]
                
                viewModel.configureToggle(cell, with: node, for: indexPath)
                
                viewModel.delegate = self
                
                if node.isActive {
                    cell.contextView.toggle.isEnabled = (session?.isDefaultNodeActive() ?? false) || numberOfActiveNodes() > 1
                } else {
                    cell.contextView.toggle.isEnabled = true
                }
            }
            
            return cell
        }
    }
}

extension NodeSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
    }
}

extension NodeSettingsViewController: NodeSettingsViewModelDelegate {
    func nodeSettingsViewModel(_ viewModel: NodeSettingsViewModel, didToggleValue value: Bool, atIndexPath indexPath: IndexPath) {
        guard indexPath.item < nodes.count + 1 else {
            return
        }
        
        if let activeNode = activeNode() {
            activeNode.update(entity: Node.entityName, with: ["isActive": NSNumber(value: 0)])
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
        guard indexPath.item < nodes.count + 1,
            indexPath.item != 0 else {
            return
        }
        self.open(.editNode(node: nodes[indexPath.item - 1]), by: .push)
    }
}

extension NodeSettingsViewController {
    fileprivate func checkNodesHealth() {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        self.view.isUserInteractionEnabled = false
        canTapBarButton = false
        
        nodeManager?.checkNodes { isHealthy in
            
            if isHealthy {
                SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                
                SVProgressHUD.dismiss(withDelay: 1.0) {
                    
                    self.canTapBarButton = true
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                    
                    self.view.isUserInteractionEnabled = true
                    self.updateNodes()
                }
            } else {
                SVProgressHUD.dismiss {
                    
                    self.canTapBarButton = false
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    
                    self.view.isUserInteractionEnabled = true
                    self.updateNodes()
                    
                    self.displaySimpleAlertWith(
                        title: "title-error".localized,
                        message: "node-settings-none-active-node-error-description".localized
                    )
                }
            }
        }
    }
    
    fileprivate func updateNodes() {
        for cell in nodeSettingsView.collectionView.visibleCells {
            if let defaultNodeCell = cell as? ToggleCell {
                defaultNodeCell.contextView.toggle.isEnabled = numberOfActiveNodes() > 0
            } else if let nodeCell = cell as? SettingsToggleCell {
                guard let indexPath = nodeCell.contextView.indexPath else {
                    continue
                }
                
                let node = nodes[indexPath.item - 1]
                
                if node.isActive {
                    nodeCell.contextView.toggle.isEnabled = (session?.isDefaultNodeActive() ?? false) || numberOfActiveNodes() > 1
                } else {
                    nodeCell.contextView.toggle.isEnabled = true
                }
            }
        }
    }
}

extension NodeSettingsViewController {
    private func numberOfActiveNodes() -> Int {
        return nodes.filter { node -> Bool in
            node.isActive
        }.count
    }
    
    private func activeNode() -> Node? {
        return nodes.first { node -> Bool in
            node.isActive
        }
    }
    
    private func indexOfActiveNode() -> Int? {
        guard let activeNode = activeNode() else {
            return nil
        }
        return nodes.firstIndex(of: activeNode)
    }
}

extension NodeSettingsViewController {
    enum Mode {
        case initialize
        case checkHealth
    }
}
