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
//  BaseCollectionViewCell.swift

import UIKit

class BaseCollectionViewCell<T: UIView>: UICollectionViewCell {
    
    typealias ContextView = T
    
    private(set) lazy var contextView = ContextView()

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
    }
    
    func prepareLayout() {
        setupContextViewLayout()
    }
    
    private func setupContextViewLayout() {
        contentView.addSubview(contextView)
        
        contextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }

    static func getContext() -> ContextView.Type {
        return ContextView.self
    }
}
