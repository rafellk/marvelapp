//
//  CharactersService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Alamofire
import Foundation

// todo: remove this from here
enum MarvelError: Error {
    case noInternetConnection
    case invalidRequestOrResponse
    case internalServerError
    
    static func toError(fromCode code: Int) -> MarvelError {
        switch code {
        case 409:
            return invalidRequestOrResponse
        default:
            return internalServerError
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your connection before proceeding."
        case .invalidRequestOrResponse, .internalServerError:
            return "An unexpected error occurred. Please try again later."
        }
    }
}

class CharactersService: BaseService {
    
    typealias CharactersResponseCallback = (CharactersResultsResponse?, MarvelError?) -> Void
    
    static func fetchCharacters(offset: Int = 0, callback: (CharactersResponseCallback)? = nil) {
        Alamofire.request(url(forEndpoint: "/v1/public/characters", withQuery: "orderBy=name&offset=\(offset)&limit=20")).responseJSON { response in
            handle(response: response, callback: callback)
        }
    }

    static func fetchCharacters(byName name: String, callback: (CharactersResponseCallback)? = nil) {
        let filteredName = name.replacingOccurrences(of: " ", with: "-").lowercased()
        Alamofire.request(url(forEndpoint: "/v1/public/characters", withQuery: "orderBy=name&name=\(filteredName)")).responseJSON { response in
            handle(response: response, callback: callback)
        }
    }
}
