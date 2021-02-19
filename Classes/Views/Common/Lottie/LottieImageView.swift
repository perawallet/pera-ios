//
//  LottieImageView.swift

import Lottie

class LottieImageView: BaseView {

    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.contentMode = .scaleAspectFit
        return animationView
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(animationView)
    }
}

extension LottieImageView {
    func setAnimation(_ animation: String) {
        let animation = Animation.named(animation)
        animationView.animation = animation
    }

    func show(with configuration: LottieConfiguration) {
        animationView.play(fromProgress: configuration.from, toProgress: configuration.to, loopMode: configuration.loopMode)
    }

    func stop() {
        animationView.stop()
    }
}

struct LottieConfiguration {
    var from: AnimationProgressTime = 0
    var to: AnimationProgressTime = 1
    var loopMode: LottieLoopMode = .playOnce
}
