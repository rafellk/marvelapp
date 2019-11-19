//
//  UIView+Extension.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/19/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     Method that instantiates the class associated with the specified nib name.
     - parameter nib: String that represents the nib file name
     - returns: A class that extends the UIView class that is associated with the nib name specified. Nil, if the nib file was not found or if the nib file
     found does not match the generics type
     */
    class func instantiate<T>(withNibName nib: String) -> T? where T: UIView {
        return UINib(nibName: nib, bundle: nil).instantiate(withOwner: nil, options: nil).first as? T
    }
}
