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

    private var isLoading = BehaviorSubject(value: false)
    var isLoadingObservable: Observable<Bool> {
        return isLoading.asObserver()
    }
    
    init(withPresenter presenter: UIViewController) {
        super.init()
        viewController = presenter
    }

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
}

extension CharactersViewModel {
    
    fileprivate func resetDatasource(withValues values: [Character]) {
        datasource.onNext(parse(values))
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
