// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SendKeyRegTransactionView.swift

import SwiftUI

struct SendKeyRegTransactionView: View {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    @ObservedObject var viewModel: SendKeyRegTransactionItemViewModel
    private let theme = SendKeyRegTransactionViewTheme()
    
    init(
        transactionDraft: KeyRegTransactionSendDraft
    ) {
        self.viewModel = SendKeyRegTransactionItemViewModel(transactionDraft)
    }
        
    var body: some View {
        content
            .background(theme.background)
    }
}

private extension SendKeyRegTransactionView {
    var content: some View {
        VStack {
            SwiftUI.ScrollView(showsIndicators: false) {
                VStack(
                    alignment: .leading,
                    spacing: theme.itemSpacing
                ) {
                    itemViews()
                    rawTransactionButton()
                }
            }
            confirmButton()
        }
        .padding(.horizontal, theme.horizontalSpacing)
        .padding(.top, theme.topSpacing)
    }
    
    func itemViews() -> some View {
        ForEach(viewModel.items) { item in
            if let action = item.action {
                lineItemActionView(
                    title: item.title,
                    value: item.value,
                    action: action
                )
            } else {
                lineItemView(
                    title: item.title,
                    value: item.value
                )
            }
            
            if item.hasSeparator {
                Divider()
                    .padding(.vertical, theme.dividerSpacing)
            }
        }
    }
    
    func lineItemActionView(
        title: String,
        value: String,
        action: String
    ) -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: theme.lineItemHorizontalSpacing
        ) {
            Text(title)
                .foregroundColor(theme.titleColor)
                .font(theme.titleFont)
                .frame(width: theme.titleMaxWidth, alignment: .leading)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            VStack(
                alignment: .leading,
                spacing: theme.noteButtonSpacing
            ) {
                if value.isEmpty {
                    noteButton(title: "send-transaction-add-note-title".localized)
                } else {
                    Text(value)
                        .foregroundColor(theme.valueColor)
                        .font(theme.valueFont)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    noteButton(title: "send-transaction-edit-note-title".localized)
                }
            }
        }
    }
    
    func lineItemView(
        title: String,
        value: String
    ) -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: theme.lineItemHorizontalSpacing
        ) {
            Text(title)
                .foregroundColor(theme.titleColor)
                .font(theme.titleFont)
                .frame(width: theme.titleMaxWidth, alignment: .leading)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            Text(value)
                .foregroundColor(theme.valueColor)
                .font(theme.valueFont)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
    }
    
    func noteButton(title: String) -> some View {
        SwiftUI.Button(action: {
            eventHandler?(.didAddNote)
        }) {
            HStack {
                Text(title)
                    .font(theme.noteButtonFont)
                    .foregroundColor(theme.noteButtonForegroundColor)
            }
        }
    }
    
    func rawTransactionButton() -> some View {
        SwiftUI.Button(action: {
            eventHandler?(.didShowRawTransaction)
        }) {
            Text("wallet-connect-raw-transaction-title".localized)
                .font(theme.rawTxnButtonFont)
                .foregroundColor(theme.rawTxnButtonForegroundColor)
                .frame(alignment: .leading)
                .padding(.vertical, theme.rawTxnButtonVerticalSpacing)
                .padding(.horizontal, theme.rawTxnButtonHorizontalSpacing)
                .background(theme.rawTxnButtonBackgroundColor)
                .cornerRadius(theme.rawTxnButtonCornerRadius)
        }
        .padding(.bottom, theme.rawTxnButtonBottomPadding)
    }
    
    func confirmButton() -> some View {
        SwiftUI.Button(action: {
            eventHandler?(.didConfirmTransaction)
        }) {
            Text("send-transaction-preview-button".localized)
                .font(theme.buttonFont)
                .foregroundColor(theme.buttonForeground)
                .frame(maxWidth: .infinity)
                .frame(height: theme.buttonHeight)
                .background(theme.buttonBackground)
                .cornerRadius(theme.buttonRadius)
        }
    }
}

extension SendKeyRegTransactionView {
    enum Event {
        case didAddNote
        case didShowRawTransaction
        case didConfirmTransaction
    }
}


#if DEBUG
#Preview {
    SendKeyRegTransactionView(transactionDraft: .mock)
}
#endif
