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
    fileprivate var loadingView: LoadingView?
    @IBOutlet weak var emptyListLabel: UILabel!
    
    var viewModel: CharactersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationItem()
        configureLoadingView()
        
        setupCollectionView()
        configureViewModel()
        
        configureEmptyListLabel()
        fetchData()
    }
    
    private func configureNavigationItem() {
        // TODO: localize this
        navigationItem.title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureLoadingView() {
        loadingView = UIView.instantiate(withNibName: "LoadingView")
        loadingView?.frame = view.frame
    }
}

// View Model methods
extension CharactersViewController {
    
    fileprivate func configureViewModel() {
        viewModel = CharactersViewModel(withPresenter: self)
        
        // todo: move callbacks to view model
        let _ = viewModel?.datasourceObservable.subscribe { [weak self] (event) in
            // todo: handle error here
            guard let datasource = event.element else { return }
            self?.update(datasource: datasource)
        }
        
        let _ = viewModel?.isLoadingObservable.subscribe(onNext: { [weak self] (isLoading) in
            if isLoading {
                if let control = self?.collectionView.refreshControl, control.isRefreshing { return }
                self?.showProgress()
            } else {
                self?.collectionView.endRefreshing()
                self?.hideProgress()
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

extension CharactersViewController {
    
    fileprivate func configureEmptyListLabel() {
        // todo: localize this
        emptyListLabel.text = "No data found. Try again later."
        emptyListLabel.isHidden = true
    }
}

// Collection view related methods
extension CharactersViewController {
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.charactersCollectionViewDelegate = self
    }
    
    fileprivate func update(datasource: [CharactersCollectionViewModel]) {
        emptyListLabel.isHidden = !datasource.isEmpty
        collectionView.datasource = datasource
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

extension CharactersViewController {
    fileprivate func showProgress() {
        if let loadingView = loadingView {
            loadingView.layer.opacity = 0
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.addSubview(loadingView)
                loadingView.layer.opacity = 1
            }
        }
    }
    
    fileprivate func hideProgress() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.loadingView?.layer.opacity = 0
            self?.loadingView?.removeFromSuperview()
        }
    }
}

extension CharactersViewController: UICollectionViewDelegate {
}
