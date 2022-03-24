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

//   SendCollectibleViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage
import SnapKit
import MagpieCore

final class SendCollectibleViewController: BaseScrollViewController {
    lazy var uiInteractions = SendCollectibleUIInteractions()
    private lazy var  bottomTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var contextViewContainer = MacaroonUIKit.BaseView()
    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var imageView = URLImageView()
    private lazy var titleAndSubtitleContainer = MacaroonUIKit.BaseView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    private lazy var bottomSheetView = SendCollectibleBottomSheetView()

    private lazy var backgroundStartStyle: ViewStyle = []
    private lazy var backgroundEndStyle: ViewStyle = []

    private lazy var keyboardController = KeyboardController()

    private lazy var keyboardHeight: CGFloat = .zero
    private lazy var bottomSheetHeightDiff: CGFloat = .zero

    private var draft: SendCollectibleDraft
    private let theme: SendCollectibleViewControllerTheme
    private let transactionController: TransactionController

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private var ongoingFetchAccountsEnpoint: EndpointOperatable?

    init(
        draft: SendCollectibleDraft,
        transactionController: TransactionController,
        theme: SendCollectibleViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.transactionController = transactionController
        self.theme = theme
        super.init(configuration: configuration)
    }

    deinit {
        keyboardController.endTracking()
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateBottomSheetLayout()
    }

    override func linkInteractors() {
        linkTransactionControllerInteractors()
        linkScrollViewInteractors()
        linkKeyboardInteractors()
        linkBottomSheetInteractors()
        linkViewInteractors()
    }

    override func prepareLayout() {
        super.prepareLayout()

        build()
        bind()
    }

    private func build() {
        addBackground()
        addContext()
        addBottomSheet()
    }

    private func bind() {
        let viewModel = SendCollectibleViewModel(
            imageSize: imageView.frame.size,
            draft: draft
        )

        if let image = draft.image {
            imageView.imageContainer.image = image
        } else {
            imageView.load(from: viewModel.image)
        }

        titleView.editText = viewModel.title
        subtitleView.editText = viewModel.subtitle
    }
}

extension SendCollectibleViewController {
    private func linkTransactionControllerInteractors() {
        transactionController.delegate = self
    }

    private func linkScrollViewInteractors() {
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
    }

    private func linkKeyboardInteractors() {
        keyboardController.dataSource = self
        keyboardController.beginTracking()

        keyboardController.notificationHandlerWhenKeyboardShown = {
            [weak self] keyboard in
            self?.keyboardHeight = keyboard.height
        }

        keyboardController.notificationHandlerWhenKeyboardHidden = {
            [weak self] _ in
            self?.keyboardHeight = .zero
        }
    }

    private func linkBottomSheetInteractors() {
        bottomSheetView.delegate = self

        bottomSheetView.handlers.didHeightChange = {
            [weak self] bottomSheetNewHeight in
            self?.handleBottomSheetHeightChange(bottomSheetNewHeight)
        }

        bottomSheetView.observe(event: .performTransfer) {
            [weak self] in
            self?.makeTransfer()
        }

        bottomSheetView.observe(event: .performSelectReceiverAccount) {
            [weak self] in
            self?.openSelectReceiver()
        }

        bottomSheetView.observe(event: .performScanQR) {
            [weak self] in
            self?.openScanQR()
        }

        bottomSheetView.observe(event: .performClose) {
            [weak self] in
            self?.dismissWithAnimation()
        }
    }

    private func linkViewInteractors() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(closeKeyboard)
            )
        )
    }
}

extension SendCollectibleViewController {
    private func addBackground() {
        backgroundStartStyle = theme.backgroundStart
        backgroundEndStyle = theme.backgroundEnd

        updateBackground(for: .start)
    }

    private func addContext()  {
        contentView.addSubview(contextViewContainer)
        contextViewContainer.snp.makeConstraints {
            $0.top <= view.safeAreaLayoutGuide.snp.top + theme.contextViewContainerTopPadding
            $0.setPaddings(
                (.noMetric, theme.horizontalPadding, .noMetric, theme.horizontalPadding)
            )
        }

        contextViewContainer.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top >= 0
            $0.bottom == 0
            $0.trailing == 0
            $0.leading == 0
            $0.center == 0
        }

        addImage()
        addTitleAndSubtitleContainer()
    }
    
    private func addImage() {
        imageView.customizeAppearance(theme.image)
        imageView.layer.draw(corner: theme.imageCorner)
        imageView.clipsToBounds = true

        contextView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
            $0.height == imageView.snp.width
        }
    }

    private func addTitleAndSubtitleContainer() {
        let aCanvasView = MacaroonUIKit.BaseView()

        contextView.addSubview(aCanvasView)
        aCanvasView.snp.makeConstraints {
            $0.top == imageView.snp.bottom
            $0.centerX == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        aCanvasView.addSubview(titleAndSubtitleContainer)
        titleAndSubtitleContainer.snp.makeConstraints {
            $0.top >= theme.titleAndSubtitleContainerVerticalPaddings.top
            $0.bottom <= theme.titleAndSubtitleContainerVerticalPaddings.bottom
            $0.center == 0

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }

        addTitle()
        addSubtitle()
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        titleAndSubtitleContainer.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }

    private func addSubtitle() {
        subtitleView.customizeAppearance(theme.subtitle)

        subtitleView.contentEdgeInsets.top = theme.subtitleTopPadding
        subtitleView.fitToIntrinsicSize()
        titleAndSubtitleContainer.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }

    private func addBottomSheet() {
        bottomSheetView.customize(theme.bottomSheetViewTheme)

        contentView.addSubview(bottomSheetView)
        bottomSheetView.fitToIntrinsicSize()
        bottomSheetView.snp.makeConstraints {
            $0.top == contextViewContainer.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}

extension SendCollectibleViewController {
    @objc
    private func closeKeyboard() {
        bottomSheetView.endEditing()
    }
}

extension SendCollectibleViewController {
    private func makeTransfer() {
        cancelOngoingFetchAccountsEnpoint()

        guard let recipientAddress = bottomSheetView.addressInputViewText else {
            return
        }

        let accountInShared = sharedDataController
            .accountCollection
            .account(for: recipientAddress)

        if let accountInShared = accountInShared {

            if draft.fromAccount.address == recipientAddress,
               accountInShared.containsCollectibleAsset(draft.collectibleAsset.id) {
                bannerController?.presentErrorBanner(
                    title: "asset-you-already-own-message".localized,
                    message: .empty
                )
                return
            }

            makeTransfer(
                for: accountInShared
            )

            return
        }

        bottomSheetView.startLoading()

        ongoingFetchAccountsEnpoint =
        api?.fetchAccount(
            AccountFetchDraft(publicKey: recipientAddress),
            queue: .main,
            ignoreResponseOnCancelled: true
        ) {
            [weak self] response in
            guard let self = self else { return }
            self.bottomSheetView.stopLoading()

            switch response {
            case .success(let accountResponse):
                let fetchedAccount = accountResponse.account

                if !fetchedAccount.isSameAccount(with: recipientAddress) {
                    UIApplication.shared.firebaseAnalytics?.record(
                        MismatchAccountErrorLog(
                            requestedAddress: recipientAddress,
                            receivedAddress: fetchedAccount.address
                        )
                    )
                    return
                }

                self.makeTransfer(
                    for: fetchedAccount
                )
            case .failure(_, _):
                break /// <todo> Show response error
            }
        }
    }

    private func makeTransfer(
        for account: Account
    ) {
        draft.toAccount = account

        let collectibleAsset = account.assets?.first(matching: (\.id, draft.collectibleAsset.id))

        guard let collectibleAsset = collectibleAsset else {
            openAskRecipientToOptIn()
            return
        }

        let isNotOwned = (collectibleAsset.amount == 0)

        if isNotOwned {
            composeCollectibleAssetTransactionData()
        }
    }

    private func cancelOngoingFetchAccountsEnpoint() {
        ongoingFetchAccountsEnpoint?.cancel()
        ongoingFetchAccountsEnpoint = nil
    }
}

extension SendCollectibleViewController {
    private func openSelectReceiver() {
        closeKeyboard()

        let screen = open(
            .sendCollectibleAccountList(
                dataController: SendCollectibleAccountListAPIDataController(sharedDataController)
            ),
            by: .present
        ) as? SendCollectibleAccountListViewController
        screen?.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }
            self.bottomSheetView.recustomizeTransferActionButtonAppearance(
                self.theme.bottomSheetViewTheme,
                isEnabled: true
            )

            switch event {
            case .didSelectAccount(let account):
                self.bottomSheetView.addressInputViewText = account.address
                self.draft.toAccount = account

                screen?.dismissScreen()
            case .didSelectContact(let contact):
                self.bottomSheetView.addressInputViewText = contact.address
                self.draft.toContact = contact

                screen?.dismissScreen()
            }
        }
    }

    private func openScanQR() {
        closeKeyboard()

        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(
                title: "qr-scan-error-title".localized,
                message: "qr-scan-error-message".localized
            )
            return
        }

        let qrScannerViewController = open(
            .qrScanner(canReadWCSession: false)
            , by: .push
        ) as? QRScannerViewController

        qrScannerViewController?.delegate = self
    }

    private func openApproveTransaction() {
        let screen = bottomTransition.perform(
            .approveCollectibleTransaction(
                draft: draft,
                transactionController: transactionController
            ),
            by: .presentWithoutNavigationController
        ) as? ApproveCollectibleTransactionViewController

        screen?.handlers.didSendTransactionSuccessfully = {
            [unowned self] _ in
            /// <todo> Dismiss screen properly.
            self.openSuccessScreen()
        }
    }

    private func openSuccessScreen() {
        let controller = open(
            .tutorial(flow: .none, tutorial: .collectibleTransferConfirmed),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            then: {
                [unowned self] in
                self.uiInteractions.didSendTransactionSuccessfully?(self)
            }
        ) as? TutorialViewController

        controller?.uiHandlers.didTapButtonPrimaryActionButton = {
            controller in
            controller.dismissScreen()
        }
    }

    private func openAskRecipientToOptIn() {
        let asset = draft.collectibleAsset
        let title = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))
        let to = draft.toContact?.address ?? draft.toAccount?.address

        let description = "collectible-recipient-opt-in-description".localized(title, to!)

        let configuratorDescription =
        BottomWarningViewConfigurator.BottomWarningDescription.custom(
            description: (description, [title, to!]), /// <todo> Change font & color of params.
            markedWordWithHandler: (
                word: "collectible-recipient-opt-in-description-marked".localized,
                handler: {
                    [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.bottomTransition.presentedViewController?.dismissScreen() {
                        self.openOptInInformation()
                    }
                }
            )
        )

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green".uiImage,
            title: "collectible-recipient-opt-in-title".localized,
            description: configuratorDescription,
            primaryActionButtonTitle: "collectible-recipient-opt-in-action-title".localized,
            secondaryActionButtonTitle: "title-close".localized,
            primaryAction: {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.requestOptInToRecipeint()
            }
        )

        bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func openOptInInformation() {
        let configurator = BottomWarningViewConfigurator(
            title: "collectible-opt-in-info-title".localized,
            description: .plain("collectible-opt-in-info-description".localized),
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func openTransferFailed(
        title: String = "collectible-transfer-failed-title".localized,
        description: String = "collectible-transfer-failed-verify-algo-desription".localized
    ) {
        let configurator = BottomWarningViewConfigurator(
            title: title,
            description: .plain(description),
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendCollectibleViewController {
    private func requestOptInToRecipeint() {
        let receiverAddress = bottomSheetView.addressInputViewText

        if let receiverAddress = receiverAddress {
            let draft = AssetSupportDraft(
                sender: draft.fromAccount.address,
                receiver: receiverAddress,
                assetId: draft.collectibleAsset.id
            )

            api?.sendAssetSupportRequest(
                draft
            )
        }
    }
}

extension SendCollectibleViewController {
    private func composeCollectibleAssetTransactionData() {
        let transactionDraft = AssetTransactionSendDraft(
            from: draft.fromAccount,
            toAccount: draft.toAccount,
            amount: draft.collectibleAsset.amountWithFraction,
            assetIndex: draft.collectibleAsset.id,
            assetDecimalFraction: draft.collectibleAsset.presentation.decimals,
            isVerifiedAsset: draft.collectibleAsset.presentation.isVerified,
            note: nil,
            toContact: draft.toContact,
            asset: draft.collectibleAsset
        )
        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetTransaction)
        
        if draft.fromAccount.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

}

extension SendCollectibleViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController?.stopLoading()

        switch error {
        case .network:
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "title-internet-connection".localized
            )
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()
        self.draft.fee = draft?.fee
        openApproveTransaction()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            openTransferFailed(
                description: "send-algos-minimum-amount-custom-error".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            bottomTransition.perform(
                .bottomWarning(
                    configurator: BottomWarningViewConfigurator(
                        image: "icon-info-green".uiImage,
                        title: "ledger-pairing-issue-error-title".localized,
                        description: .plain("ble-error-fail-ble-connection-repairing".localized),
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "title-internet-connection".localized
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerApprovalViewController = bottomTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }
}

extension SendCollectibleViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        guard qrText.mode == .address,
              let qrAddress = qrText.address else {
                  displaySimpleAlertWith(
                    title: "title-error".localized,
                    message: "qr-scan-should-scan-address-message".localized
                  ) { _ in
                      completionHandler?()
                  }
                  return
              }

        bottomSheetView.addressInputViewText = qrAddress
    }

    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            completionHandler?()
        }
    }
}

extension SendCollectibleViewController: SendCollectibleBottomSheetViewDelegate {
    func sendCollectibleBottomSheetViewDidEdit(
        _ view: SendCollectibleBottomSheetView
    ) {
        bottomSheetView.recustomizeTransferActionButtonAppearance(
            theme.bottomSheetViewTheme,
            isEnabled: isTransferActionButtonEnabled(view)
        )
    }

    func sendCollectibleBottomSheetViewShouldChangeCharactersIn(
        _ view: SendCollectibleBottomSheetView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = view.addressInputViewText else {
            return true
        }

        let newText = text.replacingCharacters(
            in: range,
            with: string
        )

        return newText.count <= validatedAddressLength
    }

    private func isTransferActionButtonEnabled(
        _ view: SendCollectibleBottomSheetView
    ) -> Bool {
        if let input = view.addressInputViewText,
           input.hasValidAddressLength &&
            input.isValidatedAddress {
            return true
        }

        return false
    }
}

extension SendCollectibleViewController {
    private func handleBottomSheetHeightChange(
        _ bottomSheetNewHeight: CGFloat
    ) {

        let isKeyboardHidden = keyboardHeight == 0

        guard isKeyboardHidden else {
            return
        }

        /// <note>
        /// When text is deleted, resize image to its initial size if needed.
        if bottomSheetView.initialHeight == bottomSheetNewHeight {
            updateImageBeforeAnimations(for: .initial)
            animateImageLayout(imageView)
            return
        }

        /// <note>
        /// If text is changed but keyboard isn't used we get the diff between `bottomSheetNewHeight` and `bottomSheetView.initialHeight`. If diff is different than initial height, we substract the diff from the image size then apply the animations.
        if bottomSheetView.isEditing {
            bottomSheetHeightDiff = bottomSheetNewHeight - bottomSheetView.initialHeight

            if bottomSheetHeightDiff != 0 {
                let imageHorizontalPaddings = 2 * theme.horizontalPadding
                let initialImageHeight = contextViewContainer.frame.width - imageHorizontalPaddings

                let imageMaxHeight = initialImageHeight
                let imageViewHeight = max(
                    theme.imageMinHeight,
                    imageMaxHeight - bottomSheetHeightDiff
                )

                updateImageBeforeAnimations(
                    for: .custom(height: imageViewHeight)
                )

                animateImageLayout(imageView)
            }
        }
    }
}

extension SendCollectibleViewController {
    private func updateImageBeforeAnimations(
        for layout: ImageLayout
    ) {
        switch layout {
        case .initial:
            let imageHorizontalPaddings = 2 * theme.horizontalPadding
            let initialImageHeight = contextViewContainer.frame.width - imageHorizontalPaddings
            let currentImageHeight = imageView.frame.height

            let isUpdateNeeded = currentImageHeight != initialImageHeight

            guard isUpdateNeeded else {
                return
            }

            imageView.snp.remakeConstraints {
                $0.centerX == 0
                $0.top == 0
                $0.leading == theme.horizontalPadding
                $0.trailing == theme.horizontalPadding
                $0.height == imageView.snp.width
            }
        case .custom(let height):
            imageView.snp.remakeConstraints {
                $0.centerX == 0
                $0.top == 0
                $0.leading >= theme.horizontalPadding
                $0.trailing <= theme.horizontalPadding
                $0.fitToSize(
                    (
                        height,
                        height
                    )
                )
            }
        }
    }
}

extension SendCollectibleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let imageHorizontalPaddings = 2 * theme.horizontalPadding
        let initialImageHeight = contextViewContainer.frame.width - imageHorizontalPaddings

        var imageViewMaxHeight = initialImageHeight

        if keyboardHeight == 0 {
            imageViewMaxHeight -= bottomSheetHeightDiff
        }

        let calculatedHeight = imageViewMaxHeight - contentY

        var imageViewHeight = max(
            theme.imageMinHeight,
            theme.imageMinHeight * calculatedHeight / imageViewMaxHeight
        )

        if contentY == 0 {
            imageViewHeight = imageViewMaxHeight
        }

        updateImageBeforeAnimations(for: .custom(height: imageViewHeight))
        animateContentLayout(view)
    }
}

extension SendCollectibleViewController {
    private func dismissWithAnimation() {
        bottomSheetView.endEditing()

        updateImageBeforeAnimations(for: .initial)
        bottomSheetView.updateContentBeforeAnimations(for: .start)

        animateContentLayout(view) {
            [weak self] in
            self?.dismissScreen(
                animated: true,
                completion: nil
            )
        }
    }
}

extension SendCollectibleViewController {
    private func animateContentLayout(
        _ view: UIView,
        completion: EmptyHandler? = nil
    ) {
        let property = UIViewPropertyAnimator(
            duration: 0.5,
            dampingRatio: 0.8
        ) {
            view.layoutIfNeeded()
        }
        property.addCompletion { _ in
            completion?()
        }
        property.startAnimation()
    }

    private func animateImageLayout(
        _ view: UIView
    ) {
        let animator = UIViewPropertyAnimator(
            duration: 0.5,
            curve: .easeInOut
        ) {
            view.layoutIfNeeded()
        }

        animator.startAnimation()
    }

    private func animateBottomSheetLayout() {
        bottomSheetView.updateContentBeforeAnimations(for: .end)

        let animator = UIViewPropertyAnimator(
            duration: 0.5,
            dampingRatio: 0.8
        ) {
            [unowned self] in

            updateAlongsideAnimations(for: .end)
            view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
}

extension SendCollectibleViewController {
    private func updateAlongsideAnimations(
        for position: SendCollectibleBottomSheetView.Position
    ) {
        updateBackground(for: position)
        bottomSheetView.updateContentAlongsideAnimations(for: position)
    }
}

extension SendCollectibleViewController {
    private func updateBackground(
        for position: SendCollectibleBottomSheetView.Position
    ) {
        let style: ViewStyle

        switch position {
        case .start: style = backgroundStartStyle
        case .end: style = backgroundEndStyle
        }

        view.customizeAppearance(style)
    }
}

extension SendCollectibleViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(
        for keyboardController: KeyboardController
    ) -> CGFloat {
        return .zero
    }

    func firstResponder(
        for keyboardController: KeyboardController
    ) -> UIView? {
        return bottomSheetView
    }

    func containerView(
        for keyboardController: KeyboardController
    ) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(
        for keyboardController: KeyboardController
    ) -> CGFloat {
        return .zero
    }
}

extension SendCollectibleViewController {
    struct SendCollectibleUIInteractions {
        var didSendTransactionSuccessfully: ((SendCollectibleViewController) -> Void)?
    }
}

extension SendCollectibleViewController {
    enum ImageLayout {
        case initial
        case custom(height: CGFloat)
    }
}
