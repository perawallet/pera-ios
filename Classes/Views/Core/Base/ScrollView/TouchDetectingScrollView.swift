//
//  TouchDetectingScrollView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 31.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
