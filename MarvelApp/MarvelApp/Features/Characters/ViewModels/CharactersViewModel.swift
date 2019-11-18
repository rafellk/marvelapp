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
        CharactersService.fetchCharacters(offset: 30) { [weak self] (response, error) in
            // todo: handle error here
            guard let characters = response?.results else { return }
            self?.resetDatasource(withValues: characters)
        }
    }
}

extension CharactersViewModel {
    
    fileprivate func resetDatasource(withValues values: [Character]) {
        datasource.onNext(parse(values))
    }
    
    private func parse(_ values: [Character]) -> [CharactersCollectionViewModel] {
        return values.map { (character) -> CharactersCollectionViewModel in
            CharactersCollectionViewModel(characterImageURL: "\(character.thumbnail.path).\(character.thumbnail.extensionString)", characterName: character.name, isFavorite: false)
        }
    }
}
