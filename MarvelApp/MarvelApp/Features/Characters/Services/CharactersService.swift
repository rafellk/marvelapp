//
//  CharactersService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Alamofire
import Foundation

class CharactersService: BaseService {
    
    static func fetchCharacters(offset: Int) {
        Alamofire.request(url(forEndpoint: "/v1/public/characters")).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let castedValue = value as? [String : Any],
                    let data = castedValue["data"] as? [String : Any], let results = data["results"] {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: results,
                                                                  options: .prettyPrinted) {
                        let characters = try! JSONDecoder().decode([Character].self, from: jsonData)
                        print(characters)
                    }
                }
                break
            case .failure(let error):
                // todo: handle error
                print(error)
            }
        }
    }
}
