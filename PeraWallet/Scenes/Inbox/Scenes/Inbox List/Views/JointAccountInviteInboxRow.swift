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

//   JointAccountInviteInboxRow.swift

import SwiftUI

struct JointAccountInviteInboxRow: View {
    
    // MARK: - Constants
    
    private let dotSize = 4.0
    private let topSectionHeight = 40.0
    
    // MARK: - Properties
    
    let isDotVisible: Bool
    let message: AttributedString
    let timestamp: Date
    let onDetailsButtonTap: (() -> Void)
    
    private let relativeDateFormatter = DefaultRelativeDateTimeFormatter()
    
    // MARK: - Body
    
    var body: some View {
        InboxJointAccountCoreRow(isDotVisible: isDotVisible, message: message) {
            HStack {
                SwiftUI.Button(action: onDetailsButtonTap) {
                    HStack {
                        Text("inbox-joint-account-invite-row-details-button")
                            .font(.DMSans.medium.size(15.0))
                        Image(.Icons.arrow)
                            .resizable()
                            .frame(width: 20.0, height: 20.0)
                    }
                    .foregroundStyle(Color.Text.main)
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 10.0)
                    .background(Color.Layer.grayLighter)
                    .cornerRadius(32.0)
                }
                Spacer()
            }
            HStack {
                Text(timestamp, formatter: relativeDateFormatter)
                    .font(.DMSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.grayLighter)
                Spacer()
            }
        }
    }
}

final class JointAccountInviteInboxCell: UICollectionViewCell, InboxRowIdentifiable {
    
    // MARK: - Properties - IndexRowIdentifiable
    
    var identifier: InboxRowIdentifier?
    
    // MARK: - Properties
    
    private let wrappedView: SwiftUICompatibilityView<JointAccountInviteInboxRow>
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        wrappedView = SwiftUICompatibilityView(view: JointAccountInviteInboxRow(isDotVisible: false, message: "", timestamp: Date(), onDetailsButtonTap: {}))
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrappedView)
        
        let constraints = [
            wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wrappedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Updates
    
    func update(isDotVisible: Bool, message: AttributedString, timestamp: Date, onDetailsButtonTap: @escaping (() -> Void)) {
        let view = JointAccountInviteInboxRow(isDotVisible: isDotVisible, message: message, timestamp: timestamp, onDetailsButtonTap: onDetailsButtonTap)
        wrappedView.update(view: view)
    }
    
    // MARK: - Autolayout
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height)
        layoutAttributes.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
