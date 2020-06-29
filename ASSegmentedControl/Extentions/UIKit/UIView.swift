//
//  UIView.swift
//  ASSegmentedControl
//
//  Created by Aleksei Smirnov on 26.06.2020.
//  Copyright © 2020 Aleksei Smirnov. All rights reserved.
//

import UIKit

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
