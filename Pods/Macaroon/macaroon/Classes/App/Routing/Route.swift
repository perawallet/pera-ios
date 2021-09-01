// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public struct Route<
    SomeFlow: Flow,
    SomePath: Path
>: Equatable {
    let identifier: String
    let flow: SomeFlow
    let destination: Destination
    let transitionStyle: TransitionStyle

    init(
        flow: SomeFlow,
        destination: Destination,
        transitionStyle: TransitionStyle
    ) {
        self.identifier = UUID().uuidString
        self.flow = flow
        self.destination = destination
        self.transitionStyle = transitionStyle
    }
}

extension Route {
    public static func flow(
        _ flow: SomeFlow,
        at existingPath: ExistingPath = .last
    ) -> Self {
        return .init(flow: flow, destination: .existing(existingPath), transitionStyle: .existing)
    }

    public static func path(
        _ existingScreen: ScreenRoutable
    ) -> Self {
        return .flow(.instance(existingScreen.flowIdentifier), at: .interim(existingScreen))
    }

    public static func next(
        _ paths: SomePath...
    ) -> Self {
        return .init(flow: .current, destination: .new(paths), transitionStyle: .next)
    }

    public static func stack(
        _ paths: SomePath...
    ) -> Self {
        return .init(flow: .current, destination: .new(paths), transitionStyle: .stack)
    }

    public static func stack(
        _ paths: SomePath...,
        attachedTo existingScreen: ScreenRoutable
    ) -> Self {
        return .init(
            flow: .instance(existingScreen.flowIdentifier),
            destination: .override(existingScreen, paths),
            transitionStyle: .stack
        )
    }

    public static func modal(
        _ paths: SomePath...
    ) -> Self {
        return .init(flow: .current, destination: .new(paths), transitionStyle: .modal)
    }

    public static func builtInModal(
        _ paths: SomePath...,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        modalTransitionStyle: UIModalTransitionStyle? = nil
    ) -> Self {
        return .init(
            flow: .current,
            destination: .new(paths),
            transitionStyle: .builtInModal(modalPresentationStyle, modalTransitionStyle)
        )
    }

    public static func customModal(
        _ paths: SomePath...,
        transitioningDelegate: UIViewControllerTransitioningDelegate
    ) -> Self {
        return .init(
            flow: .current,
            destination: .new(paths),
            transitionStyle: .customModal(transitioningDelegate)
        )
    }
}

extension Route {
    public static func ==(
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Route {
    enum Destination {
        case existing(ExistingPath)
        case new([SomePath])
        case override(ScreenRoutable, [SomePath])
    }

    enum TransitionStyle {
        /// <mark>
        /// A backward transition to an existing path, or an application flow.
        case existing

        /// <mark>
        /// A forward transition to a new path.
        case next
        case stack
        case modal
        case builtInModal(UIModalPresentationStyle, UIModalTransitionStyle?)
        case customModal(UIViewControllerTransitioningDelegate)
    }
}
