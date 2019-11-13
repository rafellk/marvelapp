//
//  UICollectionView+Extension.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/13/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    /**
     This method registers a collection view cell using the given nib name as input and building its reuse identifier string using the nib name and appending
     in the end `ID`.
     - parameter nibName: The cell nib name you wish to register
     */
    func register(cellWithNibName nibName: String) {
        register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: "\(nibName)ID")
    }
}
