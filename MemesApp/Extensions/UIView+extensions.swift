//
//  UIView+extensions.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit

extension UIView {
    
    /// Rounds only the corners of the view passed in.
    /// - Parameters:
    ///   - corners: An array of possible UIRectCorners
    ///   - radius: The corner radius to apply to the passed in corners.
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
