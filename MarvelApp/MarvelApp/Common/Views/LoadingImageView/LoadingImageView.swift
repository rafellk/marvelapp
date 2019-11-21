//
//  LoadingImageView.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/20/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class LoadingImageView: UIImageView {
    
    var loadingView: LoadingView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingView?.frame = frame
    }
    
    func configureLoadingState() {
        loadingView = UIView.instantiate(withNibName: "LoadingView")
        loadingView?.loadingText = ""
        
        loadingView?.center = CGPoint(x: frame.size.width  / 2, y: frame.size.height / 2)
        
        image = UIImage(named: "marvel_icon")
        
        if let loadingView = loadingView {
            addSubview(loadingView)
        }
    }
    
    func configureImageState(withImage image: UIImage?) {
        loadingView?.removeFromSuperview()
        self.image = image
    }
}
