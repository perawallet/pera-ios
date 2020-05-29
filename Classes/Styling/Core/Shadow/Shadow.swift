//
//  Shadow.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.04.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

struct Shadow {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}

let smallTopShadow = Shadow(color: SharedColors.smallTopShadow, offset: CGSize(width: 0.0, height: 4.0), radius: 6.0, opacity: 1.0)
let smallBottomShadow = Shadow(color: SharedColors.smallBottomShadow, offset: CGSize(width: 0.0, height: 1.0), radius: 3.0, opacity: 1.0)
let mediumTopShadow = Shadow(color: SharedColors.mediumTopShadow, offset: CGSize(width: 0.0, height: 4.0), radius: 12.0, opacity: 1.0)
let mediumBottomShadow = Shadow(color: SharedColors.mediumBottomShadow, offset: CGSize(width: 0.0, height: 2.0), radius: 6.0, opacity: 1.0)
let errorShadow = Shadow(color: SharedColors.errorShadow, offset: CGSize(width: 0.0, height: 8.0), radius: 20.0, opacity: 1.0)
let tabBarShadow = Shadow(color: UIColor.black.withAlphaComponent(0.1), offset: CGSize(width: 0.0, height: 4.0), radius: 32.0, opacity: 1.0)
