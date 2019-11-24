//
//  CharactersViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class CharactersViewController: BaseCharactersViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem(withTitle: "Characters")
        configureSearchBar()
    }
}

// View Model configuration
extension CharactersViewController {
    
    override func configureViewModel() {
        super.configureViewModel()
        
        let _ = viewModel?.filterDatasourceObservable.subscribe(onNext: { [unowned self] (datasource) in
            if self.isSearching() {
                self.collectionView.isFiltering = true
                self.update(datasource: datasource)
            }
        })
    }
}

// Data handler extension
extension CharactersViewController {
    
    override func fetchData() {
        viewModel?.subscribeToChangesInDatabase()
        viewModel?.fetchCharacters()
    }
    
    override func fetchMoreData() {
        viewModel?.fetchPaginatedCharacters()
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
