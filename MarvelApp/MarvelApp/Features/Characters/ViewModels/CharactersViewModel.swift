//
//  CharactersViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation

class CharactersViewModel {
    
    func fetchCharacters() {
        CharactersService.fetchCharacters(offset: 30) { (response, error) in
        }
    }
}
