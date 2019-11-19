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
    var viewModel: CharactersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        
        setupCollectionView()
        configureViewModel()
        
        fetchData()
    }
    
    private func configureNavigationItem() {
        // TODO: localize this
        navigationItem.title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// View Model methods
extension CharactersViewController {
    
    fileprivate func configureViewModel() {
        viewModel = CharactersViewModel(withPresenter: self)
        
        let _ = viewModel?.datasourceObservable.subscribe { [weak self] (event) in
            // todo: handle error here
            guard let datasource = event.element else { return }
            self?.update(datasouce: datasource)
        }
        
        let _ = viewModel?.isLoadingObservable.subscribe(onNext: { [weak self] (isLoading) in
            if isLoading {
                // todo: remove loading spinner
            } else {
                self?.collectionView.endRefreshing()
            }
        })
    }
    
    fileprivate func fetchData() {
        viewModel?.fetchCharacters()
    }
    
    fileprivate func fetchMoreData() {
        viewModel?.fetchPaginatedCharacters()
    }
}

// Collection view related methods
extension CharactersViewController {
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.charactersCollectionViewDelegate = self
    }
    
    fileprivate func update(datasouce: [CharactersCollectionViewModel]) {
        collectionView.datasource = datasouce
    }
}

extension CharactersViewController: CharactersCollectionViewDelegate {
    func didPullRefresh() {
        fetchData()
    }
    
    func didReachTheEnd() {
        fetchMoreData()
    }
}

extension CharactersViewController: UICollectionViewDelegate {
}
