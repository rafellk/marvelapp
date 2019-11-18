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
    var viewModel = CharactersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        setupCollectionView()
        viewModel.fetchCharacters()
    }
    
    private func configureNavigationItem() {
        // TODO: localize this
        navigationItem.title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// Collection view related methods
extension CharactersViewController {
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.charactersCollectionViewDelegate = self
    }
    
    fileprivate func fetchData() {
        viewModel.fetchCharacters()

//        collectionView.datasource = [
//            CharactersCollectionViewModel(characterImageURL: "testing",
//                                              characterName: "Capitain America",
//                                              isFavorite: false),
//            CharactersCollectionViewModel(characterImageURL: "testing",
//                                              characterName: "Iron Man",
//                                              isFavorite: false),
//            CharactersCollectionViewModel(characterImageURL: "testing",
//                                              characterName: "Spider Foca",
//                                              isFavorite: true),
//        ]
    }

}

extension CharactersViewController: CharactersCollectionViewDelegate {
    func didPullRefresh() {
        fetchData()
    }
}

extension CharactersViewController: UICollectionViewDelegate {
}
