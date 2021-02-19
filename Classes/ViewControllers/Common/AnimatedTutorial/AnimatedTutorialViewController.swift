//
//  AnimatedTutorialViewController.swift

import UIKit

class AnimatedTutorialViewController: BaseScrollViewController {

    private let tutorial: AnimatedTutorial
    private let isActionable: Bool

    private lazy var animatedTutorialView = AnimatedTutorialView(isActionable: isActionable)

    init(tutorial: AnimatedTutorial, isActionable: Bool, configuration: ViewControllerConfiguration) {
        self.tutorial = tutorial
        self.isActionable = isActionable
        super.init(configuration: configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatedTutorialView.startAnimating(with: LottieConfiguration())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animatedTutorialView.stopAnimating()
    }

    override func configureAppearance() {
        super.configureAppearance()
        setTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        contentView.backgroundColor = Colors.Background.tertiary
        animatedTutorialView.bind(AnimatedTutorialViewModel(tutorial: tutorial))
    }

    override func linkInteractors() {
        super.linkInteractors()
        animatedTutorialView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupAnimatedTutorialViewLayout()
    }
}

extension AnimatedTutorialViewController {
    private func setupAnimatedTutorialViewLayout() {
        contentView.addSubview(animatedTutorialView)
        animatedTutorialView.pinToSuperview()
    }
}

extension AnimatedTutorialViewController: AnimatedTutorialViewDelegate {
    func animatedTutorialViewDidApproveTutorial(_ animatedTutorialView: AnimatedTutorialView) {

    }

    func animatedTutorialViewDidTakeAction(_ animatedTutorialView: AnimatedTutorialView) {

    }
}

enum AnimatedTutorial {
    case backUp
    case writePassphrase
    case watchAccount
    case recover
    case passcode
    case localAuthentication
}
