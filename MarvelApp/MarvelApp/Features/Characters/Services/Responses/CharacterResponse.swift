//
//  CharacterModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/14/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation

struct CharacterResponse: Codable {
    var id: Int
    var name: String
    var description: String
    var thumbnail: Thumbnail
    var comics: ComicList
}

struct Thumbnail: Codable {
    var path: String
    var extensionString: String
    
    private enum CodingKeys : String, CodingKey {
       case path, extensionString = "extension"
    }
}

struct ComicList: Codable {
    var items: [ComicSummary]
}

struct ComicSummary: Codable {
    var resourceURI: String
    var name: String
}
