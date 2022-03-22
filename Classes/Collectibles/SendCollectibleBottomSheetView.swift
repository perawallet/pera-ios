// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SendCollectibleBottomSheetView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonForm
import SnapKit

final class SendCollectibleBottomSheetView:
    View,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    weak var delegate: SendCollectibleBottomSheetViewDelegate?

    lazy var handlers = Handlers()

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .transfer: UIControlInteraction(),
        .selectReceiverAccount: UIControlInteraction(),
        .scanQR: UIControlInteraction(),
        .close: UIControlInteraction()
    ]

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var handleView = ImageView()
    private lazy var closeActionView = MacaroonUIKit.Button()
    private lazy var titleView = Label()
    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var addressInputView = MultilineTextInputFieldView()
    private lazy var actionViewContentView = MacaroonUIKit.BaseView()
    private lazy var selectReceiverActionView = MacaroonUIKit.Button()
    private lazy var scanQRActionView = MacaroonUIKit.Button()
    private lazy var transferActionView = MacaroonUIKit.Button()

    private var isLayoutFinalized = false
    private(set) var initialHeight: CGFloat = .zero
    private var previousHeight: CGFloat = .zero
    private(set) var isEditing = false

    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []

    func customize(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    override func layoutSubviews() {
        super.layoutSubviews()

        let currentHeight = bounds.height

        if !isLayoutFinalized {
            isLayoutFinalized = true
            initialHeight = currentHeight
            return
        }

        if isEditing,
           previousHeight != currentHeight {
            previousHeight = currentHeight
            handlers.didHeightChange?(currentHeight)
        }
    }
}

extension SendCollectibleBottomSheetView {
    func updateContentBeforeAnimations(
        for position: Position
    ) {
        let currentLayout: [Constraint]
        let nextLayout: [Constraint]

        switch position {
        case .start:
            currentLayout = contentEndLayout
            nextLayout = contentStartLayout
        case .end:
            currentLayout = contentStartLayout
            nextLayout = contentEndLayout
        }

        currentLayout.deactivate()
        nextLayout.activate()
    }

    func updateContentAlongsideAnimations(
        for position: Position
    ) {
        contextView.alpha = position == .start ? 0 : 1
    }

    private func updateContent(
        for position: Position
    ) {
        updateContentBeforeAnimations(for: position)
        updateContentAlongsideAnimations(for: position)
    }
}

extension SendCollectibleBottomSheetView {
    private func addContent(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        contentView.customizeAppearance(theme.content)
        contentView.draw(corner: theme.contentCorner)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.height == snp.height
            $0.leading == 0
            $0.trailing == 0
        }

        contentView.snp.prepareConstraints {
            contentStartLayout = [ $0.top == snp.bottom ]
            contentEndLayout = [ $0.bottom == 0 ]
        }

        updateContent(for: .start)

        addHandle(theme)
        addCloseAction(theme)
        addContext(theme)
    }

    private func addHandle(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        handleView.customizeAppearance(theme.handle)

        contentView.addSubview(handleView)
        handleView.snp.makeConstraints {
            $0.centerHorizontally(
                offset: 0,
                verticalPaddings: (theme.handleTopPadding, .noMetric)
            )
        }
    }

    private func addCloseAction(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        closeActionView.customizeAppearance(theme.closeAction)

        contentView.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.setPaddings(theme.closeActionViewPaddings)
        }

        startPublishing(
            event: .close,
            for: closeActionView
        )

        addTitle(theme)
    }

    private func addTitle(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerY == closeActionView
            $0.centerX == 0
            $0.leading >= closeActionView.snp.trailing + theme.titleViewHorizontalPaddings.leading
            $0.trailing <= theme.titleViewHorizontalPaddings.trailing
        }
    }

    private func addContext(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == closeActionView.snp.bottom + theme.contextViewPaddings.top
            $0.leading == theme.contextViewPaddings.leading
            $0.bottom == safeAreaBottom + theme.contextViewPaddings.bottom
            $0.trailing == theme.contextViewPaddings.trailing
        }

        addAddressInput(theme)
        addTransferAction(theme)
    }

    private func addAddressInput(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        addressInputView.delegate = self
        addressInputView.editingDelegate = self

        addressInputView.customize(theme.addressInputTheme)

        contextView.addSubview(addressInputView)
        addressInputView.snp.makeConstraints {
            $0.greaterThanHeight(theme.addressInputViewMinHeight)

            $0.setPaddings((0, 0, .noMetric, 0))
        }

        let accessoryContainerView = MacaroonUIKit.BaseView()

        accessoryContainerView.addSubview(selectReceiverActionView)
        selectReceiverActionView.snp.makeConstraints {
            $0.setPaddings((0, 0, 0, .noMetric))
        }

        accessoryContainerView.addSubview(scanQRActionView)
        scanQRActionView.snp.makeConstraints {
            $0.leading == selectReceiverActionView.snp.trailing + theme.spacingBetweenSelectReceiverAndScanQR

            $0.setPaddings((0, .noMetric, 0, 0))
        }

        selectReceiverActionView.customizeAppearance(theme.selectReceiverAction)

        startPublishing(
            event: .selectReceiverAccount,
            for: selectReceiverActionView
        )

        scanQRActionView.customizeAppearance(theme.scanQRAction)

        startPublishing(
            event: .scanQR,
            for: scanQRActionView
        )

        addressInputView.addRightAccessoryItem(accessoryContainerView)
    }

    private func addTransferAction(
        _ theme: SendCollectibleBottomSheetViewTheme
    ) {
        transferActionView.contentEdgeInsets = UIEdgeInsets(theme.actionButtonContentEdgeInsets)
        transferActionView.draw(corner: theme.actionButtonCorner)
        transferActionView.customizeAppearance(theme.actionButton)

        contextView.addSubview(transferActionView)
        transferActionView.fitToIntrinsicSize()
        transferActionView.snp.makeConstraints {
            $0.top == addressInputView.snp.bottom + theme.actionButtonTopPadding
            $0.bottom == 0

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }

        startPublishing(
            event: .transfer,
            for: transferActionView
        )
    }
}

extension SendCollectibleBottomSheetView: FormInputFieldViewEditingDelegate {
    func formInputFieldViewDidBeginEditing(_ view: FormInputFieldView) {
        isEditing = true
    }

    func formInputFieldViewDidEndEditing(_ view: FormInputFieldView) {
        isEditing = false
    }

    func formInputFieldViewDidEdit(_ view: FormInputFieldView) {}
}

extension SendCollectibleBottomSheetView: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldView(
        _ view: MultilineTextInputFieldView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.sendCollectibleBottomSheetView(
            view,
            shouldChangeCharactersIn: range,
            replacementString: string
        )
    }

    func multilineTextInputFieldViewDidReturn(
        _ view: MultilineTextInputFieldView
    ) {
        view.endEditing()
    }
}

extension SendCollectibleBottomSheetView {
    func endEditing() {
        addressInputView.endEditing()
    }

    func setAddressInputViewText(
        _ text: String?
    ) {
        addressInputView.text = text
    }
}

extension SendCollectibleBottomSheetView {
    struct Handlers {
        var didHeightChange: ((CGFloat) -> Void)?
    }
}

extension SendCollectibleBottomSheetView {
    enum Position {
        case start
        case end
    }
}

extension SendCollectibleBottomSheetView {
    enum Event {
        case transfer
        case selectReceiverAccount
        case scanQR
        case close
    }
}

protocol SendCollectibleBottomSheetViewDelegate: AnyObject {
    func sendCollectibleBottomSheetView(
        _ view: MultilineTextInputFieldView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
}
