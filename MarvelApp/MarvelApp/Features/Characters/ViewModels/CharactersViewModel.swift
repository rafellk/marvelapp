//
//  CharactersViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import RxSwift

class CharactersViewModel {
    
    // Datasource variable
    private var datasource = BehaviorSubject(value: [CharactersCollectionViewModel]())
    var datasourceObservable: Observable<[CharactersCollectionViewModel]> {
        return datasource.asObserver()
    }
    
    func fetchCharacters() {
        CharactersService.fetchCharacters() { [weak self] (response, error) in
            // todo: handle error here
            guard let characters = response?.results else { return }
            self?.resetDatasource(withValues: characters)
        }
    }
    
    func fetchPaginatedCharacters() {
        // todo: handle error here
        guard let count = try? datasource.value().count else { return }
        CharactersService.fetchCharacters(offset: count) { [weak self] (response, error) in
            // todo: handle error here
            guard let characters = response?.results else { return }
            print("rlmg count: \(characters.count)")
            self?.appendToDatasource(withValue: characters)
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
