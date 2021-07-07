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
//   WCSingleTransactionView.swift

import UIKit

class WCSingleTransactionView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var mainStackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = layout.current.spacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var participantInformationStackView = WrappedStackView()

    private lazy var balanceInformationStackView = WrappedStackView()

    private lazy var detailedInformationStackView: WrappedStackView = {
        let detailedInformationStackView = WrappedStackView()
        detailedInformationStackView.isUserInteractionEnabled = true
        detailedInformationStackView.stackView.isUserInteractionEnabled = true
        return detailedInformationStackView
    }()

    override func prepareLayout() {
        setupMainStackViewLayout()
    }
}

extension WCSingleTransactionView {
    private func setupMainStackViewLayout() {
        addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }

        mainStackView.addArrangedSubview(participantInformationStackView)
        mainStackView.addArrangedSubview(balanceInformationStackView)
        mainStackView.addArrangedSubview(detailedInformationStackView)
    }
}

extension WCSingleTransactionView {
    func addParticipantInformationView(_ view: UIView) {
        participantInformationStackView.addArrangedSubview(view)
    }

    func addBalanceInformationView(_ view: UIView) {
        balanceInformationStackView.addArrangedSubview(view)
    }

    func addDetailedInformationView(_ view: UIView) {
        detailedInformationStackView.addArrangedSubview(view)
    }
}

extension WCSingleTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let spacing: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
    }
}
