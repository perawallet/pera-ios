// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwiftUICompatibilityView.swift

import SwiftUI

final class SwiftUICompatibilityView<WrappedView: View>: UIView {
    
    // MARK: - Properties
    
    var wrappedView: WrappedView { hostingController.rootView }
    private let hostingController: UIHostingController<WrappedView>
    
    // MARK: - Initialisers
    
    init(view: WrappedView) {
        hostingController = UIHostingController(rootView: view)
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        
        guard let view = hostingController.view else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        let constraints = [
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Updates
    
    func update(view: WrappedView) {
        hostingController.rootView = view
    }
    
    // MARK: - Autolayout
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        let size = CGSize(width: targetSize.width, height: UIView.layoutFittingCompressedSize.height)
        return hostingController.sizeThatFits(in: size)
    }
}
