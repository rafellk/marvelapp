//
//  CharactersViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/21/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class BaseCharactersViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var collectionView: CharactersCollectionView!
    @IBOutlet weak var emptyListLabel: UILabel!
    
    private var loadingView: LoadingView?
    var viewModel: CharactersViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLoadingView()
        
        setupCollectionView()
        configureViewModel()
        
        configureEmptyListLabel()
        fetchData()
    }
    
    func configureNavigationItem(withTitle title: String) {
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureLoadingView() {
        loadingView = UIView.instantiate(withNibName: "LoadingView")
        loadingView?.frame = view.frame
    }
}

// View Model methods
extension BaseCharactersViewController {
    
    @objc
    func configureViewModel() {
        viewModel = CharactersViewModel(withPresenter: self)
        
        let _ = viewModel?.datasourceObservable.subscribe(onNext: { [weak self] (datasource) in
            print("rlmg datasource: \(datasource.count)")
            self?.collectionView.isFiltering = false
            self?.update(datasource: datasource)
        })
        
        let _ = viewModel?.modelsToUpdateObservable.subscribe(onNext: { (values) in
            if !values.isEmpty {
                let indexPaths = values.map { IndexPath(item: $0, section: 0) }
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadItems(at: indexPaths)
                }
            }
        })

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
    
    @objc
    func fetchData() {
        assert(false, "Subclasses must implement this method")
    }
    
    @objc
    func fetchMoreData() {
        assert(false, "Subclasses must implement this method")
    }
}

// Empty list extension
extension BaseCharactersViewController {
    
    fileprivate func configureEmptyListLabel() {
        // todo: localize this
        emptyListLabel.text = "No data found. Try again later."
        emptyListLabel.isHidden = true
    }
}

// Collection view related methods
extension BaseCharactersViewController {
    
    fileprivate func setupCollectionView() {
        collectionView.charactersCollectionViewDelegate = self
    }
    
    func update(datasource: [Character]) {
        emptyListLabel.isHidden = !datasource.isEmpty
        collectionView.datasource = datasource
    }
}

extension BaseCharactersViewController: CharactersCollectionViewDelegate {
    
    func didPullRefresh() {
        fetchData()
    }
    
    func didReachTheEnd() {
        fetchMoreData()
    }
    
    func didFavorite(character: Character) {
        viewModel?.favorite(character: character)
    }
    
    func needsImageFetchRequest(character: Character) {
        viewModel?.fetchImage(forCharacter: character)
    }
}

// Progress extension
extension BaseCharactersViewController {
    
    func showProgress() {
        if let loadingView = loadingView {
            loadingView.layer.opacity = 0
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.addSubview(loadingView)
                loadingView.layer.opacity = 1
            }
        }
    }
    
    func hideProgress() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.loadingView?.layer.opacity = 0
            self?.loadingView?.removeFromSuperview()
        }
    }
}
