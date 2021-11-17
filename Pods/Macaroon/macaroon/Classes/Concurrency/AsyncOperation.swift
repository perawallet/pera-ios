// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

open class AsyncOperation: Operation {
    open override var isReady: Bool {
        return
            super.isReady &&
            state == .ready
    }
    open override var isExecuting: Bool {
        return state == .executing
    }
    open override var isFinished: Bool {
        return state == .finished
    }
    open override var isAsynchronous: Bool {
        return true
    }

    public var state: State {
        get { atomicState }
        set {
            willChangeValue(
                forKey: state.rawValue
            )
            willChangeValue(
                forKey: newValue.rawValue
            )
            $atomicState.modify {
                $0 = newValue
            }
            didChangeValue(
                forKey: state.rawValue
            )
            didChangeValue(
                forKey: newValue.rawValue
            )
        }
    }

    @Atomic(identifier: "operationState")
    private var atomicState: State = .ready

    open override func start() {
        if isCancelled {
            finish()
            return
        }

        state = .executing

        main()
    }

    open func finish(force: Bool = true) {
        if force ||
           state == .executing {
            state = .finished
        }
    }

    open func finishIfCancelled() -> Bool {
        if !isCancelled {
            return false
        }

        finish()

        return true
    }
}

extension AsyncOperation {
    public enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
}
