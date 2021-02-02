//
//  PollingOperation.swift

import UIKit

class PollingOperation {
    
    private var timer: DispatchSourceTimer?
    private let interval: TimeInterval
    private let handler: EmptyHandler
    
    private var isRunning = false
    
    // MARK: Initialization
    
    init(interval: TimeInterval, handler: @escaping EmptyHandler) {
        self.interval = interval
        self.handler = handler
    }
    
    deinit {
        invalidate()
    }
    
    // MARK: API
    
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        
        timer = DispatchSource.makeTimerSource()
        
        guard let timer = timer else {
            return
        }
        
        timer.schedule(deadline: .now() + interval, repeating: interval)
        
        timer.setEventHandler {
            self.handler()
        }
        
        timer.resume()
    }
    
    func invalidate() {
        guard let timer = timer else {
            
            isRunning = false
            
            return
        }
        
        timer.cancel()
        self.timer = nil
        
        isRunning = false
    }
}
