//
//  FavoritesViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/21/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class FavoritesViewController: BaseCharactersViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem(withTitle: "Favorites")
        collectionView.isInfiniteScrollActivated = false
    }
}

// Data handler extension
extension FavoritesViewController {
    
    override func fetchData() {
        viewModel?.fetchFavorites()
    }
    
    override func fetchMoreData() {}
}
