//
//  UIbtnExt.swift
//  YesNo
//
//  Created by KimSe young on 2/21/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func bounce(){
        let bouncy = CASpringAnimation(keyPath: "transform.scale.y")
        bouncy.duration = 1.0
        bouncy.fromValue = 1.0
        bouncy.toValue = 0.8
        bouncy.autoreverses = true
        bouncy.repeatCount = 2
        bouncy.initialVelocity = 0.5
        bouncy.damping = 1.0
//        bouncy.settlingDuration = 0.5
        
        layer.add(bouncy, forKey: nil)
    }
}
