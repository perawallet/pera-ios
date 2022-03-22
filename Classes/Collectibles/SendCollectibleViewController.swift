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

final class SendCollectibleViewController: BaseScrollViewController {
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

    private let draft: SendCollectibleDraft
    private let theme: SendCollectibleViewControllerTheme

    init(
        draft: SendCollectibleDraft,
        theme: SendCollectibleViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
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
        /// <todo>: Bind properly

        if let image = draft.image {
            imageView.imageContainer.image = image
        } else {
            /// <todo> Load image
        }

        titleView.text = "MetaRilla"
        subtitleView.text = "MetaRilla#10"
    }
}

extension SendCollectibleViewController {
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

        bottomSheetView.observe(event: .transfer) {
            [weak self] in
            self?.makeTransfer()
        }

        bottomSheetView.observe(event: .selectReceiverAccount) {
            [weak self] in
            self?.openSelectReceiver()
        }

        bottomSheetView.observe(event: .scanQR) {
            [weak self] in
            self?.openScanQR()
        }

        bottomSheetView.observe(event: .close) {
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
        /// <todo>: Make the transfer & open the related screens/error/success modals.
    }
}

extension SendCollectibleViewController {
    private func openSelectReceiver() {
        /// <todo>: Open select receiver screen & bind the selected account's address to address input after selection.
    }

    private func openScanQR() {
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

        bottomSheetView.setAddressInputViewText(qrAddress)
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
    func sendCollectibleBottomSheetView(
        _ view: MultilineTextInputFieldView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = view.text else {
            return true
        }

        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        return newText.hasValidAddressLength
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
    enum ImageLayout {
        case initial
        case custom(height: CGFloat)
    }
}
