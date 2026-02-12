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

//   JointAccountSendRequestInboxRow.swift

import SwiftUI

struct JointAccountSendRequestInboxRow: View {
    
    struct StateViewModel {
        let text: LocalizedStringKey?
        let icon: ImageResource
        let tint: Color
    }
    
    // MARK: - Properties
    
    let isDotVisible: Bool
    let message: AttributedString
    let stateViewModel: StateViewModel
    let creationDatetime: Date
    let signedTransactionsText: String
    let deadline: Date
    
    private let relativeDateFormatter = DefaultRelativeDateTimeFormatter(unitsStyle: .full, isNagativeValuesAllowed: true, additionalTextOption: .default)
    
    // MARK: - Body
    
    var body: some View {
        InboxJointAccountCoreRow(isDotVisible: isDotVisible, message: message) {
            HStack(alignment: .center, spacing: 0.0) {
                Image(stateViewModel.icon)
                    .resizable()
                    .frame(width: 16.0, height: 16.0)
                    .foregroundStyle(stateViewModel.tint)
                    .padding(.trailing, 6.0)
                if let text = stateViewModel.text {
                    Text(text)
                        .font(.DMSans.medium.size(13.0))
                        .foregroundStyle(stateViewModel.tint)
                        .padding(.trailing, 8.0)
                }
                Circle()
                    .frame(width: 2.0, height: 2.0)
                    .foregroundStyle(Color.Text.grayLighter)
                    .padding(.trailing, 8.0)
                RelativeDateTextView(formatter: relativeDateFormatter, date: creationDatetime)
                    .font(.DMSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.grayLighter)
                Spacer()
            }
            HStack(spacing: 8.0) {
                JointAccountSendRequestInboxCapsule(icon: .Icons.user, text: .raw(text: signedTransactionsText))
                JointAccountSendRequestInboxCapsule(icon: .Icons.clock, text: .time(date: deadline))
                Spacer()
            }
        }
    }
}

final class JointAccountSendRequestInboxCell: UICollectionViewCell, InboxRowIdentifiable {
    
    // MARK: - Properties - IndexRowIdentifiable
    
    var identifier: InboxRowIdentifier?

    // MARK: - Properties
    
    let wrappedView: SwiftUICompatibilityView<JointAccountSendRequestInboxRow>
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        wrappedView = SwiftUICompatibilityView(view: JointAccountSendRequestInboxRow(
            isDotVisible: false,
            message: "",
            stateViewModel: JointAccountSendRequestInboxRow.StateViewModel(text: nil, icon: .Icons.question, tint: .clear),
            creationDatetime: Date(),
            signedTransactionsText: "",
            deadline: Date()
        ))
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
    
    func update(isDotVisible: Bool, message: AttributedString, stateViewModel: JointAccountSendRequestInboxRow.StateViewModel, creationDatetime: Date, signedTransactionsText: String, deadline: Date) {
        let view = JointAccountSendRequestInboxRow(isDotVisible: isDotVisible, message: message, stateViewModel: stateViewModel, creationDatetime: creationDatetime, signedTransactionsText: signedTransactionsText, deadline: deadline)
        wrappedView.update(view: view)
    }
}
