//
//  router.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class Router {
    
    // todo: create build script that loads all storyboards and creates an enumeration
    class func push(fromNavigationController navigationController: UINavigationController, toStoryboard storyboardName: String, withWiewControllerID id: String? = nil) {
        var nextViewController: UIViewController!
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let id = id {
            nextViewController = storyboard.instantiateViewController(identifier: id)
        } else {
            nextViewController = storyboard.instantiateInitialViewController()
        }
        
        navigationController.pushViewController(nextViewController, animated: true)
    }
}
