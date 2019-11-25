//
//  CharactersViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class CharactersViewModel: BaseViewModel {
    
    // Observable variables
    private var datasource = BehaviorSubject(value: [Character]())
    var datasourceObservable: Observable<[Character]> {
        return datasource.asObserver()
    }

    private var filterDatasource = BehaviorSubject(value: [Character]())
    var filterDatasourceObservable: Observable<[Character]> {
        return filterDatasource.asObserver()
    }

    private var isLoading = BehaviorSubject(value: false)
    var isLoadingObservable: Observable<Bool> {
        return isLoading.asObserver()
    }
    
    private var modelsToUpdate = BehaviorSubject(value: [Int]())
    var modelsToUpdateObservable: Observable<[Int]> {
        return modelsToUpdate.asObserver()
    }
    
    private var didFetchFavorites = false    
}

// User actions
extension CharactersViewModel {
    
    func cancelFiltering() {
        // todo: handle error
        guard let oldValue = try? datasource.value() else { return }
        filterDatasource.onNext([])
        datasource.onNext([])
        datasource.onNext(oldValue)
    }
    
    func favorite(character: Character) {
        isLoading.onNext(true)
        CharactersDatabaseService.shared.addFavorite(character: character, callback: { [weak self] error in
            guard error == nil else { return }
            self?.isLoading.onNext(false)
            
        })
    }
    
    func select(item: Character) {
        if let navigationController = viewController?.navigationController {
            Router.toCharacterViewController(fromNavigationController: navigationController, withModel: item)
        }
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
    
    func fetchImage(forCharacter character: Character) {
        modelsToUpdate.onNext([])
        
        if let thumbnail = character.thumbnail {
            ImageDownloaderService.shared.requestImage(withURL: thumbnail) { [weak self] (error) in
                guard error == nil else {
                    return
                }
                
                if let index = self?.index(forCharacter: character) {
                    self?.modelsToUpdate.onNext([index])
                }
            }
        }
    }
    
    func fetchFavorites() {
        if !didFetchFavorites {
            didFetchFavorites = true
            datasource.onNext(CharactersDatabaseService.shared.listFavorites())
            
            CharactersDatabaseService.shared.subscribeToChanges { [weak self] (changes) in
                self?.datasource.onNext(changes)
            }
            
            isLoading.onNext(false)
        }
    }
    
    func subscribeToChangesInDatabase() {
        CharactersDatabaseService.shared.subscribeToChanges { [weak self] (changes) in
            guard let filterDatasource = try? self?.filterDatasource.value() else { return }
            
            if !filterDatasource.isEmpty {
                filterDatasource.forEach { (character) in
                    let index = changes.firstIndex(where: { $0.id.intValue == character.id.intValue })
                    character.isFavorite = NSNumber(booleanLiteral: index != nil)
                }
                
                self?.filterDatasource.onNext(filterDatasource)
            }
            
            guard let datasource = try? self?.datasource.value() else { return }
            
            if !datasource.isEmpty {
                datasource.forEach { (character) in
                    let index = changes.firstIndex(where: { $0.id.intValue == character.id.intValue })
                    character.isFavorite = NSNumber(booleanLiteral: index != nil)
                }
                
                self?.datasource.onNext(datasource)
            }
        }
    }
}

// Datasource manipulation extension
extension CharactersViewModel {
    
    fileprivate func resetDatasource(withValues values: [CharacterResponse]) {
        datasource.onNext(parse(values))
    }

    fileprivate func resetFilterDatasource(withValues values: [CharacterResponse]) {
        filterDatasource.onNext(parse(values))
    }

    fileprivate func appendToDatasource(withValue values: [CharacterResponse]) {
        guard let oldValues = try? datasource.value() else { return }
        var newValues = oldValues
        
        newValues.append(contentsOf: parse(values))
        datasource.onNext(newValues)
    }
    
    private func parse(_ values: [CharacterResponse]) -> [Character] {
        let favorites = CharactersDatabaseService.shared.listFavorites()
        
        return values.map { (response) -> Character in
            let character = Character()
            
            character.id = NSNumber(integerLiteral: response.id)
            character.name = response.name
            
            character.thumbnail = "\(response.thumbnail.path).\(response.thumbnail.extensionString)"
            character.characterDescription = response.description
            
            character.isFavorite = NSNumber(booleanLiteral: checkFavorite(forValue: response, inFavorites: favorites))
            return character
        }
    }
    
    private func checkFavorite(forValue value: CharacterResponse, inFavorites favorites: [Character]) -> Bool {
        return favorites.filter { $0.id.intValue == value.id }.count > 0
    }
    
    private func index(forCharacter character: Character) -> Int? {
        if let filter = try? filterDatasource.value(),
            !filter.isEmpty {
            return filter.firstIndex(of: character)
        }
        
        if let datasource = try? datasource.value(),
            !datasource.isEmpty,
            let index: Int = datasource.firstIndex(of: character) {
            return index
        }
        
        return nil
    }
}
