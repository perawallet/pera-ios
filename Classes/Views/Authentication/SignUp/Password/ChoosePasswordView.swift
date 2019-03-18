//
//  ChoosePasswordView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ChoosePasswordView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // password display view
    
    // password input view
}
