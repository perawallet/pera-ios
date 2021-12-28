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
//   OrderAccountListViewController.swift

import MacaroonUIKit
import UIKit

final class OrderAccountListViewController: BaseViewController {

    private lazy var listView = UITableView()

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func setListeners() {
        super.setListeners()
        listView.dataSource = self
        listView.delegate = self
        listView.dragDelegate = self
        listView.dropDelegate = self
    }
}

extension OrderAccountListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }

        listView.rowHeight = UITableView.automaticDimension
        listView.estimatedRowHeight = 72
        listView.separatorStyle = .none
        listView.separatorInset = .zero
        listView.verticalScrollIndicatorInsets.top = .leastNonzeroMagnitude
        listView.dragInteractionEnabled = true
    }
}

extension OrderAccountListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {

    }
}

extension OrderAccountListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        fatalError()
    }
}

extension OrderAccountListViewController: UITableViewDragDelegate {
    func tableView(
        _ tableView: UITableView,
        itemsForBeginning
        session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        return [dragItem]
    }
}

extension OrderAccountListViewController: UITableViewDropDelegate {
    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {

    }
}
