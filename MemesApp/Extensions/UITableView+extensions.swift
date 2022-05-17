//
//  UITableView+extensions.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit

extension UITableViewCell {
    /**
     Returns the class name as the default identifier.
     
     - Returns: String, The Class name.
     */
    public static var identifier: String {
        String(describing: self)
    }
    
}
