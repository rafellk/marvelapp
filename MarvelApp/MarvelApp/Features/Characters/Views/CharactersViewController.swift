//
//  CharactersViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class CharactersViewController: UIViewController {
    
    @IBOutlet weak var collectionView: CharactersCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        populateCollectionView()
    }
    
    private func configureNavigationItem() {
        // TODO: localize this
        navigationItem.title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func populateCollectionView() {
        collectionView.datasource = [
            CharactersCollectionViewCellModel(characterImageURL: "testing",
                                              characterName: "Spider Man",
                                              isFavorite: false),
            CharactersCollectionViewCellModel(characterImageURL: "testing",
                                              characterName: "Spider Man",
                                              isFavorite: false),
            CharactersCollectionViewCellModel(characterImageURL: "testing",
                                              characterName: "Spider Man",
                                              isFavorite: false),
        ]
    }
}