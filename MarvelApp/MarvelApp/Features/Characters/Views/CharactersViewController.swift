//
//  CharactersViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class CharactersViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var collectionView: CharactersCollectionView!
    @IBOutlet weak var emptyListLabel: UILabel!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var loadingView: LoadingView?
    var viewModel: CharactersViewModel?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationItem()
        configureSearchBar()
        
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
        let _ = viewModel?.filterDatasourceObservable.subscribe(onNext: { [unowned self] (datasource) in
            if self.isSearching() {
                self.collectionView.isFiltering = true
                self.update(datasource: datasource)
            }
        })
        
        let _ = viewModel?.datasourceObservable.subscribe(onNext: { [weak self] (datasource) in
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
    
    fileprivate func fetchData() {
        viewModel?.fetchCharacters()
    }
    
    fileprivate func fetchMoreData() {
        viewModel?.fetchPaginatedCharacters()
    }
}

// Empty list extension
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
        collectionView.charactersCollectionViewDelegate = self
    }
    
    fileprivate func update(datasource: [Character]) {
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
    
    func didFavorite(character: Character) {
        viewModel?.favorite(character: character)
    }
    
    func needsImageFetchRequest(character: Character) {
        viewModel?.fetchImage(forCharacter: character)
    }
}

// Progress extension
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

// SearchBar extension
extension CharactersViewController: UISearchBarDelegate {
    
    private func configureSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Character"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            viewModel?.fetchFilteredCharacters(byName: text)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.cancelFiltering()
    }
    
    private func isSearching() -> Bool {
        return searchController.isActive &&
            (searchController.searchBar.text != nil &&
            !searchController.searchBar.text!.isEmpty)
    }
}
