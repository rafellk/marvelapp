//
//  LoadingView.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/19/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet private weak var loadingLabel: UILabel!
    
    var loadingText: String = "Processing" {
        didSet {
            loadingLabel.text = loadingText
        }
    }
}
