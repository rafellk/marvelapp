//
//  CharactersService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Alamofire
import Foundation

enum MarvelError: Error {
    case invalidResponse
}

class CharactersService: BaseService {
    
    typealias CharactersResponseCallback = (CharactersResponse?, Error?) -> Void
    
    static func fetchCharacters(offset: Int = 20, callback: (CharactersResponseCallback)? = nil) {
        Alamofire.request(url(forEndpoint: "/v1/public/characters")).responseJSON { response in
            handle(response: response, callback: callback)
        }
    }
}
