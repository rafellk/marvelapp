//
//  CharactersViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import RxSwift

class CharactersViewModel: BaseViewModel {
    
    // Observable variables
    private var datasource = BehaviorSubject(value: [CharactersCollectionViewModel]())
    var datasourceObservable: Observable<[CharactersCollectionViewModel]> {
        return datasource.asObserver()
    }

    private var filterDatasource = BehaviorSubject(value: [CharactersCollectionViewModel]())
    var filterDatasourceObservable: Observable<[CharactersCollectionViewModel]> {
        return filterDatasource.asObserver()
    }

    private var isLoading = BehaviorSubject(value: false)
    var isLoadingObservable: Observable<Bool> {
        return isLoading.asObserver()
    }
    
    init(withPresenter presenter: UIViewController) {
        super.init()
        viewController = presenter
    }
}

// User actions
extension CharactersViewModel {
    
    func cancelFiltering() {
        // todo: handle error
        guard let oldValue = try? datasource.value() else { return }
        datasource.onNext([])
        datasource.onNext(oldValue)
    }
}

// Server requests extension
extension CharactersViewModel {
    
    @objc
    func fetchCharacters() {
        isLoading.onNext(true)
        
        CharactersService.fetchCharacters() { [unowned self] (response, error) in
            self.isLoading.onNext(false)
            
            if let caughtError = error {
                self.defaultErrorHandler(withError: caughtError, andRetrySelector: #selector(self.fetchCharacters))
                return
            }
            
            guard let characters = response?.results else { return }
            self.resetDatasource(withValues: characters)
        }
    }
    
    @objc
    func fetchPaginatedCharacters() {
        isLoading.onNext(true)
        
        guard let count = try? datasource.value().count else {
            isLoading.onNext(false)
            return
        }
        
        CharactersService.fetchCharacters(offset: count) { [unowned self] (response, error) in
            self.isLoading.onNext(false)
            
            if let caughtError = error {
                self.defaultErrorHandler(withError: caughtError, andRetrySelector: #selector(self.fetchPaginatedCharacters))
                return
            }
            
            guard let characters = response?.results else { return }
            self.appendToDatasource(withValue: characters)
        }
    }

    @objc
    func fetchFilteredCharacters(byName name: String) {
        isLoading.onNext(true)
        
        CharactersService.fetchCharacters(byName: name) { [unowned self] (response, error) in
            self.isLoading.onNext(false)
            
            if let caughtError = error {
                self.defaultErrorHandler(withError: caughtError)
                return
            }
            
            guard let characters = response?.results else { return }
            self.resetFilterDatasource(withValues: characters)
        }
    }
}

extension CharactersViewModel {
    
    fileprivate func resetDatasource(withValues values: [Character]) {
        datasource.onNext(parse(values))
    }

    fileprivate func resetFilterDatasource(withValues values: [Character]) {
        filterDatasource.onNext(parse(values))
    }

    fileprivate func appendToDatasource(withValue values: [Character]) {
        guard let oldValues = try? datasource.value() else { return }
        var newValues = oldValues
        
        newValues.append(contentsOf: parse(values))
        datasource.onNext(newValues)
    }
    
    private func parse(_ values: [Character]) -> [CharactersCollectionViewModel] {
        return values.map { (character) -> CharactersCollectionViewModel in
            CharactersCollectionViewModel(characterImageURL: "\(character.thumbnail.path).\(character.thumbnail.extensionString)", characterName: character.name, isFavorite: false)
        }
    }
}
