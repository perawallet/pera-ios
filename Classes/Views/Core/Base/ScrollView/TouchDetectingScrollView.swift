//
//  TouchDetectingScrollView.swift

import UIKit

protocol TouchDetectingScrollViewDelegate: NSObjectProtocol {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint)
}

class TouchDetectingScrollView: UIScrollView {
    
    weak var touchDetectingDelegate: TouchDetectingScrollViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        touchDetectingDelegate?.scrollViewDidDetectTouchEvent(scrollView: self, in: point)
        return super.hitTest(point, with: event)
    }
}
