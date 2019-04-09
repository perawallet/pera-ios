//
//  SendAlgosSuccessView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosSuccessViewDelegate: class {
    
    func sendAlgosSuccessViewDidTapDoneButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
    func sendAlgosSuccessViewDidTapSendMoreButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
}

class SendAlgosSuccessView: BaseView {
    
    weak var delegate: SendAlgosSuccessViewDelegate?
    
}
