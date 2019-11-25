//
//  router.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class Router {
    
    class func toCharacterViewController(fromNavigationController navigationController: UINavigationController, withModel model: Character) {
        if let viewController: CharacterViewController = getViewController(fromStoryboardName: "Character") {
            viewController.model = model
            navigationController.pushViewController(viewController, animated: true)            
        }
    }
    
    private class func getViewController<T>(fromStoryboardName storyboardName: String, andViewControllerID id: String? = nil) -> T? where T: UIViewController {
        var nextViewController: T?
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let id = id {
            nextViewController = storyboard.instantiateViewController(identifier: id)
        } else {
            nextViewController = storyboard.instantiateInitialViewController()
        }
        
        return nextViewController
    }
}
