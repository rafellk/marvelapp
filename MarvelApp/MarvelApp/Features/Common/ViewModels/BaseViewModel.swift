//
//  BaseViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/18/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class BaseViewModel: NSObject {
    
    // Presenter view controller
    weak var viewController: UIViewController?
    
    init(withPresenter presenter: UIViewController) {
        super.init()
        viewController = presenter
    }

    func defaultErrorHandler(withError error: MarvelError, andRetrySelector selector: Selector? = nil) {
        presentErrorAlert(withMessage: error.localizedDescription, andRetrySelector: selector)
    }
    
    private func presentErrorAlert(withMessage message: String, andRetrySelector selector: Selector? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let retry = UIAlertAction(title: "Retry", style: .default) { [weak self] (_) in
            if let method = selector {
                self?.perform(method)
            }
        }
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)

        if selector != nil {
            alert.addAction(retry)
        }
        
        alert.addAction(ok)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
